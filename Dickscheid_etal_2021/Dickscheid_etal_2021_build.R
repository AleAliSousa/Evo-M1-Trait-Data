## Dickscheid T, Bludau S, Paquola C, Schiffer C, Upschulte E, Amunts K (2021). Layer-specific distributions of
## segmented cells in different cytoarchitectonic regions of BigBrain iso cortex. EBRAINS dataset series (KG project
## f06a2fd1-a9ca-42a3-b754-adaa025adb10); one dataset version + DOI 10.25493/... per Julich-Brain area; 12 items
## Dickscheid_etal_2021_Area44 ... Dickscheid_etal_2021_AreahOc5 (registry rows with the series citation in col A).
##
## PARAMETERISED build: frozen publisher per-patch text grids -> <Item name>.csv (long, one row per layer) and the
## public TSV __Public/comparative-data/<Item encoded>.tsv, for one item or (default) every item of the series.
## This script reads the untouched downloaded grids. One parameterised script
## serves the 12 items because they are 12 identical tables; items are validated one by one with
## validate_dataset_item() (build_dataset_item() runs only the first .R of a folder, so it is not used here).
##   Rscript Dickscheid_etal_2021_build.R                               # all items
##   Rscript Dickscheid_etal_2021_build.R Dickscheid_etal_2021_Area44   # one item
##
## SINGLE-SPECIES, SINGLE-SPECIMEN: Homo sapiens, the BigBrain (Amunts et al. 2013, Science 340:1472), one 65-year-old
## male donor (KG subject sub-20, tissue sample B20).  Values are ALL SEGMENTED CELL BODIES (neurons + glia; silver
## stain, Merker 1983; automatic Contour Proposal Network segmentation), not neurons.  Data role = primary.
##
## Reformat (same formula as siibra's LayerwiseCellDensity feature and, by the
## table checks below, as the dataset's own averaged report stats.pdf):
##   per patch x layer:  volume_0.1mm3 = Area_micron2 * 20 (section thickness, micron) * 1.931^(1/3) / 1e6
##                       density       = n_cells_in_layer / volume_0.1mm3        [# detected cells / 0.1 mm^3]
##     - 1.931 is the volumetric shrinkage factor stated in the dataset README; the cube root compensates linear
##       shrinkage in the third (sectioning) dimension only, the in-plane area being used as measured.
##     - layer thickness = AvgThickness_micron as measured in the section image (shrunken tissue; the averaged report
##       plots exactly these uncorrected values although its README says the factor is applied).
##   per layer (I..VI):  mean and sd over the patches of the area; n_patches, n_sections, n_cells (sum).
##   'I-VI' row:         per patch, all cells of layers I-VI / summed volume of layers I-VI; thickness = summed layer
##                       thicknesses (cortical thickness); then mean/sd over patches as above.
##   Cells with layer index 0 or 7 in segments.txt (outside layers I-VI) are not used.  A layer with 0 segmented cells
##   in a patch enters the mean as density 0 (as in stats.pdf; siibra drops such patch-layers instead).
## Units: density kept as published (# detected cells per 0.1 mm^3); thickness micron.  No project-unit conversion
## applies to this measure class.

## 0. PATHS -- self-contained ------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  for (i in rev(seq_len(sys.nframe()))) {            # source() / sys.source()
    fn <- as.character(sys.call(i)[[1]])[1]
    if (fn %in% c("source", "sys.source")) {
      f <- get0(if (fn == "source") "ofile" else "file", envir = sys.frame(i), inherits = FALSE)
      if (is.character(f) && length(f) == 1 && file.exists(f)) return(normalizePath(f))
    }
  }
  stop("Run with Rscript file.R, source(file.R), or open in RStudio and click Source (save first).", call. = FALSE)
})
folder        <- dirname(.sp)
series        <- sub("_build$", "", tools::file_path_sans_ext(basename(.sp)))   # Dickscheid_etal_2021
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
datasets_csv   <- file.path(folder, "reference_tables", paste0(series, "_datasets.csv"))
pdf_bars_csv   <- file.path(folder, "reference_tables", paste0(series, "_stats_pdf_bars.csv"))
manifest_csv   <- file.path(folder, "ebrains_downloads", "download_manifest.csv")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. SERIES TABLES ----------------------------------------------------------
datasets  <- utils::read.csv(datasets_csv, colClasses = "character", check.names = FALSE)   # Item name <-> dataset
pdf_bars  <- utils::read.csv(pdf_bars_csv, check.names = FALSE)                             # averaged-report figures
manifest  <- utils::read.csv(manifest_csv, colClasses="character", check.names=FALSE)
filecodes <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
items <- commandArgs(TRUE)
if (!length(items)) items <- datasets$item_name
if (!all(items %in% datasets$item_name)) stop("not in ", basename(datasets_csv), ": ", paste(setdiff(items, datasets$item_name), collapse = ", "))

SHRINKAGE_VOLUMETRIC <- 1.931          # dataset README / DataDescriptor; siibra BIGBRAIN_VOLUMETRIC_SHRINKAGE_FACTOR
DENSITY_UNIT   <- "# detected cells / 0.1 mm^3 (cell bodies of all types; 20-micron section, shrinkage 1.931^(1/3) applied to section thickness)"
THICKNESS_UNIT <- "micron, as measured in the section image (shrunken tissue, no shrinkage correction)"
LAYERS <- c("I", "II", "III", "IV", "V", "VI")

table_checks <- data.frame()
for (item_name in items) {
  ds <- datasets[datasets$item_name == item_name, ]
  final_csv    <- file.path(folder, paste0(item_name, ".csv"))

  ## 3. READ FROZEN SOURCE GRIDS. The patch/layer join and cell counts happen here. ------------------------------
  area_root <- file.path(folder, "ebrains_downloads", ds$area_dir, "v1.0")
  source_manifest <- manifest[manifest$area_dir==ds$area_dir &
                              manifest$file %in% c("info.txt","layerinfo.txt","segments.txt"),]
  stopifnot(nrow(source_manifest)==3L*as.integer(ds$n_patches))
  source_paths <- file.path(folder,source_manifest$local_path)
  stopifnot(all(file.exists(source_paths)),
            all(unname(tools::md5sum(source_paths))==source_manifest$bucket_md5))
  layer_files <- sort(list.files(area_root, pattern="^layerinfo[.]txt$",
                                 recursive=TRUE, full.names=TRUE))
  stopifnot(length(layer_files)==as.integer(ds$n_patches))
  patch_rows <- lapply(layer_files, function(li_file) {
    patch_folder <- dirname(li_file)
    info <- readLines(file.path(patch_folder,"info.txt"), warn=FALSE)
    info <- strsplit(info," ",fixed=TRUE)
    info <- setNames(vapply(info,function(x) paste(x[-1],collapse=" "),character(1)),
                     vapply(info,`[`,character(1),1))
    li <- utils::read.table(li_file,skip=1,colClasses="character",
                            col.names=c("layer_number","layer_name","Area_micron2","AvgThickness_micron"),
                            comment.char="",stringsAsFactors=FALSE)
    seg <- utils::read.table(file.path(patch_folder,"segments.txt"),skip=1,
                             colClasses=c("NULL","NULL","NULL","numeric","NULL"),
                             comment.char="",stringsAsFactors=FALSE)[[1]]
    counts <- tabulate(as.integer(seg)+1L,nbins=8L)
    data.frame(area_dir=ds$area_dir,brain_id=info[["brain_id"]],
               section_id=basename(dirname(patch_folder)),patch_dir=basename(patch_folder),
               section_thickness_micron=info[["section_thickness_micron"]],
               layer_number=li$layer_number,layer_name=li$layer_name,
               Area_micron2=li$Area_micron2,AvgThickness_micron=li$AvgThickness_micron,
               n_cells_in_layer=as.character(counts[as.integer(li$layer_number)+1L]),
               stringsAsFactors=FALSE)
  })
  snap <- do.call(rbind,patch_rows)
  stopifnot(all(c("area_dir", "brain_id", "section_id", "patch_dir", "section_thickness_micron", "layer_number",
                  "layer_name", "Area_micron2", "AvgThickness_micron", "n_cells_in_layer") %in% names(snap)),
            all(snap$area_dir == ds$area_dir), all(snap$brain_id == "B20"), all(snap$section_thickness_micron == "20"),
            all(snap$layer_name == LAYERS[as.integer(snap$layer_number)]))
  snap$patch <- paste(snap$section_id, snap$patch_dir, sep = "/")
  stopifnot(all(table(snap$patch) == 6L))
  area_um2 <- as.numeric(snap$Area_micron2)
  thick_um <- as.numeric(snap$AvgThickness_micron)
  n_cells  <- as.integer(snap$n_cells_in_layer)
  stopifnot(!anyNA(area_um2), !anyNA(thick_um), !anyNA(n_cells), all(area_um2 > 0))

  ## 4. REFORMAT: per-patch density, then layer means over patches -----------------------------------------------
  vol_01mm3 <- area_um2 * as.numeric(snap$section_thickness_micron) * SHRINKAGE_VOLUMETRIC^(1/3) / 1e6
  density   <- n_cells / vol_01mm3
  per_patch <- data.frame(patch = snap$patch, section = snap$section_id, layer = snap$layer_name,
                          density = density, thick = thick_um, n_cells = n_cells, vol = vol_01mm3)
  tot <- do.call(rbind, lapply(split(per_patch, per_patch$patch), function(p) data.frame(
    patch = p$patch[1], section = p$section[1], layer = "I-VI",
    density = sum(p$n_cells) / sum(p$vol), thick = sum(p$thick), n_cells = sum(p$n_cells), vol = sum(p$vol))))
  pp <- rbind(per_patch, tot)
  pp$layer <- factor(pp$layer, levels = c(LAYERS, "I-VI"))
  agg <- do.call(rbind, lapply(split(pp, pp$layer), function(g) data.frame(
    layer              = as.character(g$layer[1]),
    cell_density       = mean(g$density),
    cell_density_sd    = stats::sd(g$density),
    layer_thickness    = mean(g$thick),
    layer_thickness_sd = stats::sd(g$thick),
    n_patches          = nrow(g),
    n_sections         = length(unique(g$section)),
    n_cells            = sum(g$n_cells),
    stringsAsFactors = FALSE)))
  final.dataframe <- data.frame(
    Species                   = "Homo sapiens",
    Species_Dickscheid2021    = "Homo sapiens",           # species label of the KG record (specimen tree); not printed in the files
    specimen                  = "BigBrain (Amunts et al. 2013; one donor, 65-y male; KG subject sub-20, brain B20)",
    structure                 = ds$julich_area,           # Julich-Brain area as named in the KG record, e.g. "Area 44 (IFG)"
    structure_bucket          = ds$area_dir,              # folder name in the data-proxy bucket, e.g. "Broca_44"
    layer                     = agg$layer,
    cell_density              = agg$cell_density,
    cell_density_sd           = agg$cell_density_sd,
    density_unit_as_published = DENSITY_UNIT,
    layer_thickness           = agg$layer_thickness,
    layer_thickness_sd        = agg$layer_thickness_sd,
    thickness_unit            = THICKNESS_UNIT,
    n_patches                 = agg$n_patches,
    n_sections                = agg$n_sections,
    n_cells                   = agg$n_cells,
    dataset_doi               = ds$dataset_doi,
    kg_dataset_version        = ds$kg_dataset_version,
    stringsAsFactors = FALSE, check.names = FALSE)
  stopifnot(nrow(final.dataframe) == 7L, !anyNA(final.dataframe$cell_density),
            all(final.dataframe$n_patches == as.integer(ds$n_patches)))

  ## 5. TABLE CHECKS: layer means vs the dataset's own averaged report (stats.pdf bar heights) --------------------
  ## tolerance = reading precision of the vector pdf (0.01 cells / 0.1 mm^3; 0.1 micron); never changes a value
  pb <- pdf_bars[pdf_bars$item_name == item_name, ]
  for (k in LAYERS) {
    for (what in c("cells_per_0.1mm3", "layer_thickness_micron")) {
      printed  <- pb$value_from_pdf[pb$panel == what & pb$layer == k]
      observed <- if (what == "cells_per_0.1mm3") agg$cell_density[agg$layer == k] else agg$layer_thickness[agg$layer == k]
      tol      <- if (what == "cells_per_0.1mm3") 0.01 else 0.1
      table_checks <- rbind(table_checks, data.frame(
        item_name = item_name,
        check_id  = paste0(what, "_", k),
        basis     = paste0("mean over patches of layer ", k, " vs the bar of stats.pdf panel '", what, "'"),
        observed = observed, printed = printed, difference = observed - printed, tolerance = tol,
        status   = ifelse(abs(observed - printed) <= tol, "pass", "mismatch"),
        note     = "bar height read from the vector pdf (reference_tables/*_stats_pdf_bars.csv); value kept as computed from segments.txt",
        stringsAsFactors = FALSE))
    }
  }
  bad <- table_checks[table_checks$item_name == item_name & table_checks$status != "pass", ]
  if (nrow(bad)) warning(item_name, ": ", nrow(bad), " table check(s) did not pass: ",
                         paste(bad$check_id, round(bad$difference, 3), collapse = "; "), call. = FALSE, immediate. = TRUE)

  ## 6. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
  options(scipen = 999)
  utils::write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name)
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                     sep = "\t", row.names = FALSE, na = "", quote = TRUE)
  message("Wrote ", nrow(final.dataframe), " rows -> ", basename(final_csv), " and ", item_encoded, ".tsv  (",
          ds$n_patches, " patches, ", sum(table_checks$item_name == item_name & table_checks$status == "pass"), "/12 table checks pass)")
}

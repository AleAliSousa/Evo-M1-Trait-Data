## Palomero-Gallagher N & Zilles K (2018-2022) -- EBRAINS receptor-density fingerprint SERIES
## (Knowledge Graph project 77aeb65e-9ff1-46b2-9f58-e11b2a0687d2; one dataset = one DOI 10.25493/... = one
## registered item; Data series = EBRAINS_receptor_densities_Juelich).
## ONE parameterised build script for the whole series: it loops over the series' registry rows and, for each
## item, READS the frozen snapshot <Item name>_snapshot.tsv (the untouched fingerprint TSV downloaded by
## <series>_snapshot.py) and WRITES the long analysis CSV <Item name>.csv plus the public TSV
## __Public/comparative-data/<Item encoded>.tsv.  Dataset-level context that is not printed in the TSV (species,
## strain, n brains, KG title / version / studied region) comes from reference_tables/<series>_dataset_metadata.csv,
## written by the snapshot script from the KG records.  Species are harmonised through
## _keys/General/species_key.csv (rows with source_publication == this folder's name); the dataset's own wording is
## kept in Species_as_published / species_label_dataset_title / strain_as_published.
## MULTI-SPECIES: Homo sapiens (41 datasets), Macaca fascicularis (5), Rattus norvegicus (10) -- species per
## dataset as stated in the KG specimen metadata, never assumed.
## Receptor names are harmonised to the Zilles_PalomeroGallagher_2017_SupplementaryTable2 vocabulary
## (BZ -> GABAA/BZ; mGluR2_3 / mGlu2/3 -> mGluR2/3, kept as an extra receptor; A1 kept as printed); the EBRAINS
## label is kept in receptor_as_published.
## Run:  Rscript PalomeroGallagher_etal_2018_build.R [ITEM_NAME ...]     (default: every item of the series)
##       or source() it.  build_dataset_item() runs only the first .R of a folder, so for this multi-item folder
##       run this script directly and call validate_dataset_item() per item (see README).

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
series_name   <- sub("_build$", "", tools::file_path_sans_ext(basename(.sp)))   # PalomeroGallagher_etal_2018
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(dataset_root)) stop("__ReadMe.xlsx not found walking up from ", folder)
setwd(folder)
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
metadata_csv   <- file.path(folder, "reference_tables", paste0(series_name, "_dataset_metadata.csv"))
species_key    <- file.path(dataset_root, "_keys", "General", "species_key.csv")

SERIES_CITATION_PREFIX <- paste0("Palomero-Gallagher, N., Zilles, K., & Amunts, K. (2018). Quantitative receptor data for human, ",
                                 "non-human primate, and rodent brains")
SERIES_ID <- "EBRAINS_receptor_densities_Juelich"

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. REGISTRY ROWS OF THE SERIES (by header, by Item name) -----------------
filecodes <- readxl::read_excel(readme_xlsx, sheet = "Sheet1", guess_max = 100000)   # sparse columns ("Data series") are typed from all rows, not the first 1000
citation  <- as.character(filecodes[[1]])
series    <- filecodes[!is.na(citation) & startsWith(citation, SERIES_CITATION_PREFIX) &
                       !is.na(filecodes$`Data series`) & filecodes$`Data series` == SERIES_ID, ]
if (nrow(series) == 0) stop("No registry rows for series ", SERIES_ID)
args <- commandArgs(TRUE)
if (length(args)) {
  miss <- setdiff(args, series$`Item name`)
  if (length(miss)) stop("Not in the series registry rows: ", paste(miss, collapse = ", "))
  series <- series[series$`Item name` %in% args, ]
}

## 3. DATASET METADATA (from the KG records) + SPECIES KEY -------------------
meta <- utils::read.csv(metadata_csv, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
stopifnot(all(c("item_name", "title_kg", "species_kg", "strain_kg", "n_subjects_kg", "version_label",
                "kg_version_uuid", "kg_record_type", "version_doi_kg", "studied_brain_region_kg") %in% names(meta)))
key <- utils::read.csv(species_key, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0) stop("species_key.csv has no rows for source_publication == ", basename(folder))
lk  <- setNames(key$accepted_name, key$variant_name)

harmonise <- c("BZ" = "GABAA/BZ", "mGluR2_3" = "mGluR2/3", "mGlu2/3" = "mGluR2/3", "mGluR2/3" = "mGluR2/3")
known <- c("AMPA", "NMDA", "kainate", "GABAA", "GABAA/BZ", "GABAB", "M1", "M2", "M3",
           "alpha4beta2", "alpha1", "alpha2", "5-HT1A", "5-HT2", "D1", "mGluR2/3", "A1")

## 4. LOOP OVER ITEMS: snapshot -> analysis CSV + public TSV ------------------
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
options(scipen = 999)
built <- character(0)
for (i in seq_len(nrow(series))) {
  item_name    <- series$`Item name`[i]
  item_encoded <- series$`Item encoded`[i]
  if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
    stop("Bad 'Item encoded' in __ReadMe.xlsx for: ", item_name)
  snapshot_tsv <- file.path(folder, paste0(item_name, "_snapshot.tsv"))
  final_csv    <- file.path(folder, paste0(item_name, ".csv"))
  if (!file.exists(snapshot_tsv)) stop("Snapshot missing (run the snapshot script first): ", basename(snapshot_tsv))
  m <- meta[meta$item_name == item_name, ]
  if (nrow(m) != 1) stop("dataset_metadata.csv must have exactly one row for ", item_name)

  ## 4a. read the frozen snapshot (4 columns: receptor label (<abbr>), density (mean), density (sd), density (unit))
  snap <- utils::read.delim(snapshot_tsv, colClasses = "character", check.names = FALSE, quote = "\"",
                            encoding = "UTF-8", na.strings = character(0), strip.white = TRUE)
  if (ncol(snap) != 4 || !grepl("^receptor label", names(snap)[1]) ||
      !identical(names(snap)[2:4], c("density (mean)", "density (sd)", "density (unit)")))
    stop(item_name, ": unexpected TSV layout: ", paste(names(snap), collapse = " | "))
  if (!all(snap$`density (unit)` == "fmol/mg")) stop(item_name, ": unexpected unit ", unique(snap$`density (unit)`))

  ## 4b. receptors
  receptor_as_published <- snap[[1]]
  receptor <- ifelse(receptor_as_published %in% names(harmonise), harmonise[receptor_as_published], receptor_as_published)
  if (!all(receptor %in% known)) stop(item_name, ": unexpected receptor label(s): ",
                                      paste(unique(setdiff(receptor, known)), collapse = ", "))

  ## 4c. species: KG specimen species (dataset's own statement) -> accepted name via the key; title label kept
  species_label <- sub("^.*\\[([^]]+)\\].*$", "\\1", m$title_kg)                    # human / macaque / rat
  if (!m$species_kg %in% names(lk)) stop(item_name, ": species '", m$species_kg, "' not in species_key.csv for ", basename(folder))
  if (!species_label %in% names(lk)) stop(item_name, ": title label '", species_label, "' not in species_key.csv for ", basename(folder))
  Species <- unname(lk[m$species_kg])
  if (!identical(Species, unname(lk[species_label])))
    stop(item_name, ": key maps species '", m$species_kg, "' and label '", species_label, "' to different accepted names")

  ## 4d. structure, parsed from the KG title "Density measurements of different receptors for <locus> [<species>] (vN)"
  locus <- trimws(sub("^Density measurements of different receptors for (.*?)\\s*\\[.*$", "\\1", m$title_kg))
  locus <- sub("^the ", "", locus)
  structure_abbr <- if (grepl("\\(([^)]*)\\)\\s*$", locus)) sub("^.*\\(([^)]*)\\)\\s*$", "\\1", locus) else ""
  core  <- trimws(sub("\\s*\\([^)]*\\)\\s*$", "", locus))
  structure_part <- ""; structure <- core
  if (grepl("^(dorsal|ventral|mediodorsal|anterior|posterior|medial|lateral) part of (the )?(.+)$", core)) {
    structure_part <- sub("^((dorsal|ventral|mediodorsal|anterior|posterior|medial|lateral) part) of (the )?(.+)$", "\\1", core)
    structure      <- sub("^((dorsal|ventral|mediodorsal|anterior|posterior|medial|lateral) part) of (the )?(.+)$", "\\4", core)
  } else if (grepl("^(stratum [a-z]+) of (.+)$", core)) {
    structure_part <- sub("^(stratum [a-z]+) of (.+)$", "\\1", core)
    structure      <- sub("^(stratum [a-z]+) of (.+)$", "\\2", core)
  } else if (grepl("^(.+), (stratum [a-z]+)$", core)) {
    structure_part <- sub("^(.+), (stratum [a-z]+)$", "\\2", core)
    structure      <- sub("^(.+), (stratum [a-z]+)$", "\\1", core)
  }
  atlas <- if (grepl("\\((Julich-Brain Atlas|MEBRAINS Atlas|Waxholm Space Rat Brain Atlas)\\)", m$studied_brain_region_kg))
             sub("^.*\\((Julich-Brain Atlas|MEBRAINS Atlas|Waxholm Space Rat Brain Atlas)\\).*$", "\\1", m$studied_brain_region_kg) else ""
  dataset_version <- sub("^.*\\((v[0-9.]+)\\)\\s*$", "\\1", m$title_kg)
  if (!grepl("^v[0-9.]+$", dataset_version)) stop(item_name, ": no version in KG title: ", m$title_kg)

  final.dataframe <- data.frame(
    Species                     = Species,                               # accepted binomial via _keys/General/species_key.csv
    Species_as_published        = m$species_kg,                          # species stated in the dataset's KG specimen metadata
    species_label_dataset_title = species_label,                         # "[human]" / "[macaque]" / "[rat]" in the dataset title
    strain_as_published         = m$strain_kg,                           # e.g. Wistar (rat); blank where none stated
    structure                   = structure,                             # e.g. "Area 44", "CA", "Thalamic Nucleus"
    structure_part              = structure_part,                        # e.g. "dorsal part", "stratum cellulare"; blank = whole structure
    structure_as_published      = locus,                                 # locus exactly as in the KG dataset title
    structure_abbreviation      = structure_abbr,                        # parenthetical of the title, e.g. PostCG, IFG, Hippocampus
    parcellation_atlas          = atlas,                                 # atlas named in the KG 'studied brain region'; blank = none stated
    kg_studied_brain_region     = m$studied_brain_region_kg,
    dataset_version             = dataset_version,                       # version of the record the TSV comes from
    receptor                    = receptor,
    receptor_as_published       = receptor_as_published,
    density_fmol_mg_protein     = as.numeric(snap$`density (mean)`),
    sd                          = as.numeric(snap$`density (sd)`),
    unit_as_published           = snap$`density (unit)`,
    n_brains                    = suppressWarnings(as.integer(m$n_subjects_kg)),   # subjects listed on the KG record
    dataset_doi                 = series$`DOI if different from article or doi Alt`[i],   # registry DOI (column C)
    dataset_version_doi         = m$version_doi_kg,                      # DOI of the version record (differs for concept DOIs)
    kg_dataset_version          = m$kg_version_uuid,
    kg_record_registry          = m$kg_registry_uuid,
    dataset_title               = m$title_kg,
    item_name                   = item_name,
    stringsAsFactors = FALSE, check.names = FALSE)
  stopifnot(!anyNA(final.dataframe$density_fmol_mg_protein), nrow(final.dataframe) == nrow(snap), nzchar(Species))
  if (anyNA(final.dataframe$sd))                     # source gap: an empty 'density (sd)' cell (alpha2 in 5 IPL datasets) -> NA, mean kept
    message(item_name, ": blank SD in the source TSV for ", paste(final.dataframe$receptor[is.na(final.dataframe$sd)], collapse = ", "))

  ## 4e. SAVE (local CSV + DOI-coded public TSV)
  utils::write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
  utils::write.table(final.dataframe, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                     sep = "\t", row.names = FALSE, na = "", quote = TRUE)
  message(sprintf("%-70s %2d rows -> %s.csv and %s.tsv", item_name, nrow(final.dataframe), item_name, item_encoded))
  built <- c(built, item_name)
}
message("Built ", length(built), " item(s) of series ", SERIES_ID)

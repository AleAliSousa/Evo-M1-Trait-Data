.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- frozen source: digital-native PLOS supporting file, untouched ----
## Wagstyl_etal_2020_S1Data_snapshot.csv is a byte-identical copy-rename (md5 47b18d88e4b3d01e90921664abe3d27d)
## of 12080526/pbio.3000678.s006.csv = the file PLOS serves as "S1 Data" (https://doi.org/10.1371/journal.pbio.3000678.s006).
## Content: 180 HCP-MMP1.0 parcels x {HCP_left, HCP_right, BB_left, BB_right} regional cortical thickness
## (in vivo MRI, Human Connectome Project vs the BigBrain histological reconstruction). NB the paper's
## Supporting-information caption for "S1 Data" describes the von Economo table instead (see README, Discrepancies).
## Everything is read as character first so the published numerals survive verbatim (value_as_published).
raw <- readr::read_csv(paste0(item_name, "_snapshot.csv"), col_types = readr::cols(.default = readr::col_character()),
                       na = character(), show_col_types = FALSE)
names(raw)[1] <- "source_row_index"           ## unnamed pandas index column in the source
stopifnot(identical(names(raw), c("source_row_index", "ROIs", "HCP_left", "HCP_right", "BB_left", "BB_right")))
stopifnot(nrow(raw) == 180L, !anyDuplicated(raw$ROIs))

## ---- species: the table never prints a species; the paper's text says "human" (Materials and methods) ----
raw$species_as_published <- "human"
key <- readr::read_csv(file.path(base, "_keys", "Stephan", "species_key.csv"), show_col_types = FALSE)
key_wg <- key[key$source_publication == "Wagstyl_etal_2020", ]
if (nrow(key_wg) == 0L)
  stop("No species_key.csv rows for source_publication == \"Wagstyl_etal_2020\" -- key rows are scoped to the paper folder name (_keys/SPECIES_NAMING.md sec 3b)", call. = FALSE)
lk <- setNames(key_wg$accepted_name, tolower(key_wg$variant_name))
raw$Species <- unname(lk[tolower(raw$species_as_published)])
stopifnot(!any(is.na(raw$Species)))

## ---- reshape wide (4 value columns) -> long (one row per parcel x dataset x hemisphere) ----
value_cols <- c("HCP_left", "HCP_right", "BB_left", "BB_right")
long <- do.call(rbind, lapply(value_cols, function(cn) {
  data.frame(
    Species               = raw$Species,
    species_as_published  = raw$species_as_published,
    source_row_index      = as.integer(raw$source_row_index),
    parcel_as_published   = raw$ROIs,
    parcellation          = "HCP-MMP1.0 (Glasser et al. 2016, ref. 33), coregistered to the BigBrain surfaces by multimodal surface matching (Methods, Surface-based parcellations)",
    dataset               = if (startsWith(cn, "HCP")) "HCP_MRI" else "BigBrain",
    specimen_or_cohort    = if (startsWith(cn, "HCP")) "Human Connectome Project in vivo MRI (n not stated in the paper; ref. 33 Glasser et al. 2016)"
                            else "BigBrain: one post-mortem human brain, male, aged 65 (Amunts et al. 2013; 20-micron cell-body-stained reconstruction)",
    hemisphere            = if (endsWith(cn, "left")) "left" else "right",
    measure               = "cortical_thickness",
    thickness_mm          = as.numeric(raw[[cn]]),
    value_as_published    = raw[[cn]],
    source_column         = cn,
    stringsAsFactors = FALSE)
}))
long$source_file   <- "pbio.3000678.s006.csv (PLOS 'S1 Data'; frozen copy Wagstyl_etal_2020_S1Data_snapshot.csv)"
long$source_location <- "Supporting information S1 Data (https://doi.org/10.1371/journal.pbio.3000678.s006); underlying data of Fig 3C"
long$data_role     <- "primary"
stopifnot(nrow(long) == 720L, !any(is.na(long$thickness_mm)))

final.dataframe <- long[, c("Species", "species_as_published", "specimen_or_cohort", "source_row_index",
                            "parcel_as_published", "parcellation", "dataset", "hemisphere", "measure",
                            "thickness_mm", "value_as_published", "source_column", "source_file",
                            "source_location", "data_role")]

## ---- table checks (HOWTO sec 7a): this table prints no totals or other checkable relation -> none ----

## Write the numeric column as the published numeral: readr/write.table shorten the 17-significant-digit
## numerals of this file (e.g. 2.4654903411865234 -> 2.465490341186523, a different double), whereas the
## published text is the exact decimal of the stored value. final.dataframe (in memory) keeps the numeric type.
out_write <- final.dataframe
out_write$thickness_mm <- final.dataframe$value_as_published
stopifnot(identical(as.numeric(out_write$thickness_mm), final.dataframe$thickness_mm))
readr::write_csv(out_write, paste0(item_name, ".csv"), na = "")
message(item_name, ": ", nrow(final.dataframe), " rows written (", length(unique(final.dataframe$parcel_as_published)), " parcels x 4 source columns)")

## ---- public TSV: look up Item encoded from __ReadMe.xlsx ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)]
} else NA_character_

if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  ## Registry row not pasted yet: derive the expected stem (paper DOI, URL-encoded, + Item number without
  ## spaces, = the formula __ReadMe.xlsx uses) so the public TSV exists; the registry remains the authority --
  ## after pasting the row and running _tools/file_list.R, confirm col K equals this stem or rename the TSV.
  doi_encoded  <- "10.1371%2Fjournal.pbio.3000678"
  item_encoded <- paste0(doi_encoded, "_", sub(paste0("^", basename(folder), "_"), "", item_name))
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx yet; using the expected stem '",
          item_encoded, "'. Paste ", item_name, "_registry_row.xlsx, run _tools/file_list.R and verify col K.")
}
if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  readr::write_tsv(out_write, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), na = "")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

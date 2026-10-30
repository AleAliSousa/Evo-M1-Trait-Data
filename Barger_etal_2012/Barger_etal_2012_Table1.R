## Barger et al. (2012) J. Comp. Neurol. 520(13):3035-3054
## Table 1 — specimens in sample
## Frozen snapshot -> individual-level analysis CSV (+ public TSV)

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

folder       <- dirname(.sp)
item_name    <- tools::file_path_sans_ext(basename(.sp))
dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

library(readxl)

## The snapshot is frozen evidence transcribed from the printed PDF table.
## This build script reads it; it does not recreate or overwrite it.
snap <- as.data.frame(
  read_excel(snapshot_xlsx, sheet = "Table1", skip = 1, .name_repair = "minimal"),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

## Keep only real specimen rows. The printed table is followed by a blank
## separator row (Species == NA) and a footnote row (Species holds the
## footnote text, all other columns NA); nzchar(Species) alone does not
## drop them because nzchar(NA) is TRUE in R. Every real specimen row has
## Sex "M" or "F", so filter on that instead.
snap <- snap[!is.na(snap[["Sex"]]) & snap[["Sex"]] %in% c("M", "F"), , drop = FALSE]
species_with_keys <- trimws(as.character(snap[["Species"]]))
collection_key <- ifelse(
  grepl("[[:space:]][a-f](,[a-f])?$", species_with_keys),
  sub("^.*[[:space:]]([a-f](,[a-f])?)$", "\\1", species_with_keys),
  ""
)
species_printed <- trimws(sub("[[:space:]][a-f](,[a-f])?$", "", species_with_keys))

collection_lookup <- c(
  a = "New histological series processed by N.B.",
  b = "Specimen from the C.M.S. collection.",
  c = "Specimen from the K.S. collection.",
  d = "Specimen from the J.M.A. collection.",
  e = "Specimen from the J.A.B. collection.",
  f = "Tissue provided by C.C.S. and P.R.H.; specimen sectioned at 40 microns."
)

expand_note <- function(x) {
  keys <- strsplit(x, ",", fixed = TRUE)[[1]]
  keys <- keys[keys %in% names(collection_lookup)]
  if (!length(keys)) return("")
  paste(unname(collection_lookup[keys]), collapse = " ")
}

age_raw <- trimws(as.character(snap[["Age (yr)"]]))
out <- data.frame(
  specimen_row = seq_len(nrow(snap)),
  Species = species_printed,
  Species_Barger2012 = species_with_keys,
  Common_name_Barger2012 = trimws(as.character(snap[["Common name"]])),
  Sex = trimws(as.character(snap[["Sex"]])),
  Age_yr = suppressWarnings(as.numeric(age_raw)),
  Age_Barger2012 = age_raw,
  Hemisphere = trimws(as.character(snap[["Hemisphere"]])),
  collection_key = collection_key,
  collection_note = vapply(collection_key, expand_note, character(1)),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

stopifnot(nrow(out) == 35L)
write.csv(out, final_csv, row.names = FALSE, na = "")

if (!is.na(dataset_root)) {
  registry <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded))
    stop("No 'Item encoded' for ", item_name, " in __ReadMe.xlsx — fix the registry row first.")
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = FALSE, na = "")
}

message("Wrote: ", final_csv)

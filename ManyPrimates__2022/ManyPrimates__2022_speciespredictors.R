# ManyPrimates__2022_speciespredictors.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of the ManyPrimates (2022)
#   `species_predictors.xlsx` (sheet "Compilation for paper") vocal-repertoire
#   columns into a lean, analysis-ready CSV of primate vocal repertoire size
#   (number of vocalization types), one row per species, with the original
#   per-species primary reference preserved.
#   Column meanings are documented in
#   reference_tables/ManyPrimates__2022_speciespredictors_definitions.csv.
#
#   NOTE: the source file also contains many other ecological/life-history
#   columns (colour vision, group size, home range, diet, body size, ...).
#   Those are sourced independently elsewhere in the repo and are NOT extracted
#   here; only the vocal-repertoire block is snapshotted and built.
#
# Input
#   ManyPrimates__2022_speciespredictors_snapshot.xlsx    sheet: speciespredictors_snap
#
# Outputs
#   ManyPrimates__2022_speciespredictors.csv              one row per species (41 rows)
#   <DOI>_speciespredictors.tsv in __Public/comparative-data/   DOI-named copy

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
})

## ---- paths: self-contained ----
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
item_name <- tools::file_path_sans_ext(basename(.sp))          # = ManyPrimates__2022_speciespredictors
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- "ManyPrimates__2022_speciespredictors_snapshot.xlsx"
snapshot_sheet <- "speciespredictors_snap"

# ---- read snapshot: row 1 = title, row 2 = header ----
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", na = character())
header <- as.character(unlist(raw[2, ], use.names = FALSE))
dat <- raw[-c(1, 2), , drop = FALSE]
names(dat) <- header
dat <- dat[!is.na(dat$species_latin) & nzchar(trimws(dat$species_latin)), , drop = FALSE]

na_txt <- function(x) ifelse(is.na(x) | trimws(x) %in% c("", "NA", "N/A"), NA_character_, trimws(x))

final.dataframe <- dat %>%
  transmute(
    Species                  = trimws(gsub("_", " ", species_latin)),
    common_name              = na_txt(species_english),
    family                   = na_txt(family),
    superordinate_group      = na_txt(superordinate_group),
    vocal_repertoire_types   = na_txt(`vocal_repertoire (# vocalization types)`),
    vocal_repertoire_source  = na_txt(Source),
    vocal_repertoire_comment = na_txt(Comments),
    source                   = "ManyPrimates__2022"
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
# The registry Item encoded for this row contains a path-like label ("data/
# speciespredictors.xlsx"); use a filesystem-safe DOI-coded name instead. The
# Shiny source_manifest resolves the citation from the DOI prefix regardless.
item_encoded <- "10.26451%2Fabc.09.04.06.2022_speciespredictors"

if (!is.na(base) && dir.exists(path.expand(tsv_dir))) {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
} else {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
}
message("Rows: ", nrow(final.dataframe))

## Heffner_etal_1969_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, H. E., Ravizza, R. J., & Masterton, B. (1969). Hearing in
## primitive mammals, III: Tree shrew (Tupaia glis). Journal of Auditory
## Research, 9(1), 12-18.
## No DOI exists for this paper (Journal of Auditory Research is a defunct
## journal never assigned Crossref DOIs, and it is not indexed in
## PubMed/Medline). Following this registry's precedent for DOI-less
## sources (e.g. PMID/ISBN/OCLC-style Alt identifiers used elsewhere in
## __ReadMe.xlsx column I), this item uses the Alt identifier
## "JAudRes:9:12-18" (journal abbreviation:volume:pages).
##
## Source is a scanned (Acrobat "Paper Capture") PDF with no usable text
## layer at all (BotDoc extraction returns only page-image markers). Every
## page was rendered at 150 dpi and read visually; the quoted sentences
## below (from the printed Results, Discussion "Overall sensitivity"/"Best
## frequency" subsections, and Summary) were transcribed directly from the
## rendered page images and are frozen verbatim in the snapshot.

## 0. PATHS --------------------------------------------------------
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_1969_ResultsText"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 1)

final.dataframe <- tibble(
  species_sci = "Tupaia glis", common_name = "Tree shrew",
  method = "conditioned suppression",
  best_sensitivity_db_spl = -15, best_frequency_khz = 16,
  tested_range_low_khz = 0.25, tested_range_high_khz = 60,
  extrapolated_range_low_khz = 0.125, extrapolated_range_high_khz = 70,
  extrapolation_criterion_db_spl = 80, n_animals = 2,
  data_role = "primary",
  source = "Heffner et al. (1969) Results/Discussion/Summary"
)
stopifnot(nrow(final.dataframe) == nrow(snap))

## 3. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

## Heffner_Heffner_2010_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, Jr., H., & Heffner, H. E. (2010). The behavioral audiogram of
## whitetail deer (Odocoileus virginianus). Journal of the Acoustical
## Society of America 127(3), EL111-EL114. doi:10.1121/1.3284546
##
## Source is a born-digital PDF (JASA Express Letters, short format).
## Folder-identity note: this folder ("Heffner_Heffner_2010", 2 authors)
## actually contains this whitetail-deer audiogram paper -- NOT a
## rhinoceros paper. It was re-verified via a fresh GetDriveChildren listing
## of THIS folder before opening the PDF, distinct from the differently
## authored ("etal", 3-author) "Heffner_etal_2010" folder (binaural cues in
## non-echolocating bats) and from "Heffner_Heffner_2010_b" (a separate,
## already-registered candidate row handled by a different agent -- not
## touched here). See README for the full cross-check.
##
## No printed table exists in this short-format letter (Fig. 1 shows the
## audiogram curve only); the core reported numbers are stated directly in
## the Abstract and Results text and were transcribed from there,
## cross-checked word-for-word against the extracted text layer.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_2010_ResultsText"
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
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                  colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 1)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  best_frequency_kHz = as.numeric(snap$`Best frequency (kHz)`),
  best_threshold_dB_SPL = as.numeric(snap$`Best threshold (dB SPL)`),
  low_freq_limit_60dB_Hz = as.numeric(snap$`Low-frequency limit at 60 dB SPL (Hz)`),
  high_freq_limit_60dB_kHz = as.numeric(snap$`High-frequency limit at 60 dB SPL (kHz)`),
  low_freq_limit_maxintensity_Hz = as.numeric(snap$`Low-frequency limit at max intensity (Hz)`),
  max_intensity_for_low_limit_dB = as.numeric(snap$`Max intensity for low limit (dB)`),
  high_freq_limit_maxintensity_kHz = as.numeric(snap$`High-frequency limit at max intensity (kHz)`),
  max_intensity_for_high_limit_dB = as.numeric(snap$`Max intensity for high limit (dB)`),
  data_role = "primary",
  source = "this study"
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  ## Registry lookup name differs from this file's name (added 2026-09-27): the citation's first author is "Heffner, Jr., H.", and the extra comma makes the registry formula read it as "etal", giving Heffner_etal_2010_Resultstext (a different paper from the Heffner_etal_2010 folder's TableI).
  ## Only the lookup uses it; the local files keep this folder's naming.
  registry_item_name <- "Heffner_etal_2010_Resultstext"
  nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
  item_encoded <- filecodes$`Item encoded`[match(nfc(registry_item_name), nfc(filecodes$`Item name`))]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", registry_item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

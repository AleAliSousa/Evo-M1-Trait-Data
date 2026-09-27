## Heffner_etal_1994_a_Figure2.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Heffner, H. E., Contos, C., & Kearns, D. (1994). Hearing in
## prairie dogs: transition between surface and subterranean rodents. Hearing
## Research 73:185-189. doi:10.1016/0378-5955(94)90233-x
##
## Registry item is nominally "Figure 2" (audiogram of a white-tailed prairie
## dog, Cynomys leucurus) but per house rules the values were taken from the
## Results text (p. 187), which restates the figure's two key summary values
## verbatim ("the white-tailed prairie dog's lowest threshold (at 8 kHz) is
## only 24 dB SPL. Its hearing range at 60 dB SPL extends from 44 Hz to 26
## kHz."), so the full curve was NOT digitized. Source is a scanned/OCR PDF;
## all values were cross-checked against a rendered page image (p. 187) before
## finalizing.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_1994_a_Figure2"
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
  n_individuals = as.integer(snap$N),
  best_sensitivity_dB_SPL = as.numeric(snap$`Best sensitivity (dB SPL)`),
  best_frequency_kHz = as.numeric(snap$`Best frequency (kHz)`),
  lowest_frequency_tested_Hz = as.numeric(snap$`Lowest frequency tested (Hz)`),
  hearing_range_low_60dBSPL_Hz = as.numeric(snap$`60-dB SPL range low (Hz)`),
  hearing_range_high_60dBSPL_kHz = as.numeric(snap$`60-dB SPL range high (kHz)`),
  data_role = "primary",
  source = paste0("Heffner et al. (1994a), ", snap$`Source location`)
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
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

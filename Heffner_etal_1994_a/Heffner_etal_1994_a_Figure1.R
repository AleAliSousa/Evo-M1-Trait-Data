## Heffner_etal_1994_a_Figure1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Heffner, H. E., Contos, C., & Kearns, D. (1994). Hearing in
## prairie dogs: transition between surface and subterranean rodents. Hearing
## Research 73:185-189. doi:10.1016/0378-5955(94)90233-x
##
## Registry item is nominally "Figure 1" (audiograms of four black-tailed
## prairie dogs, Cynomys ludovicianus, individuals A-D) but per house rules
## the values were taken from the Results text (p. 187), which states the
## summary values directly ("thresholds between 500 Hz and 8 kHz varying by
## less than 10 dB. The lowest average threshold was 20.3 dB SPL at 4 kHz.
## The range of frequencies audible at 60 dB SPL extended from 29 Hz to 26
## kHz for the black-tailed prairie dogs."), so the four individual curves
## were NOT digitized. Companion item to Heffner_etal_1994_a_Figure2 (the
## white-tailed prairie dog, priority 1 for this folder); built alongside it
## because the values are stated in the same Results paragraph (trivial
## incremental effort).
##
## NOTE: pdftotext's OCR of this scanned reprint misread the frequency of the
## lowest average threshold as "3 kHz"; a 250-dpi render of PDF page 3
## (printed p. 187) was checked and the printed text unambiguously reads
## "4 kHz". The value used here (4 kHz) is the OCR-corrected, image-verified
## reading, not a change to anything the source actually states.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_1994_a_Figure1"
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
  individual_ids = snap$Individuals,
  lowest_average_threshold_dB_SPL = as.numeric(snap$`Lowest average threshold (dB SPL)`),
  lowest_average_threshold_frequency_kHz = as.numeric(snap$`Lowest average threshold frequency (kHz)`),
  midrange_flatband_low_Hz = as.numeric(snap$`Midrange flat-band low (Hz)`),
  midrange_flatband_high_kHz = as.numeric(snap$`Midrange flat-band high (kHz)`),
  midrange_flatband_variation_dB = as.numeric(snap$`Midrange flat-band variation (dB)`),
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

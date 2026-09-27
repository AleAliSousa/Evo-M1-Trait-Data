## Heffner_etal_2003_Resultstext.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2003). Hearing in American
## leaf-nosed bats. III: Artibeus jamaicensis. Hearing Research 184:113-122.
## doi:10.1016/s0378-5955(03)00233-8
##
## Values transcribed directly from the born-digital PDF's Results section
## (p. 116): "Beginning with a threshold of 88 dB at 1 kHz, sensitivity
## increased rapidly ... with the lowest mean threshold of 8.5 dB at 16 kHz.
## ... At a level of 60 dB SPL, the audiogram extends from 2.8 to 131 kHz, a
## range of 5.5 octaves." (independently verified: log2(131/2.8) = 5.55,
## consistent with the printed "5.5 octaves").
##
## FLAG: functional interaural distance. The pre-existing registry draft and
## SensoryData_compiled assumed 89 us for A. jamaicensis. The PDF's own Fig.
## 4 (p. 117), rendered at 220 dpi and visually inspected, unambiguously
## labels "Artibeus jamaicensis (96 us)" -- not 89 us. No occurrence of "89"
## appears anywhere in this PDF's extracted text or figure labels. The
## printed source value (96 us) is used here per house rules (never
## fabricate/silently correct); the discrepancy with the previously assumed
## 89 us is flagged, not resolved.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2003_Resultstext"
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
  best_sensitivity_dB = as.numeric(snap$`Best sensitivity (dB)`),
  best_frequency_kHz = as.numeric(snap$`Best frequency (kHz)`),
  hearing_range_low_60dBSPL_kHz = as.numeric(snap$`60-dB SPL range low (kHz)`),
  hearing_range_high_60dBSPL_kHz = as.numeric(snap$`60-dB SPL range high (kHz)`),
  hearing_range_octaves = as.numeric(snap$`Hearing range (octaves)`),
  interaural_distance_functional_us = as.numeric(snap$`Functional interaural distance (us)`),
  data_role = "primary",
  source = paste0("Heffner et al. (2003), ", snap$`Source location`)
)

## sanity check: 60-dB octave span should match the reported octave count
stopifnot(abs(log2(final.dataframe$hearing_range_high_60dBSPL_kHz /
                    final.dataframe$hearing_range_low_60dBSPL_kHz) -
               final.dataframe$hearing_range_octaves) < 0.1)

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

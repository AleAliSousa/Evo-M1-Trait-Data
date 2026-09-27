## Heffner_etal_2006_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2006). Hearing in large
## (Eidolon helvum) and small (Cynopterus brachyotis) non-echolocating fruit
## bats. Hearing Research 221:17-25. doi:10.1016/j.heares.2006.06.008
##
## Source is a born-digital PDF; no printed table of audiogram summary
## values exists in this paper (Figs. 2-4 show the full audiograms as
## curves). The core reported numbers -- best frequency/threshold and the
## 60-dB-SPL hearing-range limits for each species -- are stated explicitly
## in the Results text (Sections 3.1 and the Cynopterus paragraph) and were
## transcribed directly from there, cross-checked word-for-word against the
## extracted text layer.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2006_ResultsText"
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
stopifnot(nrow(snap) == 2)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  best_frequency_kHz = as.numeric(snap$`Best frequency (kHz)`),
  best_threshold_dB_SPL = as.numeric(snap$`Best threshold (dB SPL)`),
  low_freq_limit_60dB_kHz = as.numeric(snap$`Low-frequency limit at 60 dB SPL (kHz)`),
  high_freq_limit_60dB_kHz = as.numeric(snap$`High-frequency limit at 60 dB SPL (kHz)`),
  hearing_range_60dB_octaves = as.numeric(snap$`Hearing range at 60 dB SPL (octaves)`),
  lowest_freq_tested_kHz = as.numeric(snap$`Lowest frequency tested (kHz)`),
  threshold_at_lowest_freq_dB_SPL = snap$`Threshold at lowest frequency tested (dB SPL)`,
  data_role = "primary",
  source = "this study"
)
## NOTE: for E. helvum, the printed 60-dB octave span (4.82) does not
## exactly reproduce from the printed rounded boundary values (1.38-41 kHz
## recomputes to ~4.89 octaves); this is a minor rounding artifact of the
## source (the paper likely used unrounded internal values). The printed
## 4.82 is kept as-is -- see README and registry N.B.; never silently
## corrected.

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

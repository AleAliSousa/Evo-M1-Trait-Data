## Heffner_Heffner_1982_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1982). Hearing in the elephant (Elephas
## maximus): Absolute sensitivity, frequency discrimination, and sound
## localization. Journal of Comparative and Physiological Psychology
## 96(6):926-944. doi:10.1037/0735-7036.96.6.926
##
## Source is a scanned/OCR PDF (text layer extracted cleanly with
## pdftotext). This paper reports three separate experiments (absolute
## sensitivity/audiogram, frequency discrimination, sound localization);
## only Experiment 1 (absolute sensitivity, i.e. the audiogram) is captured
## here as the core hearing-sensitivity trait for this registry cluster.
## No printed table gives the full audiogram (Table 1 in the paper is a
## sound-field calibration table, not the audiogram; the audiogram itself
## is Figure 2, a curve). The core summary numbers -- best frequency and
## threshold, and the 60-dB-SPL low/high hearing-range limits -- are
## explicitly stated in the Results text ("Best frequency of hearing",
## "High-frequency hearing", and "Low-frequency hearing" subsections) and
## were transcribed directly from there.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1982_ResultsText"
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
  additional_detail = snap$`Additional detail`,
  data_role = "primary",
  source = "this study"
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

## Heffner_etal_2014_Resultstext.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas
## (Vicugna pacos): audiogram, localization acuity, and use of binaural
## locus cues. Journal of the Acoustical Society of America, 135(2), 778-788.
## doi:10.1121/1.4861344
##
## Source is a born-digital PDF; all values transcribed directly from the
## Results text (Sections III.A-D), not digitized from Figs. 3-6.

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
item_name <- tools::file_path_sans_ext(basename(.sp))
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
stopifnot(nrow(snap) == 10)

## 3. CLEAN -----------------------------------------------------------
## The interaural-distance row (10th in the snapshot) is explicitly not a
## printed text value (only shown graphically in Figs. 8/11) and is dropped
## from the tidy analysis table rather than fabricated as a number.
final.dataframe <- tibble(
  trait_row   = seq_len(9),
  binomial    = "Vicugna pacos",
  common_name = "Alpaca",
  measure     = c("audible_freq_low_60dBSPL","audible_freq_high_60dBSPL","hearing_range",
                  "best_sensitivity","best_frequency","sound_localization_threshold",
                  "binaural_phase_cue","binaural_intensity_cue","pinna_cue_use"),
  value       = c(40, 32.8, 9.7, -0.5, 8, 23, NA, NA, NA),
  value_chr   = c(NA, NA, NA, NA, NA, NA, "Y", "N", "Y"),
  unit        = c("Hz","kHz","octaves","dB SPL","kHz","deg","Y/N","Y/N","Y/N"),
  data_role   = "primary",
  source_location = c(rep("Results III.A, p.781", 5), "Results III.B, p.781-782",
                       rep("Results III.C, p.781-782", 2), "Results III.D, p.782-783")
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

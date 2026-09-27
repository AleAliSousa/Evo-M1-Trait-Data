## Heffner_Heffner_1985_Resultstext.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1985). Hearing in Mammals: The Least
## Weasel. J Mammal, 66, 745-755. doi:10.2307/1380801
##
## Source PDF is a scanned/OCR'd article. All digits below were verified
## against 150-dpi renders of the printed pages (p. 745 abstract and
## p. 749 Results, section headings "Best frequency.-", "Best
## sensitivity.-", "High-frequency sensitivity.-") before finalizing this
## script -- not the raw OCR text layer alone, which contains scattered
## character-recognition errors elsewhere in the article (e.g. author
## affiliation line).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1985_Resultstext"
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
  binomial    = "Mustela nivalis",
  common_name = "Least weasel",
  audible_freq_low_60dBSPL_khz  = as.numeric(snap$`Low-frequency hearing limit (Hz)`) / 1000,
  audible_freq_high_60dBSPL_khz = as.numeric(snap$`High-frequency hearing limit (kHz)`),
  region_best_hearing_low_khz   = as.numeric(snap$`Region of best hearing low (kHz)`),
  region_best_hearing_high_khz  = as.numeric(snap$`Region of best hearing high (kHz)`),
  best_frequency_khz  = as.numeric(snap$`Best frequency (kHz)`),
  best_sensitivity_db = as.numeric(snap$`Best sensitivity (dB)`),
  data_role = "primary",
  source = "this study (Results text)"
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

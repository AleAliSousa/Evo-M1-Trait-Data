## Schusterman_Moore_1980_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Schusterman, R. J., & Moore, P. W. B. (1980). Auditory sensitivity of
## northern fur seals (Callorhinus ursinus) and a California sea lion
## (Zalophus californianus) to airborne sound. Journal of the Acoustical
## Society of America, 68(S1), S6 [100th Meeting of the Acoustical Society of
## America, abstract Cll]. doi:10.1121/1.2004876
##
## Source is a born-digital 2-page PDF (a meeting-abstract reprint from J.
## Acoust. Soc. Am. Suppl. 1, Vol. 68, Fall 1980, p. 86). It has no separate
## printed data table -- the audiogram values for both subjects are given
## directly in the abstract's running Results text, one averaged threshold
## per frequency for each species. Values were transcribed directly from the
## clean, born-digital text layer (no OCR artifacts observed) and re-checked
## word-for-word against the extracted text.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Schusterman_Moore_1980_ResultsText"
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
stopifnot(nrow(snap) == 14)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  n_subjects  = snap$N,
  frequency_khz = as.numeric(snap$`Frequency (kHz)`),
  threshold_db_re_0.0002dyncm2 = as.numeric(snap$`Threshold (dB re 0.0002 dyn/cm2)`),
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

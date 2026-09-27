## Frost_Masterton_1994_Resultstext.R -- snapshot -> analysis CSV + public TSV
##
## Frost, S. B., & Masterton, R. B. (1994). Hearing in primitive mammals:
## Monodelphis domestica and Marmosa elegans. Hear Res, 76, 67-72.
## doi:10.1016/0378-5955(94)90088-4
##
## Source PDF has an OCR-derived text layer (older scanned-and-recognized
## article; some characters/ligatures are garbled, e.g. species names).
## The values below were cross-checked against a 150-dpi page render of
## printed page 70 (Results section), not merely the extracted text.
## This item transcribes the Results-text summary statistics -- preferred
## per the registry's own priority note over digitising Figure 3 (a
## separately registered, lower-priority candidate row).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Frost_Masterton_1994_Resultstext"
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
## NOTE on Monodelphis best frequency: the printed sentence reads "the
## average lowest reliable threshold was 20 dB at 8 and 16 kHz for
## Monodelphis" -- i.e. the paper itself reports a tie between two
## frequencies, not a single best frequency. We deliberately leave
## best_frequency_khz as NA for Monodelphis rather than arbitrarily
## picking one of the two printed values.
binomial_map <- c("Monodelphis domestica" = "Monodelphis domestica",
                   "Marmosa elegans" = "Marmosa elegans")
common_map <- c("Monodelphis domestica" = "Gray short-tailed opossum",
                 "Marmosa elegans" = "Elegant mouse opossum")
best_freq_map <- c("Monodelphis domestica" = NA_real_, "Marmosa elegans" = 32)

final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = binomial_map[snap$Species],
  common_name = common_map[snap$Species],
  audible_freq_low_60dBSPL_khz  = as.numeric(snap$`60-dB SPL hearing range low (kHz)`),
  audible_freq_high_60dBSPL_khz = as.numeric(snap$`60-dB SPL hearing range high (kHz)`),
  best_sensitivity_db = as.numeric(snap$`Average lowest threshold (dB SPL)`),
  best_frequency_khz  = best_freq_map[snap$Species],
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

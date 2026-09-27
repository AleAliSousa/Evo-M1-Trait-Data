## Wenstrup__1984_Figures3-5.R -- snapshot -> analysis CSV + public TSV
##
## Wenstrup, J. J. (1984). Auditory sensitivity in the fish-catching bat,
## Noctilio leporinus. Journal of Comparative Physiology A, 155, 91-101.
## doi:10.1007/BF00610934
##
## Despite the registered item name ("Figures3-5"), no curve digitization
## was actually needed: the paper's Results section (p.96) states the
## group-level summary numbers explicitly in prose. Per-individual peak
## sensitivity is NOT broken out numerically in the text (only shown in the
## three bats' separate curves, Figs. 3-5); it is therefore left blank
## rather than read off the figures, per house rule to prefer printed text
## over digitized figures and to never fabricate an unstated per-animal
## value.

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
stopifnot(nrow(snap) == 3)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  subject_row  = seq_len(3),
  binomial     = "Noctilio leporinus",
  common_name  = "Fish-catching bat",
  subject_id   = snap$Subject_id,
  cf_frequency_kHz = 57,
  threshold_at_cf_dB_low  = -1,
  threshold_at_cf_dB_high = 4,
  audible_freq_low_60dBSPL_kHz  = 7,
  audible_freq_high_60dBSPL_kHz = c(NA, 101, 115),
  data_role    = "primary",
  source_location = "Results, p.96 (text)"
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

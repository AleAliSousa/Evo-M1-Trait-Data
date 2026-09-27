## Kastak_Schusterman_1999_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Kastak, D., & Schusterman, R. J. (1999). In-air and underwater hearing
## sensitivity of a northern elephant seal (Mirounga angustirostris).
## Canadian Journal of Zoology, 77(11), 1751-1758. doi:10.1139/z99-151
##
## Source is a born-digital PDF; the paper prints no data table (only
## figures). The values below are transcribed verbatim from the Abstract,
## which restates the same numbers found in the Results section, and were
## cross-checked against the duplicate wording in the paper's French resume.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kastak_Schusterman_1999_ResultsText"
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
stopifnot(nrow(snap) == 2)  # Air row, Underwater row

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  obs_row     = seq_len(nrow(snap)),
  binomial    = "Mirounga angustirostris",
  common_name = "Northern elephant seal",
  subject     = "Burnyce",
  medium      = snap$medium,
  best_range_low_khz  = as.numeric(snap$best_range_low_khz),
  best_range_high_khz = as.numeric(snap$best_range_high_khz),
  best_frequency_khz  = as.numeric(snap$best_frequency_khz),
  best_threshold_db   = as.numeric(snap$best_threshold_value),
  reference_pressure  = snap$best_threshold_unit,
  upper_freq_limit_khz = as.numeric(snap$upper_freq_limit_khz),
  upper_freq_is_approx  = as.logical(snap$upper_freq_is_approx),
  underwater_vs_air_pressure_diff_db  = 19,
  underwater_vs_air_intensity_diff_db = 52,
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

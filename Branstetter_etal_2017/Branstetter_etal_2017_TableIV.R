## Branstetter_etal_2017_TableIV.R -- snapshot -> analysis CSV + public TSV
##
## Branstetter, B. K., St Leger, J., Acton, D., Stewart, J., Houser, D.,
## Finneran, J. J., & Jenkins, K. (2017). Killer whale (Orcinus orca)
## behavioral audiograms. J Acoust Soc Am, 141, 2387-2398.
## doi:10.1121/1.4979116
##
## Source is a born-digital PDF; Table IV (4 rows, species composite
## metrics for O. orca, D. leucas, T. truncatus, P. phocoena) was
## transcribed directly from the extracted text layer and cross-checked
## against the printed table. This item supersedes/complements Table I
## (raw per-subject threshold matrix for the 10 individual killer whales,
## registered separately) -- Table IV is the paper's own derived-metric
## summary and is the direct printed source of the four O. orca values
## (low/high 60-dB cutoff, best frequency, best sensitivity) used by
## SensoryData_compiled.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Branstetter_etal_2017_TableIV"
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
stopifnot(nrow(snap) == 4)

## 3. CLEAN -----------------------------------------------------------
binomial_map <- c("O. orca" = "Orcinus orca", "D. leucas" = "Delphinapterus leucas",
                   "T. truncatus" = "Tursiops truncatus", "P. phocoena" = "Phocoena phocoena")
common_map <- c("O. orca" = "Killer whale", "D. leucas" = "Beluga whale",
                "T. truncatus" = "Bottlenose dolphin", "P. phocoena" = "Harbor porpoise")

range_split <- strsplit(snap$`Best hearing range (kHz)`, "-")

final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = binomial_map[snap$Species],
  common_name = common_map[snap$Species],
  mass_kg     = as.numeric(snap$`Mass (kg)`),
  best_frequency_khz = as.numeric(snap$`Best sensitivity (kHz)`),
  best_sensitivity_db = as.numeric(snap$`Lowest threshold (dB)`),
  best_range_low_khz  = as.numeric(sapply(range_split, `[`, 1)),
  best_range_high_khz = as.numeric(sapply(range_split, `[`, 2)),
  audible_freq_low_60dBSPL_khz  = as.numeric(snap$`Low-frequency cutoff (kHz)`),
  audible_freq_high_60dBSPL_khz = as.numeric(snap$`High-frequency cutoff (kHz)`),
  n_subjects = as.integer(snap$N),
  data_role = ifelse(snap$Species == "O. orca", "primary", "secondary"),
  source = ifelse(snap$Species == "O. orca", "this study",
                   "this study (composite audiogram; see Table III for reference sources)")
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

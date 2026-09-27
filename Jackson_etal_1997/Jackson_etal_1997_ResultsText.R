## Jackson_etal_1997_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Jackson, L. L., Heffner, H. E., & Heffner, R. S. (1997). Audiogram of the
## fox squirrel (Sciurus niger). Journal of Comparative Psychology, 111(1),
## 100-104. doi:10.1037/0735-7036.111.1.100
##
## Source is a born-digital PDF with a clean text layer; no data table is
## printed in this brief communication (all audiogram values appear only in
## Fig. 2). The six quantitative statements in the Results paragraph (p. 102)
## were transcribed directly and cross-checked word-for-word against the
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Jackson_etal_1997_ResultsText"
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
stopifnot(nrow(snap) == 6)

## 3. CLEAN -----------------------------------------------------------
## Convert every reported frequency to kHz for a consistent analysis column.
freq_to_khz <- function(value, unit) {
  value <- as.numeric(value)
  ifelse(grepl("^Hz$", unit, ignore.case = TRUE), value / 1000, value)
}

final.dataframe <- tibble(
  obs_row      = seq_len(nrow(snap)),
  binomial     = "Sciurus niger",
  common_name  = "Fox squirrel",
  subject      = snap$subject,
  metric       = snap$metric,
  frequency_khz = freq_to_khz(snap$frequency_value, snap$frequency_unit),
  threshold_db  = as.numeric(snap$threshold_value),
  data_role     = "primary",
  notes = c(
    "audible low-frequency point reported in Results text",
    "best threshold; frequency of best hearing",
    "highest frequency tested for Squirrel A",
    "highest frequency tested for Squirrel B",
    "60-dB SPL low-frequency cutoff (criterion threshold = 60 dB)",
    "60-dB SPL high-frequency cutoff (criterion threshold = 60 dB)"
  ),
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

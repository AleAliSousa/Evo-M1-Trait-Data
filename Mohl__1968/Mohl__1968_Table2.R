## Mohl__1968_Table2.R -- snapshot -> analysis CSV + public TSV
##
## Moehl, B. (1968). Auditory sensitivity of the common seal in air and
## water. The Journal of Auditory Research, 8, 27-38.
## (No DOI was ever assigned to this pre-DOI-era journal; see registry N.B.)
##
## Source is a scanned (born-analog, OCR'd) PDF; Table II (p. 32, "Water"
## and "Air" sub-tables) was transcribed directly from a 150-dpi page render
## of the source PDF (pdftoppm), because the extracted OCR text layer
## contained numerous character-recognition errors (e.g. the water-table
## reference level printed as "db re 1 uBar" was OCR'd as "db re 4 uBar",
## and low-frequency dashes/digits were frequently garbled). All 20 rows
## (11 water + 9 air) were cross-checked digit-by-digit against the
## rendered page image before finalizing.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Mohl__1968_Table2"
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
stopifnot(nrow(snap) == 20)

## 3. CLEAN -----------------------------------------------------------
## Parenthesized values in the source table (e.g. "(-16)", "(33)") mark
## thresholds the author himself flagged as less certain (extrapolated
## calibration or small/uncertain N); we keep the numeric value but record
## a flag column rather than silently treating them as equally solid data.
parse_flagged <- function(x) {
  flag <- ifelse(grepl("\\(", x), "parenthetical_in_source", "")
  val  <- as.numeric(gsub("[()]", "", x))
  list(val = val, flag = flag)
}
thr <- parse_flagged(snap$`Threshold (db)`)
sdv <- parse_flagged(snap$`Standard deviation (db)`)

final.dataframe <- tibble(
  row_id                    = seq_len(nrow(snap)),
  medium                    = snap$Medium,
  frequency_kHz             = as.numeric(snap$`Frequency (kc/s)`),
  threshold_dB              = thr$val,
  threshold_flag            = thr$flag,
  reference_level           = snap$Reference,
  sd_dB                     = sdv$val,
  sd_flag                   = sdv$flag,
  n_catch_trials            = as.integer(snap$`Number of Catch Trials`),
  pct_correct_catch_trials  = as.numeric(snap$`% Correct Catch Trials`),
  data_role                 = "primary",
  source                    = "Mohl (1968)"
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

## Koay_etal_2003_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Koay, G., Heffner, R. S., Bitter, K. S., & Heffner, H. E. (2003). Hearing
## in American leaf-nosed bats. II: Carollia perspicillata. Hearing
## Research, 178(1-2), 27-34. doi:10.1016/S0378-5955(03)00025-X
##
## Source is a born-digital PDF. The Results text (p. 30) explicitly refers
## to a "Table 1" of mean per-bat thresholds, but no such table is present or
## extractable anywhere in the delivered PDF (checked the text layer for all
## 8 pages and 220-dpi renders of the Results page) -- only the Results-text
## sentences and the Fig. 1 audiogram plot are available. The eight named
## frequency/threshold values stated verbatim in the Results text were
## transcribed; additional per-frequency points visible only in Fig. 1 were
## NOT digitized, to avoid fabricating numbers beyond what the text states.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Koay_etal_2003_ResultsText"
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
stopifnot(nrow(snap) == 8)

## 3. CLEAN -----------------------------------------------------------
notes_lookup <- c(
  threshold_at_4kHz       = "low-frequency reference point",
  best_sensitivity        = "frequency of best hearing (primary peak)",
  threshold_at_50kHz      = "local minimum sensitivity (peak of insensitivity) between the two sensitivity peaks",
  secondary_peak          = "secondary region of sensitivity",
  threshold_at_125kHz     = "high-frequency decline point",
  threshold_at_160kHz     = "highest frequency tested",
  hearing_range_60dB_low  = "60-dB SPL low-frequency cutoff (criterion threshold = 60 dB); range spans 4.85 octaves",
  hearing_range_60dB_high = "60-dB SPL high-frequency cutoff (criterion threshold = 60 dB); range spans 4.85 octaves"
)

final.dataframe <- tibble(
  obs_row     = seq_len(nrow(snap)),
  binomial    = "Carollia perspicillata",
  common_name = "Short-tailed fruit bat",
  metric      = snap$metric,
  frequency_khz = as.numeric(snap$frequency_khz),
  threshold_db_spl = as.numeric(snap$threshold_db_spl),
  data_role = "primary",
  notes = unname(notes_lookup[snap$metric]),
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

## Kastak_Schusterman_1998_TablesI-II.R -- snapshot -> analysis CSV + public TSV
##
## Kastak, D., & Schusterman, R. J. (1998). Low-frequency amphibious hearing
## in pinnipeds: Methods, measurements, noise, and ecology. Journal of the
## Acoustical Society of America, 103(4), 2216-2228. doi:10.1121/1.421367
##
## Source is a born-digital PDF; Table I (aerial thresholds, p. 2220) and
## Table II (underwater thresholds, p. 2221) were transcribed directly and
## cross-checked against 200-dpi page renders of both tables.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kastak_Schusterman_1998_TablesI-II"
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
stopifnot(nrow(snap) == 50)  # 21 aerial (Table I) + 29 underwater (Table II) rows

## 3. CLEAN -----------------------------------------------------------
common_names <- c(
  "Rocky"   = "California sea lion",
  "Rio"     = "California sea lion",
  "Sprouts" = "Harbor seal",
  "Burnyce" = "Northern elephant seal"
)
binomials <- c(
  "Rocky"   = "Zalophus californianus",
  "Rio"     = "Zalophus californianus",
  "Sprouts" = "Phoca vitulina",
  "Burnyce" = "Mirounga angustirostris"
)

final.dataframe <- tibble(
  obs_row     = seq_len(nrow(snap)),
  binomial    = binomials[snap$Subject],
  common_name = common_names[snap$Subject],
  subject_id  = snap$Subject,
  medium      = snap$Medium,
  frequency_hz = as.integer(snap$`Frequency (Hz)`),
  threshold_db = as.numeric(snap$`Threshold (dB)`),
  reference_pressure = ifelse(snap$Medium == "Aerial", "20 uPa", "1 uPa"),
  false_alarm_pct = as.numeric(snap$`False alarms (%)`),
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

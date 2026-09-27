## Koay_etal_1998_b_Resultstext.R -- snapshot -> analysis CSV + public TSV
##
## Koay, G., Kearns, D., Heffner, H. E., & Heffner, R. S. (1998). Passive
## sound-localization ability of the big brown bat (Eptesicus fuscus).
## Hear Res, 119, 37-48. doi:10.1016/s0378-5955(98)00037-9
##
## NOTE ON FOLDER IDENTITY: this is the "_b" folder for the big brown bat
## (Eptesicus fuscus) sound-localization paper, NOT the unrelated,
## already-FINISHED "Koay_etal_1998" (no suffix) folder, which is a
## different DOI (10.1037%2F0735-7036.112.4.371) about a different genus
## entirely. The registry rows for this folder originally had
## H = "Koay_etal_1998" (missing the "_b") on all three candidate rows;
## these have been corrected to H = "Koay_etal_1998_b" with J/K updated to
## include the "_b" marker.
##
## Source is a born-digital PDF; the three Results-text values
## transcribed here (minimum audible angle, use of binaural cues, width of
## field of best vision) were cross-checked word-for-word against the
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Koay_etal_1998_b_Resultstext"
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
## MAA average of 14 deg is computed by the paper's authors as the mean of
## three individual bats' thresholds (16, 12, 13 deg) -- reproduced here as
## printed, not recomputed.
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = "Eptesicus fuscus",
  common_name = "Big brown bat",
  sound_localization_threshold_deg = as.numeric(snap$`MAA average (deg)`),
  binaural_intensity_difference_cue = snap$`Binaural intensity-difference cue used`,
  binaural_phase_cue = snap$`Binaural time-difference cue used`,
  field_of_best_vision_width_deg = as.numeric(snap$`Field of best vision width (deg)`),
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

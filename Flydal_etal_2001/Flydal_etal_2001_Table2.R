## Flydal_etal_2001_Table2.R -- snapshot -> analysis CSV + public TSV
##
## Flydal, K., Hermansen, A., Enger, P. S., & Reimers, E. (2001). Hearing in
## reindeer (Rangifer tarandus). Journal of Comparative Physiology A, 187,
## 265-269. doi:10.1007/s003590100198
##
## Source is a born-digital PDF, but its embedded font/glyph encoding is
## corrupted in the extracted text layer (control characters instead of
## letters throughout). Table 2 (printed p. 267, "Individual hearing
## thresholds with sound from the front and sound from behind the animal")
## was therefore transcribed entirely by hand from a 150-dpi render of the
## PDF page and cross-checked digit-by-digit against the image before
## writing the snapshot.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Flydal_etal_2001_Table2"
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
## Skip the title + blank line; header row then 11 frequency rows.
snap <- read.csv(snapshot_csv, skip = 2, stringsAsFactors = FALSE,
                  check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 11)

freq_hz <- c(63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000, 32000, 38000)
stopifnot(all(as.numeric(gsub("[^0-9.]", "", snap$`Frequency (Hz)`) ) * 1 >= 0))  # sanity: numeric-ish

to_num <- function(x) suppressWarnings(as.numeric(ifelse(trimws(x) %in% c("-", ""), NA, x)))

long <- bind_rows(
  tibble(animal_id = "Reindeer_1", sound_direction = "front",  frequency_hz = freq_hz,
         threshold_db_re_20uPa = to_num(snap[["Reindeer 1, sound from front (dB)"]])),
  tibble(animal_id = "Reindeer_2", sound_direction = "front",  frequency_hz = freq_hz,
         threshold_db_re_20uPa = to_num(snap[["Reindeer 2, sound from front (dB)"]])),
  tibble(animal_id = "Reindeer_1", sound_direction = "behind", frequency_hz = freq_hz,
         threshold_db_re_20uPa = to_num(snap[["Reindeer 1, sound from behind (dB)"]])),
  tibble(animal_id = "Reindeer_2", sound_direction = "behind", frequency_hz = freq_hz,
         threshold_db_re_20uPa = to_num(snap[["Reindeer 2, sound from behind (dB)"]]))
)

final.dataframe <- long %>%
  mutate(species_sci = "Rangifer tarandus tarandus", common_name = "reindeer",
         frequency_khz = frequency_hz / 1000, data_role = "primary",
         source = "Flydal et al. (2001) Table 2") %>%
  select(species_sci, common_name, animal_id, sound_direction, frequency_hz,
         frequency_khz, threshold_db_re_20uPa, data_role, source)

stopifnot(nrow(final.dataframe) == 44)  # 11 frequencies x 2 animals x 2 directions

## 3. CHECK -------------------------------------------------------------
## Abstract states: 60-dB range ~70 Hz-38 kHz; best sensitivity 3 dB at
## 8 kHz. These summary values describe the *averaged* front/behind audiogram
## (Fig. 1), not any single printed cell here, so they are not required to
## exactly match any individual row -- but the paper's lowest printed
## individual threshold should be in the right neighborhood of "a few dB".
stopifnot(min(final.dataframe$threshold_db_re_20uPa, na.rm = TRUE) <= 3)

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

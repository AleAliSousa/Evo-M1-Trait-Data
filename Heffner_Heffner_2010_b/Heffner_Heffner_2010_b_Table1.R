## Heffner_Heffner_2010_b_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R., & Heffner, H. (2010). Explaining high-frequency hearing.
## Anat Rec (Hoboken), 293, 2080-2082. doi:10.1002/ar.21292
##
## NOTE ON FOLDER IDENTITY: this is the "_b" folder -- a short Letter to
## the Editor responding to Kirk and Gosselin-Ildari (2009), NOT the
## unrelated, separately-registered "Heffner_Heffner_2010" (no suffix)
## paper on binaural cues for sound localization. The registry row for
## this item originally had H = "Heffner_Heffner_2010" (missing the "_b")
## and J/K without the "_b" marker; these have been corrected to match
## this folder exactly.
##
## Source is a born-digital PDF; Table 1 (21 species, printed p. 2081) was
## transcribed directly and cross-checked word-for-word against the
## extracted text layer. This is a small table, transcribed in full.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_2010_b_Table1"
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
stopifnot(nrow(snap) == 21)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  audible_freq_high_60dBSPL_khz = as.numeric(snap$`High-frequency Hearing Limit (kHz)`),
  interaural_distance_functional_us = as.numeric(snap$`Functional Interaural Distance (us)`),
  basilar_membrane_length_mm = as.numeric(snap$`Basilar Membrane Length (mm)`),
  data_role = ifelse(snap$Species == "Tursiops truncatus", "primary", "secondary"),
  source = "see reference_tables/Heffner_Heffner_2010_b_Table1_footnotes.csv for per-row citation letters"
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

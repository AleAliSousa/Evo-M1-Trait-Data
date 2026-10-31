## Koay_etal_2002_Figure3.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Koay, G., Bitter, K. S., Heffner, H. E., & Heffner, R. S. (2002). Hearing in American
## leaf-nosed bats. I: Phyllostomus hastatus. Hear Res 171:96-102.
## doi:10.1016/s0378-5955(02)00458-6
##
## THE ITEM IS A FIGURE. Figure 3 (p. 101) carries TWO series on one pair of axes: this
## paper's own behavioural audiogram of Phyllostomus hastatus (thick line, no markers) and
## multi-unit inferior-colliculus thresholds replotted from Grinnell (1970) (thin line with
## markers). Values are digitised by Koay_etal_2002_Figure3_extract_snapshot.py and frozen
## in the snapshot; this script attaches the series source and the data role.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Koay_etal_2002_Figure3"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = "character")
refs <- read.csv(refs_csv,     stringsAsFactors = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 26, length(unique(snap$series_as_printed)) == 2)

## 3. CLEAN ----------------------------------------------------------
final.dataframe <- tibble(
  binomial  = "Phyllostomus hastatus",
  series_as_printed = snap$series_as_printed,
  measure = ifelse(snap$series_as_printed == "Behavioral Audiogram",
                   "behavioural detection threshold (mean 50% detection)",
                   "multi-unit inferior-colliculus response threshold"),
  frequency_kHz   = as.numeric(snap$frequency_kHz_as_read),
  threshold_dB_SPL = as.numeric(snap$threshold_dB_SPL_as_read),
  point_type = snap$point_type,
  value_source = ifelse(snap$series_as_printed == "Behavioral Audiogram", "this study", "Grinnell, 1970"),
  data_role    = ifelse(snap$series_as_printed == "Behavioral Audiogram", "primary", "secondary"),
  value_origin = "digitised_from_figure",
  note = snap$note
) %>% arrange(series_as_printed, frequency_kHz) %>%
  mutate(across(where(is.character), ~replace_na(., "")))
stopifnot(all(final.dataframe$value_source %in% refs$ref_key))

## 4. WRITE CSV + PUBLIC TSV ---------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  stopifnot(!is.na(item_encoded), !grepl("_$", item_encoded))
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

## 5. COMPARISON -----------------------------------------------------
## None. The README records the agreement with this paper's own Results text
## (built as Koay_etal_2002_ResultsText): 60-dB limits 1.8/105 kHz and best
## sensitivity 1 dB at 20 kHz.

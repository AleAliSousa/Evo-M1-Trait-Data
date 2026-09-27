## Heffner_etal_2001_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2001). Audiograms of five
## species of rodents: implications for the evolution of hearing and the
## perception of pitch. Hearing Research, 157(1-2), 138-152.
## doi:10.1016/S0378-5955(01)00298-2
##
## Source is a born-digital PDF with a clean text layer. There is no single
## printed summary table of the five species' 60-dB hearing-range/
## best-sensitivity values (Fig. 2/Fig. 4 plot the full audiogram curves);
## instead, each species' 60-dB hearing range (low/high frequency limit,
## in octaves) and average best sensitivity/frequency is stated explicitly,
## once per species, in its own Results subsection (3.1-3.5). All five
## quoted sentences are frozen verbatim in the snapshot.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2001_ResultsText"
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
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 5)

## Values re-keyed from the quoted sentences in the snapshot (one species
## per row, in the order the paper presents them: 3.1 chipmunk, 3.2
## groundhog, 3.3 hamster, 3.4 Darwin's leaf-eared mouse, 3.5 spiny mouse).
final.dataframe <- tibble(
  species_sci = c("Tamias striatus", "Marmota monax", "Mesocricetus auratus",
                   "Phyllotis darwinii", "Acomys cahirinus"),
  common_name = c("Eastern chipmunk", "Groundhog", "Golden hamster",
                   "Darwin's leaf-eared mouse", "Egyptian spiny mouse"),
  hearing_range_low_khz  = c(0.039, 0.040, 0.096, 1.55, 2.3),
  hearing_range_high_khz = c(52, 27.5, 46.5, 73.5, 71),
  hearing_range_octaves_printed = c(10.4, 9.4, 8.9, 5.5, 4.9),
  best_sensitivity_db_spl = c(16.7, 21.5, 1, 33.5, 14),
  best_frequency_khz = c(1, 4, 10, 11, 8),
  range_criterion_db_spl = 60,
  data_role = "primary",
  source = "Heffner et al. (2001) Results text"
) %>%
  mutate(hearing_range_octaves_computed =
           round(log2(hearing_range_high_khz / hearing_range_low_khz), 2))

stopifnot(nrow(final.dataframe) == nrow(snap))

## 3. CHECK -------------------------------------------------------------
## Recomputed octave span (log2(high/low)) should match the printed octave
## count within rounding for every species -- verification only, printed
## values (both range limits and octave count) are kept as-is regardless.
diffs <- abs(final.dataframe$hearing_range_octaves_computed -
             final.dataframe$hearing_range_octaves_printed)
stopifnot(all(diffs < 0.15))

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

## Dalland__1965_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Dalland, J. I. (1965). Hearing sensitivity in bats. Science, 150(3700),
## 1185-1186. doi:10.1126/science.150.3700.1185
##
## Source is a born-digital PDF (clean text layer, republished by Science);
## no printed data table exists -- the paper reports its two bats' audiogram
## values (best sensitivity, best frequency, tested/audible frequency range)
## only in running Abstract/Results text and a figure (Fig. 1, not
## digitized here per house rule to prefer text/table over a figure). The
## quoted sentences containing every number used below are frozen verbatim
## in the snapshot.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Dalland__1965_ResultsText"
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

## 2. LOAD ------------------------------------------------------------
## The snapshot is a verbatim-quote table (not a printed data table); the
## numeric fields below were hand-extracted from those exact quotes and are
## re-typed here as a small literal table rather than parsed out of the
## quote text (parsing free text is more error-prone than re-keying the two
## numbers per species that the quotes already establish unambiguously).
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 2)

final.dataframe <- tibble(
  species_sci = c("Eptesicus fuscus", "Myotis lucifugus"),
  common_name = c("Big brown bat", "Little brown bat"),
  best_sensitivity_db_re_1dyne_cm2 = c(-68, -64),
  best_frequency_khz = c(20, 40),
  secondary_peak_frequency_khz = c(60, NA),
  audible_range_low_khz = c(2.5, 10),
  audible_range_high_khz = c(100, 120),
  range_criterion = c("nondestructive test intensity, <15 dB re 1 dyne/cm2",
                       "responded at <0 dB re 1 dyne/cm2 (i.e. <1 dyne/cm2)"),
  data_role = "primary",
  source = "Dalland (1965) Results text"
)
stopifnot(nrow(final.dataframe) == nrow(snap))

## 3. WRITE CSV + PUBLIC TSV ------------------------------------------
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

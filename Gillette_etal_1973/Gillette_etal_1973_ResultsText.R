## Gillette_etal_1973_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Gillette, R. G., Brown, R., Herman, P., Vernon, S., & Vernon, J. (1973).
## The auditory sensitivity of the lemur. American Journal of Physical
## Anthropology, 38(2), 365-370. doi:10.1002/ajpa.1330380234
##
## *** N.B. on year/filename discrepancy ***
## The source PDF supplied in this folder is filed as
## "Gillette-2005-The auditory sensitivity of the.pdf" (filename implies
## year 2005), but the PDF's own title page, running head, and every
## in-text citation confirm this is actually Gillette, Brown, Herman,
## Vernon & Vernon (1973), American Journal of Physical Anthropology 38(2):
## 365-370 (PMID 4689764; DOI 10.1002/ajpa.1330380234; confirmed against
## Sci-Hub, Europe PMC, and Wikidata, all of which list it as a March 1973
## publication). The folder name Gillette_etal_1973 is CORRECT; the PDF's
## own filename year (2005) is the erroneous label and is NOT used anywhere
## in this registry entry. See README N.B. section.
##
## Source is a born-digital PDF with a clean text layer; no printed data
## table gives a full audiogram (Table 1 is animal demographics; Table 2 is
## a test-retest method-comparison table, not the primary audiogram). The
## paper's own headline quantitative result -- a 60-dB hearing range of
## 1-32 kHz for Lemur catta -- is stated in the Abstract, and is frozen
## verbatim in the snapshot.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Gillette_etal_1973_ResultsText"
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
stopifnot(nrow(snap) == 1)

final.dataframe <- tibble(
  species_sci = "Lemur catta", common_name = "Ring-tailed lemur",
  sensitivity_criterion_db_below_1dyne_cm2 = 60,
  range_low_khz = 1, range_high_khz = 32,
  tested_range_low_khz = 0.1, tested_range_high_khz = 75,
  data_role = "primary",
  source = "Gillette et al. (1973) Abstract/Discussion"
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

## Heffner_Heffner_2003_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## IMPORTANT CITATION/YEAR MISMATCH -- see README and registry N.B. for full
## detail. The folder name ("Heffner_Heffner_2003") and the source PDF's
## filename ("Heffner-2003-Audition.pdf") both imply the paper:
##   Heffner, H. E., & Heffner, R. S. (2003). Audition. In S. F. Davis (Ed.),
##   Handbook of Research Methods in Experimental Psychology (pp. 413-440).
##   Blackwell.
## However, the ACTUAL text inside this PDF is a different, later chapter:
##   Heffner, H. E., & Heffner, R. S. (2008). High-frequency hearing. In
##   P. Dallos, D. Oertel, & R. Hoy (Eds.), Handbook of the Senses: Audition
##   (pp. 55-60). Elsevier. doi:10.1016/B978-012370880-9.00004-9
## The book title "Handbook of the Senses: AUDITION" most likely explains
## how the file came to be named/filed as though it were the other,
## similarly-titled 2003 "Audition" chapter. This script (and the registry
## row it feeds) is built from what is ACTUALLY in the PDF (the 2008
## High-Frequency Hearing chapter), not the 2003 chapter the folder name
## implies. This is a review/synthesis chapter, not a primary-data paper.
##
## No printed data table exists in this chapter. Its single explicitly
## quantitative comparative finding is a correlation statistic (stated in
## prose, next to Fig. 1, a scatterplot of >60 species that is NOT
## digitized here per house rules preferring text/table over figure
## digitization): the relationship between functional head size and the
## 60-dB-SPL high-frequency hearing limit is r = -0.79, p < 0.0001, "shown
## to hold for over 60 species ranging in size from mice and bats to
## humans and elephants."

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_2003_ResultsText"
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
final.dataframe <- tibble(
  row = seq_len(nrow(snap)),
  relationship = snap$Relationship,
  correlation_r = as.numeric(snap$`Correlation coefficient (r)`),
  p_value = snap$`p-value`,
  approx_n_species = snap$`Approx. number of species`,
  source_figure = snap$`Source figure`,
  data_role = "primary(review synthesis)",
  source = "this chapter"
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  ## Registry lookup name differs from this file's name (added 2026-09-27): the PDF is the 2008 "High-frequency hearing" chapter (see README), and the registry row is filed under 2008.
  ## Only the lookup uses it; the local files keep this folder's naming.
  registry_item_name <- "Heffner_Heffner_2008_Resultstext"
  nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
  item_encoded <- filecodes$`Item encoded`[match(nfc(registry_item_name), nfc(filecodes$`Item name`))]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", registry_item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

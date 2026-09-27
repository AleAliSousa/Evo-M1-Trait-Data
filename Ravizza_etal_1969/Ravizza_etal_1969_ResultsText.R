## Ravizza_etal_1969_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Ravizza, R. J., Heffner, H. E., & Masterton, B. (1969). Hearing in
## primitive mammals, I: Opossum (Didelphis virginianus). The Journal of
## Auditory Research, 9, 1-7.
## (No DOI was ever assigned to this pre-DOI-era journal; see registry N.B.)
##
## Source is a scanned (OCR'd) PDF. This paper reports its core auditory
## result -- the opossum's measured hearing range, its extrapolated range
## at an 80 dB criterion, and the two subjects' best (lowest-threshold)
## sensitivity values and the between-subject disparity at 32 and 60 kc/s
## -- ONLY as prose in the Results/Discussion sections and as an
## unlabeled audiogram figure (Fig. 2); no table of numeric thresholds
## is printed. Per house rule (prefer Table > Results text > Figure), the
## explicit numeric statements in the Discussion text were transcribed
## rather than digitizing Figure 2. All quoted figures were verified
## against a 150-dpi render of the source PDF page.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Ravizza_etal_1969_ResultsText"
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
final.dataframe <- tibble(
  row_id              = seq_len(nrow(snap)),
  metric              = snap$Metric,
  value               = snap$Value,   # kept as character: one row prints "70 or 80"
  units               = snap$Units,
  individual          = snap$Individual,
  quoted_source_text  = snap$`Quoted source text`
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

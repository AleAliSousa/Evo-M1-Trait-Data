## Ravizza_Masterton_1972_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Ravizza, R. J., & Masterton, B. (1972). Contribution of neocortex to
## sound localization in opossum (Didelphis virginiana). Journal of
## Neurophysiology, 35(3), 344-356. doi:10.1152/jn.1972.35.3.344
##
## NOTE ON SCOPE: this is an ablation/lesion study, not a simple species
## audiogram paper. Its comparative-hearing-relevant datum is the
## MINIMUM AUDIBLE ANGLE (MAA) for horizontal (azimuth) sound-source
## localization in the opossum -- both in normal opossums (a genuine
## species baseline value, comparable to other MAA data in this project)
## and after complete bilateral neocortical ablation (the experimental
## manipulation). These four values (2 groups x 2 performance criteria)
## are explicitly stated as numbers in the Results text and in the Fig. 9
## legend/axis (not read off an uncaptioned curve), so this counts as a
## "Results text" item under the house rule to prefer table/text over
## digitizing a figure. Test I (pure-tone thresholds, Fig. 7) is
## reported only qualitatively ("little effect" of decortication) with
## no printed numbers, so it is not included here.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Ravizza_Masterton_1972_ResultsText"
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
stopifnot(nrow(snap) == 4)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  row_id                 = seq_len(nrow(snap)),
  group                  = snap$Group,                                  # Normal | Decorticate
  performance_criterion  = as.numeric(snap$`Performance criterion`),     # 0.5 or 0.2
  maa_threshold_deg      = as.numeric(snap$`MAA threshold (deg azimuth)`),
  n                      = as.integer(snap$N),
  quoted_source_text     = snap$`Quoted source text`
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

## Kelly_etal_1986_ResultsText.R -- snapshot -> analysis CSV + public TSV
##
## Kelly, J. B., Kavanagh, G. L., & Dalton, J. C. H. (1986). Hearing in the
## ferret (Mustela putorius): Thresholds for pure tone detection. Hearing
## Research, 24(3), 269-275. doi:10.1016/0378-5955(86)90025-0
##
## Source is a born-digital PDF; the paper prints no data table (all
## audiogram values appear only in Figs. 1-2). The 60-dB SPL hearing range
## and the qualitative 8-12 kHz best-sensitivity region are transcribed
## verbatim from the Results text (p. 271) and the Abstract. Because the
## paper does NOT state a single numeric best-threshold/best-frequency value
## for each animal, those two rows were instead carefully read off the
## printed Fig. 2 audiogram (200-dpi page render) and are explicitly flagged
## as approximate/digitized -- consistent with the text's own statement that
## the two ferrets' thresholds diverged by 27 dB at 8 kHz.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kelly_etal_1986_ResultsText"
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
stopifnot(nrow(snap) == 9)

## 3. CLEAN -----------------------------------------------------------
## Collapse the 9-row snapshot into the 7 analysis rows used by the registry
## (the two best_region_* snapshot rows become the low/high bounds of a
## single "best_sensitivity_region" pair; everything else maps 1:1).
final.dataframe <- tibble(
  obs_row     = 1:7,
  binomial    = "Mustela putorius",
  common_name = "Ferret",
  subject = c("mean (97 & 98)", "mean (97 & 98)", "mean (97 & 98)", "mean (97 & 98)",
              "ferret 97", "ferret 98", "ferret 97 vs 98"),
  metric = c("hearing_range_60dB_low", "hearing_range_60dB_high",
             "best_sensitivity_region_low", "best_sensitivity_region_high",
             "best_threshold_approx", "best_threshold_approx",
             "mid_freq_discrepancy_8kHz"),
  frequency_khz = c(0.037, 44, 8, 12, 8, 12, 8),
  value = c(60, 60, NA, NA, -10, -5, 27),
  value_unit = c("dB SPL criterion", "dB SPL criterion",
                 "kHz (qualitative region bound)", "kHz (qualitative region bound)",
                 "dB SPL (approx)", "dB SPL (approx)", "dB (difference)"),
  evidence_type = c(rep("text (Results, p.271)", 4),
                     rep("figure (digitized, Fig. 2)", 2),
                     "text (Discussion, p.272)"),
  data_role = "primary",
  source = "this study"
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

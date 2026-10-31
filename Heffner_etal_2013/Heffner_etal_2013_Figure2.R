## Heffner_etal_2013_Figure2.R -- frozen vector extraction of Figure 2 -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2013). Hearing in American leaf-nosed bats. IV:
## the Common vampire bat, Desmodus rotundus. Hearing Research 296:42-50.
## doi:10.1016/j.heares.2012.09.011
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 2 (p. 45, PDF page 4): mean
## pure-tone audiogram of three D. rotundus (29 points, primary) with the narrowband
## noise thresholds of Gröger & Wiegrebe 2006 (9 points, SECONDARY) for comparison.
## The figure is born-digital vector art, so values were read from the PDF drawing
## commands (polyline vertices) by Heffner_etal_2013_Figure2_extract.py -- no raster digitising.
## Calibration: least squares to 11 labelled x ticks (log10 kHz) and 18 y ticks (dB SPL);
## max residual 0.13 pt (x, ~0.3% in frequency) and 0.11 dB (y). The snapshot is read
## as text and never edited. Checks: the 60-dB SPL crossings of the pure-tone curve
## (log-frequency interpolation) reproduce the text's 716 Hz and 113 kHz, and the
## minimum reproduces "-5 dB at 20 kHz" (p. 45); 4 point values printed in the
## Results (p. 44) are reproduced within 0.6 dB.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2013_Figure2"
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

## UTF-8 output even under Rscript in a C locale (printed labels carry µ, °, −)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", fileEncoding = "UTF-8", na.strings = NULL)
refs <- read.csv(refs_csv, stringsAsFactors = FALSE, colClasses = "character", fileEncoding = "UTF-8")
stopifnot(nrow(snap) == 38L, sum(snap$`Series (label as printed)` == "Pure Tone Thresholds") == 29L)

## 3. CLEAN -------------------------------------------------------------
pt <- snap$`Series (label as printed)` == "Pure Tone Thresholds"
final.dataframe <- tibble(
  series_as_printed = snap$`Series (label as printed)`,
  point = snap$Point,
  species_as_published = "D. rotundus",          # Fig. 2 caption
  species = resolve("D. rotundus"),
  stimulus = ifelse(pt, "pure tone", "narrowband noise (centre frequency)"),
  frequency_kHz = as.numeric(snap$`Frequency (in kHz)`),
  threshold_dB_SPL = as.numeric(snap$`Threshold (in dB SPL)`),
  n_individuals = ifelse(pt, 3L, NA_integer_),
  stat = ifelse(pt, "mean of 3 animals", "as plotted (Gröger and Wiegrebe, 2006)"),
  source_ref_key = ifelse(pt, "Current report", "Gröger and Wiegrebe, 2006"),
  value_origin = "vector_extracted_from_figure",
  data_role = ifelse(pt, "primary", "secondary"))
stopifnot(all(final.dataframe$source_ref_key %in% refs$ref_key))

## 7a. CHECKS against the text (p. 45) ------------------------------------
p <- final.dataframe[pt, ]
cross <- function(i) { a <- p[i, ]; b <- p[i + 1, ]
  10^(log10(a$frequency_kHz) + (60 - a$threshold_dB_SPL) / (b$threshold_dB_SPL - a$threshold_dB_SPL) *
      (log10(b$frequency_kHz) - log10(a$frequency_kHz))) }
i_lo <- which(p$threshold_dB_SPL[-nrow(p)] > 60 & p$threshold_dB_SPL[-1] <= 60)[1]
i_hi <- tail(which(p$threshold_dB_SPL[-nrow(p)] <= 60 & p$threshold_dB_SPL[-1] > 60), 1)
lo <- cross(i_lo); hi <- cross(i_hi)
cat(sprintf("60-dB limits from figure: %.3f kHz (text 0.716) and %.1f kHz (text 113)\n", lo, hi))
stopifnot(abs(lo / 0.716 - 1) < 0.02, abs(hi / 113 - 1) < 0.02)
best <- p[which.min(p$threshold_dB_SPL), ]
stopifnot(abs(best$threshold_dB_SPL - (-5)) < 0.5, abs(best$frequency_kHz / 20 - 1) < 0.02)
## point values printed in the Results (p. 44): 72 dB at 500 Hz, 20 dB at 63 kHz, 1 dB at 71 kHz, 74.5 dB at 116 kHz
txt <- tibble(f = c(0.5, 63, 71, 116), db = c(72, 20, 1, 74.5))
near <- sapply(txt$f, function(f) which.min(abs(log(p$frequency_kHz / f))))
print(data.frame(txt, figure_dB = p$threshold_dB_SPL[near]))
stopifnot(all(abs(p$threshold_dB_SPL[near] - txt$db) < 0.6))

## WRITE CSV + PUBLIC TSV ---------------------------------------------
final.dataframe <- final.dataframe %>% mutate(across(where(is.character), ~replace_na(., "")))
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")

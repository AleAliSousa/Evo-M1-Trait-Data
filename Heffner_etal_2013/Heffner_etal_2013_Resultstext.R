## Heffner_etal_2013_Resultstext.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2013). Hearing in American
## leaf-nosed bats. IV: the Common vampire bat, Desmodus rotundus. Hearing
## Research 296:42-50. doi:10.1016/j.heares.2012.09.011
##
## Row 1 (Desmodus rotundus) -- values transcribed directly from the
## born-digital PDF's Results text (p. 45) and Discussion section 4.3.1
## (p. 47), both visually cross-checked against page renders:
##   - "At an intensity of 60 dB SPL, the hearing of D. rotundus ranges from
##     716 Hz to 113 kHz, a span of 7.3 octaves." (independently verified:
##     log2(113/0.716) = 7.30)
##   - "the average best hearing of three Common vampire bats of 5 dB at
##     20 kHz" (best sensitivity)
##   - "The Common vampire bat, with an interaural distance of only 61 us"
##     (p. 47; the plain-text extraction rendered the mu sign as "ms", but
##     the rendered page image (200 dpi) unambiguously shows "61 us")
##
## FLAG (internal inconsistency in the source, kept as printed): the same
## paper's Discussion (comparing to Inferior Colliculus recordings, p. 45)
## separately states "the behavioral hearing limit of 710 Hz at 60 dB" for
## D. rotundus -- 6 Hz different from the 716 Hz given in the Abstract and
## Results. Both figures are printed in the source; 716 Hz (Abstract +
## Results, the paper's primary summary statement) is used as the recorded
## value here, and the 710 Hz mention is flagged in the README rather than
## silently reconciled.
##
## Row 2 (Phyllostomus hastatus) -- a DERIVED secondary value, included
## because SensoryData_compiled attributes a "hearing_range: Phyllostomus
## hastatus = 5.9 octaves" fact to this paper. No single stated sentence in
## this PDF gives that octave span directly; it is reconstructed here from
## two separate numbers that this same paper DOES state for that species:
##   - low-frequency limit ~1.77 kHz ("the next most sensitive species being
##     the far larger Phyllostomus hastatus that hears only down to about
##     1.77 kHz at 60 dB SPL", p. 46)
##   - high-frequency limit 105.0 kHz (this paper's own Table 1, "Observed
##     high-frequency hearing limit", Phyllostomus hastatus row, originally
##     from Koay et al., 2002)
## octaves = log2(105.0 / 1.77) = 5.89, rounds to 5.9, matching
## SensoryData_compiled's figure. This derivation is shown explicitly rather
## than presented as if the source printed "5.9 octaves" verbatim.
## Functional interaural distance for P. hastatus (108 us) IS directly
## text-stated in this paper's Fig. 4 label (p. 46).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2013_Resultstext"
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
                  colClasses = "character", encoding = "UTF-8", na.strings = "")
stopifnot(nrow(snap) == 2)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  n_individuals = suppressWarnings(as.integer(snap$N)),
  best_sensitivity_dB = suppressWarnings(as.numeric(snap$`Best sensitivity (dB)`)),
  best_frequency_kHz = suppressWarnings(as.numeric(snap$`Best frequency (kHz)`)),
  hearing_range_low_60dBSPL_kHz = as.numeric(snap$`60-dB SPL range low (kHz)`),
  hearing_range_high_60dBSPL_kHz = as.numeric(snap$`60-dB SPL range high (kHz)`),
  hearing_range_octaves = suppressWarnings(as.numeric(gsub(" \\(derived\\)", "", snap$`Hearing range (octaves)`))),
  interaural_distance_functional_us = as.numeric(snap$`Functional interaural distance (us)`),
  data_role = c("primary", "secondary (derived)"),
  source = snap$`Source location`
)

## sanity check: recompute the octave span for row 1 (D. rotundus) and for
## the derived row 2 (P. hastatus) from the low/high limits given
stopifnot(abs(log2(final.dataframe$hearing_range_high_60dBSPL_kHz[1] /
                    final.dataframe$hearing_range_low_60dBSPL_kHz[1]) -
               final.dataframe$hearing_range_octaves[1]) < 0.1)
stopifnot(abs(log2(final.dataframe$hearing_range_high_60dBSPL_kHz[2] /
                    final.dataframe$hearing_range_low_60dBSPL_kHz[2]) -
               final.dataframe$hearing_range_octaves[2]) < 0.05)

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

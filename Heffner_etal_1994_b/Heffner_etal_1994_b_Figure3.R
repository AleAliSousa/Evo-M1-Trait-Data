## Heffner_etal_1994_b_Figure3.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, H. E., Heffner, R. S., Contos, C., & Ott, T. (1994). Audiogram of
## the hooded Norway rat. Hearing Research 73:244-247.
## doi:10.1016/0378-5955(94)90240-2
##
## FLAG (naming): SensoryData_compiled.csv labels this paper "Heffner et al
## 1994c" while SensoryData_compiled_references.csv and this registry treat
## it as "Heffner_etal_1994_b" -- the a/b/c letters appear to be swapped
## between the two SensoryData files for the 1994 short communications. Not
## resolved here per house instructions; documented for a future pass.
##
## FLAG (figure content): the registry's original draft description for this
## item read "Average audiograms of the hooded rat (this study), albino rat
## and wild Norway rat" -- but the actual Fig. 3 in this PDF (p. 247) is
## captioned "Average audiograms of the hooded rat (H, this study), albino
## rat (A, Kelly and Masterton, 1977), cotton rat, Sigmodon hispidus (C,
## Heffner and Masterton, 1980), and wood rat, Neotoma floridana (W, Heffner
## and Heffner, 1985a)." There is no "wild Norway rat" curve anywhere in this
## paper (a citation to Heffner and Heffner's 1985b wild-Norway-rat
## localization paper appears only in the reference list, unrelated to Fig.
## 3). The registry M-column description was corrected to match the PDF;
## flagged here rather than silently carried forward.
##
## Only the hooded (this study) and albino (cited) curves have quantified
## threshold values stated in the Results-and-discussion text; the cotton rat
## and wood rat curves in Fig. 3 are shown only for qualitative visual
## comparison with no accompanying numeric values in text, and were not
## digitized (house rule: prefer text over digitizing a figure; values not
## in text were left blank rather than invented).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_1994_b_Figure3"
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
                  na.strings = "NA", encoding = "UTF-8")
stopifnot(nrow(snap) == 4)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  binomial    = snap$Species,
  common_name = snap$`Common name`,
  figure_key  = snap$`Figure key`,
  n_individuals = suppressWarnings(as.integer(snap$N)),
  best_hearing_point1_kHz = suppressWarnings(as.numeric(snap$`Best hearing point 1 (kHz)`)),
  best_hearing_point2_kHz_range = snap$`Best hearing point 2 (kHz range)`,
  hearing_range_low_60dBSPL_Hz = suppressWarnings(as.numeric(snap$`60-dB SPL range low (Hz)`)),
  hearing_range_high_60dBSPL_kHz = suppressWarnings(as.numeric(gsub(" \\(estimated\\)", "", snap$`60-dB SPL range high (kHz)`))),
  quantified_in_text = grepl("^Yes", snap$`Quantified in text`),
  data_role = ifelse(snap$`Data role` == "this study", "primary", "secondary"),
  source = snap$Source
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

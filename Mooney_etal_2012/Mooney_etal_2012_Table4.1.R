## Mooney_etal_2012_Table4.1.R -- snapshot -> analysis CSV + public TSV
##
## Mooney, T. A., Yamato, M., & Branstetter, B. K. (2012). Hearing in
## Cetaceans: From Natural History to Experimental Biology. Advances in
## Marine Biology 63:197-246. doi:10.1016/B978-0-12-394282-1.00004-1
##
## Source is a born-digital PDF; Table 4.1 (31 rows across 18 species) was
## transcribed directly, cross-checked word-for-word against the extracted
## text layer.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Mooney_etal_2012_Table4.1"
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
stopifnot(nrow(snap) == 31)

binomial_map <- c(
  "T. truncatus" = "Tursiops truncatus", "P. phocoena" = "Phocoena phocoena",
  "O. orca" = "Orcinus orca", "I. geoffrensis" = "Inia geoffrensis",
  "D. leucas" = "Delphinapterus leucas", "T. truncatus gilli" = "Tursiops truncatus gilli",
  "P. crassidens" = "Pseudorca crassidens", "L. vexillifer" = "Lipotes vexillifer",
  "G. griseus" = "Grampus griseus", "S. fluviatilis guianensis" = "Sotalia fluviatilis guianensis",
  "S. coeruleoalba" = "Stenella coeruleoalba", "N. phocaenoides" = "Neophocaena phocaenoides",
  "M. europaeus" = "Mesoplodon europaeus", "L. albirostris" = "Lagenorhynchus albirostris",
  "G. melas" = "Globicephala melas", "S. bredanensis" = "Steno bredanensis",
  "M. densirostris" = "Mesoplodon densirostris", "F. attenuata" = "Feresa attenuata"
)
common_map <- c(
  "T. truncatus" = "Bottlenose dolphin", "P. phocoena" = "Harbour porpoise",
  "O. orca" = "Killer whale", "I. geoffrensis" = "Amazon river dolphin",
  "D. leucas" = "Beluga whale", "T. truncatus gilli" = "Pacific bottlenose dolphin",
  "P. crassidens" = "False killer whale", "L. vexillifer" = "Chinese river dolphin (baiji)",
  "G. griseus" = "Risso's dolphin", "S. fluviatilis guianensis" = "Tucuxi",
  "S. coeruleoalba" = "Striped dolphin", "N. phocaenoides" = "Finless porpoise",
  "M. europaeus" = "Gervais' beaked whale", "L. albirostris" = "White-beaked dolphin",
  "G. melas" = "Long-finned pilot whale", "S. bredanensis" = "Rough-toothed dolphin",
  "M. densirostris" = "Blainville's beaked whale", "F. attenuata" = "Pygmy killer whale"
)
footnote_map <- c(
  "a" = "Greatly varied depending on sex and age",
  "b" = "Same animal tested as preceding study",
  "c" = "Did not establish upper limit",
  "unclear" = "Best-sensitivity range not established (printed as 'Unclear' in source)"
)

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(x))
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  common_name = unname(common_map[snap$Species]),
  binomial    = unname(binomial_map[snap$Species]),
  n           = as.integer(snap$n),
  hearing_range_low_kHz  = num(snap$`Hearing range low (kHz)`),
  hearing_range_high_kHz = num(snap$`Hearing range high (kHz)`),
  best_sensitivity_low_kHz  = num(snap$`Best sensitivity low (kHz)`),
  best_sensitivity_high_kHz = num(snap$`Best sensitivity high (kHz)`),
  footnote = snap$Footnote,
  footnote_text = unname(footnote_map[snap$Footnote]),
  method = snap$Method,
  reference = snap$Reference,
  data_role = "secondary"
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

## Schusterman__1981_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Schusterman, R. J. (1981). Behavioral capabilities of seals and sea
## lions: A review of their hearing, visual, learning and diving skills.
## The Psychological Record, 31, 125-143. doi:10.1007/BF03394729
##
## N.B. -- THIS SOURCE IS A REVIEW/COMPILATION, NOT A PRIMARY DATA PAPER.
## Table 1 ("A Summary of Major Features of Underwater Audiograms
## (including Critical Ratios) of Pinnipeds", p. 128) is itself a
## secondary compilation: each row's audiogram summary is drawn from a
## previously published primary study, explicitly cited in the table's
## own "Source" column:
##   - California sea lion  <- Schusterman, Balliet, & Nixon (1972)
##   - Northern fur seal    <- Schusterman & Moore (1978b)
##   - Harbor seal          <- Moehl (1968)  [also built in this project
##                              as Mohl__1968_Table2, though that item
##                              captures the full air+water threshold
##                              table rather than this review's single
##                              best-range/high-cutoff summary]
##   - Harp seal            <- Terhune & Ronald (1972)
##   - Ringed seal           <- Terhune & Ronald (1975a)
##   - Gray seal (evoked-potential audiogram, not behavioral) <- Ridgway (1973)
## This item is built anyway (rather than skipped) because it is the only
## place in this project's source PDFs where these six species' key
## audiogram features (best-sensitivity range, dB, and high-frequency
## cutoff) are tabulated side-by-side for direct cross-species comparison
## -- exactly the kind of comparative summary this registry curates.
##
## Source PDF is a born-digital/clean scan; Table 1 was transcribed
## directly and cross-checked against a 200-dpi page render (p. 128).
## The paper's Table 2 (aerial audiograms), Table 3 (frequency
## discrimination) and Table 4 (localization/MAA) are NOT part of this
## item; only Table 1 (underwater audiograms) was selected as the single
## new registry row per house rule ("build only the priority item").

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Schusterman__1981_Table1"
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
stopifnot(nrow(snap) == 6)

## 3. CLEAN -----------------------------------------------------------
binomial_lut <- c(
  "California sea lion" = "Zalophus californianus",
  "Northern fur seal"   = "Callorhinus ursinus",
  "Harbor seal"         = "Phoca vitulina",
  "Harp seal"           = "Pagophilus groenlandicus",
  "Ringed seal"         = "Pusa hispida",
  "Gray seal"           = "Halichoerus grypus"
)

split_to <- function(x) {
  m <- regmatches(x, regexec("^(-?[0-9.]+)\\s*to\\s*(-?[0-9.]+)$", x))
  lo <- sapply(m, function(e) if (length(e) == 3) e[2] else NA_character_)
  hi <- sapply(m, function(e) if (length(e) == 3) e[3] else NA_character_)
  list(lo = as.numeric(lo), hi = as.numeric(hi))
}

freq_rng   <- split_to(snap$`Best Range of Sound Detection Thresholds (kHz)`)
db_rng     <- split_to(snap$`Best Range of Sound Detection Thresholds (dB re 1 uBar)`)
cutoff_rng <- split_to(snap$`Approximate High-Frequency Cut-Off (kHz)`)

final.dataframe <- tibble(
  row_id                        = seq_len(nrow(snap)),
  group                         = snap$Group,
  common_name                   = snap$Species,
  binomial                      = binomial_lut[snap$Species],
  n_subjects                    = as.integer(snap$`Number of Subjects Tested`),
  best_range_freq_low_kHz       = freq_rng$lo,
  best_range_freq_high_kHz      = freq_rng$hi,
  best_range_threshold_low_dB   = db_rng$lo,
  best_range_threshold_high_dB  = db_rng$hi,
  high_freq_cutoff_low_kHz      = cutoff_rng$lo,
  high_freq_cutoff_high_kHz     = cutoff_rng$hi,
  primary_source_cited          = snap$Source,
  notes                         = snap$Notes
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

## Owren_etal_1988_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Owren, M. J., Hopp, S. L., Sinnott, J. M., & Petersen, M. R. (1988).
## Absolute auditory thresholds in three Old World monkey species
## (Cercopithecus aethiops, C. neglectus, Macaca fuscata) and humans (Homo
## sapiens). Journal of Comparative Psychology, 102(2), 99-107.
## doi:10.1037/0735-7036.102.2.99
##
## Source is a born-digital PDF with a clean, directly extractable text
## layer; Table 1 (p. 102, frequencies up to 32.0 kHz, all 4 subject
## groups) and Table 3 (p. 103, frequencies above 32.0 kHz, monkey
## subjects only) were transcribed directly and cross-checked against a
## 200-dpi page render, because both tables report the SAME experiment's
## audiogram (Table 3 is simply the high-frequency extension of Table 1
## for the 3 monkey species, after humans and one macaque/de Brazza's
## individual dropped out of responding), so they are combined here into
## one tidy long-format dataset rather than built as two separate
## registry items.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Owren_etal_1988_Table1"
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
stopifnot(nrow(snap) == 94)

## 3. CLEAN -----------------------------------------------------------
common_name_lut <- c(
  "Cercopithecus aethiops"  = "Vervet monkey",
  "Cercopithecus neglectus" = "de Brazza's monkey",
  "Macaca fuscata"          = "Japanese macaque",
  "Homo sapiens"            = "Human"
)

## Ranges are printed like "57-67" or, for negative bounds, "-6--2" / "-5-8".
## Split on the first "-" that is not the leading sign of the range itself.
split_range <- function(x) {
  lo <- hi <- rep(NA_real_, length(x))
  for (i in seq_along(x)) {
    v <- x[i]
    if (is.na(v) || !nzchar(v)) next
    if (grepl("--", v, fixed = TRUE)) {
      parts <- strsplit(v, "--", fixed = TRUE)[[1]]
      lo[i] <- as.numeric(parts[1])
      hi[i] <- -as.numeric(parts[2])
    } else {
      # find first '-' at position > 1
      chars <- strsplit(v, "")[[1]]
      idx <- which(chars == "-")
      idx <- idx[idx > 1][1]
      if (!is.na(idx)) {
        lo[i] <- as.numeric(substr(v, 1, idx - 1))
        hi[i] <- as.numeric(substr(v, idx + 1, nchar(v)))
      }
    }
  }
  list(lo = lo, hi = hi)
}
rng <- split_range(snap$`Range (dB)`)

final.dataframe <- tibble(
  row_id                 = seq_len(nrow(snap)),
  table_source           = snap$Table,
  frequency_kHz          = as.numeric(snap$`Frequency (kHz)`),
  binomial               = snap$Species,
  common_name            = common_name_lut[snap$Species],
  n                      = as.integer(snap$n),
  mean_threshold_dB_SPL  = snap$`M (dB)`,      # kept as character: 2 rows print ">72"
  sd_dB                  = as.numeric(snap$`SD (dB)`),
  range_dB_as_printed    = snap$`Range (dB)`,
  range_low_dB           = rng$lo,
  range_high_dB          = rng$hi,
  note                   = snap$`Range note`
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  ## Registry lookup name differs from this file's name (added 2026-09-27): the registry row covers the printed Table 1 and Table 3 together ("Table 1 + Table 3").
  ## Only the lookup uses it; the local files keep this folder's naming.
  registry_item_name <- "Owren_etal_1988_Table1+Table3"
  nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
  item_encoded <- filecodes$`Item encoded`[match(nfc(registry_item_name), nfc(filecodes$`Item name`))]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", registry_item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

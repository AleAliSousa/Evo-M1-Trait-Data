## Thomas_etal_1988_TableI.R -- snapshot -> analysis CSV + public TSV
##
## Thomas, J., Chun, N., Au, W., & Pugh, K. (1988). Underwater audiogram of
## a false killer whale (Pseudorca crassidens). Journal of the Acoustical
## Society of America, 84(3), 936-940. doi:10.1121/1.396662
##
## Source is a born-digital PDF (JASA); Table I (printed p. 939) was
## transcribed from the extracted text layer and cross-checked against a
## 200 dpi render of the table's page, since some digits in the OCR/text
## extraction were visually ambiguous (e.g. "8O"/"3O" for "80"/"30"). All
## values match the rendered page image exactly.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Thomas_etal_1988_TableI"
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
                  colClasses = "character", encoding = "UTF-8", skip = 1)
stopifnot(nrow(snap) == 10)

## 3. CLEAN -----------------------------------------------------------
## Parse "99 (95-101)" style cells into overall threshold + session range;
## reshape the two transducer columns (J9, WAU) into long format, dropping
## the transducer not used at a given frequency.
parse_cell <- function(x) {
  x <- trimws(x)
  if (!nzchar(x)) return(c(NA_real_, NA_real_, NA_real_))
  m <- regmatches(x, regexec("^(-?[0-9.]+) \\(([-0-9.]+)-([-0-9.]+)\\)$", x))[[1]]
  if (length(m) != 4) stop("Unparseable cell: ", x)
  as.numeric(m[2:4])
}

long_rows <- list()
k <- 0
for (i in seq_len(nrow(snap))) {
  freq <- as.numeric(snap$`Test frequency (kHz)`[i])
  nrev <- as.numeric(snap$`Number of reversals tested`[i])
  j9  <- parse_cell(snap$`Overall threshold J9 transducer (dB re 1 µPa; range of session means)`[i])
  wau <- parse_cell(snap$`Overall threshold WAU transducer (dB re 1 µPa; range of session means)`[i])
  if (!is.na(j9[1])) {
    k <- k + 1
    long_rows[[k]] <- tibble(determination_row = k, frequency_khz = freq,
                              transducer = "J9", n_reversals_tested = nrev,
                              threshold_db_re_1upa = j9[1],
                              session_range_low_db = j9[2], session_range_high_db = j9[3])
  }
  if (!is.na(wau[1])) {
    k <- k + 1
    long_rows[[k]] <- tibble(determination_row = k, frequency_khz = freq,
                              transducer = "WAU", n_reversals_tested = nrev,
                              threshold_db_re_1upa = wau[1],
                              session_range_low_db = wau[2], session_range_high_db = wau[3])
  }
}

final.dataframe <- bind_rows(long_rows) %>%
  mutate(subject_species = "Pseudorca crassidens (false killer whale)",
         data_role = "primary", source = "this study")

## Sanity check: text states range of greatest sensitivity (10 dB from
## maximum) was 16-64 kHz, with maximum sensitivity at 64 kHz.
stopifnot(final.dataframe$frequency_khz[which.min(final.dataframe$threshold_db_re_1upa)] == 64)
stopifnot(min(final.dataframe$threshold_db_re_1upa) == 39)

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

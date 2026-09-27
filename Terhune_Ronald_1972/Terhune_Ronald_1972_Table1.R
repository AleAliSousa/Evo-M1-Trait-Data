## Terhune_Ronald_1972_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Terhune, J. M., & Ronald, K. (1972). The harp seal, Pagophilus
## groenlandicus (Erxleben, 1777). III. The underwater audiogram. Canadian
## Journal of Zoology, 50(5), 565-569. doi:10.1139/z72-077
##
## Source is a scanned/OCR'd photocopy (NRC Research Press reprint); the
## extracted text layer for Table 1 was garbled/incomplete (columnar OCR
## errors, e.g. "d/pbar" for "db/µbar"). Table 1 (21 determinations, printed
## p. 566) was therefore transcribed by hand from a 200 dpi render of PDF
## page 2 and cross-checked digit-by-digit against the rendered image before
## writing the snapshot.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Terhune_Ronald_1972_Table1"
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
## skip the title line and the trailing footnote line
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                  colClasses = "character", encoding = "UTF-8",
                  skip = 1, nrows = 21)
stopifnot(nrow(snap) == 21)

## 3. CLEAN -----------------------------------------------------------
## Two ambient-noise cells are printed with a "less-than" sign (<-77, <-78);
## strip the "<" for the numeric column and keep the printed sign in a flag.
amb_raw <- snap$`Ambient noise level* (db/µbar)`
amb_lt  <- grepl("^<", amb_raw)
amb_num <- suppressWarnings(as.numeric(sub("^<", "", amb_raw)))

final.dataframe <- tibble(
  determination_row = seq_len(nrow(snap)),
  frequency_khz = as.numeric(snap$`Frequency (kHz)`),
  threshold_db_re_1ubar = as.numeric(snap$`Threshold (db/µbar)`),
  sd_db = as.numeric(snap$`Standard deviation (db)`),
  ambient_noise_db_re_1ubar_spectrum_level = amb_num,
  ambient_noise_is_upper_bound = amb_lt,
  catch_trials_pct_correct = as.numeric(snap$`Catch trials (% correct)`),
  test_date = as.character(as.Date(snap$Date, format = "%m-%d-%y")),
  subject = "single 4-yr-old immature female (P. groenlandicus)",
  data_role = "primary",
  source = "this study"
)

## Sanity check: printed Discussion text states max sensitivity of
## -32.9 db/pbar at 15.0 kHz -- this frequency was NOT one of the tested
## points (nearest tested points are 11.3 and 16.0 kHz) and does not match
## any raw Table 1 threshold. The lowest *printed table* value is actually
## -37 db/pbar at 22.9 kHz (12-28-70 determination). This is presumed to be
## a value read from the fitted/interpolated audiogram curve in Fig. 2
## rather than a raw Table 1 entry -- kept as printed, not corrected; see
## N.B. in the registry and the README.
stopifnot(min(final.dataframe$threshold_db_re_1ubar) == -37)

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

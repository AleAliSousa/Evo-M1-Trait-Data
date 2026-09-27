## Yuen_etal_2005_TableI.R -- snapshot -> analysis CSV + public TSV
##
## Yuen, M. M. L., Nachtigall, P. E., Breese, M., & Supin, A. Ya. (2005).
## Behavioral and auditory evoked potential audiograms of a false killer
## whale (Pseudorca crassidens). Journal of the Acoustical Society of
## America, 118(4), 2688-2695. doi:10.1121/1.2010350
##
## Source is a born-digital, clean-text-layer PDF (JASA); Table I (printed
## p. 2691) was transcribed directly from the extracted text, which matched
## the paper's own Results-text summary statistics exactly (no OCR
## artifacts observed, so no image re-render was needed).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Yuen_etal_2005_TableI"
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
stopifnot(nrow(snap) == 16)

## 3. CLEAN -----------------------------------------------------------
## Reshape wide (2001/2004 columns, with many 2001 cells blank because only
## 5 of the 16 frequencies were tested in that preliminary year) into long
## format, one row per year x frequency actually measured.
wide <- tibble(
  frequency_khz = as.numeric(snap$`Frequency (kHz)`),
  thr_2001 = suppressWarnings(as.numeric(snap$`Threshold 2001 (dB re 1 µPa)`)),
  thr_2004 = suppressWarnings(as.numeric(snap$`Threshold 2004 (dB re 1 µPa)`))
)

long_2001 <- wide %>% filter(!is.na(thr_2001)) %>%
  transmute(frequency_khz, audiogram_year = 2001L, threshold_db_re_1upa = thr_2001)
long_2004 <- wide %>% filter(!is.na(thr_2004)) %>%
  transmute(frequency_khz, audiogram_year = 2004L, threshold_db_re_1upa = thr_2004)

final.dataframe <- bind_rows(long_2001, long_2004) %>%
  arrange(frequency_khz, audiogram_year) %>%
  mutate(determination_row = row_number(), .before = 1) %>%
  mutate(subject_species = "Pseudorca crassidens (false killer whale)",
         data_role = "primary", source = "this study")

## Sanity check: Results text states region of best sensitivity 16-24 kHz,
## lowest threshold of 69 dB at 20 kHz (2004 behavioral audiogram).
stopifnot(min(final.dataframe$threshold_db_re_1upa) == 69.5)
stopifnot(final.dataframe$frequency_khz[which.min(final.dataframe$threshold_db_re_1upa)] == 20)

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

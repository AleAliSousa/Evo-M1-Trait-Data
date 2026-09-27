## Kastelein_etal_2010_b_TableI.R -- snapshot -> analysis CSV + public TSV
##
## Kastelein, R. A., Hoek, L., de Jong, C. A. F., & Wensveen, P. J. (2010).
## The effect of signal duration on the underwater detection thresholds of a
## harbor porpoise (Phocoena phocoena) for single frequency-modulated tonal
## signals between 0.25 and 160 kHz. Journal of the Acoustical Society of
## America, 128(5), 3211-3222. doi:10.1121/1.3493435
##
## Source is a born-digital PDF; Table I (p. 3214) was transcribed directly
## and cross-checked against a 200-dpi page render. The table has many blank
## (untested) frequency x duration combinations, printed as "..." -- these
## are kept as missing (row simply omitted), never interpolated/fabricated.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kastelein_etal_2010_b_TableI"
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
stopifnot(nrow(snap) == 19)  # 19 center frequencies (0.25-180 kHz)

## 3. RESHAPE (wide printed layout -> long tidy rows) -----------------
## The snapshot has one column per signal duration (plus the Kastelein et al.
## 2002 corrected 1700-ms comparison column) and one row per frequency, i.e.
## exactly as printed. Melt to long format, dropping untested (blank) cells.
duration_cols <- setdiff(names(snap), c("Center frequency (kHz)",
                                         "Kastelein et al. 2002 corrected (1700 ms)"))

long_present <- snap %>%
  select(`Center frequency (kHz)`, all_of(duration_cols)) %>%
  pivot_longer(cols = all_of(duration_cols), names_to = "duration_label",
               values_to = "threshold_db_re_1uPa") %>%
  filter(threshold_db_re_1uPa != "") %>%
  mutate(
    center_frequency_khz = as.numeric(`Center frequency (kHz)`),
    signal_duration_ms   = as.numeric(sub(" ms$", "", duration_label)),
    threshold_db_re_1uPa = as.numeric(threshold_db_re_1uPa),
    source_study = "present study",
    data_role = "primary"
  ) %>%
  select(center_frequency_khz, signal_duration_ms, threshold_db_re_1uPa, source_study, data_role)

long_k2002 <- snap %>%
  filter(`Kastelein et al. 2002 corrected (1700 ms)` != "") %>%
  transmute(
    center_frequency_khz = as.numeric(`Center frequency (kHz)`),
    signal_duration_ms = 1700,
    threshold_db_re_1uPa = as.numeric(`Kastelein et al. 2002 corrected (1700 ms)`),
    source_study = "Kastelein et al. 2002 (corrected)",
    data_role = "secondary"
  )

final.dataframe <- bind_rows(long_k2002, long_present) %>%
  arrange(center_frequency_khz, signal_duration_ms) %>%
  mutate(
    obs_row = row_number(),
    binomial = "Phocoena phocoena",
    common_name = "Harbor porpoise"
  ) %>%
  select(obs_row, binomial, common_name, center_frequency_khz, signal_duration_ms,
         threshold_db_re_1uPa, source_study, data_role)

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

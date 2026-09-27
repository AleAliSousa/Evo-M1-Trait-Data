## Awbrey_etal_1988_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Awbrey, F. T., Thomas, J. A., & Kastelein, R. A. (1988). Low-frequency
## underwater hearing sensitivity in belugas, Delphinapterus leucas.
## Journal of the Acoustical Society of America, 84(6), 2273-2275.
## doi:10.1121/1.397022
##
## Source is a born-digital PDF (hybrid text layer); Table I (7 tested
## octave frequencies x 3 subjects + combined mean, on printed p. 2274) was
## transcribed directly from the extracted text layer, then cross-checked
## digit-by-digit against a 150-dpi render of the same page before
## finalizing (the raw text-layer extraction misread the "1" in the
## Combined-row 2-kHz mean of 101 as "10!"; the rendered page image
## confirmed the correct printed value is 101).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Awbrey_etal_1988_Table1"
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
## The snapshot preserves the printed layout: title line, blank line, header
## row, then 4 subjects (Adult male / Adult female / Juvenile male /
## Combined) x 4 statistic rows (Mean / Range / N / FA) each, one column
## per tested frequency (125 Hz-8 kHz) plus a Catch column (N, FA totals).
snap <- read.csv(snapshot_csv, skip = 2, stringsAsFactors = FALSE,
                  check.names = FALSE, colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 16)  # 4 subjects x 4 statistic rows

freq_cols <- c("125 Hz", "250 Hz", "500 Hz", "1 kHz", "2 kHz", "4 kHz", "8 kHz")
freq_hz   <- c(125, 250, 500, 1000, 2000, 4000, 8000)
freq_khz  <- freq_hz / 1000

## 3. RESHAPE ---------------------------------------------------------
subjects <- c("Adult male" = "adult_male", "Adult female" = "adult_female",
              "Juvenile male" = "juvenile_male", "Combined" = "combined")
row_type_for <- function(s) if (s == "combined") "group_mean" else "individual"

build_subject <- function(subj_label, subj_id) {
  sub_rows <- snap %>% filter(Subject == subj_label)
  mean_row  <- sub_rows %>% filter(Statistic == "Mean")
  range_row <- sub_rows %>% filter(Statistic == "Range")
  n_row     <- sub_rows %>% filter(Statistic == "N")
  fa_row    <- sub_rows %>% filter(Statistic == "FA")
  catch_n   <- as.integer(n_row$Catch)
  catch_fa  <- as.integer(fa_row$Catch)
  tibble(
    species_sci = "Delphinapterus leucas", common_name = "beluga",
    subject_id = subj_id, row_type = row_type_for(subj_id),
    frequency_hz = freq_hz, frequency_khz = freq_khz,
    threshold_mean_db_re_1uPa = as.numeric(unlist(mean_row[freq_cols])),
    threshold_range_low_db  = as.numeric(str_split_fixed(unlist(range_row[freq_cols]), "-", 2)[, 1]),
    threshold_range_high_db = as.numeric(str_split_fixed(unlist(range_row[freq_cols]), "-", 2)[, 2]),
    n_ascending_series = as.integer(unlist(n_row[freq_cols])),
    catch_series_n = catch_n, catch_false_alarms = catch_fa,
    source = "Awbrey et al. (1988) Table I"
  )
}

result <- map2_dfr(names(subjects), unname(subjects), build_subject)
stopifnot(nrow(result) == 28)

## 4. CHECKS ----------------------------------------------------------
## Combined mean at each frequency should fall within (usually near the
## midpoint of) the three individual subjects' means -- sanity check only,
## printed values are kept as-is regardless.
indiv <- result %>% filter(row_type == "individual")
combined <- result %>% filter(row_type == "group_mean")
chk <- indiv %>% group_by(frequency_hz) %>%
  summarise(lo = min(threshold_mean_db_re_1uPa), hi = max(threshold_mean_db_re_1uPa), .groups = "drop") %>%
  left_join(combined %>% select(frequency_hz, threshold_mean_db_re_1uPa), by = "frequency_hz")
stopifnot(all(chk$threshold_mean_db_re_1uPa >= chk$lo & chk$threshold_mean_db_re_1uPa <= chk$hi))

## 5. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(result, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(result, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

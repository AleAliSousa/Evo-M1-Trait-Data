## Heffner_etal_2016_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, H. E., Koay, G., & Heffner, R. S. (2016). Budgerigars
## (Melopsittacus undulatus) do not hear infrasound: the audiogram from 8 Hz
## to 10 kHz. Journal of Comparative Physiology A 202:853-857.
## doi:10.1007/s00359-016-1125-9
##
## Source is a born-digital PDF; Table 1 (14 frequencies x 3 individuals +
## mean) was transcribed directly from the printed table (p. 856),
## cross-checked word-for-word against the extracted text layer. Each
## printed mean was independently recomputed in Python from the three
## individual values and reproduces exactly (see README); none were
## altered.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2016_Table1"
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
stopifnot(nrow(snap) == 14)

## 3. RESHAPE TO LONG FORMAT (one row per frequency x individual, plus mean) --
long <- snap %>%
  mutate(`Frequency (Hz)` = as.numeric(`Frequency (Hz)`)) %>%
  pivot_longer(cols = c(`P1 (female)`, `P2 (male)`, `P3 (female)`, `Mean`),
               names_to = "individual_raw", values_to = "threshold_dB_SPL") %>%
  mutate(
    threshold_dB_SPL = as.numeric(threshold_dB_SPL),
    individual_id = case_when(
      individual_raw == "P1 (female)" ~ "P1",
      individual_raw == "P2 (male)"   ~ "P2",
      individual_raw == "P3 (female)" ~ "P3",
      individual_raw == "Mean"        ~ "mean"
    ),
    sex = case_when(
      individual_raw == "P1 (female)" ~ "female",
      individual_raw == "P2 (male)"   ~ "male",
      individual_raw == "P3 (female)" ~ "female",
      individual_raw == "Mean"        ~ NA_character_
    )
  ) %>%
  arrange(`Frequency (Hz)`, match(individual_id, c("P1","P2","P3","mean")))

final.dataframe <- tibble(
  row = seq_len(nrow(long)),
  frequency_Hz = long$`Frequency (Hz)`,
  individual_id = long$individual_id,
  sex = long$sex,
  threshold_dB_SPL = long$threshold_dB_SPL
)

## Sanity check: recompute each frequency's mean from P1/P2/P3 and confirm
## it reproduces the printed Mean column (within rounding).
chk <- snap %>%
  mutate(across(-`Frequency (Hz)`, as.numeric)) %>%
  mutate(recomputed_mean = round((`P1 (female)` + `P2 (male)` + `P3 (female)`) / 3, 1))
stopifnot(all(abs(chk$recomputed_mean - chk$Mean) < 0.15))

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

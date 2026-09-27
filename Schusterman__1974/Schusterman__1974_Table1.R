## Schusterman__1974_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Schusterman, R. J. (1974). Auditory sensitivity of a California sea
## lion to airborne sound. Journal of the Acoustical Society of America,
## 56(4), 1248-1251. doi:10.1121/1.1903415
##
## Source is a born-digital PDF with a clean, directly extractable text
## layer; Table I (p. 1250) was transcribed directly and cross-checked
## against a 200-dpi page render. The table reports "hearing loss (in dB)"
## -- the difference between each species' airborne and underwater
## auditory thresholds at each frequency -- for three pinniped species,
## drawing on Schusterman's own new Zalophus data plus previously
## published Pagophilus (Terhune & Ronald, 1972) and Phoca v. (Moehl,
## 1968) data; this is the paper's central comparative table (supporting
## its headline conclusion that the otariid Zalophus ear, like phocid
## ears, is water-adapted). Cells printed as "..." in the source (not
## tested / not reported at that frequency for that species) are kept as
## missing values, flagged `not_tested_or_not_reported`.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Schusterman__1974_Table1"
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
stopifnot(nrow(snap) == 10)

## 3. CLEAN -----------------------------------------------------------
species_meta <- tibble(
  species_label = c("Zalophus", "Pagophilus", "Phoca v."),
  binomial       = c("Zalophus californianus", "Pagophilus groenlandicus", "Phoca vitulina"),
  common_name    = c("California sea lion", "Harp seal", "Harbor (common) seal"),
  family         = c("Otariidae", "Phocidae", "Phocidae")
)

long <- snap %>%
  pivot_longer(cols = c("Zalophus", "Pagophilus", "Phoca v."),
               names_to = "species_label", values_to = "raw_value") %>%
  left_join(species_meta, by = "species_label") %>%
  mutate(
    flag = ifelse(raw_value == "...", "not_tested_or_not_reported", ""),
    hearing_loss_air_vs_water_dB = ifelse(raw_value == "...", NA_real_, as.numeric(raw_value)),
    frequency_kHz = as.numeric(`Frequency (kHz)`)
  ) %>%
  arrange(frequency_kHz, species_label) %>%
  mutate(row_id = row_number()) %>%
  select(row_id, frequency_kHz, species_label, binomial, common_name, family,
         hearing_loss_air_vs_water_dB, flag)

final.dataframe <- long

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  ## Registry lookup name differs from this file's name (added 2026-09-27): the registry keeps the printed Roman numeral ("Table I"), so its Item name is Schusterman__1974_TableI.
  ## Only the lookup uses it; the local files keep this folder's naming.
  registry_item_name <- "Schusterman__1974_TableI"
  nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
  item_encoded <- filecodes$`Item encoded`[match(nfc(registry_item_name), nfc(filecodes$`Item name`))]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", registry_item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

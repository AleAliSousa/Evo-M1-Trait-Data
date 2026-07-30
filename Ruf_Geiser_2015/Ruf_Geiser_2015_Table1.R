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
folder <- paper_dir <- dirname(.sp)
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))
base <- dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
public_tsv_dir<- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx   <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(stringr)
library(readxl)

## 2. LOAD SNAPSHOT -------------------------------------------------
# Ruf & Geiser (2015) Table 1: torpor characteristics in birds and mammals.
# 213 species extracted from the printed Table 1 across pages 894-905.
# Column key (from paper's caption):
#   T       = torpor type ('DT' = daily torpor, 'HIB' = hibernation)
#   BM      = body mass (kg)
#   Tb min  = minimum torpor body temperature (°C)
#   TMRmin  = minimum torpor metabolic rate (ml O2 / g / h)
#   TMRrel  = TMRmin as % of basal metabolic rate
#   TBDmax  = maximum torpor bout duration (h for daily; h for hibernation)
#   TBDmean = mean torpor bout duration (units as printed)
#   IBE     = interbout euthermia duration (h)
#   LAT     = latitude of study site (° N positive, S negative)
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
# The em-dash '—' is used throughout the printed table for "not reported".
# Convert to NA in the numeric columns.
to_num <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("−", "-", x, fixed = TRUE)          # Unicode minus -> ASCII
  x[x %in% c("", "—", "-", "NA")] <- NA
  suppressWarnings(as.numeric(x))
}

final.dataframe <- df_snapshot %>%
  rename(
    class          = Class,
    order          = Order,
    taxon          = Taxon,
    torpor_type    = T,
    body_mass_kg   = BM,
    tb_min_c       = `Tb min`,
    tmr_min        = TMRmin,
    tmr_rel_pct    = TMRrel,
    tbd_max_h      = TBDmax,
    tbd_mean_h     = TBDmean,
    ibe_h          = IBE,
    latitude_deg   = LAT,
    references     = References
  ) %>%
  mutate(
    class         = trimws(class),
    order         = trimws(order),
    taxon         = trimws(taxon),
    torpor_type   = trimws(torpor_type),
    body_mass_kg  = to_num(body_mass_kg),
    tb_min_c      = to_num(tb_min_c),
    tmr_min       = to_num(tmr_min),
    tmr_rel_pct   = to_num(tmr_rel_pct),
    tbd_max_h     = to_num(tbd_max_h),
    tbd_mean_h    = to_num(tbd_mean_h),
    ibe_h         = to_num(ibe_h),
    latitude_deg  = to_num(latitude_deg),
    references    = trimws(references)
  )

## 4. SAVE OUTPUTS -------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, final_csv, row.names = FALSE)

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' found in __ReadMe.xlsx for Item name: ", table_name,
            " -- add a row to __ReadMe.xlsx before final submission.")
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(
      final.dataframe,
      file      = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
      sep       = "\t",
      row.names = FALSE
    )
  }
}

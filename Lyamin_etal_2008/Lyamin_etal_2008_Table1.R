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
# Snapshot columns as printed in Lyamin et al. (2008) Table 1:
#   Species | Common name | Body mass (kg) | Brain mass (g)
#   | Total sleep time (h/day) | Unihemispheric SWS (%) | Bilateral SWS (%)
#   | REM sleep (%) | Method | Reference
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
final.dataframe <- df_snapshot %>%
  rename(
    species                  = Species,
    common_name              = `Common name`,
    body_mass_kg             = `Body mass (kg)`,
    brain_mass_g             = `Brain mass (g)`,
    total_sleep_time_h_day   = `Total sleep time (h/day)`,
    unihemispheric_sws_pct   = `Unihemispheric SWS (% of sleep)`,
    bilateral_sws_pct        = `Bilateral SWS (% of sleep)`,
    rem_sleep_pct            = `REM sleep (% of sleep)`,
    method                   = Method,
    reference                = Reference
  ) %>%
  mutate(
    common_name              = tolower(trimws(common_name)),
    species                  = trimws(species),
    body_mass_kg             = as.numeric(gsub("[^0-9.\\-]", "", body_mass_kg)),
    brain_mass_g             = as.numeric(gsub("[^0-9.\\-]", "", brain_mass_g)),
    total_sleep_time_h_day   = as.numeric(gsub("[^0-9.\\-]", "", total_sleep_time_h_day)),
    unihemispheric_sws_pct   = as.numeric(gsub("[^0-9.\\-]", "", unihemispheric_sws_pct)),
    bilateral_sws_pct        = as.numeric(gsub("[^0-9.\\-]", "", bilateral_sws_pct)),
    rem_sleep_pct            = as.numeric(gsub("[^0-9.\\-]", "", rem_sleep_pct))
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

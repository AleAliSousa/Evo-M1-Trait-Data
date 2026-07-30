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
# Lyamin et al. (2008) Table 2: quantitative sleep parameters across
# four cetacean species (bottlenose dolphin, harbor porpoise, Amazon
# river dolphin, beluga). The printed table has species-as-COLUMNS;
# the snapshot has been reoriented to species-as-ROWS for database
# consistency (documented in the ReadMe).
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
final.dataframe <- df_snapshot %>%
  rename(
    species                       = Species,
    common_name                   = `Common name`,
    n_animals                     = `Number of animals`,
    sex                           = Sex,
    age                           = Age,
    total_sws_pct                 = `Total SWS (% of 24-h)`,
    sws_left_hemisphere_pct       = `SWS left hemisphere (% of 24-h)`,
    sws_right_hemisphere_pct      = `SWS right hemisphere (% of 24-h)`,
    low_amp_usws_pct_tst          = `Low amplitude USWS (% of TST)`,
    high_amp_usws_pct_tst         = `High amplitude USWS (% of TST)`,
    asymmetrical_sws_pct_tst      = `Asymmetrical SWS (% of TST)`,
    low_amp_bilateral_sws_pct_tst = `Low amplitude bilateral SWS (% of TST)`,
    high_amp_bilateral_sws_pct_tst= `High amplitude bilateral SWS (% of TST)`,
    reference                     = Reference
  ) %>%
  mutate(
    common_name = tolower(trimws(common_name)),
    species     = trimws(species)
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

## 0. PATHS --------------------------------------------------------
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))   # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                       # repo root; NA if run as a lone folder
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
# The snapshot is a faithful copy of Table S1 as printed in the Caves (2018)
# supplementary raw data (Word file). Four columns exactly as in the paper:
#   Common Name | Latin Name | Citation[Acuity, eye size] | Method
# The species are ordered by decreasing visual acuity (top row = highest
# acuity), matching Figure I of Box 1 in the published paper.
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
# Cleaning steps:
#   (a) tidy column names to snake_case
#   (b) preserve row order and add an explicit acuity_rank (1 = highest)
#   (c) normalise capitalisation on common names (paper is inconsistent:
#       "Common ostrich", "Domestic chicken", "Mangrove mud-nesting ant"
#       all become lowercased for consistency with the majority)
#   (d) strip the parenthetical clade note from "red-eared slider (turtle)"
#       and "Dust lice (Psocoptera)" -- keep the primary common name
#   (e) tidy the method label (paper uses "Peak retinal cell density" once
#       where every other RGC-based entry says "Peak RGC" -- collapse)
#   (f) keep the citation column as-is (as a character string). The Caves
#       header states first citation = acuity, second = eye size, but rows
#       with 1 or 3 citations don't fit that scheme cleanly -- so we do NOT
#       auto-split. Any split is a decision for downstream analysis.
final.dataframe <- df_snapshot %>%
  rename(
    common_name = `Common Name`,
    latin_name  = `Latin Name`,
    citations   = `Citation[Acuity, eye size]`,
    method      = Method
  ) %>%
  mutate(
    acuity_rank = row_number(),
    common_name = tolower(trimws(common_name)),
    common_name = str_replace(common_name, "\\s*\\([^)]+\\)\\s*$", ""),
    latin_name  = trimws(latin_name),
    method      = str_replace(method, "Peak retinal cell density", "Peak RGC"),
    citations   = trimws(citations)
  ) %>%
  select(acuity_rank, common_name, latin_name, method, citations)

## 4. SAVE OUTPUTS -------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, final_csv, row.names = FALSE)

# Public TSV: only if run inside the full repo (i.e. __ReadMe.xlsx is found).
# If run as a lone folder, skip this step.
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

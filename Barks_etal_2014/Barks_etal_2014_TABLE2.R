## 0. PATHS ---------------------------------------------------------------

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
folder <- paper_dir <- dirname(.sp)                                  # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

library(tidyverse)
library(readxl)
library(dplyr)
library(stringr)
library(readr)

script_path  <- .sp
paper_dir    <- dirname(script_path)
dataset_root <- dirname(paper_dir)                   # Evo-M1-Trait-Data
table_name   <- tools::file_path_sans_ext(basename(script_path))

# Outputs
snapshot_xlsx <- file.path(paper_dir, paste0(table_name, "_snapshot.xlsx"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. LOAD SNAPSHOT AND SET HEADERS ---------------------------------------

# Barks SK et al. 2014/2015, Table 2.
# This script follows the local TABLE1 script style but TABLE2 has a different
# structure: one title row, one header row, and then region-by-hemisphere rows.
#
# Expected local input/output files in paper_dir:
#   Barks_etal_2014_TABLE2.R
#   Barks_etal_2014_TABLE2_snapshot.xlsx
#   Barks_etal_2014_TABLE2.csv
#
# Expected public TSV output:
#   dataset_root/__Public/comparative-data/<Item encoded>.tsv
# where <Item encoded> is looked up from __ReadMe.xlsx using Item name ==
# Barks_etal_2014_TABLE2.

# Load the snapshot, skipping the printed table title row. The snapshot contains
# one blank trailing column in some exports, so keep only the columns used by the
# table itself.
raw <- read_xlsx(snapshot_xlsx, skip = 1, col_names = TRUE) %>%
  select(where(~ !all(is.na(.x))))

# Standardize column names for analysis-ready use.
data <- raw %>%
  rename(
    region = Region,
    hemisphere = Hemisphere,
    average_number_points_counted = `Average number points counted`,
    ce = CE
  ) %>%
  mutate(
    across(everything(), ~ str_squish(as.character(.x))),
    across(everything(), ~ na_if(.x, ""))
  )

## 2. CLEAN REGION LABELS AND VALUES --------------------------------------

# Most paired left/right rows print the region name only on the left-row and
# leave the right-row region blank. One exception is split across rows in the
# snapshot/PDF: "External capsule/" on the left-row and
# "claustrum/extreme capsule" on the right-row. Recombine that split label and
# assign it to both hemisphere rows before filling other region labels down.
result_df <- data %>%
  mutate(
    next_region = lead(region),
    previous_region = lag(region),
    region = case_when(
      str_detect(coalesce(region, ""), "/$") & !is.na(next_region) ~
        paste0(region, next_region),
      !is.na(region) & str_detect(coalesce(previous_region, ""), "/$") ~
        paste0(previous_region, region),
      TRUE ~ region
    )
  ) %>%
  select(-next_region, -previous_region) %>%
  fill(region, .direction = "down") %>%
  filter(!is.na(region), !is.na(hemisphere)) %>%
  mutate(
    average_number_points_counted = parse_number(average_number_points_counted),
    ce = parse_number(ce)
  ) %>%
  select(region, hemisphere, average_number_points_counted, ce)

# Remove completely blank rows introduced by formatting in the snapshot.
result_df <- result_df %>%
  filter(if_any(everything(), ~ !is.na(.x)))

# Set the scipen option to a high value to turn off scientific notation.
options(scipen = 999)


## 3. SAVE ---------------------------------------------------------------

final.dataframe <- result_df

filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")

item_encoded <- filecodes$`Item encoded`[
  match(table_name, filecodes$`Item name`)
]

if (is.na(item_encoded) || item_encoded == "") {
  stop("No 'Item encoded' entry found in __ReadMe.xlsx for Item name: ", table_name)
}

# Local CSV (paper folder)
write.csv(final.dataframe, final_csv, row.names = FALSE)

# Public TSV
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  final.dataframe,
  file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
  sep = "\t",
  row.names = FALSE
)

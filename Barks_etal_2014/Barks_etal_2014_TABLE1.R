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
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
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

# Barks SK et al. 2014/2015, Table I.
# This script follows the Sherwood_etal_2004_TABLEI.R model script.
# Both Barks table scripts belong in the same paper folder. Each table has its
# own R script, snapshot XLSX, local CSV, and public TSV, all named from
# table_name.
#
# Expected local input/output files in paper_dir:
#   Barks_etal_2014_TABLEI.R
#   Barks_etal_2014_TABLEI_snapshot.xlsx
#   Barks_etal_2014_TABLEI.csv
#
# Expected public TSV output:
#   dataset_root/__Public/comparative-data/<Item encoded>.tsv
# where <Item encoded> is looked up from __ReadMe.xlsx using Item name ==
# Barks_etal_2014_TABLEI.

# Load the data
data <- read_xlsx(snapshot_xlsx)

# Move values ending in "a" from Brain volume into a new column
data1 <- data %>%
  mutate(
    brain_volume_has_a = str_detect(coalesce(`Brain volume (cm3)`, ""), "a$"),
    
    `Brain volume minus cerebellum (cm3)` = if_else(
      brain_volume_has_a,
      parse_number(`Brain volume (cm3)`),
      NA_real_
    ),
    
    `Brain volume (cm3)` = if_else(
      brain_volume_has_a,
      NA_real_,
      parse_number(`Brain volume (cm3)`)
    )
  ) %>%
  select(-brain_volume_has_a) %>%
  relocate(
    `Brain volume minus cerebellum (cm3)`,
    .after = `Brain volume (cm3)`
  )

data2 <- data1 %>%
  mutate(
    Subject = str_squish(as.character(Subject)),
    
    is_species_row = str_detect(
      coalesce(Subject, ""),
      "\\([^()]+\\)"
    ),
    
    species = if_else(
      is_species_row,
      str_match(Subject, "\\(([^()]+)\\)")[, 2],
      NA_character_
    ),
    
    specimen_number = if_else(
      str_detect(coalesce(Subject, ""), "^[0-9]+$"),
      Subject,
      NA_character_
    )
  ) %>%
  fill(species, .direction = "down") %>%
  filter(!is_species_row, !is.na(specimen_number)) %>%
  select(-Subject, -is_species_row) %>%
  relocate(species, specimen_number)


# Remove completely blank rows introduced by formatting in the snapshot.
result_df <- data2 %>%
  mutate(across(everything(), ~ str_squish(as.character(.x)))) %>%
  mutate(across(everything(), ~ na_if(.x, ""))) %>%
  filter(if_any(everything(), ~ !is.na(.x)))


## 2. CLEAN VALUES --------------------------------------------------------

# Convert columns that are now cleanly numeric to numeric while leaving text
# columns, such as individual IDs, species names, and notes, as character.
result_df <- type_convert(
  result_df,
  na = c("", "NA", "N/A", "n/a", "NaN", "NULL")
)

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

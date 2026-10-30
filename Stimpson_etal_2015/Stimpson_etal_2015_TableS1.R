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

script_path  <- .sp
paper_dir    <- dirname(script_path)
dataset_root <- dirname(paper_dir)                   # Evo-M1-Trait-Data
table_name   <- tools::file_path_sans_ext(basename(script_path))

# Outputs
snapshot_xlsx <- file.path(paper_dir, paste0(table_name, "_snapshot.xlsx"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. LOAD SNAPSHOT -------------------------------------------------------

# Stimpson CD et al. 2015/2016, Supplementary Table S1.
# Per-individual brain mass (g) for bonobos and chimpanzees.
# This script follows the Sherwood_etal_2004_TABLEI.R model script.
# Both Stimpson table scripts belong in the same paper folder. Each table has
# its own R script, snapshot XLSX, local CSV, and public TSV, all named from
# table_name.
#
# Expected local input/output files in paper_dir:
#   Stimpson_etal_2015_TableS1.R
#   Stimpson_etal_2015_TableS1_snapshot.xlsx
#   Stimpson_etal_2015_TableS1.csv
#
# Expected public TSV output:
#   dataset_root/__Public/comparative-data/<Item encoded>.tsv
# where <Item encoded> is looked up from __ReadMe.xlsx using Item name ==
# Stimpson_etal_2015_TableS1.

sp_map <- c(
  Bonobo = "Pan paniscus",
  Chimpanzee = "Pan troglodytes"
)

numv <- function(x) {
  suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
}

raw_data <- read_excel(
  snapshot_xlsx,
  sheet = 1,
  col_names = FALSE,
  skip = 2,
  col_types = "text",
  .name_repair = "minimal"
)

names(raw_data)[1:5] <- c(
  "common",
  "subject_no",
  "sex",
  "age_years",
  "brain_mass_g"
)

## 2. CLEAN VALUES --------------------------------------------------------

result_df <- raw_data %>%
  mutate(common = na_if(str_squish(common), "")) %>%
  fill(common, .direction = "down") %>%
  filter(!is.na(subject_no) & str_detect(subject_no, "[0-9]")) %>%
  transmute(
    species = unname(sp_map[common]),
    common_name = common,
    subject_no = as.integer(numv(subject_no)),
    sex = str_squish(sex),
    age_years = numv(age_years),
    brain_mass_g = numv(brain_mass_g),
    source = "Stimpson_etal_2015"
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

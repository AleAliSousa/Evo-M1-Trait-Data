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
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
# Cleaning steps:
#   - column names -> snake_case
#   - numeric columns coerced
#   - water_temp_c kept as printed (range string, e.g. "−1–9") -- also
#     add derived min/max columns for downstream analysis
parse_temp_range <- function(x) {
  x <- trimws(x)
  x <- gsub("−", "-", x, fixed = TRUE)
  parts <- str_match(x, "^\\s*(-?[0-9\\.]+)\\s*[-–]\\s*(-?[0-9\\.]+)\\s*$")
  tibble(min = suppressWarnings(as.numeric(parts[, 2])),
         max = suppressWarnings(as.numeric(parts[, 3])))
}

temps <- parse_temp_range(df_snapshot$`Water temp. (°C)`)

final.dataframe <- df_snapshot %>%
  rename(
    species                    = Species,
    suborder                   = Suborder,
    family                     = Family,
    brain_mass_g               = `Brain mass (g)`,
    body_mass_g                = `Body mass (g)`,
    encephalisation_quotient   = `Encephalisation quotient`,
    water_temp_range_c         = `Water temp. (°C)`,
    source                     = Source
  ) %>%
  mutate(
    species                    = trimws(species),
    suborder                   = trimws(suborder),
    family                     = trimws(family),
    brain_mass_g               = as.numeric(gsub("[^0-9.\\-]", "", brain_mass_g)),
    body_mass_g                = as.numeric(gsub("[^0-9.\\-]", "", body_mass_g)),
    encephalisation_quotient   = as.numeric(gsub("[^0-9.\\-]", "", encephalisation_quotient)),
    water_temp_min_c           = temps$min,
    water_temp_max_c           = temps$max
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

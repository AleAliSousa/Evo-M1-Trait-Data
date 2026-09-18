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
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(stringr)
library(readxl)

## 2. LOAD SNAPSHOT -------------------------------------------------
# Lyamin et al. (2008) Table 1, "Number of muscle jerks in cetaceans".
# Printed columns: Cetacean species | Age | Number of jerks | Reference
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
# number_of_jerks is kept verbatim. The printed values use incompatible
# denominators -- totals over a period, per-day rates, means with SD, upper
# bounds, per-individual splits, and one qualitative entry -- so the column is
# not a comparable quantity and is not coerced to numeric here.
final.dataframe <- df_snapshot %>%
  rename(
    common_name_printed = `Cetacean species`,
    age_printed         = Age,
    number_of_jerks     = `Number of jerks`,
    reference           = Reference
  ) %>%
  mutate(
    common_name_printed = str_squish(common_name_printed),
    common_name         = tolower(common_name_printed),
    age_printed         = str_squish(age_printed),
    number_of_jerks     = str_squish(number_of_jerks),
    reference           = str_squish(reference),
    ## Order matters. "Three adult males and one adult female" is four animals,
    ## so the compound pattern has to be tested before the bare "^three", or the
    ## row scores 3. It was the wrong way round until 2026-09-16 and the
    ## committed CSV carried n_animals = 3 for the bottlenose row.
    n_animals = case_when(
      str_detect(age_printed, regex("three .* and one", ignore_case = TRUE)) ~ 4L,
      str_detect(age_printed, regex("^one\\b",   ignore_case = TRUE)) ~ 1L,
      str_detect(age_printed, regex("^two\\b",   ignore_case = TRUE)) ~ 2L,
      str_detect(age_printed, regex("^three\\b", ignore_case = TRUE)) ~ 3L,
      TRUE ~ NA_integer_
    ),
    age_class = case_when(
      str_detect(age_printed, regex("calf",   ignore_case = TRUE)) ~ "calf",
      str_detect(age_printed, regex("adult",  ignore_case = TRUE)) ~ "adult",
      str_detect(age_printed, regex("year",   ignore_case = TRUE)) ~ "juvenile",
      TRUE ~ NA_character_
    ),
    reference_unpublished = str_detect(reference, regex("unpublished", ignore_case = TRUE)),
    reference_in_press    = str_detect(reference, regex("in press",    ignore_case = TRUE))
  ) %>%
  select(common_name, common_name_printed,
         n_animals, age_class, age_printed,
         number_of_jerks, reference, reference_unpublished, reference_in_press)

## 3a. SPECIES --------------------------------------------------------
## Binomials come from _keys/Lyamin/species_key.csv, never from a map inside
## this script. species_resolution_Lyamin_Table1.csv, which used to sit in this
## folder and carry the mapping, has been deleted: HOWTO section 5 puts every
## name mapping in the key so it is reusable across papers. The confidence notes
## it also carried are a column of the key itself, so this CSV keeps every column
## it already had.
key_path <- if (!is.na(dataset_root)) file.path(dataset_root, "_keys", "Lyamin", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx.",
       call. = FALSE)
}
key <- read.csv(key_path, stringsAsFactors = FALSE)
key <- key[key$source_publication == sub("_Table[^_]*$", "", table_name), ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
ck  <- setNames(key$species_confidence, tolower(key$variant_name))
final.dataframe$species            <- unname(lk[tolower(final.dataframe$common_name_printed)])
final.dataframe$species_confidence <- unname(ck[tolower(final.dataframe$common_name_printed)])
if (anyNA(final.dataframe$species)) {
  stop("Not in _keys/Lyamin/species_key.csv: ",
       paste(unique(final.dataframe$common_name_printed[is.na(final.dataframe$species)]),
             collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)
}
## the column order the definitions file expects; unchanged from the committed CSV
final.dataframe <- final.dataframe[, c("species", "species_confidence", "common_name",
  "common_name_printed", "n_animals", "age_class", "age_printed", "number_of_jerks",
  "reference", "reference_unpublished", "reference_in_press")]

## 3b. CHECKS ------------------------------------------------------
# The bottlenose row is "Three adult males and one adult female" = 4 animals;
# the ^three rule would otherwise catch it first. Verify the override held.
stopifnot(nrow(final.dataframe) == 7L, !anyNA(final.dataframe$species))

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
    write.table(final.dataframe,
                file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
  }
}

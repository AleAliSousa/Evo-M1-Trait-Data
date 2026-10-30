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
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

library(dplyr)
library(readxl)
library(readr)
library(stringr)

## =============================================================================
## Rilling & Insel (1999) Table 1 --> analysis-ready CSV
## Differential expansion of neural projection systems in primate brain evolution.
## NeuroReport 10:1453-1459.
## =============================================================================
##
## SNAPSHOT RULE
## -----------------------------------------------------------------------------
## The snapshot workbook is the faithful capture of the printed table. Do not edit
## the snapshot to clean the data. All interpretation happens in this script.
##
## The printed cells use a middle dot as the decimal mark and combine means, SDs,
## and occasional parenthetical notes in the same cell, for example:
##   103·0±1·4  (5)
## Here, 103.0 is the mean, 1.4 is the SD, and 5 is the parenthetical note from
## the table footnote: the number of subjects used when it is less than the total
## N for that species.
## =============================================================================

input_xlsx <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
output_csv <- file.path(folder, paste0(item_name, ".csv"))

if (!file.exists(input_xlsx)) {
  stop("Missing snapshot workbook: ", input_xlsx, call. = FALSE)
}

## ---- helpers -----------------------------------------------------------------

parse_measure <- function(x) {
  x <- as.character(x)
  x <- str_squish(x)
  x[x %in% c("", "NA", "No data", "No  data")] <- NA_character_

  note <- str_match(x, "\\(([^)]*)\\)")[, 2]
  value <- x |>
    str_remove("\\s*\\([^)]*\\)") |>
    str_replace_all("·", ".") |>
    str_squish()

  mean <- suppressWarnings(as.numeric(str_match(value, "^([0-9.]+)")[, 2]))
  sd   <- suppressWarnings(as.numeric(str_match(value, "±\\s*([0-9.]+)")[, 2]))

  tibble(mean = mean, sd = sd, note = note)
}

parse_sex_n <- function(x) {
  x <- str_squish(as.character(x))
  males   <- suppressWarnings(as.integer(str_match(x, "([0-9]+)\\s*M")[, 2]))
  females <- suppressWarnings(as.integer(str_match(x, "([0-9]+)\\s*F")[, 2]))
  tibble(n_male = males, n_female = females, n_total = males + females)
}

full_species <- c(
  "H. sapiens"      = "Homo sapiens",
  "P. paniscus"     = "Pan paniscus",
  "P. troglodytes"  = "Pan troglodytes",
  "G. gorilla"      = "Gorilla gorilla",
  "P. pygmaeus"     = "Pongo pygmaeus",
  "H. lar"          = "Hylobates lar",
  "P. cynocephalus" = "Papio cynocephalus",
  "M. mulatta"      = "Macaca mulatta",
  "C. atys"         = "Cercocebus atys",
  "C. apella"       = "Cebus apella",
  "S. sciureus"     = "Saimiri sciureus"
)

measure_cols <- c(
  body_weight_kg              = "Body weight",
  spinal_cord_area_mm2        = "Spinal cord area",
  brain_volume_cc             = "Brain volume",
  neocortical_gray_matter_cc  = "Neocortical gray matter",
  cerebral_white_matter_cc    = "Cerebral white matter"
)

## ---- read snapshot -----------------------------------------------------------

raw <- read_excel(
  input_xlsx,
  sheet = 1,
  skip = 3,
  col_names = c("species_abbrev", "n", unname(measure_cols)),
  na = c("", "NA")
) |>
  filter(!is.na(species_abbrev), species_abbrev %in% names(full_species))

## ---- clean -------------------------------------------------------------------

clean_base <- raw |>
  transmute(
    Species = unname(full_species[species_abbrev]),
    species_abbrev,
    n_raw = n
  ) |>
  bind_cols(parse_sex_n(raw$n))

clean_measures <- bind_cols(lapply(names(measure_cols), function(nm) {
  out <- parse_measure(raw[[measure_cols[[nm]]]])
  names(out) <- paste0(nm, c("_mean", "_sd", "_note"))
  out
}))

clean <- bind_cols(clean_base, clean_measures) |>
  arrange(Species)

## ---- checks ------------------------------------------------------------------

expected_species <- unname(full_species)
missing_species <- setdiff(expected_species, clean$Species)
if (length(missing_species)) {
  stop("These expected species were not parsed: ", paste(missing_species, collapse = ", "), call. = FALSE)
}

if (any(is.na(clean$n_total))) {
  stop("Could not parse N for: ", paste(clean$species[is.na(clean$n_total)], collapse = ", "), call. = FALSE)
}

## ---- write local CSV and public TSV when run inside the full dataset ----------

write_csv(clean, output_csv)

if (!is.na(dataset_root)) {
  readme_xlsx <- file.path(dataset_root, "__ReadMe.xlsx")
  public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

  filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]

  if (is.na(item_encoded)) {
    stop("No matching 'Item encoded' found for: ", item_name, call. = FALSE)
  }

  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write_tsv(clean, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")))
}

# Schenker_etal_2005_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Schenker et al. (2005),
# "Neural connectivity and cortical substrates of cognition in hominoids",
# Table 1, into analysis-ready CSV and TSV files. Output comes from the snapshot only.
#
# Table 1 reports species means ± S.E. for 10 bilateral regions of interest.
# Values are in cm3. Numbers of individuals are printed in parentheses after species.
#
# Input : Schenker_etal_2005_Table1_snapshot.xlsx, sheet "Table1"
# Output: Schenker_etal_2005_Table1.csv
#         Schenker_etal_2005_Table1.tsv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr); library(tidyr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)

dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot_file <- "Schenker_etal_2005_Table1_snapshot.xlsx"

raw <- read_excel(snapshot_file, sheet = "Table1", skip = 1, col_names = TRUE, col_types = "text") %>%
  filter(str_detect(Species, "\\(\\d+\\)$"))

expected <- c("Species", "Dorsal cortex", "Mesial cortex", "Orbital cortex",
              "Dorsal GWM", "Mesial GWM", "Orbital GWM", "Frontal core",
              "Temporal cortex", "Temporal GWM", "Temporal core")
if (!identical(names(raw), expected)) {
  stop("Unexpected Table1 headers: ", paste(names(raw), collapse = ", "), call. = FALSE)
}

measure_names <- c("dorsal_cortex", "mesial_cortex", "orbital_cortex",
                   "dorsal_GWM", "mesial_GWM", "orbital_GWM", "frontal_core",
                   "temporal_cortex", "temporal_GWM", "temporal_core")

species <- str_match(raw$Species, "^(.*) \\((\\d+)\\)$")
if (any(is.na(species[, 2:3]))) stop("Could not parse one or more Species (n) labels.", call. = FALSE)

parsed <- raw %>%
  select(-Species) %>%
  setNames(measure_names) %>%
  mutate(row_id = row_number(), .before = 1) %>%
  pivot_longer(-row_id, names_to = "measure", values_to = "printed") %>%
  separate_wider_delim(printed, delim = " ± ", names = c("mean", "SE"), too_few = "error", too_many = "error") %>%
  mutate(mean = parse_double(mean), SE = parse_double(SE)) %>%
  pivot_wider(names_from = measure, values_from = c(mean, SE), names_glue = "{measure}_{.value}_cm3")

# Put each mean immediately before its S.E., matching the intended public schema.
value_cols <- unlist(lapply(measure_names, function(x) c(paste0(x, "_mean_cm3"), paste0(x, "_SE_cm3"))))
final.dataframe <- tibble(
  Species = str_squish(species[, 2]),
  n_individuals = parse_integer(species[, 3])
) %>%
  bind_cols(parsed %>% select(all_of(value_cols)))

if (nrow(final.dataframe) != 6L) stop("Expected 6 species rows; found ", nrow(final.dataframe), ".", call. = FALSE)
if (anyDuplicated(final.dataframe$Species)) stop("Duplicate species remained after parsing.", call. = FALSE)
if (anyNA(final.dataframe)) stop("Unexpected missing value after parsing Table 1.", call. = FALSE)

write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")

if (!is.na(dataset_root)) {
  registry <- readxl::read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded))
    stop("No 'Item encoded' for ", item_name, " in __ReadMe.xlsx — fix the registry row first.")
  public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write_tsv(final.dataframe, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")), na = "")
}

message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " species)")

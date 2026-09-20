# Schenker_etal_2005_Appendix1.R
#
# Preparation step. Turn the journal-faithful snapshot of Schenker et al. (2005),
# "Neural connectivity and cortical substrates of cognition in hominoids",
# Appendix 1, into analysis-ready CSV and TSV files. Output comes from the
# snapshot only.
#
# Appendix 1 reports individual age, sex, rearing history, and bilateral volumes
# for 11 regions. Values are in cm3 and include both hemispheres combined.
#
# Input : Schenker_etal_2005_Appendix1_snapshot.xlsx, sheet "Appendix1"
# Output: Schenker_etal_2005_Appendix1.csv
#         Schenker_etal_2005_Appendix1.tsv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
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

snapshot_file <- "Schenker_etal_2005_Appendix1_snapshot.xlsx"
raw <- read_excel(snapshot_file, sheet = "Appendix1", skip = 1, col_names = TRUE, col_types = "text") %>%
  filter(!is.na(Individual), str_detect(Age, "^\\d+$"))

expected <- c("Species", "Individual", "Age", "Sex", "Rearing history",
              "Frontal cortex", "Dorsal cortex", "Mesial cortex", "Orbital cortex",
              "Dorsal GWM", "Mesial GWM", "Orbital GWM", "Frontal core",
              "Temporal cortex", "Temporal GWM", "Temporal core")
if (!identical(names(raw), expected)) {
  stop("Unexpected Appendix1 headers: ", paste(names(raw), collapse = ", "), call. = FALSE)
}

numeric_source <- expected[6:16]
numeric_output <- c("frontal_cortex_cm3", "dorsal_cortex_cm3", "mesial_cortex_cm3",
                    "orbital_cortex_cm3", "dorsal_GWM_cm3", "mesial_GWM_cm3",
                    "orbital_GWM_cm3", "frontal_core_cm3", "temporal_cortex_cm3",
                    "temporal_GWM_cm3", "temporal_core_cm3")

final.dataframe <- raw %>%
  transmute(
    Species = str_squish(Species),
    Individual = str_squish(Individual),
    Age_years = parse_integer(Age),
    Sex = Sex,
    Rearing_history = `Rearing history`,
    across(all_of(numeric_source), parse_double)
  ) %>%
  rename(!!!setNames(numeric_source, numeric_output))

if (nrow(final.dataframe) != 27L) stop("Expected 27 individuals; found ", nrow(final.dataframe), ".", call. = FALSE)
if (anyDuplicated(final.dataframe$Individual)) stop("Duplicate Individual IDs remained after parsing.", call. = FALSE)
if (anyNA(final.dataframe)) stop("Unexpected missing value after parsing Appendix 1.", call. = FALSE)
if (!all(final.dataframe$Sex %in% c("F", "M"))) stop("Unexpected Sex code.", call. = FALSE)
if (!all(final.dataframe$Rearing_history %in% c("HR", "MR", "N/A"))) stop("Unexpected Rearing_history code.", call. = FALSE)

# Internal consistency stated in the Appendix footnotes.
tol <- 0.11
cortex_sum <- final.dataframe$dorsal_cortex_cm3 + final.dataframe$mesial_cortex_cm3 + final.dataframe$orbital_cortex_cm3
if (any(abs(cortex_sum - final.dataframe$frontal_cortex_cm3) > tol)) {
  warning("One or more frontal cortex totals differ from component sums by > ", tol, " cm3.")
}

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

message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " individuals)")

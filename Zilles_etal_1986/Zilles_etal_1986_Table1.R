# Zilles_etal_1986_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Zilles et al. (1986),
# "Quantitative cytoarchitectonics of the posterior cingulate cortex in primates",
# Table 1, into an analysis-ready CSV. Output comes from the snapshot only.
#
# Table 1 reports volumetric proportions (percent) of molecular, outer-main, granular where present, and inner-main laminae across posterior cingulate areas 29, 30, 23, and 31.
# Seventeen primate species are included.
#
# Input : Zilles_etal_1986_Table1_snapshot.xlsx, sheet "Table1"
# Output: Zilles_etal_1986_Table1.csv
#         <Item encoded>.tsv under __Public/comparative-data/

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

snapshot_file <- "Zilles_etal_1986_Table1_snapshot.xlsx"
raw <- read_excel(snapshot_file, sheet = "Table1", skip = 2, col_names = TRUE, col_types = "text") %>%
  filter(!is.na(Species), nzchar(str_squish(Species)))

expected <- c("Species", "M", "O", "I", "M", "O", "I", "M", "O", "G", "I", "M", "O", "G", "I")
if (!identical(names(raw), expected)) {
  stop("Unexpected Table1 headers: ", paste(names(raw), collapse = ", "), call. = FALSE)
}

names(raw) <- c("Species", "area29_molecular_pct", "area29_outer_main_pct", "area29_inner_main_pct", "area30_molecular_pct", "area30_outer_main_pct", "area30_inner_main_pct", "area23_molecular_pct", "area23_outer_main_pct", "area23_granular_pct", "area23_inner_main_pct", "area31_molecular_pct", "area31_outer_main_pct", "area31_granular_pct", "area31_inner_main_pct")
final.dataframe <- raw %>%
  mutate(Species = str_squish(Species), across(-Species, parse_double))

if (nrow(final.dataframe) != 17L) stop("Expected 17 species rows; found ", nrow(final.dataframe), ".", call. = FALSE)
if (anyDuplicated(final.dataframe$Species)) stop("Duplicate species remained after parsing.", call. = FALSE)
if (anyNA(final.dataframe)) stop("Unexpected missing value after parsing Table 1.", call. = FALSE)

# Each area's printed volumetric proportions should sum to 100 percent.
area_sums <- list(
  area29 = rowSums(final.dataframe[c("area29_molecular_pct", "area29_outer_main_pct", "area29_inner_main_pct")]),
  area30 = rowSums(final.dataframe[c("area30_molecular_pct", "area30_outer_main_pct", "area30_inner_main_pct")]),
  area23 = rowSums(final.dataframe[c("area23_molecular_pct", "area23_outer_main_pct", "area23_granular_pct", "area23_inner_main_pct")]),
  area31 = rowSums(final.dataframe[c("area31_molecular_pct", "area31_outer_main_pct", "area31_granular_pct", "area31_inner_main_pct")])
)
if (any(vapply(area_sums, function(x) any(abs(x - 100) > 1), logical(1)))) stop("One or more area proportions differ from 100 by more than one percentage point.", call. = FALSE)

write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")

if (is.na(dataset_root)) {
  warning("Repository root containing __ReadMe.xlsx was not found; public TSV skipped.")
} else {
  registry <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
    stop("No 'Item encoded' for ", item_name, " in __ReadMe.xlsx; fix the registry row first.", call. = FALSE)
  }
  public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  tsv_file <- file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
  write_tsv(final.dataframe, tsv_file, na = "")
  message("Wrote ", tsv_file)
}

message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " species)")

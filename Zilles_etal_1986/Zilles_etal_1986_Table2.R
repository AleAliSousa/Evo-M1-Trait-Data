# Zilles_etal_1986_Table2.R
#
# Preparation step. Turn the journal-faithful snapshot of Zilles et al. (1986),
# "Quantitative cytoarchitectonics of the posterior cingulate cortex in primates",
# Table 2, into an analysis-ready CSV. Output comes from the snapshot only.
#
# Table 2 reports standardized grey-level index (GLI) values for outer-main, granular where present, and inner-main laminae across posterior cingulate areas 29, 30, 23, and 31.
# Seventeen primate species are included.
#
# Input : Zilles_etal_1986_Table2_snapshot.xlsx, sheet "Table2"
# Output: Zilles_etal_1986_Table2.csv
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

snapshot_file <- "Zilles_etal_1986_Table2_snapshot.xlsx"
raw <- read_excel(snapshot_file, sheet = "Table2", skip = 2, col_names = TRUE, col_types = "text") %>%
  filter(!is.na(Species), nzchar(str_squish(Species)))

expected <- c("Species", "O", "I", "O", "I", "O", "G", "I", "O", "G", "I")
if (!identical(names(raw), expected)) {
  stop("Unexpected Table2 headers: ", paste(names(raw), collapse = ", "), call. = FALSE)
}

names(raw) <- c("Species", "area29_outer_main_GLI", "area29_inner_main_GLI", "area30_outer_main_GLI", "area30_inner_main_GLI", "area23_outer_main_GLI", "area23_granular_GLI", "area23_inner_main_GLI", "area31_outer_main_GLI", "area31_granular_GLI", "area31_inner_main_GLI")
final.dataframe <- raw %>%
  mutate(Species = str_squish(Species), across(-Species, parse_double))

if (nrow(final.dataframe) != 17L) stop("Expected 17 species rows; found ", nrow(final.dataframe), ".", call. = FALSE)
if (anyDuplicated(final.dataframe$Species)) stop("Duplicate species remained after parsing.", call. = FALSE)
if (anyNA(final.dataframe)) stop("Unexpected missing value after parsing Table 2.", call. = FALSE)

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

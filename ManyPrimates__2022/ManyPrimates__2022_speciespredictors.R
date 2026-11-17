# ManyPrimates__2022_speciespredictors.R
#
# Purpose
#   Read the unchanged source-workbook snapshot and build all 13 predictors
#   from sheet "Compilation for paper". Preserve each predictor's positional
#   Source and Comments cells; life_expectancy has no companion citation
#   columns in the source. Column meanings are documented in
#   reference_tables/ManyPrimates__2022_speciespredictors_definitions.csv.
#
# Input
#   ManyPrimates__2022_speciespredictors_snapshot.xlsx
#   sheet: Compilation for paper (row 1 headers, 41 species rows)
#
# Outputs
#   ManyPrimates__2022_speciespredictors.csv              one row per species (41 rows)
#   Registry-named TSV in __Public/comparative-data/

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
})

## ---- paths: self-contained ----
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))          # = ManyPrimates__2022_speciespredictors
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Compilation for paper"

# The source sheet repeats Source and Comments after each predictor. Map by
# position and fail if a changed workbook shifts any of these blocks.
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", na = character(), .name_repair = "minimal")
header <- as.character(unlist(raw[1, ], use.names = FALSE))
value_cols <- c(
  color_vision = 6L, vocal_repertoire_types = 9L, group_size = 12L,
  home_range = 15L, day_journey_length = 18L,
  resting_time_percent_activitybudget = 21L, feeding_budget = 24L,
  dietary_breadth = 27L, diet_diversity = 30L,
  percent_frugivory = 33L, terrestriality = 36L, body_size_kg = 39L
)
printed_headers <- c(
  "color_vision", "vocal_repertoire (# vocalization types)", "group_size",
  "home_range", "day_journey_length", "resting_time_percent_activitybudget",
  "feeding_budget", "dietary_breadth", "diet_diversity",
  "percent_frugivory", "terrestriality", "body_size (kg)"
)
if (nrow(raw) != 42L || length(header) != 41L ||
    !identical(header[1:5],
               c("species_latin", "species_english", "family",
                 "superordinate_group", "life_expectancy")) ||
    !identical(unname(header[value_cols]), printed_headers) ||
    !all(header[value_cols + 1L] == "Source") ||
    !all(header[value_cols + 2L] == "Comments")) {
  stop("Source sheet column layout changed; review the positional citations")
}
column_types <- rep("text", 41L)
column_types[c(5L, 9L, 12L, 15L, 18L, 21L, 24L, 27L, 33L, 39L)] <- "numeric"
dat <- read_excel(snapshot_file, sheet = snapshot_sheet, range = "A2:AO42",
                  col_names = FALSE, col_types = column_types,
                  .name_repair = "minimal")
dat <- dat[!is.na(dat[[1L]]) & nzchar(trimws(dat[[1L]])), , drop = FALSE]

na_txt <- function(x) {
  x <- gsub("[ \t]*[\r\n]+[ \t]*", " ", as.character(x))
  ifelse(is.na(x) | trimws(x) %in% c("", "NA", "N/A"),
         NA_character_, trimws(x))
}
cell <- function(i) na_txt(dat[[i]])

final.dataframe <- data.frame(
  Species = trimws(gsub("_", " ", cell(1L))),
  common_name = cell(2L),
  family = cell(3L),
  superordinate_group = cell(4L),
  life_expectancy = cell(5L),
  stringsAsFactors = FALSE
)
for (measure in names(value_cols)) {
  i <- value_cols[[measure]]
  value <- cell(i)
  if (measure == "vocal_repertoire_types") {
    n <- suppressWarnings(as.numeric(value))
    if (any(!is.na(value) & (is.na(n) | n != round(n)))) {
      stop("Vocal repertoire contains a noninteger or nonnumeric value")
    }
    # Keep the existing CSV/TSV spelling (for example, 14.0) for this
    # downstream-used column while reading the original source value.
    value <- ifelse(is.na(n), NA_character_, sprintf("%.1f", n))
  }
  final.dataframe[[measure]] <- value
  prefix <- if (measure == "vocal_repertoire_types") "vocal_repertoire" else measure
  final.dataframe[[paste0(prefix, "_source")]] <- cell(i + 1L)
  final.dataframe[[paste0(prefix, "_comment")]] <- cell(i + 2L)
}
final.dataframe$source <- "ManyPrimates__2022"
if (nrow(final.dataframe) != 41L || anyDuplicated(final.dataframe$Species)) {
  stop("Expected 41 distinct species in the source sheet")
}

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
if (is.na(base)) stop("Repository registry __ReadMe.xlsx not found")
registry <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1",
                       col_types = "text")
row <- registry[registry[["Item name"]] == item_name &
                  !is.na(registry[["Item name"]]), , drop = FALSE]
if (nrow(row) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- row[["Item encoded"]][[1L]]
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  stop("Registry Item encoded is blank for ", item_name)
}
if (!dir.exists(tsv_dir)) stop("Shared TSV folder not found: ", tsv_dir)
write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE)
message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
message("Rows: ", nrow(final.dataframe))

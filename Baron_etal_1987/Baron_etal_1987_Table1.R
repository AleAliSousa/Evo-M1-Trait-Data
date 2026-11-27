# Baron_etal_1987_Table1.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of Baron et al. 1987
#   Table 1 (paleocortical / olfactory structures) into a lean, analysis-ready
#   CSV. Everything in the output comes from the paper via the snapshot only --
#   no crosswalk, no comparison files. Structure codes and units are documented
#   in reference_tables/Baron_etal_1987_definitions.csv, not in the data.
#
# Input
#   Baron_etal_1987_Table1_snapshot.xlsx        sheets: Table1, Table2
#   reference_tables/Baron_etal_1987_Table1_species_lookup.csv
#
# Outputs
#   Baron_etal_1987_Table1.csv                  one row per species (89 rows)
#   <DOI>.tsv in __Public/comparative-data/     tab-separated copy named by the
#                                               item's encoded DOI (from __ReadMe.xlsx)

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

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
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- "Baron_etal_1987_Table1_snapshot.xlsx"
output_file    <- "Baron_etal_1987_Table1.csv"

structures <- c("BOL", "RB", "PRPI", "TOL", "TRL", "COA", "SIN")

# ---- helpers ---------------------------------------------------------------

parse_value <- function(x) parse_number(x, na = c("", "-", "NA", "n.a.", "__"))

# ---- source-layout sheets; species names/order are prepared here -----------
lookup <- read_csv("reference_tables/Baron_etal_1987_Table1_species_lookup.csv",
                   show_col_types = FALSE)
read_table <- function(sheet) {
  raw <- read_excel(snapshot_file, sheet = sheet, col_names = FALSE,
                    col_types = "text", na = c(""), .name_repair = "minimal")
  dat <- tibble(table = sheet, snapshot_row = seq_len(nrow(raw)),
                source_species = raw[[1]])
  for (i in seq_along(structures)) dat[[structures[i]]] <- raw[[i + 1]]
  dat
}
final.dataframe <- bind_rows(lapply(c("Table1", "Table2"), read_table)) %>%
  inner_join(lookup, by = c("table", "snapshot_row", "source_species")) %>%
  arrange(analysis_order) %>%
  transmute(Species = analysis_species,
            across(all_of(structures), parse_value))
stopifnot(nrow(final.dataframe) == 89)

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------

write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

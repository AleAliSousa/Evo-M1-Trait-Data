## DosSantos_etal_2020_Table1.R -- reads DosSantos_etal_2020_Table1_snapshot.csv (written by DosSantos_etal_2020_Table1_snapshot.R); builds the analysis CSV + public TSV.
# =====================================================================================
# Dos Santos et al. (2020), J Neurosci 40(24):4622-4643 — PUBLISHED Table 1 (main PDF).
# NOTE: the published Table 1 contains transcription typos in several cell-count values
#   (some impossible — neurons/microglia > total cells; e.g. Tragelaphus strepsiceros
#   whole-brain cells ~1000x too small). It is kept here only as a reference snapshot.
#   For analysis we use the authors' UNPUBLISHED data instead (DosSantos_etal_2020_unpublished),
#   which is internally consistent and matches older publications (Herculano-Houzel et al. 2015).
#   Checks: DosSantos_etal_2020_Table1_check.R  |  summary: DosSantos_etal_2020_comparison_summary.md.
#   This script just reformats the published table into a faithful snapshot/CSV.
# =====================================================================================
## 0. PATHS (NO setwd) -------------------------------------------------------

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

paper_dir <- here::here("DosSantos_etal_2020")
dataset_root  <- dirname(paper_dir)
table_name    <- "DosSantos_etal_2020_Table1"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. PACKAGES ---------------------------------------------------------------
library(tidyverse)
library(readxl)
## 2. READ SNAPSHOT ---------------------------------------------------------
# Frozen snapshot written by DosSantos_etal_2020_Table1_snapshot.R (this script only reads it).
combined_df <- read.csv(snapshot_csv, colClasses = "character", check.names = FALSE)
## 3. MAKE DATA READABLE -----------------------------------------------------
# Drop trailing "*"/"**" markers on the structure labels (e.g. "Cx**" -> "Cx")
combined_df$Structure <- gsub("\\*", "", combined_df$Structure)
# Remove the space thousands-separators and coerce the measure columns to
# numeric ("NA" text -> NA).
value_cols <- c("Structure mass (g)", "C", "N", "I", "N/mg", "I/mg", "I/N", "No. of samples")
for (col in value_cols) {
  combined_df[[col]] <- suppressWarnings(as.numeric(gsub(" ", "", combined_df[[col]])))
}
options(scipen = 999)
# Pivot to one row per species, columns "<Structure>_<measure>"
result_df <- combined_df %>%
  pivot_wider(
    names_from  = Structure,
    values_from = all_of(value_cols),
    names_glue  = "{Structure}_{.value}",
    values_fill = NA
  ) %>%
  select(`Species name`, sort(colnames(.)))
## 4. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- result_df
filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", table_name)
write.csv(final.dataframe, final_csv, row.names = FALSE)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  final.dataframe,
  file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
  sep = "\t", row.names = FALSE
)

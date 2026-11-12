## DosSantos_etal_2020_Table1_snapshot.R -- writes ONLY DosSantos_etal_2020_Table1_snapshot.csv (PDF extraction); DosSantos_etal_2020_Table1.R reads it.
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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)
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
# --- YOU SET THIS MANUALLY ---
# Original source (the old script fetched this URL directly):
#   https://www.jneurosci.org/content/jneuro/40/24/4622.full.pdf
pdf_file <- file.path(paper_dir, "Dos Santos-2020-Similar Microglial Cell Densit.pdf")
## 1. PACKAGES ---------------------------------------------------------------
# Migrated from the retired 'tabulizer' package to 'tabulapdf' (its maintained
# successor). Both wrap the same tabula-java engine.
library(rJava)
library(tabulapdf)
library(tidyverse)
library(readxl)
## 2. EXTRACT (pages 4-6) + SAVE SNAPSHOT ------------------------------------
# Table 1 spans pages 4-6 (one caption + 2-row header per page, footnotes
# below). Target just the data rows on each page with the shared column
# separators, so the spurious empty columns / page-to-page header shifts the old
# version had to patch never appear. Coordinates are PDF points from top-left.
#   per-page area = c(top, left, bottom, right)  (bottom = last data row, above
#                    "(Table continues.)" / the footnotes)
#   columns       = x of the 9 separators between the 10 columns
shared_cols <- c(118, 162, 210, 273, 336, 393, 433, 473, 514)
tables1 <- extract_tables(
  pdf_file,
  pages   = c(4, 5, 6),
  guess   = FALSE,
  area    = list(c(95, 38, 729, 548),   # page 4
                 c(95, 38, 731, 548),   # page 5
                 c(95, 38, 413, 548)),  # page 6 (stops before footnotes)
  columns = list(shared_cols, shared_cols, shared_cols),
  output  = "matrix"
)
combined <- as.data.frame(do.call(rbind, tables1), stringsAsFactors = FALSE)
colnames(combined) <- c(
  "Species name", "Structure", "Structure mass (g)", "C", "N", "I",
  "N/mg", "I/mg", "I/N", "No. of samples"
)
# Fold wrapped species names: a row that has only a Species name (no Structure,
# no data) is the tail of the name on the line above (e.g. "Papio anubis" /
# "cynocephalus"). Merge it up. (Replaces the old hard-coded row 155/156 fix.)
is_blank <- function(x) is.na(x) | trimws(x) == ""
keep <- rep(TRUE, nrow(combined))
last_real <- NA_integer_
for (i in seq_len(nrow(combined))) {
  sp <- trimws(combined[i, 1]); st <- trimws(combined[i, 2])
  rest_blank <- all(is_blank(unlist(combined[i, 3:10], use.names = FALSE)))
  if (st == "" && sp != "" && rest_blank && !is.na(last_real)) {
    combined[last_real, 1] <- trimws(paste(combined[last_real, 1], sp))
    keep[i] <- FALSE
  } else {
    last_real <- i
  }
}
combined_df <- combined[keep, , drop = FALSE]
row.names(combined_df) <- NULL
# The "+" in "P+M" extracts as "1"; restore it before saving the snapshot.
combined_df$Structure[combined_df$Structure == "P1M"] <- "P+M"
write.csv(combined_df, snapshot_csv, row.names = FALSE)

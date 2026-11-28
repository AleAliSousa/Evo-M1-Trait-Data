## Burish_etal_2010_Table1_snapshot.R -- writes ONLY Burish_etal_2010_Table1_snapshot.csv (PDF extraction); Burish_etal_2010_Table1.R reads it.
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

paper_dir <- here::here("Burish_etal_2010")
dataset_root  <- dirname(paper_dir)
table_name    <- "Burish_etal_2010_Table1"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
# --- YOU SET THIS MANUALLY ---
# Original source (the old script fetched this URL directly):
#   https://karger.com/bbe/article-pdf/76/1/45/2262181/000319019.pdf
pdf_file <- file.path(paper_dir, "Burish-2010-Cellular scaling rules for primate.pdf")
## 1. PACKAGES ---------------------------------------------------------------
# Migrated from the retired 'tabulizer' package to 'tabulapdf' (its maintained
# successor). Both wrap the same tabula-java engine.
library(rJava)
library(tabulapdf)
library(tidyverse)
library(stringr)
library(readxl)
## 2. EXTRACT TABLE 1 + SAVE SNAPSHOT ----------------------------------------
# Table 1 ("Cellular composition of the spinal cord") is on page 3. Target the
# data rows (caption + multi-line header excluded) with fixed column separators,
# so the column names can be assigned directly instead of rebuilt from the two
# stacked header rows. Coordinates are PDF points (1/72") from the top-left.
#   area    = c(top, left, bottom, right)  -> data rows incl. the "Variation" row
#   columns = x of the 14 separators between the 15 columns
tables1 <- extract_tables(
  pdf_file,
  pages   = 3,
  guess   = FALSE,
  area    = list(c(122, 48, 274, 560)),
  columns = list(c(119, 135, 169, 207, 237, 271, 307, 339, 377, 415, 440, 473, 500, 538)),
  output  = "matrix"
)
df1 <- as.data.frame(tables1[[1]], stringsAsFactors = FALSE)
# Column names exactly as in the paper's stacked header (two-line headers keep
# the line break, matching the standardized terms used downstream).
colnames(df1) <- c(
  "Species", "n", "MSC", "LSC", "%NSC", "NSC", "OSC", "DN", "DO", "MBD",
  "MSC%\nMBD", "MBR", "MSC%\nMCNS", "NBR", "NSC%\nNCNS"
)
# In this PDF's text layer the "±" glyph extracts as a trailing "8" and the
# "×" glyph as a trailing "!". For multi-individual species (n > 1) every mean
# in the 8 measured columns carries a "±", so restore it; restore "×" in the
# "Variation" (fold-change) row.
columns_to_check <- c("MSC", "LSC", "%NSC", "NSC", "OSC", "DN", "DO", "MBD")
rows_to_replace <- {
  nnum <- suppressWarnings(as.numeric(df1$n))
  !is.na(nnum) & nnum > 1
}
df1[rows_to_replace, columns_to_check] <- lapply(
  df1[rows_to_replace, columns_to_check],
  function(x) str_replace(x, "8$", "±")
)
variation_rows <- df1$Species == "Variation"
df1[variation_rows, ] <- apply(df1[variation_rows, ], 2, function(x) {
  ifelse(str_ends(x, "!"), str_replace(x, "!$", "×"), x)
})
# Keep the printed caption above the unchanged 15-column grid.
write.table(matrix(c("Table 1. Cellular composition of the spinal cord",
                     rep("", ncol(df1) - 1L)), nrow = 1L),
            snapshot_csv, sep = ",", row.names = FALSE, col.names = FALSE,
            quote = TRUE)
write.table(df1, snapshot_csv, sep = ",", row.names = FALSE,
            col.names = TRUE, quote = TRUE, append = TRUE, na = "NA")

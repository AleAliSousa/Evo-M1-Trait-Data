## AvelinodeSouza_etal_2025_TABLE1_snapshot.R -- writes the snapshot of Table 1 (PDF page 5, tabulapdf extract).

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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = file name minus _snapshot (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

paper_dir    <- folder
dataset_root <- base
table_name   <- item_name

# --- PDF SOURCE (manual, per your rule) ---
pdf_file <- file.path(
  paper_dir,
  "Avelino-de-Souz-2025-Cellular Composition of t.pdf"
)
# Output
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
# Load the tabulizer library and rJava
## 1. SOURCE ---------------------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)
tables1 <- extract_tables(pdf_file, pages = c(5))
## 2. FIX FORMATTING AND SAVE SNAPSHOT
# Convert the matrices into data frames
df1 <- as.data.frame(tables1[[1]])
# Remove the the text rows after row 21
df1 <- df1[1:min(21, nrow(df1)), , drop = FALSE]
row.names(df1) <- NULL  # reset row names
# Split the 4th column at the first space
library(dplyr); library(tidyr)
n4 <- names(df1)[4]
df1 <- df1 %>%
  separate_wider_delim({{ n4 }}, delim = " ", names = c(n4, "...0"), too_many = "merge")
# Fix up the headers
# Combine colnames (headings) with first row
header <- paste(names(df1), as.character(unlist(df1[1, ], use.names = FALSE)))
# Strip the "...<number>" (e.g., "...1", "...3") in any column name (there may be a space, but wait to eliminate in next step)
header <- gsub("\\.{3}\\d+", "", header)
# Trim whitespace from the names
header=trimws(header)
# Use the header as column names for the first matrix in tables1
colnames(df1) <- header
# Remove the redundant first row and the text rows after row 21
df1 <- df1[2:min(21, nrow(df1)), , drop = FALSE]
row.names(df1) <- NULL  # reset row names
# Combine rows where row label (in the first column) gets broken across multiple lines.
# Treat NA as not-text; only non-empty strings are text
is_text <- function(x) !is.na(x) & nzchar(trimws(x))
# continuation rows: first col has text AND every other col has no text
others_have_text <- rowSums(as.data.frame(lapply(df1[-1], is_text))) > 0
cont <- is_text(df1[[1]]) & !others_have_text
# Group index: increases at each "real" row, so continuations share parent’s group
g <- cumsum(!cont)
# Merge text in first column across each group, separated by space
df1[[1]] <- ave(df1[[1]], g, FUN = function(v) paste(v[is_text(v)], collapse = " "))
# Keep only the non-continuation (parent) rows
df1 <- df1[!cont, , drop = FALSE]
row.names(df1) <- NULL
# Save snapshot as a CSV file
write.csv(df1, snapshot_csv, row.names = FALSE)

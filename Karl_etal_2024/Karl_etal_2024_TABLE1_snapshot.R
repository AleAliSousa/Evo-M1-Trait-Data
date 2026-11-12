## Karl_etal_2024_TABLE1_snapshot.R -- PDF table (tabulapdf) -> frozen snapshot; the item script Karl_etal_2024_TABLE1.R only READS the snapshot.
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

paper_dir <- here::here("Karl_etal_2024")
dataset_root  <- dirname(paper_dir)
table_name    <- sub("_snapshot$", "", item_name)   # Karl_etal_2024_TABLE1
# output (this script writes ONLY <item>_snapshot.csv)
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
# --- YOU SET THIS MANUALLY ---
pdf_file <- file.path(paper_dir, "Karl-2024-Invariance of Mitochondria and Synap.pdf")
## 1. SOURCE -----------------------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)
library(dplyr)
library(tidyr)
library(readxl)
# Extract Table 1 (YOU control pages)
tables1 <- extract_tables(pdf_file, pages = c(3))
## 2. FIX FORMATTING AND SAVE SNAPSHOT ---------------------------------------
df1 <- as.data.frame(tables1[[1]])
df2 <- df1
## 2.1. COLLECT HEADER COMPONENTS ---------------------------------------------
# Matrix: rows = (colnames, row1, row2), cols = table columns
header_mat <- rbind(
  colnames(df2),
  as.character(df2[1, ]),
  as.character(df2[2, ])
)
## 2.2. FUNCTION TO CLEAN + COMBINE ONE COLUMN ---------------------------------
make_header <- function(x) {
  x <- x[!is.na(x)]                      # drop NA
  x <- x[!str_detect(x, "^\\.\\.\\.")]   # drop ...1, ...2, etc.
  x <- str_trim(x)
  x <- x[x != ""]                        # drop empty strings
  str_squish(paste(x, collapse = " "))   # combine with spaces
}
## 2.3. BUILD FINAL HEADER ----------------------------------------------------
new_header <- apply(header_mat, 2, make_header)
## 2.4. APPLY HEADER + DROP HEADER ROWS ---------------------------------------
colnames(df2) <- new_header
df2 <- df2[-c(1, 2), ]
row.names(df2) <- NULL
## 3. FIX CONTINUATION ROWS
## 3.1. HELPERS ---------------------------------------------------------------
is_text_only <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(FALSE)
  
  # A cell is numeric if it contains a digit
  any_digit <- str_detect(x, "\\d")
  
  # TRUE if there are NO digits anywhere in the row
  !any(any_digit)
}
merge_cells <- function(a, b) {
  # merge b into a with a space if needed
  if (is.na(b) || b == "") return(a)
  if (is.na(a) || a == "") return(b)
  str_squish(paste(a, b))
}
## 3.2. FIND CONTINUATION ROWS -----------------------------------------------
df3<-df2
cont_rows <- apply(df3, 1, is_text_only)
## 3.3. MERGE UPWARD ----------------------------------------------------------
for (i in which(cont_rows)) {
  if (i == 1) next  # safety
  
  df3[i - 1, ] <- Map(
    merge_cells,
    df3[i - 1, ],
    df3[i, ]
  )
}
## 3.4. DROP CONTINUATION ROWS -----------------------------------------------
df3 <- df3[!cont_rows, , drop = FALSE]
row.names(df3) <- NULL
# Snapshot named from script filename
write.csv(df3, snapshot_csv, row.names = FALSE)

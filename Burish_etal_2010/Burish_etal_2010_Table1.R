## Burish_etal_2010_Table1.R -- reads Burish_etal_2010_Table1_snapshot.csv (written by Burish_etal_2010_Table1_snapshot.R); builds the analysis CSV + public TSV.
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

paper_dir <- here::here("Burish_etal_2010")
dataset_root  <- dirname(paper_dir)
table_name    <- "Burish_etal_2010_Table1"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. PACKAGES ---------------------------------------------------------------
library(tidyverse)
library(stringr)
library(readxl)
## 2. READ SNAPSHOT ---------------------------------------------------------
# Frozen snapshot written by Burish_etal_2010_Table1_snapshot.R (this script only reads it).
df1 <- read.csv(snapshot_csv, skip = 1L, colClasses = "character", check.names = FALSE)
## 3. MAKE DATA READABLE -----------------------------------------------------
result_df <- df1
# Replace "n.a." with NA in the entire dataframe
result_df <- as.data.frame(sapply(result_df, function(x) gsub("n\\.a\\.", NA, x)))
# Delete the row where Species = "Variation"
result_df <- result_df[-which(result_df$Species == "Variation"), , drop = FALSE]
row.names(result_df) <- NULL
# For every column that carries a "±" (mean ± SD), add an empty "<col>_SD" column
for (col in colnames(result_df)) {
  if (any(grepl("±$", result_df[[col]]))) {
    new_col_name <- paste0(col, "_SD")
    result_df[[new_col_name]] <- NA
  }
}
# Copy each SD (the row below a mean that ends in "±") into its "_SD" column
for (i in 1:(nrow(result_df) - 1)) {
  if (any(sapply(result_df[i, ], function(cell) grepl("±$", cell)))) {
    cols_with_pm <- colnames(result_df)[sapply(result_df[i, ], function(cell) grepl("±$", cell))]
    for (col_pm in cols_with_pm) {
      col_sd <- paste0(col_pm, "_SD")
      result_df[i, col_sd] <- result_df[i + 1, col_pm]
    }
  }
}
# Delete rows where Species is NA, strip the trailing "±", drop blank Species rows
result_df <- result_df[!is.na(result_df$Species), ]
result_df[] <- lapply(result_df, function(x) gsub("±$", "", x))
result_df <- result_df[result_df$Species != "", ]
row.names(result_df) <- NULL
# Remove commas and convert all non-Species columns to numeric
columns_to_convert <- names(result_df)[names(result_df) != "Species"]
result_df[columns_to_convert] <- lapply(result_df[, columns_to_convert], function(x) gsub(",", "", x))
result_df[columns_to_convert] <- lapply(result_df[columns_to_convert], as.numeric)
## 4. CORRECT SPECIES NAME ---------------------------------------------------
result_df$Species[result_df$Species == "Otolemur garnetti"] <- "Otolemur garnettii"
options(scipen = 999)
## 5. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
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

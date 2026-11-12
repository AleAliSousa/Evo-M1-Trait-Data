## Burish_etal_2010_SupplementaryTable1.R -- reads Burish_etal_2010_SupplementaryTable1_snapshot.csv (written by Burish_etal_2010_SupplementaryTable1_snapshot.R); builds the analysis CSV + public TSV.
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
table_name    <- "Burish_etal_2010_SupplementaryTable1"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. PACKAGES ---------------------------------------------------------------
library(dplyr)
library(readxl)
## 2. READ SNAPSHOT ---------------------------------------------------------
# Frozen snapshot written by Burish_etal_2010_SupplementaryTable1_snapshot.R (this script only reads it).
combined_df <- read.csv(snapshot_csv, colClasses = "character", check.names = FALSE)
is_blank <- function(x) is.na(x) | trimws(x) == ""
## 4. MAKE DATA READABLE -----------------------------------------------------
cleaned_df <- combined_df
# drop blank separator rows
all_empty <- apply(cleaned_df, 1, function(r) all(is_blank(r)))
cleaned_df <- cleaned_df[!all_empty, , drop = FALSE]
row.names(cleaned_df) <- NULL
# numeric columns (3:9 and 11); "unknown" / "n.a." coerce to NA
columns_to_convert <- c(3:9, 11)
for (col in columns_to_convert) {
  cleaned_df[[col]] <- suppressWarnings(as.numeric(gsub(",", "", cleaned_df[[col]])))
}
options(scipen = 999)
## 5. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- cleaned_df
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

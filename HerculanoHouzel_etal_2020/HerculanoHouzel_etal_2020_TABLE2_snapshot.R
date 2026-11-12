## HerculanoHouzel_etal_2020_TABLE2_snapshot.R: extracts the snapshot from the PDF; writes only HerculanoHouzel_etal_2020_TABLE2_snapshot.csv.
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

paper_dir <- here::here("HerculanoHouzel_etal_2020")
dataset_root  <- dirname(paper_dir)
table_name    <- "HerculanoHouzel_etal_2020_TABLE2"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
# --- YOU SET THIS MANUALLY ---
pdf_file <- file.path(paper_dir, "Herculano-Houze-2020-Microchiropterans have a.pdf")
## 1. PACKAGES ---------------------------------------------------------------
# Migrated from the retired 'tabulizer' package to 'tabulapdf' (its maintained
# successor). Both wrap the same tabula-java engine.
library(rJava)
library(tabulapdf)
library(tidyverse)
library(readxl)
## 2. EXTRACT TABLE 2 --------------------------------------------------------
# Table 2 is on page 4. Target the data rows with fixed column separators
# (PDF points from top-left): area = c(top, left, bottom, right);
# columns = x of the 8 separators between the 9 columns.
tables1 <- extract_tables(
  pdf_file,
  pages   = 4,
  guess   = FALSE,
  area    = list(c(553, 48, 730, 545)),
  columns = list(c(140, 196, 267, 322, 377, 430, 468, 511)),
  output  = "matrix"
)
df1 <- as.data.frame(tables1[[1]], stringsAsFactors = FALSE)
colnames(df1) <- c(
  "Species", "Micro/mega", "Family",
  "NCX", "NCB", "NRoB", "DN,CX", "DN,Cb", "DN,RoB"
)
## 3. SAVE SNAPSHOT ----------------------------------------------------------
write.csv(df1, snapshot_csv, row.names = FALSE)
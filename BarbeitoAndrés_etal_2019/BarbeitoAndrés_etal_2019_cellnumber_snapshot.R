# BarbeitoAndrés_etal_2019_cellnumber_snapshot.R
# Writes the frozen snapshot BarbeitoAndrés_etal_2019_cellnumber_snapshot.csv/.tsv (data_figshare.xlsx, sheet Hoja1, cell-number block, rows 34-48).
# Run once; BarbeitoAndrés_etal_2019_cellnumber.R reads the snapshot.

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

suppressPackageStartupMessages({ library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr) })
base <- base
folder <- file.path(base, "BarbeitoAndrés_etal_2019")
xls <- file.path(folder, "data_figshare.xlsx")
numv <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
raw <- read_excel(xls, sheet = "Hoja1", col_names = FALSE)

## ---- output helper: TSVs replicate CSVs ----
write_csv_tsv <- function(x, stem, dir = folder) {
  csv_file <- file.path(dir, paste0(stem, ".csv"))
  tsv_file <- file.path(dir, paste0(stem, ".tsv"))

  readr::write_csv(x, csv_file, na = "")
  readr::write_tsv(x, tsv_file, na = "")

  message("Wrote ", csv_file)
  message("Wrote ", tsv_file)
}

## ---- Block 2: cell number ----
cell_regions <- c("Cerebellum","Cortex","Olfactory","Hippocampus","Rest")
cell_cols <- as.vector(t(outer(cell_regions, c("Total","Neurons","Non_neurons"), paste, sep = "__")))
blk <- raw[34:48, ]
names(blk)[1] <- "group"; names(blk)[2:16] <- cell_cols
blk <- blk %>% filter(!is.na(group), group %in% c("C","LP","LCP")) %>%
  mutate(group = as.character(group))
write_csv_tsv(blk, item_name)

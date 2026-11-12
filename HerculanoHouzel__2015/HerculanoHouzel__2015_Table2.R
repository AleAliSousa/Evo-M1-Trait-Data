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
item_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

paper_dir <- dirname(.sp)
dataset_root  <- dirname(paper_dir)
# outputs
snapshot_csv  <- file.path(paper_dir, paste0(item_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. SOURCE  (frozen snapshot HerculanoHouzel__2015_Table2_snapshot.csv, written by HerculanoHouzel__2015_Table2_snapshot.R)
library(tidyverse)
library(dplyr)
library(tidyr)
library(readxl)
df2 <- read.csv(snapshot_csv, check.names = FALSE, colClasses = "character")
## 2.6 Converting to Numeric-------------------------------------------------------
df2 <- df2 %>%
  mutate_all(~ as.numeric(.))
result_df <- df2
## 5. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- result_df
# Item encoded lookup uses item_name (script filename)
filecodes <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
# Local output next to the paper
write.csv(final.dataframe, final_csv, row.names = FALSE)
# Public TSV output
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(final.dataframe,
           file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
           sep = "\t", row.names = FALSE)

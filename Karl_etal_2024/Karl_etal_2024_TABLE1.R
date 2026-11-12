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
table_name    <- "Karl_etal_2024_TABLE1"
# outputs
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. SOURCE (frozen snapshot written by Karl_etal_2024_TABLE1_snapshot.R) ----------
library(tidyverse)
library(dplyr)
library(tidyr)
library(readxl)
df3 <- read.csv(snapshot_csv, check.names = FALSE, colClasses = "character", stringsAsFactors = FALSE)
## 4. MAKE DATA READABLE -----------------------------------------------------
## 4.1 Extract trailing reference letters from brain mass
##     (e.g. "675.0a" → Brain mass = 675.0, Reference = "a")
df4 <- df3 %>%
  mutate(
    Reference = str_extract(`Brain mass (g)`, "[A-Za-z]+$"),
    `Brain mass (g)` = str_remove(`Brain mass (g)`, "[A-Za-z]+$")
  )
## 4.2 Remove thousands separators and coerce numeric columns
numeric_cols <- c(
  "Neuron density (mm2)",
  "Mitochondria density (mm2)",
  "Synapse density (mm2)",
  "PSD length (nm)"
)
result_df <- df4 %>%
  mutate(
    across(
      all_of(numeric_cols),
      ~ as.numeric(str_remove_all(.x, ","))
    )
  )
## 5. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- result_df
# Item encoded lookup uses table_name (script filename)
filecodes <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
# Local output next to the paper
write.csv(final.dataframe, final_csv, row.names = FALSE)
# Public TSV output
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(final.dataframe,
            file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE)

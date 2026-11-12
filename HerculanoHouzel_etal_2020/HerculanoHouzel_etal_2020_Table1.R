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

paper_dir <- here::here("HerculanoHouzel_etal_2020")
dataset_root  <- dirname(paper_dir)
table_name    <- "HerculanoHouzel_etal_2020_TABLE1"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. PACKAGES ---------------------------------------------------------------
library(tidyverse)
library(readxl)
## 2. READ SNAPSHOT (written by HerculanoHouzel_etal_2020_TABLE1_snapshot.R; never regenerated here) ----
df_snapshot <- read.csv(snapshot_csv, colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE)
## 4. MAKE DATA READABLE -----------------------------------------------------
result_df <- df_snapshot %>%
  # split "n" into count + sample notes at the first space
  separate(n, into = c("n", "SampleInfo"), sep = " ", extra = "merge", fill = "right") %>%
  mutate(
    `MBODY, g` = as.numeric(`MBODY, g`),
    `MBRAIN, g` = as.numeric(`MBRAIN, g`),
    NBRAIN = as.numeric(gsub(",", "", NBRAIN)),
    # correct species-name typo (see paper text)
    Species = if_else(Species == "Hypsignathus mostrosus",
                      "Hypsignathus monstrosus", Species)
  )
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

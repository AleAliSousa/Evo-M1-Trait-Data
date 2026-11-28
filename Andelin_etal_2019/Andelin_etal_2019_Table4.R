## 0. PATHS -------------------------------------------------------

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

paper_dir <- here::here("Andelin_etal_2019")
dataset_root  <- dirname(paper_dir)
table_name    <- "Andelin_etal_2019_Table4"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
## 1. PACKAGES ----------------------------------------------------
library(tidyverse)
library(stringr)
library(readxl)
## 2. READ SNAPSHOT (written by Andelin_etal_2019_Table4_snapshot.R; never regenerated here) ----
source_rows <- read.csv(snapshot_csv, header = FALSE, colClasses = "character",
                        check.names = FALSE, stringsAsFactors = FALSE,
                        na.strings = character())
stopifnot(nrow(source_rows) == 8L, ncol(source_rows) == 9L,
          identical(source_rows[4:7, 1], c("AN", "EB", "LB", "SC")))
df_snapshot <- source_rows[4:7, , drop = FALSE]
names(df_snapshot) <- c(
  "Group", "N", "Event time", "V1 Surface area Left", "V1 Surface area Right",
  "Cortex surface area Left", "Cortex surface area Right",
  "% SC VSAR Left", "% SC VSAR Right"
)
## 4. STANDARDIZE --> FINAL TABLE ----------------------------------
measure_cols <- c(
  "V1 Surface area Left",      "V1 Surface area Right",
  "Cortex surface area Left",  "Cortex surface area Right",
  "% SC VSAR Left",            "% SC VSAR Right"
)
final.dataframe <- df_snapshot %>%
  mutate(
    N = as.numeric(N),
    # Event time: ">1.0" -> 1.0 ; en-dash / blank -> NA ; else the number
    Event_time = case_when(
      str_detect(`Event time`, "[0-9]") ~ as.numeric(str_extract(`Event time`, "[0-9.]+")),
      TRUE                              ~ NA_real_
    )
  ) %>%
  mutate(across(all_of(measure_cols), ~ as.numeric(gsub("[ ,]", "", .x)))) %>%
  select(
    Group, N, Event_time,
    `V1 Surface area Left`,     `V1 Surface area Right`,
    `Cortex surface area Left`, `Cortex surface area Right`,
    `% SC VSAR Left`,           `% SC VSAR Right`
  )
## 5. SAVE OUTPUTS -------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, final_csv, row.names = FALSE)
# Public TSV is named with the DOI-encoded code, looked up in __ReadMe.xlsx
# (match this table_name in "Item name" -> use its "Item encoded").
# e.g. Andelin_etal_2019_Table4 -> 10.1093%2Fcercor%2Fbhy315_Table4
filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
if (is.na(item_encoded)) {
  stop("No 'Item encoded' found in __ReadMe.xlsx for Item name: ", table_name)
}
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  final.dataframe,
  file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
  sep = "\t",
  row.names = FALSE
)

## Eagleman_Vaughn_2021_TABLE1_snapshot.R: extracts Table 1 from the PDF and writes ONLY
## Eagleman_Vaughn_2021_TABLE1_snapshot.csv. The item script Eagleman_Vaughn_2021_TABLE1.R reads it.
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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)


paper_dir <- here::here("Eagleman_Vaughn_2021")
dataset_root  <- dirname(paper_dir)
table_name    <- item_name
# outputs
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
## --- YOU SET THIS MANUALLY ---
pdf_file <- file.path(
  paper_dir,
  "Eagleman-2021-The Defensive Activation Theory_.pdf"
)
## 1. PACKAGES ---------------------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)
library(stringr)
## 2. EXTRACT TABLE 1 + SAVE SNAPSHOT ----------------------------------------
# Table 1 is on page 3. The previous version extracted the whole page with
# guess = FALSE and then took a hard-coded row range (slice(7:31)); the current
# tabula engine emits one extra header line, so that slice silently dropped the
# last species (Human). Instead, target the table's data rows with fixed column
# separators and assign headers directly. Coordinates are PDF points from
# top-left:  area = c(top, left, bottom, right); columns = the 5 separators.
tables1 <- extract_tables(
  pdf_file,
  pages   = 3,
  guess   = FALSE,
  area    = list(c(118, 40, 415, 560)),
  columns = list(c(150, 230, 315, 400, 485)),
  output  = "matrix"
)
df0 <- as.data.frame(tables1[[1]], stringsAsFactors = FALSE)
# Headers as printed in the table (two-line labels keep their line breaks).
colnames(df0) <- c(
  "Coloquial name",
  "Time to \nlocomotion\n(Days)",
  "Time to\n weaning\n (Days)",
  "Time to\n adolescence\n (Months)",
  "Percentage of \nsleep in REM",
  "Phylogenetic\n distance from\n humans (M\n years)"
)
# Keep only real species rows (drop any footnote / caption line that crept in).
df_snapshot <- df0 %>%
  filter(
    str_detect(`Coloquial name`, "^[A-Za-z]"),
    !str_detect(`Coloquial name`, "Supplementary|Material|Table|METHODS")
  )
write.csv(df_snapshot, snapshot_csv, row.names = FALSE)

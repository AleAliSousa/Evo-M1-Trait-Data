## HerculanoHouzel_etal_2020_TABLE1_snapshot.R: extracts the snapshot from the PDF; writes only HerculanoHouzel_etal_2020_TABLE1_snapshot.csv.
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
table_name    <- "HerculanoHouzel_etal_2020_TABLE1"
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
## 2. EXTRACT TABLE 1 --------------------------------------------------------
# Table 1 is on page 3. Point tabula at the data rows (caption + header
# excluded) with fixed column separators, so no whole-page text is pulled in.
# Coordinates are PDF points (1/72") from the page's top-left.
#   area    = c(top, left, bottom, right)
#   columns = x of the 7 separators between the 8 columns
tables1 <- extract_tables(
  pdf_file,
  pages   = 3,
  guess   = FALSE,
  area    = list(c(470, 50, 700, 545)),
  columns = list(c(145, 200, 273, 344, 398, 445, 493)),
  output  = "matrix"
)
df0 <- as.data.frame(tables1[[1]], stringsAsFactors = FALSE)
colnames(df0) <- c(
  "Species", "Micro/mega", "Family", "Clade", "n",
  "MBODY, g", "MBRAIN, g", "NBRAIN"
)
## 3. FOLD WRAPPED 'n' VALUES + SAVE SNAPSHOT --------------------------------
# A few 'n' cells wrap onto a second line (e.g. "2 females" / "(1H each)").
# tabula returns the wrap as an extra row that is blank except for n; fold each
# such row's n into the most recent real row. (Replaces the old hard-coded,
# species-by-species merge.)
is_blank <- function(x) is.na(x) | trimws(x) == ""
keep <- integer(0)
for (i in seq_len(nrow(df0))) {
  if (length(keep) > 0 && is_blank(df0$Species[i])) {
    last <- keep[length(keep)]
    df0$n[last] <- trimws(paste(df0$n[last], df0$n[i]))
  } else {
    keep <- c(keep, i)
  }
}
df_snapshot <- df0[keep, , drop = FALSE]
row.names(df_snapshot) <- NULL
write.csv(df_snapshot, snapshot_csv, row.names = FALSE)
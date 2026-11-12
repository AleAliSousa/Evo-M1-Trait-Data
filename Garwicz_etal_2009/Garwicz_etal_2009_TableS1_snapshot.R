## Garwicz_etal_2009_TableS1_snapshot.R -- writes ONLY Garwicz_etal_2009_TableS1_snapshot.csv (Table S1, taxonomy, PDF p. 5); Garwicz_etal_2009_TableS1.R reads it.
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

paper_dir <- here::here("Garwicz_etal_2009")
dataset_root  <- dirname(paper_dir)
table_name    <- "Garwicz_etal_2009_TableS1"
snapshot_s1   <- file.path(paper_dir, "Garwicz_etal_2009_TableS1_snapshot.csv")
snapshot_s2   <- file.path(paper_dir, "Garwicz_etal_2009_TableS2_snapshot.csv")
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
pdf_file <- file.path(paper_dir, "0905777106si.pdf")
## 1. PACKAGES ---------------------------------------------------------------
# Uses 'tabulapdf' (maintained successor to 'tabulizer'). The old, orphaned
# 'tabulizerjars' dependency has been removed -- tabulapdf does not need it.
library(rJava)
library(tabulapdf)
## 2. EXTRACT TABLE S1 + SAVE SNAPSHOT --------------------------------------
# Table S1 (taxonomy) is on page 5. Target the
# table's data rows with fixed column separators and assign headers directly
# (so the old "first row as header" / PC-PN rename patches are no longer
# needed). Coordinates are PDF points (1/72") from the top-left.
# --- Table S1: page 5, 4 columns ---
s1 <- extract_tables(
  pdf_file, pages = 5, guess = FALSE,
  area = list(c(69, 30, 320, 545)),
  columns = list(c(140, 290, 425)),
  output = "matrix"
)
df2 <- as.data.frame(s1[[1]], stringsAsFactors = FALSE)
colnames(df2) <- c("Lay term", "Order/suborder", "Family", "Genus/species")
write.csv(df2, snapshot_s1, row.names = FALSE)

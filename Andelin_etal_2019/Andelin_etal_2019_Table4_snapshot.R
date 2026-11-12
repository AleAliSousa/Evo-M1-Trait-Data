## Andelin_etal_2019_Table4_snapshot.R: extracts the Table 4 snapshot from the PDF; writes only Andelin_etal_2019_Table4_snapshot.csv.
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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)
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
pdf_file <- file.path(
  paper_dir,
  "Andelin-2019-The Effect of Onset Age of Visual.pdf"
)
## 1. PACKAGES ----------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)
library(stringr)
library(readxl)
## 2. EXTRACT TABLE 4 ----------------------------------------------
# Table 4 ("Human surface area means by hemisphere") sits in the lower-LEFT
# column of a two-column page (page 6). The previous version called
# extract_tables(pages = 6, guess = FALSE) with no area, so tabula returned the
# ENTIRE page -- both columns of body text -- and the downstream regex then
# matched any line merely containing "AN"/"EB"/"LB"/"SC" (which also occur in
# the running text), producing a garbled snapshot.
#
# Instead we point tabula at the exact bounding box of the 4 data rows and give
# it the fixed column separators. Coordinates are in PDF points (1/72"),
# measured from the TOP-LEFT of page 6 (page is 594 x 783 pt):
#   area    = c(top, left, bottom, right)  -> the AN/EB/LB/SC rows only
#                                             (excludes the caption above and
#                                              the "Areas in mm2" note below)
#   columns = x of the 8 separators between the 9 columns
area_tbl    <- list(c(665, 52, 713, 290))
columns_tbl <- list(c(78, 92, 135, 157, 181, 208, 236, 263))
tables1 <- extract_tables(
  pdf_file,
  pages   = 6,
  guess   = FALSE,
  area    = area_tbl,
  columns = columns_tbl,
  output  = "matrix"
)
df0 <- as.data.frame(tables1[[1]], stringsAsFactors = FALSE)
# Re-attach the paper's two-row header, flattened to "<measure> <hemisphere>".
colnames(df0) <- c(
  "Group", "N", "Event time",
  "V1 Surface area Left",      "V1 Surface area Right",
  "Cortex surface area Left",  "Cortex surface area Right",
  "% SC VSAR Left",            "% SC VSAR Right"
)
## 3. TIDY + SAVE SNAPSHOT -----------------------------------------
# Keep only the four real group rows, in the paper's order, and drop the thin
# space the typesetting uses as a thousands separator (e.g. "90 447" -> "90447")
# so the snapshot is a clean, faithful copy of Table 4.
drop_digit_space <- function(x) gsub("(?<=\\d)\\s+(?=\\d)", "", x, perl = TRUE)
df_snapshot <- df0 %>%
  filter(str_detect(Group, "^(AN|EB|LB|SC)$")) %>%
  arrange(match(Group, c("AN", "EB", "LB", "SC"))) %>%
  mutate(across(everything(), ~ drop_digit_space(trimws(.x))))
write.csv(df_snapshot, snapshot_csv, row.names = FALSE)
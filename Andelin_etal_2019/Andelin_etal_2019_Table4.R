## 0. PATHS -------------------------------------------------------
library(rstudioapi)

script_path   <- rstudioapi::getActiveDocumentContext()$path
paper_dir     <- dirname(script_path)
dataset_root  <- dirname(paper_dir)
table_name    <- tools::file_path_sans_ext(basename(script_path))

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

## 0. PATHS (NO setwd) -------------------------------------------------------
library(rstudioapi)

script_path   <- rstudioapi::getActiveDocumentContext()$path
paper_dir     <- dirname(script_path)
dataset_root  <- dirname(paper_dir)
table_name    <- tools::file_path_sans_ext(basename(script_path))

# outputs
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")

# --- YOU SET THIS MANUALLY ---
pdf_file <- file.path(paper_dir, "Karl-2024-Invariance of Mitochondria and Synap.pdf")

## 1. SOURCE -----------------------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)
library(dplyr)
library(tidyr)
library(readxl)

# Extract Table 1 (YOU control pages)
tables1 <- extract_tables(pdf_file, pages = c(3))

## 2. FIX FORMATTING AND SAVE SNAPSHOT ---------------------------------------
df1 <- as.data.frame(tables1[[1]])

df2 <- df1

## 2.1. COLLECT HEADER COMPONENTS ---------------------------------------------

# Matrix: rows = (colnames, row1, row2), cols = table columns
header_mat <- rbind(
  colnames(df2),
  as.character(df2[1, ]),
  as.character(df2[2, ])
)

## 2.2. FUNCTION TO CLEAN + COMBINE ONE COLUMN ---------------------------------

make_header <- function(x) {
  x <- x[!is.na(x)]                      # drop NA
  x <- x[!str_detect(x, "^\\.\\.\\.")]   # drop ...1, ...2, etc.
  x <- str_trim(x)
  x <- x[x != ""]                        # drop empty strings
  str_squish(paste(x, collapse = " "))   # combine with spaces
}

## 2.3. BUILD FINAL HEADER ----------------------------------------------------

new_header <- apply(header_mat, 2, make_header)

## 2.4. APPLY HEADER + DROP HEADER ROWS ---------------------------------------

colnames(df2) <- new_header
df2 <- df2[-c(1, 2), ]
row.names(df2) <- NULL

## 3. FIX CONTINUATION ROWS
## 3.1. HELPERS ---------------------------------------------------------------

is_text_only <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(FALSE)
  
  # A cell is numeric if it contains a digit
  any_digit <- str_detect(x, "\\d")
  
  # TRUE if there are NO digits anywhere in the row
  !any(any_digit)
}

merge_cells <- function(a, b) {
  # merge b into a with a space if needed
  if (is.na(b) || b == "") return(a)
  if (is.na(a) || a == "") return(b)
  str_squish(paste(a, b))
}

## 3.2. FIND CONTINUATION ROWS -----------------------------------------------

df3<-df2

cont_rows <- apply(df3, 1, is_text_only)

## 3.3. MERGE UPWARD ----------------------------------------------------------

for (i in which(cont_rows)) {
  if (i == 1) next  # safety
  
  df3[i - 1, ] <- Map(
    merge_cells,
    df3[i - 1, ],
    df3[i, ]
  )
}

## 3.4. DROP CONTINUATION ROWS -----------------------------------------------

df3 <- df3[!cont_rows, , drop = FALSE]
row.names(df3) <- NULL

# Snapshot named from script filename
write.csv(df3, snapshot_csv, row.names = FALSE)

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
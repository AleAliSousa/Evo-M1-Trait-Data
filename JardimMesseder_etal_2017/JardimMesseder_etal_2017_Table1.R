## 1. SOURCE

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


## 2. READ SNAPSHOT (written by JardimMesseder_etal_2017_Table1_snapshot.R)
tabledirectxl <- read.csv(paste0(item_name, "_snapshot.csv"), check.names = FALSE, colClasses = "character",
                          na.strings = "NA", stringsAsFactors = FALSE)
# the snapshot header cell above "MBD, kg" is NA (empty in the source); write.csv stored it as "NA"
names(tabledirectxl)[names(tabledirectxl) == "NA"] <- NA_character_

## 3. MAKE DATA READABLE

# TRANSPOSE
# transpose the dataframe to a matrix
m <- t(tabledirectxl)
# convert from matrix to dataframe
tabledirectxl <- as.data.frame(m)
# Set column names to values in the first row of matrix
colnames(tabledirectxl) <- m[1, ]
# Delete the first row of a dataframe by subsetting it to exclude the first row.
tabledirectxl <- tabledirectxl[-1, , drop = FALSE]
# Create a new column 'Species' with values copied from row names
tabledirectxl$Species <- rownames(tabledirectxl)
# Reorder the columns with "Species" as the first column
tabledirectxl <- tabledirectxl[, c("Species", setdiff(names(tabledirectxl), "Species"))]
# Add a new column with row numbers
tabledirectxl$Row_Numbers <- 1:nrow(tabledirectxl)
# Replace rownames (species names) with Row_numbers
rownames(tabledirectxl) <- tabledirectxl$Row_Numbers
# Delete the "Row_Numbers" column using subset
tabledirectxl <- subset(tabledirectxl, select = -Row_Numbers)

# remove unnecessary string in the whole dataset
tabledirectxl <- data.frame(sapply(tabledirectxl,function(x) gsub("n.a.","",as.character(x))))
tabledirectxl <- data.frame(lapply(tabledirectxl,function(x) gsub(",","",as.character(x))))

## CALCULATE DATA
# Assuming your data frame is named 'tabledirectxl'
for (row in 1:nrow(tabledirectxl)) {
  for (col in 1:ncol(tabledirectxl)) {
    if (grepl(" × 106", tabledirectxl[row, col], fixed = TRUE)) {
      tabledirectxl[row, col] <- gsub(" × 106", "", tabledirectxl[row, col])
      tabledirectxl[row, col] <- as.numeric(tabledirectxl[row, col]) * 10^6
    }
  }
}

# Loop through the columns to convert all values to numeric, except for the first column (Species)
for (col in names(tabledirectxl)) {
  if (col != "Species") {
    tabledirectxl[[col]] <- as.numeric(tabledirectxl[[col]])
  }
}

# SPLIT COLUMN
# Split the Species names (common and scientific) into two columns

# Load the 'tidyr' package
library(tidyr)
library(dplyr)

# Define the column to split and its corresponding new column names
cols_to_split <- c("Species")
new_col_names <- c("Common Name", "Species")

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i], new_col_names[i + 1]),  # New column names without duplication
    sep = "\\s*\\.\\.\\s*",  # Specify the separator as a regular expression to split on '..' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

# MOVE SPECIES COLUMN, TIDY CHARACTERS, RESTORE ABBREVIATED TERMS
# Identify the column indices for "Species" and "Common Name"
species_col_index <- which(colnames(tabledirectxl) == "Species")
common_name_col_index <- which(colnames(tabledirectxl) == "Common Name")

# Specify the order of all columns
column_order <- c(species_col_index, common_name_col_index, setdiff(seq_along(tabledirectxl), c(species_col_index, common_name_col_index)))

# Reorder the columns
tabledirectxl <- tabledirectxl[, column_order]

# Rename the columns to ensure "Species" is the first column and "Common Name" is the second column
colnames(tabledirectxl) <- c("Species", "Common Name", colnames(tabledirectxl)[-c(species_col_index, common_name_col_index)])

# Replace "." with " " in the "Species", "Common Name" columns
tabledirectxl$Species <- gsub("\\.", " ", tabledirectxl$Species)
tabledirectxl$"Common Name" <- gsub("\\.", " ", tabledirectxl$"Common Name")
# Remove leading and trailing whitespace from the "Species" column
tabledirectxl$Species <- trimws(tabledirectxl$Species)

# Restore original abbreviated terms in column names
colnames(tabledirectxl) <- gsub("O.N", "O/N", colnames(tabledirectxl))
# # replace ".g" with "..g" and ".kg" with "..kg"
colnames(tabledirectxl) <- gsub("\\.\\.(g|kg)", ".\\1", colnames(tabledirectxl))

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. SAVE
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(.sp))

# Get Item encoded
library(readxl) 
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- paste0(file.path(base, "__Public", "comparative-data"), "/")
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
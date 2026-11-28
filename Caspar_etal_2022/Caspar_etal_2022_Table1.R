# Table 1

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

setwd(folder)

## 1. Read the printed two-page grid; captions and repeated headers stay in the snapshot
library(readxl)
raw <- read_excel("Caspar_etal_2022_Table1_snapshot.xlsx", col_names = FALSE,
                  col_types = "text")
header_row <- which(raw[[1]] == "Species")[1]
stopifnot(length(header_row) == 1L, !is.na(header_row))
header <- as.character(unlist(raw[header_row, ], use.names = FALSE))
header[is.na(header) | !nzchar(header)] <- paste0("unused_", which(is.na(header) | !nzchar(header)))
tabledirectxl <- raw[-seq_len(header_row), , drop = FALSE]
names(tabledirectxl) <- header
tabledirectxl <- tabledirectxl[!is.na(tabledirectxl$Species) &
                               grepl("^[0-9]+$", tabledirectxl$N), , drop = FALSE]

## 2. Genus totals are printed once per genus, sometimes on its last or
## middle species row. Propagate only within the matching genus in R.
genus <- sub(" .*", "", tabledirectxl$Species)
genus_cols <- c("nGenus", "Genus direction bias (HI), p value",
                "Genus L/R/A distribution, p value")
for (rows in split(seq_len(nrow(tabledirectxl)), genus)) {
  for (column in genus_cols) {
    observed <- tabledirectxl[[column]][rows]
    observed <- observed[!is.na(observed) & nzchar(observed)]
    stopifnot(length(unique(observed)) == 1L)
    tabledirectxl[[column]][rows] <- observed[1]
  }
}

## 4. Split 3 columns containing both frequency (#) and percentage (%) into 6 different columns.

# Load the 'tidyr' package
library(tidyr)

# Modify all occurrences of "0" in the "# Ambipreferent (%)" column to "0(0)"
tabledirectxl$`# Ambipreferent (%)` <- gsub("^0$", "0 (0)", tabledirectxl$`# Ambipreferent (%)`, perl = TRUE)

# Define the columns to split and their corresponding new column names
cols_to_split <- c("# Left (%)", "# Right (%)", "# Ambipreferent (%)")
new_col_names <- c("# Left", "Left %", "# Right", "Right %", "# Ambipreferent", "Ambipreferent %")

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], " %")),  # New column names with space before %
    sep = " \\(|\\)",  # Specify the separator as a regular expression to split on ' (' and ')'
    extra = "drop"  # Drop any extra pieces
  )
}

## 5. Species note 
# paper indicates the Gorilla gorilla is Western gorilla.
# Add a new column "Species note" and set the value for "Gorilla gorilla"
tabledirectxl$`Species note` <- NA  # Create a new column with NAs
tabledirectxl[tabledirectxl$Species == "Gorilla gorilla", "Species note"] <- "Western gorilla"

## 6. Correct signs and make numerical data usable
# Replace non-standard minus signs with standard minus sign character
tabledirectxl$MeanHI <- gsub("–", "-", tabledirectxl$MeanHI)

# Convert individual columns to numeric
tabledirectxl$N <- as.numeric(tabledirectxl$N)
tabledirectxl$`# Left` <- as.numeric(tabledirectxl$`# Left`)
tabledirectxl$`# Left %` <- as.numeric(tabledirectxl$`# Left %`)
tabledirectxl$`# Right` <- as.numeric(tabledirectxl$`# Right`)
tabledirectxl$`# Right %` <- as.numeric(tabledirectxl$`# Right %`)
tabledirectxl$`# Ambipreferent` <- as.numeric(tabledirectxl$`# Ambipreferent`)
tabledirectxl$`# Ambipreferent %` <- as.numeric(tabledirectxl$`# Ambipreferent %`)
tabledirectxl$MeanHI <- as.numeric(tabledirectxl$MeanHI)
tabledirectxl$MeanAbsHI <- as.numeric(tabledirectxl$MeanAbsHI)
tabledirectxl$nGenus <- as.numeric(tabledirectxl$nGenus)

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 7. Save

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

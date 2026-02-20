## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Kverkova_etal_2018")

# Read directly from online docx file
# Load docxtractr
library(docxtractr)
# Define the PDF file path
docx <- read_docx("https://static-content.springer.com/esm/art%3A10.1038%2Fs41598-018-26062-8/MediaObjects/41598_2018_26062_MOESM1_ESM.docx")
# Use docx_extract_all_tbls
tables5 <- docx_extract_all_tbls(docx,guess_header=TRUE,preserve=FALSE,trim=TRUE)

# Replace any "." with "" in the column names
colnames(tables5[[5]]) <- gsub("\\.", " ", colnames(tables5[[5]]))
# Replace any "106" with ", x 10ˆ6" in the column names with a single space before "x"
colnames(tables5[[5]]) <- gsub("\\s*106", ", x 10ˆ6", colnames(tables5[[5]]))

# Replace any "±" "± " or " ±" without both a space before/after to " ± " with spaces both before and after in data of tables1[[1]]
tables5[[5]] <- apply(tables5[[5]], 2, function(x) gsub("(?<![[:space:]])±( |%)|(?<![[:space:]])± | ±(?![[:space:]])", " ± ", x, perl=TRUE))

# Save the data frame to a "primary or equivalent" to a CSV file
write.csv(tables5[[5]], file = "Kverkova_etal_2018_TableS5_snapshot.csv", row.names = FALSE)

## 2. MAKE READABLE

# Convert the table matrix into a dataframe
df5 <- as.data.frame(tables5[[5]])

# Define the columns to split and their corresponding new column names
library(tidyr)

cols_to_split <- c(
  "Whole brain, x 10ˆ6", "Olfactory bulbs, x 10ˆ6", "Cortex, x 10ˆ6",
  "Subcortical forebrain, x 10ˆ6", "Cerebellum, x 10ˆ6", "Brain stem, x 10ˆ6"
)

new_col_names <- c(
  "Whole brain, x 10ˆ6", "Whole brain, x 10ˆ6_SD",
  "Olfactory bulbs, x 10ˆ6", "Olfactory bulbs, x 10ˆ6_SD",
  "Cortex, x 10ˆ6", "Cortex, x 10ˆ6_SD",
  "Subcortical forebrain, x 10ˆ6", "Subcortical forebrain, x 10ˆ6_SD",
  "Cerebellum, x 10ˆ6", "Cerebellum, x 10ˆ6_SD",
  "Brain stem, x 10ˆ6", "Brain stem, x 10ˆ6_SD"
)

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  df5 <- separate(
    df5,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], "_SD")),  # New column names with space before SD
    sep = "\\s*±\\s*",  # Specify the separator as a regular expression to split on ' ±' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

## 3. SPECIES CORRECTION

# Complete abbreviated species name based on reference in supplement
df5$Species[df5$Species == "Heliophobius argent."] <- "Heliophobius argenteocinereus"

# Convert the columns to numeric excluding the first column called "Species" in dataframe df5 from the list of numeric columns

df5[, names(df5) != "Species"] <- lapply(df5[, names(df5) != "Species"], as.numeric)

## 4. CALCULATE DATA

print(colnames(df5))
# Multiply all data by 10ˆ6
# Assuming your data frame is named 'df5'
df5[, -1] <- df5[, -1] * 10^6

# Drop ", x 10ˆ6" from all column names
colnames(df5) <- gsub(", x 10ˆ6", "_N.n", colnames(df5), fixed = TRUE)

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 5. SAVE

# Finalize dataframe (UPDATE!!!)
final.dataframe <- df5

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
library(readxl) 
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
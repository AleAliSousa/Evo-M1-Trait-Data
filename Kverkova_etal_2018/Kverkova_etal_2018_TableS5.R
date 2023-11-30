## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/Kverkova_etal_2018")

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
write.csv(tables5[[5]], file = "Kverkova_etal_2018_TableS5_primary_or_equivalent.csv", row.names = FALSE)

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
  "Whole brain, x 10ˆ6", "Whole brain, x 10ˆ6 SD",
  "Olfactory bulbs, x 10ˆ6", "Olfactory bulbs, x 10ˆ6 SD",
  "Cortex, x 10ˆ6", "Cortex, x 10ˆ6 SD",
  "Subcortical forebrain, x 10ˆ6", "Subcortical forebrain, x 10ˆ6 SD",
  "Cerebellum, x 10ˆ6", "Cerebellum, x 10ˆ6 SD",
  "Brain stem, x 10ˆ6", "Brain stem, x 10ˆ6 SD"
)

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  df5 <- separate(
    df5,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], " SD")),  # New column names with space before SD
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
colnames(df5) <- gsub(", x 10ˆ6", "", colnames(df5), fixed = TRUE)

## 5. SAVE

# Save the dataframe to a CSV file
write.csv(df5, file = "Kverkova_etal_2018_TableS5.csv", row.names = FALSE)

# Save the dataframe to a TSV file for online database
write.csv(df5, file = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__Public/comparative-data/10.1038%2Fs41598-018-26062-8_TableS5.tsv", row.names = FALSE)

## Export colnames to merge terms
# Edit for your existing DATAFRAME and TABLE
# Create a new dataframe with the desired structure
new_dataframe <- data.frame(
  Original_Term = rep("", ncol(df5)),  # Empty character column with the same number of rows as columns in df5
  Standardized_Term = colnames(df5),  # Column headers from df5
  Reference = rep("Kverkova_etal_2018_TableS5", ncol(df5)),  # Reference column
  Description = rep("", ncol(df5))  # Empty character column with the same number of rows as columns in df5
)

# Save the new dataframe to a CSV file
file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging/Kverkova_etal_2018_TableS5_terms.csv"
write.csv(new_dataframe, file_path, row.names = FALSE)

# Print the new dataframe
print(new_dataframe)

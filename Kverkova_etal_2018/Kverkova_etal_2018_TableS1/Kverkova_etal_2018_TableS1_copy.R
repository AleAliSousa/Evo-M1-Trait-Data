## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/Kverkova_etal_2018/Kverkova_etal_2018_TableS1")

# Copy a Word table into Excel 
# In Word document, select the rows and columns of the table to copy to an Excel worksheet. 
# top and bottom of Table S1 done separately.

## 2. Read from xl
library(readxl)
matrix1 <- as.matrix(read_excel("Kverkova_etal_2018_TableS1_primary_or_equivalent.xlsx"))

# Delete row 25 which is just a space
matrix1 <- matrix1[-25, , drop = FALSE]


# Split the matrices into two based on the header start index
# Find the indices where the first column is "Species" in matrix1
header_start_index <- which(matrix1[, 1] == "Species")

# Use the indices to split the matrix into two parts
matrix1_top <- matrix1[1:(header_start_index[2] - 1), ]
matrix1_bottom <- matrix1[(header_start_index[2]):nrow(matrix1), ]

# Check if the "Species" column is identical
are_species_identical <- identical(matrix1_top[, 1] == "Species", matrix1_bottom[, 1] == "Species")
# Print the result
cat("Are the 'Species' columns identical? ", are_species_identical, "\n")

# Combine the two matrices based on row numbers
matrix1 <- cbind(matrix1_top, matrix1_bottom)

# Load the zoo package
library(zoo)

# Use na.locf to fill missing values in the first column with values from the row above
matrix1[, 1] <- zoo::na.locf(matrix1[, 1], na.rm = FALSE)

# Print the resulting matrix
print(matrix1)


# # Read directly from online docx file
# # Load docxtractr
# library(docxtractr)
# # Define the PDF file path
# docx <- read_docx("https://static-content.springer.com/esm/art%3A10.1038%2Fs41598-018-26062-8/MediaObjects/41598_2018_26062_MOESM1_ESM.docx")
# # Use docx_extract_all_tbls
# tables1 <- docx_extract_all_tbls(docx,guess_header=TRUE,preserve=FALSE,trim=TRUE)

# Replace any "." with "" in the column names of tables1[[1]]
colnames(tables1[[1]]) <- gsub("\\.", " ", colnames(tables1[[1]]))

# Replace any "±" "± " or " ±" without both a space before/after to " ± " with spaces both before and after in data of tables1[[1]]
tables1[[1]] <- apply(tables1[[1]], 2, function(x) gsub("(?<![[:space:]])±( |%)|(?<![[:space:]])± | ±(?![[:space:]])", " ± ", x, perl=TRUE))

# Convert the table matrix into a dataframe
df1 <- as.data.frame(tables1[[1]])

# Save the data frame to a "primary or equivalent" to a CSV file
write.csv(df1, file = "Kverkova_etal_2018_TableS1_primary_or_equivalent.csv", row.names = FALSE)

## 2. Make data readable

# Rearrange the split and stacked table
# Find the index where the header is "Species" in df1
header_start_index <- which(df1$Species == "Species")[1]

# Split the dataframe into two based on the header start index
df1_top <- df1[1:(header_start_index - 1), ]
df1_bottom <- df1[(header_start_index + 1):nrow(df1), ]

# Use df1 row 12 values for the headers of df1_bottom
colnames(df1_bottom) <- (df1)[12, ]

# Combine the two dataframes based on the "Species" column
df1 <- merge(df1_top, df1_bottom, by = "Species", all = TRUE)

# Reset the row names
rownames(df1) <- NULL

# Split columns
# Load the 'tidyr' package
library(tidyr)

# Define the columns to split and their corresponding new column names
cols_to_split <- c(
  "Body mass", "Brain mass", "Olfactory bulbs", "Olfactory cortices",
  "Neocortex", "Entorhinal cortex", "Hippocampus", "Amygdala",
  "Striatum", "Septum", "Thalamus", "Hypothalamus",
  "Cerebellum", "Tectum", "Tegmentum", "Medulla oblongata"
)

new_col_names <- c(
  "Body mass", "Body mass SD", "Brain mass", "Brain mass SD",
  "Olfactory bulbs", "Olfactory bulbs SD", "Olfactory cortices", "Olfactory cortices SD",
  "Neocortex", "Neocortex SD", "Entorhinal cortex", "Entorhinal cortex SD",
  "Hippocampus", "Hippocampus SD", "Amygdala", "Amygdala SD",
  "Striatum", "Striatum SD", "Septum", "Septum SD",
  "Thalamus", "Thalamus SD", "Hypothalamus", "Hypothalamus SD",
  "Cerebellum", "Cerebellum SD", "Tectum", "Tectum SD",
  "Tegmentum", "Tegmentum SD", "Medulla oblongata", "Medulla oblongata SD"
)

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  df1 <- separate(
    df1,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], " SD")),  # New column names with space before SD
    sep = "\\s*±\\s*",  # Specify the separator as a regular expression to split on ' ±' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

# Make data numerical
# Columns to convert to numeric
numeric_columns <- c(
  "Body mass", "Body mass SD", "Brain mass", "Brain mass SD",
  "Olfactory bulbs", "Olfactory bulbs SD", "Olfactory cortices", "Olfactory cortices SD",
  "Neocortex", "Neocortex SD", "Entorhinal cortex", "Entorhinal cortex SD",
  "Hippocampus", "Hippocampus SD", "Amygdala", "Amygdala SD",
  "Striatum", "Striatum SD", "Septum", "Septum SD",
  "Thalamus", "Thalamus SD", "Hypothalamus", "Hypothalamus SD",
  "Cerebellum", "Cerebellum SD", "Tectum", "Tectum SD",
  "Tegmentum", "Tegmentum SD", "Medulla oblongata", "Medulla oblongata SD"
)

# Convert the specified columns to numeric in df1
df1[numeric_columns] <- lapply(df1[numeric_columns], as.numeric)


## 7. Save as csv

# Save the data frame to a CSV file
write.csv(df1, file = "Kverkova_etal_2018_TableS1.csv", row.names = FALSE)

## 8. Save as tsv with DOI file name

# Save the data frame to a TSV file
write.csv(df1, file = "10.1038%2Fs41598-018-26062-8_tables1.tsv", row.names = FALSE)



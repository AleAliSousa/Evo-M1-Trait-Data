## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Kverkova_etal_2018")

# Copy a Word table into Excel 
# In Word document, select the rows and columns of the table to copy to an Excel worksheet. 
# top and bottom of Table S1 done separately.

# Read from xlsx
library(readxl)
matrix1 <- as.matrix(read_excel("Kverkova_etal_2018_TableS1_primary_or_equivalent.xlsx"))

## 2. MAKE READABLE

# Rename columns
colnames(matrix1) <- matrix1[1, ]

# Delete row 25 which is just a space
matrix1 <- matrix1[-25, , drop = FALSE]

# Merge text in rows 25 and 26
# Replace NAs with empty strings in the matrix1[26, ]
matrix1[26, ][is.na(matrix1[26, ])] <- ""
# Combine text from rows 25 and 26, separated by a space
matrix1[25, ] <- paste(matrix1[25, ], matrix1[26, ])
# Update row 25 with the combined text

# Remove text in row 26 and row 2 (to match them)
matrix1[26, ] <- ""
matrix1[2, ] <- ""
# Trim whitespace in row 25
matrix1[25, ] <- trimws(matrix1[25, ])

# Create a new column for type in matrix1
# Insert 'type' column to the right of the first column, and keep the remaining columns.
matrix1 <- cbind(
  matrix1[, 1],  # Keep the first column
  type = ifelse(is.na(matrix1[, 2]) | matrix1[, 2] == "", "_p.C.Brain", ""),  # Create 'type' column
  matrix1[, -c(1)]  # Keep the remaining columns
)

# Split the matrices into two based on the header start index
# Find the indices where the first column is "Species" in matrix1
header_start_index <- which(matrix1[, 1] == "Species")
# Use the indices to split the matrix into two parts
matrix1_top <- matrix1[1:(header_start_index[2] - 1), ]
matrix1_bottom <- matrix1[(header_start_index[2]):nrow(matrix1), ]

# Rename columns
colnames(matrix1_top) <- matrix1_top[1, ]
colnames(matrix1_bottom) <- matrix1_bottom[1, ]

# Check if the "Species" (and type) column is identical
are_species_identical <- identical(matrix1_top[, 1] == "Species", matrix1_bottom[, 1] == "Species")
are_type_identical <- identical(matrix1_top[, 2], matrix1_bottom[, 2])

# Merge matrices based on the first two columns
combined_matrix <- cbind(matrix1_top, matrix1_bottom)

# Check if the "Species"(and type)  column is identical / repeated
are_species_identical2 <- identical(combined_matrix[, 1] == "Species", combined_matrix[, 11] == "Species")
are_type_identical2 <- identical(combined_matrix[, 2], combined_matrix[, 12])

# Delete columns 11 and 12 which are repeated or unneeded
combined_matrix <- combined_matrix[, -c(11, 12)]

# Delete rows 1,2 which are place holders
combined_matrix <- combined_matrix[-c(1, 2), ]

# Load the zoo package
library(zoo)

# Use na.locf to fill missing values in the first column with values from the row above
combined_matrix[, 1] <- zoo::na.locf(combined_matrix[, 1], na.rm = FALSE)

# Convert the table matrix into a dataframe
combined_df <- as.data.frame(combined_matrix, header = FALSE)

# Make new columns based on the percentage of brain values
# The "Species" column has repeated values. Pivoting will be used to reorganize
# Check the "V2" data # Display the unique values and their frequencies
V2_counts <- table(combined_df$V2)

# Use pivot_wider to convert to more variables
library(tidyverse)
df1 <- combined_df %>%
  pivot_wider(
    names_from = V2,
    values_from = c("Olfactory bulbs", "Olfactory cortices", "Neocortex", "Entorhinal cortex", "Hippocampus", "Amygdala", "Striatum", "Septum", "Thalamus", "Hypothalamus", "Cerebellum", "Tectum", "Tegmentum", "Medulla oblongata"),
    names_glue = "{.value}{V2}",
    values_fill = NA
  ) 

# Summarize the column for each species (collapse Species pairs of rows). 
library(dplyr)
# If for a species all values in a column are NA, the entire column is filled with NA. Otherwise, the first non-NA value is retained.
df1_combined <- df1 %>%
  group_by(Species) %>%
  summarise(across(everything(), ~ ifelse(all(is.na(.)), NA, first(na.omit(.)))))

# Define the columns to split and their corresponding new column names. 
library(tidyr)
cols_to_split <- c(
  "Body mass", "Brain mass", "Olfactory bulbs", "Olfactory cortices",
  "Neocortex", "Entorhinal cortex", "Hippocampus", "Amygdala",
  "Striatum", "Septum", "Thalamus", "Hypothalamus",
  "Cerebellum", "Tectum", "Tegmentum", "Medulla oblongata"
)
# Give measurement details based on Table note. Elsewhere in Supplement it is indicated that Body mass is in (g)
new_col_names <- c(
  "Body_Mass.g", "Body_Mass.g_SD", "Brain_Mass.g", "Brain_Mass.g_SD",
  "Olfactory bulbs_Vol.mm3", "Olfactory bulbs_Vol.mm3_SD", "Olfactory cortices_Vol.mm3", "Olfactory cortices_Vol.mm3_SD",
  "Neocortex_Vol.mm3", "Neocortex_Vol.mm3_SD", "Entorhinal cortex_Vol.mm3", "Entorhinal cortex_Vol.mm3_SD",
  "Hippocampus_Vol.mm3", "Hippocampus_Vol.mm3_SD", "Amygdala_Vol.mm3", "Amygdala_Vol.mm3_SD",
  "Striatum_Vol.mm3", "Striatum_Vol.mm3_SD", "Septum_Vol.mm3", "Septum_Vol.mm3_SD",
  "Thalamus_Vol.mm3", "Thalamus_Vol.mm3_SD", "Hypothalamus_Vol.mm3", "Hypothalamus_Vol.mm3_SD",
  "Cerebellum_Vol.mm3", "Cerebellum_Vol.mm3_SD", "Tectum_Vol.mm3", "Tectum_Vol.mm3_SD",
  "Tegmentum_Vol.mm3", "Tegmentum_Vol.mm3_SD", "Medulla oblongata_Vol.mm3", "Medulla oblongata_Vol.mm3_SD"
)

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  df1_combined <- separate(
    df1_combined,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], "_SD")),  # New column names with space before SD
    sep = "\\s*±\\s*",  # Specify the separator as a regular expression to split on ' ±' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

# Convert the columns to numeric excluding the first column called "Species" in dataframe df1_combined from the list of numeric columns
df1_combined[, names(df1_combined) != "Species"] <- lapply(df1_combined[, names(df1_combined) != "Species"], as.numeric)

## 3. SPECIES CORRECTION

# Complete abbreviated species name based on reference in supplement
df1_combined$Species[df1_combined$Species == "Heliophobius argent."] <- "Heliophobius argenteocinereus"

## 5. SAVE

# Save the dataframe to a CSV file
write.csv(df1_combined, file = "Kverkova_etal_2018_TableS1.csv", row.names = FALSE)

# Save the dataframe to a TSV file for online database
write.csv(df1_combined, file = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/10.1038%2Fs41598-018-26062-8_TableS1.tsv", row.names = FALSE)

## Export colnames to merge terms
# Edit for your existing DATAFRAME and TABLE
# Create a new dataframe with the desired structure
new_dataframe <- data.frame(
  Original_Term = colnames(df1_combined),  # Column headers from df1_combined
  Reference = rep("Kverkova_etal_2018_TableS1", ncol(df1_combined))  # Reference column
)

# Save the new dataframe to a CSV file
file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging/Kverkova_etal_2018_TableS1_terms.csv"
write.csv(new_dataframe, file_path, row.names = FALSE)

# Print the new dataframe
print(new_dataframe)

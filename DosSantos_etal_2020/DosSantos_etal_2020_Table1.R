## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./DosSantos_etal_2020/"

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "https://www.jneurosci.org/content/jneuro/40/24/4622.full.pdf"
# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = c(4:6))

## 2. FIX FORMATTING AND SAVE SNAPSHOT
# Convert the matrices into data frames
df1 <- as.data.frame(tables1[[1]])
df2 <- as.data.frame(tables1[[2]])
df3 <- as.data.frame(tables1[[3]])

# Combine the top two rows and set as the header row, adding spaces where collapsed
header <- paste(df1[1, ], df1[2, ])

# Trim whitespace from the header
header=trimws(header)

# Remove the first row
df1 <- df1[-1, ]
df2 <- df2[-1, ]
df3 <- df3[-1, ]

# Use the now first row as column names for the first matrix in tables1
colnames(df1) <- header
colnames(df2) <- header
colnames(df3) <- header

# Deal with shifted header in df3
# Shift column names in df3 for columns 6-9
colnames(df3)[6:9] <- colnames(df3)[5:8]

# Delete the now first row 
df1 <- df1[-1, ]
df2 <- df2[-1, ]
df3 <- df3[-1, ]

# Delete empty columns
df1 <- df1[, colSums(df1  != "") > 0]
df2 <- df2[, colSums(df2  != "") > 0]
df3 <- df3[, colSums(df3  != "") > 0]

# Load the dplyr package if not already loaded
library(dplyr)

# Stack df1, df2, and df3 into a new combined data frame
combined_df <- bind_rows(df1, df2, df3)

# Deal with empty row where the name was split among two rows
# Combine the text from rows 155 and 156 into row 155
combined_df[155,] <- paste(combined_df[155,], combined_df[156,], sep = " ")
# Delete row 156
combined_df <- combined_df[-156, ]
# Trim whitespace
combined_df[155,]=trimws(combined_df[155,])

# Deal with converted symbol
# in combined_df column "Structure" change string from "P1M" to "P+M"
combined_df$Structure[combined_df$Structure == "P1M"] <- "P+M"

# Save snapshot as a CSV file
write.csv(combined_df, paste0(folder_path, file = "DosSantos_etal_2020_Table1_snapshot.csv"), row.names = FALSE)

## 3. MAKE DATA READABLE
# Assuming combined_df is your data frame
columns_to_clean <- c("Structure mass (g)", "C", "N", "I", "N/mg", "I/mg")

# Loop through columns and remove spaces
for (col in columns_to_clean) {
  combined_df[[col]] <- gsub(" ", "", combined_df[[col]])
}

# Convert specified columns to numeric
columns_to_convert <- c("Structure mass (g)", "C", "N", "I", "N/mg", "I/mg", "I/N", "No. of samples")
combined_df[, columns_to_convert] <- lapply(combined_df[, columns_to_convert], as.numeric)

# Remove * at the end of the string
combined_df$`Structure` <- gsub("\\*", "", combined_df$`Structure`)
# combined_df$`Structure` <- gsub("\\*{1,2}$", "", combined_df$`Structure`) # to only remove one or two occurrences of *

# The "Species names" column has repeated values. Pivoting will be used to reorganize by "Structure"
# Check the "Structure" data
# Display the unique values and their frequencies
structure_counts <- table(combined_df$Structure)
print(structure_counts)

# Load the tidyverse package
library(tidyverse)

# Assuming your data frame is called 'combined_df'
result_df <- combined_df %>%
  # Pivot wider to spread the 'Variable' columns
  pivot_wider(names_from = Structure,
              values_from = c("Structure mass (g)", "C", "N", "I", "N/mg", "I/mg", "I/N", "No. of samples"),
              names_glue = "{Structure}_{.value}",
              values_fill = NA) %>%
  # Arrange columns alphabetically, including 'Species name'
  select("Species name", sort(colnames(.)))


# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. Save

# Finalize dataframe (UPDATE!!!)
final.dataframe <- result_df

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
library(readxl) 
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "./__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)


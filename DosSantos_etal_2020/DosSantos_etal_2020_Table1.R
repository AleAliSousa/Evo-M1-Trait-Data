## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/DosSantos_etal_2020")

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "https://www.jneurosci.org/content/jneuro/40/24/4622.full.pdf"
# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = c(4:6))

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

# Save the data frame to a "primary or equivalent" to a CSV file
write.csv(combined_df, file = "dossantos_etal_2020_Table1_primary_or_equivalent.csv", row.names = FALSE)

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

# Save the data frame to a CSV file
write.csv(result_df, file = "DosSantos_etal_2020_Table1.csv", row.names = FALSE)

# Save the data frame to a TSV file for online database
write.csv(result_df, file = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__Public/comparative-data/10.1523%2FJNEUROSCI.2339-19.2020%0A_table1.tsv", row.names = FALSE)

## Export colnames to merge terms
# Edit for your existing DATAFRAME and TABLE
# Create a new dataframe with the desired structure
new_dataframe <- data.frame(
  Original_Term = colnames(result_df),  # Column headers from result_df
  Reference = rep("DosSantos_etal_2020_Table1", ncol(result_df))  # Reference column
)

# Save the new dataframe to a CSV file
file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging/DosSantos_etal_2020_Table1_terms.csv"
write.csv(new_dataframe, file_path, row.names = FALSE)

# Print the new dataframe
print(new_dataframe)

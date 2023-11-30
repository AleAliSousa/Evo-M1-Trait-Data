## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/HerculanoHouzel_etal_2020")

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/HerculanoHouzel_etal_2020/Herculano-Houze-2020-Microchiropterans have a.pdf"
# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = c(3))

# Convert the matrix into a dataframe
df1 <- as.data.frame(tables1[[1]])

# Set the first row as the header
colnames(df1) <- df1[1,]

# Remove the first row (which is now the header)
df1 <- df1[-1,]

# Renumber the rows
rownames(df1) <- NULL

# Function to combine and clean rows by value in the "Species" column
combine_and_clean_by_species <- function(df, species_value) {
  row_number <- which(df$Species == species_value)
  if (length(row_number) == 0) {
    cat("Row value not found in 'Species' column:", species_value, "\n")
    return(df)
  }
  
  df[row_number,] <- trimws(paste(df[row_number,], df[row_number + 1,], sep = " "))
  df <- df[-(row_number + 1), ]
  rownames(df) <- NULL
  return(df)
}

# Apply the function for the specified values in the "Species" column
df1 <- combine_and_clean_by_species(df1, "Hipposideros commersoni")
df1 <- combine_and_clean_by_species(df1, "Chaerephon pumilus")
df1 <- combine_and_clean_by_species(df1, "Epomophorus wahlbergi")
df1 <- combine_and_clean_by_species(df1, "Rousettus aegyptiacus")
df1 <- combine_and_clean_by_species(df1, "Hypsignathus mostrosus")

# Save the data frame to a "primary or equivalent" to a CSV file
write.csv(df1, file = "HerculanoHouzel_etal_2020_Table1_primary_or_equivalent.csv", row.names = FALSE)

# Loop through columns and remove commas in numbers
columns_to_clean <- c("NBRAIN")
for (col in columns_to_clean) {
  df1[[col]] <- gsub(",", "", df1[[col]])
}

# Convert specified columns to numeric
columns_to_convert <- c("MBODY, g", "MBRAIN, g", "NBRAIN")
df1[, columns_to_convert] <- lapply(df1[, columns_to_convert], as.numeric)

# Save the data frame to a CSV file
write.csv(df1, file = "HerculanoHouzel_etal_2020_Table1.csv", row.names = FALSE)

# Save the data frame to a TSV file for online database
write.csv(df1, file = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__Public/comparative-data/10.1002%2Fcne.24985_Table1.tsv", row.names = FALSE)

## Export colnames to merge terms
# Edit for your existing DATAFRAME and TABLE
# Create a new dataframe with the desired structure
new_dataframe <- data.frame(
  Original_Term = rep("", ncol(df1)),  # Empty character column with the same number of rows as columns in df1
  Standardized_Term = colnames(df1),  # Column headers from df1
  Reference = rep("HerculanoHouzel_etal_2020_Table1", ncol(df1)),  # Reference column
  Description = rep("", ncol(df1))  # Empty character column with the same number of rows as columns in df1
)

# Save the new dataframe to a CSV file
file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging/HerculanoHouzel_etal_2020_Table1_terms.csv"
write.csv(new_dataframe, file_path, row.names = FALSE)

# Print the new dataframe
print(new_dataframe)

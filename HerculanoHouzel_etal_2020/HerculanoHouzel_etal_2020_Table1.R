## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2020")

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2020/Herculano-Houze-2020-Microchiropterans have a.pdf"
# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = c(3))

# Convert the matrix into a dataframe
df1 <- as.data.frame(tables1[[1]])

## 2. FIX FORMATTING AND SAVE SNAPSHOT
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

# Save snapshot to a CSV file 
write.csv(df1, file = "HerculanoHouzel_etal_2020_TABLE1_snapshot.csv", row.names = FALSE)

## 3. MAKE DATA READABLE
# Loop through columns and remove commas in numbers
columns_to_clean <- c("NBRAIN")
for (col in columns_to_clean) {
  df1[[col]] <- gsub(",", "", df1[[col]])
}

# Convert specified columns to numeric
columns_to_convert <- c("MBODY, g", "MBRAIN, g", "NBRAIN")
df1[, columns_to_convert] <- lapply(df1[, columns_to_convert], as.numeric)

## 4. CORRECT SPECIES NAME TYPO
# See paper text for correct spelling of species
df1$Species[df1$Species == "Hypsignathus mostrosus"] <- "Hypsignathus monstrosus"

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)


## 5. SAVE
# Finalize dataframe (UPDATE!!!)
final.dataframe <- df1

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

## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")

# Table 5
## 1. Read direct from xl
library(readxl)
folder_path <- "./HerculanoHouzel_etal_2015/"
tabledirectxl <- read_excel(paste0(folder_path,"HerculanoHouzel_etal_2015_Table5_snapshot.xlsx"))

## 2. Check Table name
# Assuming the first column header is "Table 5. Whole brain"
first_column_name <- colnames(tabledirectxl)[1]
# Specify the prefix to remove
prefix_to_remove <- "Table 5. "
# Extract the part after the prefix
structure_name <- sub(paste0("^", prefix_to_remove), "", first_column_name)

## 3. Remove table name header and bottom note
# Set the next row as the new header
colnames(tabledirectxl) <- as.character(unlist(tabledirectxl[1, ]))
# Remove the first row since it's now the header
tabledirectxl <- tabledirectxl[-1, ]
# Remove the last two rows which are notes
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-2), ]

# ## 3. Correct (possible) error
# # There seems to be a " + " in place of " ± " in 	column "N,n" row "Rattus norvegicus"
# # Replace " + " with " ± " in the entire dataset
# tabledirectxl[] <- lapply(tabledirectxl, function(x) gsub("\\s*\\+\\s*", " ± ", x))

## 4. Split 6 columns containing average ± standard deviation into 12 different columns.
# Load the 'tidyr' package
library(tidyr)
# Define the columns to split and their corresponding new column names
cols_to_split <- c("Body mass, g", "Brain mass, g","Neurons", "Other cells", "% Neurons")
new_col_names <- c("Body mass, g", "Body mass, g SD", "Brain mass, g", "Brain mass, g SD", "Neurons", "Neurons SD", "Other cells", "Other cells SD", "% Neurons", "% Neurons SD")
# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], " SD")),  # New column names with space before SD
    #sep = " ± ",  # Specify the separator as a regular expression to split on ' ±'
    sep = "\\s*±\\s*",  # Specify the separator as a regular expression to split on ' ±' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

## 5. Convert columns to numeric (taking away commas)
columns_to_convert <- c("n", "Body mass, g", "Body mass, g SD", "Brain mass, g", "Brain mass, g SD", "Neurons", "Neurons SD", "Other cells", "Other cells SD", "% Neurons", "% Neurons SD")
for (column in columns_to_convert) {
  tabledirectxl[[column]] <- as.numeric(gsub(",", "", tabledirectxl[[column]]))
}

## 6. Name columns after the structure 
# Specify the columns to rename
columns_to_rename <- c("n", "Neurons", "Neurons SD", "Other cells", "Other cells SD", "% Neurons", "% Neurons SD", "Source")
# Add structure at the beginning of each column name
colnames(tabledirectxl)[match(columns_to_rename, colnames(tabledirectxl))] <- paste0(structure_name, " ", columns_to_rename)

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 7. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

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

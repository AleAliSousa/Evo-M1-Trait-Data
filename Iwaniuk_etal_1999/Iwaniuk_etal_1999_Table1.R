## 1. Source
#setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institue/Evo-M1-Trait-Data/") #is this a typo? #check if " Institue" versus is a typo and/or throwing off the code for writing to?
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
#setwd("C:/Users/Rigby/OneDrive - University of Bath/Evo-M1-Trait-Data/")

## 2. Table 2
#1. Read direct from xl
library(readxl)
folder_path <- "./Iwaniuk_etal_1999/"
tabledirectxl <-
  read_excel(paste0(folder_path, "Iwaniuk_etal_1999_Table1_snapshot.xlsx"))

#2. Change header name of column 1 and 2
colnames(tabledirectxl)[1] <- "Species Generic Name"
colnames(tabledirectxl)[2] <- "Species Scientific Name"

## 3. Split 2 columns containing both value and reference in [] into 4 different columns.

# Load the 'tidyr' package
library(tidyr)

# Define the columns to split and their corresponding new column names
cols_to_split <- c("Depth", "Length")
new_col_names <- c("Depth", "Depth_Ref", "Length", "Length_Ref")

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], "_Ref")),  # New column names with "_" before Ref
    sep = " \\[|\\]",  # Specify the separator as a regular expression to split on ' [' and ']'
    extra = "drop"  # Drop any extra pieces
  )
}

## 4.  Move "Species scientific name" column and rename it
tabledirectxl <- tabledirectxl[, c("Species Scientific Name", setdiff(names(tabledirectxl), "Species Scientific Name"))]
names(tabledirectxl)[1] <- "Species"

## 5. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <-
  gsub("\\.R$",
       "",
       basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
library(readxl)
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <-
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(
  final.dataframe,
  file = paste0(folder_path, item_name, ".csv"),
  row.names = FALSE
)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "./__Public/comparative-data/"
write.table(
  final.dataframe,
  file = paste0(tsv_file_path, item_encoded, ".tsv"),
  sep = "\t",
  row.names = FALSE
)
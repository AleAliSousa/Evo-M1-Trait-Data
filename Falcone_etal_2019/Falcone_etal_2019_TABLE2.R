## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")

library(readr)
library(tidyverse)

# TABLE 1
## 1. Read direct from csv
folder_path <- "./Falcone_etal_2019/"
tabledirectcsv <- read_csv(paste0(folder_path,"Falcone_etal_2019_TABLE2_snapshot.csv"))


# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 8. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectcsv

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

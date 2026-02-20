## Load Libraries
library(readxl)
library(rstudioapi)

#1. Source
setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institute/Evo-M1-Trait-Data/")
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")

#2. Table 1

## 1. Read direct from xl
folder_path <- "./Iwaniuk_etal_2001/"
tabledirectxl <- read_excel(paste0(folder_path,"Iwaniuk_etal_2001_Table1_snapshot.xlsx"))

#3. Save

# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "./__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)

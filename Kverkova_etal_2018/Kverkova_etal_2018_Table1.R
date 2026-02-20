## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Kverkova_etal_2018")

# Load required library
library(readxl)
library(tidyverse)

# Read Excel file
tabledirectxl <- read_excel("Kverkova_etal_2018_Table1_snapshot.xlsx", col_names = FALSE)

tabledirectxl <- as.data.frame(tabledirectxl)


## 2. MAKE DATA READABLE
# A lot of column naming

names(tabledirectxl)[1] <- as.character(tabledirectxl[1, 1])
names(tabledirectxl)[2] <- as.character(paste0((tabledirectxl[1, 2]),"_",(tabledirectxl[2, 2]),"_",(tabledirectxl[3, 2])))
names(tabledirectxl)[3] <- as.character(paste0((tabledirectxl[1, 2]),"_",(tabledirectxl[2, 2]),"_",(tabledirectxl[3, 3])))
names(tabledirectxl)[4] <- as.character(paste0((tabledirectxl[1, 2]),"_",(tabledirectxl[2, 2]),"_",(tabledirectxl[3, 4])))
names(tabledirectxl)[5] <- as.character(paste0((tabledirectxl[1, 2]),"_",(tabledirectxl[2, 5])))
names(tabledirectxl)[6] <- as.character(paste0((tabledirectxl[1, 6]),"_",(tabledirectxl[2, 6])))
names(tabledirectxl)[7] <- as.character(paste0((tabledirectxl[1, 6]),"_",(tabledirectxl[2, 7])))
names(tabledirectxl)[8] <- as.character(paste0((tabledirectxl[1, 6]),"_",(tabledirectxl[2, 8])))

tabledirectxl <- tabledirectxl[-c(1:3), ]

# Delete the row where "Species" is "Total"
tabledirectxl <- tabledirectxl %>%
  filter(Species != "Total")

#Improve Colnames
names(tabledirectxl) <- make.names(names(tabledirectxl))
names(tabledirectxl) <- gsub("\\.\\.", ".", names(tabledirectxl))


## 3. SPECIES CORRECTION

# Complete abbreviated species name based on reference in supplement
tabledirectxl$Species[tabledirectxl$Species == "Heliophobius argent."] <- "Heliophobius argenteocinereus"

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. SAVE

# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

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
## Load Libraries
library(readxl)
library(rstudioapi)

#1. Source
setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institute/Evo-M1-Trait-Data/")
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")

#2. Table 2
## Read direct from xl
folder_path <- "./Iwaniuk_etal_2001/"
tabledirectxl <- read_excel(paste0(folder_path,"Iwaniuk_etal_2001_Table2_snapshot.xlsx"))

## Remove table name header and bottom note
# Set the third row as the new header
colnames(tabledirectxl) <- as.character(unlist(tabledirectxl[3, ]))
# Remove the third row since it's now the header
tabledirectxl <- tabledirectxl[-3, ]
# Remove the last two rows which are notes
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-2), ]

## Rename column names
# Extract the string from row 2 of the "Complexity index" column
prefix <- as.character(tabledirectxl[2, "Complexity index"])
# Define the column names you want to update
columns_to_update <- c("Complexity index", "Wrestling", "Play fighting", "Locomotor play", "Total play")
# Concatenate the prefix with each column name using the paste() function
new_column_names <- paste(prefix, columns_to_update, sep = "_")
# Update the specified column names of the dataframe
colnames(tabledirectxl)[match(columns_to_update, colnames(tabledirectxl))] <- new_column_names

## Remove the 1,2 and 3 row 
tabledirectxl <- tabledirectxl[-(1:3), ]

## Convert columns to numerical
tabledirectxl$`Brain Size` <- as.numeric(tabledirectxl$`Brain Size`)
tabledirectxl$`Play scores_Complexity index` <- as.numeric(tabledirectxl$`Play scores_Complexity index`)
tabledirectxl$`Play scores_Wrestling` <- as.numeric(tabledirectxl$`Play scores_Wrestling`)
tabledirectxl$`Play scores_Play fighting` <- as.numeric(tabledirectxl$`Play scores_Play fighting`)
tabledirectxl$`Play scores_Locomotor play` <- as.numeric(tabledirectxl$`Play scores_Locomotor play`)
tabledirectxl$`Play scores_Total play` <- as.numeric(tabledirectxl$`Play scores_Total play`)

## Update Species Names
tabledirectxl[which(tabledirectxl$Species == "M. montanus"), "Species"] <- "Microtus montanus"
tabledirectxl[which(tabledirectxl$Species == "M. ochrogaster"), "Species"] <- "Microtus ochrogaster"
tabledirectxl[which(tabledirectxl$Species == "M. pennsylvanicus"), "Species"] <- "Microtus pennsylvanicus"
tabledirectxl[which(tabledirectxl$Species == "P. shortridgei"), "Species"] <- "Pseudomys shortridgei"
tabledirectxl[which(tabledirectxl$Species == "P. maniculatus"), "Species"] <- "Peromyscus maniculatus"
tabledirectxl[which(tabledirectxl$Species == "R. rattus"), "Species"] <- "Rattus rattus"

## Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

#3. Save

## Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

## Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

## Get Item encoded
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

## Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

## Save dataframe to a TSV file in the online database
tsv_file_path <- "./__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
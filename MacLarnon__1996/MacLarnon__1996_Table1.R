#1. Source
#setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institue/Evo-M1-Trait-Data/")
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")

## Install and load necessary libraries
library(dplyr) #Better to load all libraries at the beginning. If they are not installed there wil be an error and they can be installed at the beginning
library(readxl)
library(rstudioapi)

#2. Table 1
## Read direct from xl
folder_path <- "./MacLarnon__1996/" #Note there are tow underscores in the file name -- this is because there is a single author.  See __ReadMe.xlsx
tabledirectxl <- read_excel(paste0(folder_path,"MacLarnon__1996_Table1_snapshot.xlsx"))

## Create a new "Order" column 
Order_column <- rep(NA, nrow(tabledirectxl))
tabledirectxl <- cbind(Order = Order_column, tabledirectxl)

## Remove the rows with order names
rows_to_delete <- c(1, 23, 29, 36, 41, 50)
tabledirectxl <- tabledirectxl %>%
  slice(-rows_to_delete)

## Add order names
tabledirectxl$Order[1:21] <- "Primate"
tabledirectxl$Order[22:26] <- "Cetacean"
tabledirectxl$Order[27:32] <- "Rodent"
tabledirectxl$Order[33:36] <- "Lagomorph"
tabledirectxl$Order[37:44] <- "Bird"
tabledirectxl$Order[45] <- "Amphibian"

## Create a new "Subspecies_size" column
tabledirectxl <- tabledirectxl %>%
  mutate(Subspecies_size = NA) %>%
  select(1:which(colnames(tabledirectxl) == "Species"), Subspecies_size, everything())

## Adding Subspecies Size
tabledirectxl$Subspecies_size[28:29] <- "Small"
tabledirectxl$Subspecies_size[30:31] <- "Large"
tabledirectxl$Subspecies_size[33:34] <- "Small"
tabledirectxl$Subspecies_size[35:36] <- "Large"

## Removing Subspecies size from Species column 
tabledirectxl[which(tabledirectxl$Species == "Rattus  norvegicus  (small subspecies)"), "Species"] <- "Rattus  norvegicus"
tabledirectxl[which(tabledirectxl$Species == "Rattus  norvegicus  (large subspecies)"), "Species"] <- "Rattus  norvegicus"
tabledirectxl[which(tabledirectxl$Species == "Oryctolagus  cuniculus  (small subspecies)"), "Species"] <- "Oryctolagus  cuniculus"
tabledirectxl[which(tabledirectxl$Species == "Oryctolagus  cuniculus  (large subspecies)"), "Species"] <- "Oryctolagus  cuniculus"

## Replacing reference numbers with citations
tabledirectxl[which(tabledirectxl$Refs == "1"), "Refs"] <- "Present study (FS  subset)"
tabledirectxl[which(tabledirectxl$Refs == "2"), "Refs"] <- "Present study (non-FS  subset)"
tabledirectxl[which(tabledirectxl$Refs == "3"), "Refs"] <- "Hopf & Claussen  (1971)"
tabledirectxl[which(tabledirectxl$Refs == "4"), "Refs"] <- "Krompecher & Lipák  (1966)"
tabledirectxl[which(tabledirectxl$Refs == "5"), "Refs"] <- "Ridgway et al. (1966)"
tabledirectxl[which(tabledirectxl$Refs == "6"), "Refs"] <- "Donaldson & Hatai (1911)"
tabledirectxl[which(tabledirectxl$Refs == "7"), "Refs"] <- "Latimer (1950)"
tabledirectxl[which(tabledirectxl$Refs == "8"), "Refs"] <- "Latimer & Sawin (1955)"
tabledirectxl[which(tabledirectxl$Refs == "9"), "Refs"] <- "Latimer & Sawin (1957)"
tabledirectxl[which(tabledirectxl$Refs == "10"), "Refs"] <- "Ravenel (1877)"
tabledirectxl[which(tabledirectxl$Refs == "11"), "Refs"] <- "Nayak (1933)"
tabledirectxl$Refs[21] <- "Present study (non-FS subset); Krompecher & Lipák (1966); Ravenel (1877)"

## Change the header name of the 'Refs' column
names(tabledirectxl)[which(names(tabledirectxl) == "Refs")] <- "References (all data for a species come from a single source except where indicated)"

## Citing the * in Body weight (g) column
tabledirectxl$`Body weight (g)`[1] <- "2800 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[3] <- "1165 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[4] <- "287 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[7] <- "805 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[12] <- "3469 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[14] <- "3610 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[15] <- "21 750 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[16] <- "17 950 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[17] <- "10 000 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[18] <- "19 410 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[19] <- "11 690 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[20] <- "34 100 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g)`[21] <- "60 000 *Martin & MacLarnon (unpublished data collection)"

## Citing the * in Body weight (mg) column
tabledirectxl$`Body weight (mg)`[3] <- "10 650 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[4] <- "7980 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[5] <- "9250 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[7] <- "24 700 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[8] <- "86 200 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[9] <- "60 800 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[13] <- "110 500 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[14] <- "62 100 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[15] <- "180 900 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[16] <- "165 500 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[17] <- "147 300 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[18] <- "121 000 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[19] <- "114 500 *Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (mg)`[21] <- "1 273 700 *Martin & MacLarnon (unpublished data collection)"

## Delete last row as now references are added in the table
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-1), ]

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
# Original file:
# Dos Santos, S. E., Porfirio, J., da Cunha, F. B., Manger, P. R., Tavares, W., Pessoa, L., Raghanti, M. A., Sherwood, C. C., & Herculano-Houzel, S. (2017). Cellular Scaling Rules for the Brains of Marsupials: Not as "Primitive" as Expected. Brain Behav Evol. https://doi.org/10.1159/000452856 	
# Supplementary Material online
# 1. "Downloaded" from link (figshare via online article):
# https://ndownloader.figstatic.com/files/7428211
# 2. Open 452856_sm10.doc in MS Word (double click it)
# 3. Save as Plain Text (.txt)

## 1. READ FILE
# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/DosSantos_etal_2017")

#Load readr
library(readr)
# Read the text version 
sheetfromtxt <- read_delim("452856_sm10.txt", 
                            delim = "\t", escape_double = FALSE, 
                            trim_ws = TRUE, skip = 1)

## 2. FIX FORMATTING ERROR TO ALIGN CELLS AND SAVE SNAPSHOT
# Delete 2 empty columns by column names #left one name since there will be shifting and hard to work with nameless column
sheetfromtxt <- sheetfromtxt[, !colnames(sheetfromtxt) %in% c("?", "...15")]
# Align column headers / Remove unwanted extra column header. Takes names from columns 1-7, adds next to them names from columns 9-last. Assigns new names to original df
names(sheetfromtxt) = c(names(sheetfromtxt)[1:7],  names(sheetfromtxt)[9:length(names(sheetfromtxt))])
# Delete empty columns that contain only NA values and have no header names.
sheetfromtxt <- sheetfromtxt[, colSums(is.na(sheetfromtxt)) != nrow(sheetfromtxt), drop = FALSE]
# rename column names
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "...1"] ="_"
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "...13"] ="Δ"
# rename string in column names
colnames(sheetfromtxt) = gsub("\\b..\\b", ". ", colnames(sheetfromtxt))
# Save it as snapshot
write.csv(sheetfromtxt, file = "DosSantos_etal_2017_TableS1_snapshot.csv", row.names = FALSE)


## 3. CORRECT ERRATUM
# "The correct number of neurons in the cerebral cortex (NCX) of the Tasmanian devil (Sarcophilus) in online supplementary Table S1 is 71.66 × 106"
# must change cell [13,6] from 122.60x106 to 71.66×106
# first confirm which cell it is
Sarcophilus_NCX_1 <- sheetfromtxt[13, "Sarcophilus"]
print(Sarcophilus_NCX_1)
# then change it to the corrected value
sheetfromtxt[13, "Sarcophilus"] <- "71.66x106"
# check the correction worked
Sarcophilus_NCX_2 <- sheetfromtxt[13, "Sarcophilus"]
print(Sarcophilus_NCX_2)

## 4. NAME AND TOUCH UP VARIABLES
# remove unnecessary character in a specific column #"Δ" will not actually be used and could be removed earlier 
sheetfromtxt$"Δ" = gsub("x", "", sheetfromtxt$"Δ")
# remove unnecessary string in the whole dataset
sheetfromtxt <- data.frame(sapply(sheetfromtxt,function(x) gsub("n.a.","",as.character(x))))
sheetfromtxt <- data.frame(sapply(sheetfromtxt,function(x) gsub(",","",as.character(x))))
# changing again since R didn't like the column name "_" #next time find a better placeholder
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "X_"] <- "_"
# changing again since R didn't like the column names with "_" #next time find a better placeholder
colnames(sheetfromtxt) = gsub("\\b..\\b", ". ", colnames(sheetfromtxt))

## 5. CALCULATE DATA
# Assuming your data frame is named 'speciesfromtxt'
for (row in 1:nrow(sheetfromtxt)) {
  for (col in 1:ncol(sheetfromtxt)) {
    if (grepl("x106", sheetfromtxt[row, col], fixed = TRUE)) {
      sheetfromtxt[row, col] <- gsub("x106", "", sheetfromtxt[row, col])
      sheetfromtxt[row, col] <- as.numeric(sheetfromtxt[row, col]) * 10^6
    }
  }
}
for (row in 1:nrow(sheetfromtxt)) {
  for (col in 1:ncol(sheetfromtxt)) {
    if (grepl("x109", sheetfromtxt[row, col], fixed = TRUE)) {
      sheetfromtxt[row, col] <- gsub("x109", "", sheetfromtxt[row, col])
      sheetfromtxt[row, col] <- as.numeric(sheetfromtxt[row, col]) * 10^9
    }
  }
}


## 6. TRANSPOSE AND SHIFT INTO PLACE
# transpose the dataframe to a matrix
m <- t(sheetfromtxt)
# convert from matrix to dataframe
sheetfromtxt <- as.data.frame(m)
# Set column names to values in the first row of matrix
colnames(sheetfromtxt) <- m[1, ]
# Delete the first row of a dataframe by subsetting it to exclude the first row.
sheetfromtxt <- sheetfromtxt[-1, , drop = FALSE]
# Create a new column 'Species' with values copied from row names
sheetfromtxt$Species <- rownames(sheetfromtxt)
# Reorder the columns with "Species" as the first column
sheetfromtxt <- sheetfromtxt[, c("Species", setdiff(names(sheetfromtxt), "Species"))]
# Add a new column with row numbers
sheetfromtxt$Row_Numbers <- 1:nrow(sheetfromtxt)
# Replace rownames (species names) with Row_numbers
rownames(sheetfromtxt) <- sheetfromtxt$Row_Numbers
# Delete the "Row_numbers" column using subset
sheetfromtxt <- subset(sheetfromtxt, select = -Row_Numbers)
# Loop through the columns to convert all values to numeric, except for the first column (Species)
for (col in names(sheetfromtxt)) {
  if (col != "Species") {
    sheetfromtxt[[col]] <- as.numeric(sheetfromtxt[[col]])
  }
}

## 7. COMPLETE SPECIES NAMES
# rename species so names are complete, according to the publication
# rename string in column names (Genus)
sheetfromtxt$Species[sheetfromtxt$Species == "Marmosops"] <- "Marmosops incanus"
sheetfromtxt$Species[sheetfromtxt$Species == "Metachirus"] <- "Metachirus nudicaudatus"
sheetfromtxt$Species[sheetfromtxt$Species == "Didelphis"] <- "Didelphis aurita"
sheetfromtxt$Species[sheetfromtxt$Species == "M. parma"] <- "Macropus parma"
sheetfromtxt$Species[sheetfromtxt$Species == "Sarcophilus"] <- "Sarcophilus harrisii"
sheetfromtxt$Species[sheetfromtxt$Species == "M. rufogriseus"] <- "Macropus rufogriseus"
sheetfromtxt$Species[sheetfromtxt$Species == "Wallabia"] <- "Wallabia bicolor"
sheetfromtxt$Species[sheetfromtxt$Species == "M. rufus"] <- "Macropus rufus"
sheetfromtxt$Species[sheetfromtxt$Species == "Dendrolagus"] <- "Dendrolagus goodfellowi"
sheetfromtxt$Species[sheetfromtxt$Species == "M. fuliginosus"] <- "Macropus fuliginosus"

## 8. DELETE CALCULATIONS THAT ARE REDUNDANT OR UNNEEDED
# Delete the row "Δ"
sheetfromtxt <- sheetfromtxt[!sheetfromtxt$Species == "Δ", ]

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 9. SAVE

# Finalize dataframe (UPDATE!!!)
final.dataframe <- sheetfromtxt

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

## 1. Read direct from xl
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Finlay_etal_2006")

library(readxl)
tablefromxl <- read_excel("Finlay_etal_2006_Table6.1_snapshot.xlsx", col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

# 2. Species 
# Create a new data frame with "Species" as the first column copied from Species Name #double square brackets to prevent converting spaces
tablefromxl$Species <- tablefromxl[["Species Name"]]

# rename row names with typos 
tablefromxl$Species <- gsub("Felis cattus", "Felis catus", tablefromxl$Species)
tablefromxl$Species <- gsub("Echinops telfairi", "Echinops telfari", tablefromxl$Species)


# # rename row names based on text, refs, also see Kaskan et al 2005, Changizi 2001
# tablefromxl$Species <- gsub("Mouse sp.", "Mus sp.", tablefromxl$Species)
# # Changizi 2011 cites Krubitzer 1995 which only mentions Sciurus carolinensis
# tablefromxl$Species <- gsub("Squirrel sp.", "Squirrel check species", tablefromxl$Species)


# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. Save

# Finalize dataframe (UPDATE!!!)
final.dataframe <- tablefromxl 

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





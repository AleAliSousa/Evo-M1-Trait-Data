# 1. Data comes from Fig 3 caption and was not tabulated, so a table was created, Changizi__2001_Figure3_snapshot.csv
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Changizi__2001")

# open file and read last two columns as numeric
figdata <- read.csv("Changizi__2001_Figure3_snapshot.csv", check.names = FALSE)


# 2. Make data readable
# Add unlogged data

#make numerical
figdata[, 2:3] <- lapply(figdata[, 2:3], as.numeric)

# Unlogged values of columns 2 and 3 which are log-transformed
figdata[, 4] <- 10^figdata[, 2]  # Add a new column with unlogged values of column 2
figdata[, 5] <- 10^figdata[, 3]  # Add a new column with unlogged values of column 3

# Rename columns 4 and 5 to match the headings of columns 2 and 3 without "log"
colnames(figdata)[4:5] <- sub("log ", "", colnames(figdata)[2:3])

# Remove all digits after the decimal point in columns 4 and 5 #these are not maningful since they were produced by logging
figdata[, 4:5] <- lapply(figdata[, 4:5], function(x) trunc(x))

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 3. Save

# Finalize dataframe (UPDATE!!!)
final.dataframe <- figdata

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



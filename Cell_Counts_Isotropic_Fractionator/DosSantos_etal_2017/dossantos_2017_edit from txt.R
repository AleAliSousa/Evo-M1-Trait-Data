# Original file:
# Dos Santos, S. E., Porfirio, J., da Cunha, F. B., Manger, P. R., Tavares, W., Pessoa, L., Raghanti, M. A., Sherwood, C. C., & Herculano-Houzel, S. (2017). Cellular Scaling Rules for the Brains of Marsupials: Not as "Primitive" as Expected. Brain Behav Evol. https://doi.org/10.1159/000452856 	
# Supplementary Material online
# link to figshare
# 1. "Downloaded all" from figshare link:
# https://figshare.com/articles/journal_contribution/Supplementary_Material_for_Cellular_Scaling_Rules_for_the_Brains_of_Marsupials_Not_as_Primitive_as_Expected/4588471?file=7428211
# 2. Unzip zipped file 4588471.zip (double click it)
# 3. Open 4588471/452856_sm10.doc in MS Word (double click it)
# 4. Save as Plain Text (.txt)

## PART ONE: READ FILE
# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/Cell_Counts_Isotropic_Fractionator/DosSantos_etal_2017")

#Load readr
library(readr)
# Read the text version 
sheetfromtxt <- read_delim("452856_sm10.txt", 
                            delim = "\t", escape_double = FALSE, 
                            trim_ws = TRUE, skip = 1)
View(sheetfromtxt)

## PART TWO: FIX FORMATTING ERROR TO ALIGN CELLS
# Delete 2 empty columns by column names #left one name since there will be shifting and hard to work with nameless column
sheetfromtxt <- sheetfromtxt[, !colnames(sheetfromtxt) %in% c("?", "...15")]
# Align column headers / Remove unwanted extra column header. Takes names from columns 1-7, adds next to them names from columns 9-last. Assigns new names to original df
names(sheetfromtxt) = c(names(sheetfromtxt)[1:7],  names(sheetfromtxt)[9:length(names(sheetfromtxt))])
# Delete empty columns that contain only NA values and have no header names.
sheetfromtxt <- sheetfromtxt[, colSums(is.na(sheetfromtxt)) != nrow(sheetfromtxt), drop = FALSE]

## PART THREE: CORRECT ERRATUM
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

## PART FOUR: NAME AND TOUCH UP VARIABLES
# rename columns (these are actually just placeholders)
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "...1"] ="Species"
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "...13"] ="delta"

# remove unnecessary character in a specific column #delta will not actually be used and could be removed earlier 
sheetfromtxt$delta = gsub("x", "", sheetfromtxt$delta)
# remove unnecessary string in the whole dataset
sheetfromtxt <- data.frame(sapply(sheetfromtxt,function(x) gsub("n.a.","",as.character(x))))
sheetfromtxt <- data.frame(sapply(sheetfromtxt,function(x) gsub(",","",as.character(x))))
# rename string in column names
colnames(sheetfromtxt) = gsub("\\b..\\b", "_", colnames(sheetfromtxt))
# rename string in column names (Genus)
colnames(sheetfromtxt) = gsub("M_", "Macropus_", colnames(sheetfromtxt))

## PART FIVE: CALCULATE DATA
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

## PART SIX: CORRECT AND SPELL OUT ABBREVIATIONS
# Replace specific brain component endings at the end of a string with the corresponding strings prepended in the "Species" column
sheetfromtxt$Species <- sub("^(.*)MES\\+D\\+S$", "mesencephalon+diencephalon+striatum_\\1", sheetfromtxt$Species) #this needs to be before D+S 
sheetfromtxt$Species <- sub("^(.*)BD$", "Body_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)BR$", "whole_brain_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)CX$", "Cerebral_Cortex_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)HP$", "hippocampus_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)CB$", "Cerebellum_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)ROB$", "RoB_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)D\\+S$", "diencephalon+striatum_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)D\\s*\\+\\s*S$", "diencephalon+striatum_\\1", sheetfromtxt$Species) #change those with spacing errors as well
sheetfromtxt$Species <- sub("^(.*)D\\+S\\s*$", "diencephalon+striatum_\\1", sheetfromtxt$Species) #change those with spacing errors as well
sheetfromtxt$Species <- sub("^(.*)MES$", "mesencephalon_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)P\\+M$", "pons+medulla_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)OB$", "Olfactory_bulb_\\1", sheetfromtxt$Species)
sheetfromtxt$Species <- sub("^(.*)GM$", "Cerebral_Cortex_Grey_Matter_\\1", sheetfromtxt$Species)
# Replace specific cellular composition part of strings in the "Species" column
sheetfromtxt$Species <- sub("_M$", "_Mass_g", sheetfromtxt$Species) #Mass (g)
sheetfromtxt$Species <- sub("_N$", "_N_n", sheetfromtxt$Species) #number of neurons
sheetfromtxt$Species <- sub("_DN$", "_Nmg", sheetfromtxt$Species) #neuronal density (in neurons/mg)
sheetfromtxt$Species <- sub("_O/N$", "_ON", sheetfromtxt$Species) #O/N, ratio between numbers of other (non-neuronal) cells and neurons

## PART SEVEN: TRANSPOSE AND SHIFT INTO PLACE
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

## PART EIGHT: COMPLETE SPECIES NAMES
# rename species so names are complete, according to the publication
sheetfromtxt$Species[sheetfromtxt$Species == "Marmosops"] <- "Marmosops_incanus"
sheetfromtxt$Species[sheetfromtxt$Species == "Metachirus"] <- "Metachirus_nudicaudatus"
sheetfromtxt$Species[sheetfromtxt$Species == "Didelphis"] <- "Didelphis_aurita"
sheetfromtxt$Species[sheetfromtxt$Species == "Sarcophilus"] <- "Sarcophilus_harrisii"
sheetfromtxt$Species[sheetfromtxt$Species == "Wallabia"] <- "Wallabia_bicolor"
sheetfromtxt$Species[sheetfromtxt$Species == "Dendrolagus"] <- "Dendrolagus_goodfellowi"

## PART NINE: DELETE CALCULATIONS THAT ARE REDUNDANT OR UNNEEDED
# Delete the row Delta
sheetfromtxt <- sheetfromtxt[!sheetfromtxt$Species == "delta", ]

## PART TEN: Save to CSV
# Save it as 'dossantos_etal_2017.csv'
write.csv(sheetfromtxt, file = "dossantos_etal_2017.csv", row.names = FALSE)

## NOTE:
# Turn off scientific notation
# options(scipen=999)
# Turn on scientific notation
# options(scipen=0)


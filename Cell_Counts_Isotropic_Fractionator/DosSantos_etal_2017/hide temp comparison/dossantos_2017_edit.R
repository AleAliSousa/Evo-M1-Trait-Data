## Original file:
# Dos Santos, S. E., Porfirio, J., da Cunha, F. B., Manger, P. R., Tavares, W., Pessoa, L., Raghanti, M. A., Sherwood, C. C., & Herculano-Houzel, S. (2017). Cellular Scaling Rules for the Brains of Marsupials: Not as "Primitive" as Expected. Brain Behav Evol. https://doi.org/10.1159/000452856 	
# Supplementary Material online
# link to figshare
# 1. "Downloaded all" from figshare link:
# https://figshare.com/articles/journal_contribution/Supplementary_Material_for_Cellular_Scaling_Rules_for_the_Brains_of_Marsupials_Not_as_Primitive_as_Expected/4588471?file=7428211
# 2. Unzip zipped file 4588471.zip (double click it)
# 3a. Open 4588471/452856_sm10.doc in Word (double click it)
# 3b. Copy the selected spreadsheet by pressing Ctrl+C (Windows) or Command+C (Mac).
# 3c. Open Microsoft Excel on your computer.
# 3d. Create a new workbook in Excel by going to "File" > "New Workbook."
# 3e. Paste the Spreadsheet into Excel:
# 3f. In the new Excel workbook, paste the copied spreadsheet by pressing Ctrl+V (Windows) or Command+V (Mac). This will paste the contents of the spreadsheet into Excel.

###2nd version from csv (Original)###
# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/Cell_Counts_Isotropic_Fractionator/DosSantos_etal_2017")
# Read the spreadsheet
spreadsheet<-read.csv("dossantos_2017_wrangled_copyandpaste.csv")
View(spreadsheet)
# Remove unwanted names. Takes names from columns 1-7, adds next to them names from 9-last #assigns new names to original df
names(spreadsheet) = c(names(spreadsheet)[1:7],  names(spreadsheet)[9:length(names(spreadsheet))])
# Delete empty column (you need to run it twice or use two similar functions, for some reason)  -- !
spreadsheet[,13]<-NULL
spreadsheet=spreadsheet[,-13]
# spreadsheet[,13]<-NULL
# spreadsheet=spreadsheet[,-13]
# rename columns
colnames(spreadsheet)[colnames(spreadsheet) == "X"] ="Anatomy"
colnames(spreadsheet)[colnames(spreadsheet) == "X.2"] ="delta"
# remove unnecessary character in a specific column
spreadsheet$delta = gsub("x", "", spreadsheet$delta)
# remove unnecessary string in the whole dataset
spreadsheet <- data.frame(sapply(spreadsheet,function(x) gsub("n.a.","",as.character(x))))
spreadsheet <- data.frame(sapply(spreadsheet,function(x) gsub(",","",as.character(x))))
# rename string in columns
colnames(spreadsheet) = gsub("\\b..\\b", "_", colnames(spreadsheet))
# rename string in columns (Genus)
colnames(spreadsheet) = gsub("M_", "Macropus_", colnames(spreadsheet))
# Convert equation string to a number (Steps 1_2)
# Step 1: load tidyverse
library(tidyverse)
# Step 2: look for columns TRUE for 106 or 109. If true, need to multiply equation.   
for (i in 2:length(names(spreadsheet))) {
  spreadsheet$x106=str_detect(spreadsheet[,i], 'x106')
  spreadsheet$x109=str_detect(spreadsheet[,i], 'x109')
  ifelse (spreadsheet$x106 == TRUE, spreadsheet[,i] <- gsub("x106", "", spreadsheet[,i]), spreadsheet[,i])
  ifelse (spreadsheet$x109 == TRUE, spreadsheet[,i] <- gsub("x109", "", spreadsheet[,i]), spreadsheet[,i])
  spreadsheet[,i] <- as.numeric(spreadsheet[,i])
  ifelse (spreadsheet$x106 == TRUE, as.numeric(spreadsheet[,i] <-  spreadsheet[,i]*10^6), spreadsheet[,i])
  ifelse (spreadsheet$x109 == TRUE, as.numeric(spreadsheet[,i] <-  spreadsheet[,i]*10^9), spreadsheet[,i])
}
spreadsheet$x106 = NULL
spreadsheet$x109 = NULL
# Replace specific brain component endings at the end of a string with the corresponding strings prepended in the "Anatomy" column
spreadsheet$Anatomy <- sub("^(.*)MES\\+D\\+S$", "mesencephalon+diencephalon+striatum_\\1", spreadsheet$Anatomy) #this needs to be before D+S 
spreadsheet$Anatomy <- sub("^(.*)BD$", "Body_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)BR$", "whole_brain_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)CX$", "Cerebral_Cortex_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)HP$", "hippocampus_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)CB$", "Cerebellum_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)ROB$", "RoB_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)D\\+S$", "diencephalon+striatum_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)D\\s*\\+\\s*S$", "diencephalon+striatum_\\1", spreadsheet$Anatomy) #change those with spacing errors as well
spreadsheet$Anatomy <- sub("^(.*)D\\+S\\s*$", "diencephalon+striatum_\\1", spreadsheet$Anatomy) #change those with spacing errors as well
spreadsheet$Anatomy <- sub("^(.*)MES$", "mesencephalon_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)P\\+M$", "pons+medulla_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)OB$", "Olfactory_bulb_\\1", spreadsheet$Anatomy)
spreadsheet$Anatomy <- sub("^(.*)GM$", "Cerebral_Cortex_Grey_Matter_\\1", spreadsheet$Anatomy)
# Replace specific cellular composition part of strings in the "Anatomy" column
spreadsheet$Anatomy <- sub("_M$", "_Mass_g", spreadsheet$Anatomy) #Mass (g)
spreadsheet$Anatomy <- sub("_N$", "_N_n", spreadsheet$Anatomy) #number of neurons
spreadsheet$Anatomy <- sub("_DN$", "_Nmg", spreadsheet$Anatomy) #neuronal density (in neurons/mg)
spreadsheet$Anatomy <- sub("_O/N$", "_ON", spreadsheet$Anatomy) #O/N, ratio between numbers of other (non-neuronal) cells and neurons
# Transpose
spreadsheet <- t(spreadsheet)
spreadsheet$Species <- spreadsheet$Anatomy
# optional: Turn of scientific notation
#options(scipen=999)


## To do list
# 2. Correct the erratum
# 3. Add column for Species
# 4. Add column for Anatomical_variable
# Add a new first column called "Anatomical_variable"
spreadsheet <- cbind(Anatomial_variable = NA, spreadsheet)
# Create a copy of the first column
spreadsheet$Anatomical <- spreadsheet$Anatomy
# Move the new column to the first position
spreadsheet <- spreadsheet[, c("Anatomical", names(spreadsheet)[-1])]


## Finalizing: delete redundant or unnecessary information
# 1. Delete Delta

## Finishing touches
# 1. Delete old anatomy column
# 2. Delete old species column
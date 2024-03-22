setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__EvoM1_TraitTable")
# Heffner 1975 dexterity and corticospinal tract for EvoM1
## Need to add other Heffner paper

## 1 Get data for cell count analyses
library(tidyverse)
library(readxl)
library(writexl)

## Create a list with all the dataframes for cell count analyses
item_name <- c(
  "Heffner_Masterton_1975_TableI"
)

# Initialize an empty list to store data frames with cell counts data
heffner_data_list <- list()

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")

# Loop through item names, read tables from TSVs, and store as dataframes in the list
for (i in seq_along(item_name)) {
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  item_data <- read.table(file = paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/", item_encoded, ".tsv"), 
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, sep = "\t")
  
  # Store the data frame in the list with the corresponding item name
  heffner_data_list[[item_name[i]]] <- item_data
}

Heffner_Masterton_1975_TableI <- heffner_data_list$Heffner_Masterton_1975_TableI

# Add Species names to use based on Genus level match or better
Heffner_Masterton_1975_TableI$species_sci <- NA 
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Homo sapiens"] <- "Homo sapiens"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Pan troglodytes"] <- "Pan troglodytes"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Gorilla gorilla gorilla"] <- "Gorilla gorilla gorilla"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Macaca mulatta"] <- "Macaca mulatta"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Macaca ira"] <- "Macaca nemestrina" #Macaca ira = Macaca fascicularis
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Papio papio"] <- "Papio anubis" #Genus 
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Cercopithecus pygerythrus"] <- "Chlorocebus sabaeus" #Genus Cercopithecus pygerythrus = Chlorocebus pygerythrus
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Saimiri sciureus"] <- "Saimiri boliviensis boliviensis" #Genus 
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Cebus apella"] <- "Sapajus apella"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Callithrix jacchus"] <- "Callithrix jacchus"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Aotus nancymaae"] <- "Aotus nancymaae"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Galago crassicaudatus"] <- "Otolemur garnettii" #Genus #Otolemur crassicaudatus
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Microcebus murinus"] <- "Microcebus murinus"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Tupaia glis"] <- "Tupaia belangeri" #Genus
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Animal == "Mouse (unspecified)"] <- "Mus musculus" #Genus? Unsure 
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Animal == "Rat (unspecified)"] <- "Rattus norvegicus" #Genus? Unsure 
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Heterocephalus glaber"] <- "Heterocephalus glaber"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Urocitellus parryii"] <- "Urocitellus parryii"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Oryctolagus cuniculus"] <- "Oryctolagus cuniculus"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Putorius furo"] <- "Mustela putorius furo"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Canis familiaris"] <- "Canis latrans" #Genus 
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Felis catus"] <- "Felis catus"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Sus scrofa"] <- "Sus scrofa"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Dasypus novemcinctus"] <- "Dasypus novemcinctus"
Heffner_Masterton_1975_TableI$species_sci[Heffner_Masterton_1975_TableI$Species == "Monodelphis domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
Heffner_Masterton_1975_TableI <- Heffner_Masterton_1975_TableI[, c("species_sci", setdiff(names(Heffner_Masterton_1975_TableI), "species_sci"))]

# Write the dataframe to an Excel file
write_xlsx(Heffner_Masterton_1975_TableI, "dexterity_corticospinaltract.xlsx")

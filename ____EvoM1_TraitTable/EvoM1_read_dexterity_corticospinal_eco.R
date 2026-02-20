setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"

# Iwaniuk 1975 dexterity, corticospinal tract, and socioecological / behavioural data for EvoM1

## 1 Get data for cell count analyses
library(tidyverse)
library(readxl)
library(writexl)

## Create a list with all the dataframes for cell count analyses
item_name <- c(
  "Iwaniuk_etal_1999_Table1"
)

# Initialize an empty list to store data frames with cell counts data
data_list <- list()

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")

# Loop through item names, read tables from TSVs, and store as dataframes in the list
for (i in seq_along(item_name)) {
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  item_data <- read.table(file = paste0("./__Public/comparative-data/", item_encoded, ".tsv"), 
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, sep = "\t")
  
  # Store the data frame in the list with the corresponding item name
  data_list[[item_name[i]]] <- item_data
}

Iwaniuk_etal_1999_Table1 <- data_list$Iwaniuk_etal_1999_Table1

# Add Species names to use based on Genus level match or better # Copied from Heffner which had more species so some are not relevant here.
Iwaniuk_etal_1999_Table1$species_sci <- NA 
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Homo sapiens"] <- "Homo sapiens"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Pan troglodytes"] <- "Pan troglodytes"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Gorilla gorilla gorilla"] <- "Gorilla gorilla gorilla"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Macaca mulatta"] <- "Macaca mulatta"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Macaca ira"] <- "Macaca nemestrina" #Macaca ira = Macaca fascicularis
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Papio papio"] <- "Papio anubis" #Genus 
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Cercopithecus pygerythrus"] <- "Chlorocebus sabaeus" #Genus Cercopithecus pygerythrus = Chlorocebus pygerythrus
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Saimiri sciureus"] <- "Saimiri boliviensis boliviensis" #Genus 
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Cebus apella"] <- "Sapajus apella"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Callithrix jacchus"] <- "Callithrix jacchus"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Aotus nancymaae"] <- "Aotus nancymaae"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Galago crassicaudatus"] <- "Otolemur garnettii" #Genus #Otolemur crassicaudatus
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Microcebus murinus"] <- "Microcebus murinus"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Tupaia glis"] <- "Tupaia belangeri" #Genus
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Mus musculus"] <- "Mus musculus" 
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Rattus norvegicus"] <- "Rattus norvegicus"  
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Heterocephalus glaber"] <- "Heterocephalus glaber"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Urocitellus parryii"] <- "Urocitellus parryii"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Oryctolagus cuniculus"] <- "Oryctolagus cuniculus"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Putorius furo"] <- "Mustela putorius furo"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Canis familiaris"] <- "Canis latrans" #Genus 
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Felis domesticus"] <- "Felis catus"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Sus scrofa"] <- "Sus scrofa"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Dasypus novemcinctus"] <- "Dasypus novemcinctus"
Iwaniuk_etal_1999_Table1$species_sci[Iwaniuk_etal_1999_Table1$Species == "Monodelphis domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
Iwaniuk_etal_1999_Table1 <- Iwaniuk_etal_1999_Table1[, c("species_sci", setdiff(names(Iwaniuk_etal_1999_Table1), "species_sci"))]

# Write the dataframe to an Excel file
write_xlsx(Iwaniuk_etal_1999_Table1, paste0(folder_path, "corticospinaltract_etc.xlsx"))

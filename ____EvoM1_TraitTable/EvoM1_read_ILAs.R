setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/____EvoM1_TraitTable")

# Falcone interlaminar astrocyte  data M1

## 1 Get data for cell count analyses
library(tidyverse)
library(readxl)
library(writexl)

## Create a list with all the dataframes for cell count analyses
item_name <- c(
  "Falcone_etal_2019_TABLE1",
  "Falcone_etal_2019_TABLE2"
)

# Initialize an empty list to store data frames with cell counts data
data_list <- list()

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")

# Loop through item names, read tables from TSVs, and store as dataframes in the list
for (i in seq_along(item_name)) {
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  item_data <- read.table(file = paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/", item_encoded, ".tsv"), 
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, sep = "\t")
  
  # Store the data frame in the list with the corresponding item name
  data_list[[item_name[i]]] <- item_data
}

## 3 Merge the dataframes from the list which are from the same paper. Both have Species columns which are idenfiers, and GI columns which have complementary data
data <- merge(
  x = as.data.frame(data_list$Falcone_etal_2019_TABLE1),
  y = as.data.frame(data_list$Falcone_etal_2019_TABLE2),
  by = ,
  all = TRUE
)
data <- rename(data, Species = `Scientific name`)


# Add Species names to use based on Genus level match or better
data$species_sci <- NA 
data$species_sci[data$Species == "Homo sapiens"] <- "Homo sapiens"
data$species_sci[data$Species == "Pan troglodytes"] <- "Pan troglodytes"
data$species_sci[data$Species == "Gorilla gorilla"] <- "Gorilla gorilla gorilla" #Species
data$species_sci[data$Species == "Macaca mulatta"] <- "Macaca mulatta"
#data$species_sci[data$Species == "Macaca_nemestrina"] <- "Macaca nemestrina"
data$species_sci[data$Species == "Papio ursinus"] <- "Papio anubis" #Genus 
data$species_sci[data$Species == "Chlorocebus pygerythrus"] <- "Chlorocebus sabaeus"
#data$species_sci[data$Species == "Saimiri_sciureus"] <- "Saimiri boliviensis boliviensis" #Genus 
#data$species_sci[data$Species == "Sapajus_apella"] <- "Sapajus apella"
#data$species_sci[data$Species == "Callithrix_jacchus"] <- "Callithrix jacchus"
#data$species_sci[data$Species == "Aotus_trivirgatus"] <- "Aotus nancymaae" #Genus 
#data$species_sci[data$Species == "Otolemur_crassicaudatus"] <- "Otolemur garnettii" #Genus 
#data$species_sci[data$Species == "Microcebus_murinus"] <- "Microcebus murinus"
data$species_sci[data$Species == "Tupaia belangeri"] <- "Tupaia belangeri" #Genus 
data$species_sci[data$Species == "Mus musculus"] <- "Mus musculus"
data$species_sci[data$Species == "Rattus norvegicus"] <- "Rattus norvegicus"
#data$species_sci[data$Species == "Heterocephalus_glaber"] <- "Heterocephalus glaber"
#data$species_sci[data$Species == "Urocitellus_parryii"] <- "Urocitellus parryii"
#data$species_sci[data$Species == "Oryctolagus_cuniculus*"] <- "Oryctolagus cuniculus"
data$species_sci[data$Species == "Mustela putorius"] <- "Mustela putorius furo" #Species
#data$species_sci[data$Species == "Canis_latrans"] <- "Canis latrans"
data$species_sci[data$Species == "Felis catus"] <- "Felis catus"
#data$species_sci[data$Species == "Sus_scrofa_domesticus"] <- "Sus scrofa" #Domestic
#data$species_sci[data$Species == "Dasypus_novemcinctus*"] <- "Dasypus novemcinctus"
data$species_sci[data$Species == "Monodelphis domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
data <- data[, c("species_sci", setdiff(names(data), "species_sci"))]


# Phylo1 average table
data$phylo1_sci <- NA

data <- data %>%
  mutate(phylo1_sci = case_when(
    Order == "Primates" ~ "Euarchonta",
    Order == "Scandentia" ~ "Euarchonta",
    Order == "Rodentia" ~ "Glires",
    Order == "Carnivora" ~ "Laurasiatheria",
    Order == "Artiodactyla" ~ "Laurasiatheria",
    Order == "Xenarthra" ~ "Xenarthra",
    Order == "Didelphimorphia" ~ "Marsupialia",
    TRUE ~ phylo1_sci
  ))

data <- data %>%
  mutate(phylo1_sci = case_when(
    Order == "Eulipotyphla" ~ "Laurasiatheria",
    Order == "Chiroptera" ~ "Laurasiatheria",
    Order == "Diprotodontia" ~ "Marsupialia",
    TRUE ~ phylo1_sci
  ))


# Phylo2 average table
data$phylo2_sci <- NA

data <- data %>%
  mutate(phylo2_sci = case_when(
    Family == "Hominidae" ~ "Hominid",
    Family == "Cercopithecidae" ~ "Cercopithecid",
    Parvorder == "Platyrrhini" ~ "Platyrrhine",
    Suborder == "Strepsirrhini" ~ "Strepsirrhine",
    Order == "Scandentia" ~ "Scandentia",
    Order == "Rodentia" ~ "Rodentia",
    Order == "Carnivora" ~ "Carnivora",
    Order == "Artiodactyla" ~ "Artiodactyla",
    Order == "Didelphimorphia" ~ "Didelphimorphia",
    TRUE ~ phylo2_sci
  ))


# Write the dataframe to an Excel file
write_xlsx(data, "interlaminar_astrocytes.xlsx")


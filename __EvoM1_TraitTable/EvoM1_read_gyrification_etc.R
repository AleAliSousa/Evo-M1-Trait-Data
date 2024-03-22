setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__EvoM1_TraitTable")

# Lewitus Glia and Gyrification for EvoM1

## 1 Get data for cell count analyses
library(tidyverse)
library(readxl)
library(writexl)

## Create a list with all the dataframes for cell count analyses
item_name <- c(
  "Lewitus_etal_2014_TableS1",
  "Lewitus_etal_2014_TableS8"
)

# Initialize an empty list to store data frames with cell counts data
lewitus_data_list <- list()

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")

# Loop through item names, read tables from TSVs, and store as dataframes in the list
for (i in seq_along(item_name)) {
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  item_data <- read.table(file = paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/", item_encoded, ".tsv"), 
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, sep = "\t")
  
  # Store the data frame in the list with the corresponding item name
  lewitus_data_list[[item_name[i]]] <- item_data
}

# ## 2 Compare the tables
# ## 2.1 Compare Species
# 
# # Find the species present in lewitus_data_list$Lewitus_etal_2014_TableS1 but not in lewitus_data_list$Lewitus_etal_2014_TableS8
# species_only_in_tableS1 <- setdiff(lewitus_data_list$Lewitus_etal_2014_TableS1$Species, lewitus_data_list$Lewitus_etal_2014_TableS8$Species)
# species_only_in_tableS1
# 
# # Find the species present in lewitus_data_list$Lewitus_etal_2014_TableS8 but not in lewitus_data_list$Lewitus_etal_2014_TableS1
# species_only_in_tableS8 <- setdiff(lewitus_data_list$Lewitus_etal_2014_TableS8$Species, lewitus_data_list$Lewitus_etal_2014_TableS1$Species)
# species_only_in_tableS8
# 
# # Find the species present in both datasets
# species_in_both <- intersect(lewitus_data_list$Lewitus_etal_2014_TableS1$Species, lewitus_data_list$Lewitus_etal_2014_TableS2$Species)
# 
# # Initialize a list to store conflicting species
# conflicting_species <- list()
# # Loop through each species
# for (species in species_in_both) {
#   # Extract the GI values for the current species in each dataset
#   GI_s1 <- lewitus_data_list$Lewitus_etal_2014_TableS1$GI[lewitus_data_list$Lewitus_etal_2014_TableS1$Species == species]
#   GI_s2 <- lewitus_data_list$Lewitus_etal_2014_TableS2$GI[lewitus_data_list$Lewitus_etal_2014_TableS2$Species == species]
#   # Check if the GI values are different
#   if (!identical(GI_s1, GI_s2)) {
#     conflicting_species[[species]] <- list(GI_s1 = GI_s1, GI_s2 = GI_s2)
#   }
# }
# 
# # Print conflicting species
# if (length(conflicting_species) == 0) {
#   print("No conflicting values found for the same species.")
# } else {
#   print("Conflicting values found for the following species:")
#   print(conflicting_species)
# }
# 
# # Find the species present in both lewitus_data_list$Lewitus_etal_2014_TableS1 and lewitus_data_list$Lewitus_etal_2014_TableS8
# species_in_both <- intersect(lewitus_data_list$Lewitus_etal_2014_TableS1$Species, lewitus_data_list$Lewitus_etal_2014_TableS8$Species)
# 
# # Print the species present in both
# cat("Species present in both lewitus_data_list$Lewitus_etal_2014_TableS1 and lewitus_data_list$Lewitus_etal_2014_TableS8:\n")
# print(species_in_both)
# 
# ## 2.2 Compare if they have the same column in 2 dfs 
# 
# # Initialize a list to store conflicting species
# conflicting_species <- list()
# 
# # Loop through each species
# for (species in species_in_both) {
#   # Extract the GI values for the current species in each dataset
#   GI_s1 <- lewitus_data_list$Lewitus_etal_2014_TableS1$GI[lewitus_data_list$Lewitus_etal_2014_TableS1$Species == species]
#   GI_s2 <- lewitus_data_list$Lewitus_etal_2014_TableS2$GI[lewitus_data_list$Lewitus_etal_2014_TableS2$Species == species]
#   # Check if the GI values are different
#   if (!identical(GI_s1, GI_s2)) {
#     conflicting_species[[species]] <- list(GI_s1 = GI_s1, GI_s2 = GI_s2)
#   }
# }
# 
# # Print conflicting species
# if (length(conflicting_species) == 0) {
#   print("No conflicting values found for the same species.")
# } else {
#   print("Conflicting values found for the following species:")
#   print(conflicting_species)
# }
# 
# ## 2.3 Compare and contrast colnames
# colnames_s1 <- colnames(lewitus_data_list$Lewitus_etal_2014_TableS1)
# colnames_s8 <- colnames(lewitus_data_list$Lewitus_etal_2014_TableS8)
# 
# # Identify common column names
# common_colnames <- intersect(colnames_s1, colnames_s8)
# 
# # Identify column names unique to lewitus_data_list$Lewitus_etal_2014_TableS1
# unique_colnames_s1 <- setdiff(colnames_s1, colnames_s8)
# 
# # Identify column names unique to lewitus_data_list$Lewitus_etal_2014_TableS8
# unique_colnames_s8 <- setdiff(colnames_s8, colnames_s1)
# 
# # Print the results
# cat("Common column names:\n")
# print(common_colnames)
# 
# cat("\nColumn names unique to lewitus_data_list$Lewitus_etal_2014_TableS1:\n")
# print(unique_colnames_s1)
# 
# cat("\nColumn names unique to lewitus_data_list$Lewitus_etal_2014_TableS8:\n")
# print(unique_colnames_s8)

## 3 Merge the dataframes from the list which are from the same paper. Both have Species columns which are idenfiers, and GI columns which have complementary data
lewitus_data <- merge(
  x = as.data.frame(lewitus_data_list$Lewitus_etal_2014_TableS1),
  y = as.data.frame(lewitus_data_list$Lewitus_etal_2014_TableS8),
  by = c("Species", "GI"),
  all = TRUE
)


Lewitus_etal_2014_TableS1 <- lewitus_data_list$Lewitus_etal_2014_TableS1
Lewitus_etal_2014_TableS8 <- lewitus_data_list$Lewitus_etal_2014_TableS8

sort(lewitus_data_list$Lewitus_etal_2014_TableS1$Species)

# Add Species names to use based on Genus level match or better
Lewitus_etal_2014_TableS1$species_sci <- NA 
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Homo_sapiens"] <- "Homo sapiens"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Pan_troglodytes"] <- "Pan troglodytes"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Gorilla_gorilla"] <- "Gorilla gorilla gorilla" #Species
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Macaca_mulatta"] <- "Macaca mulatta"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Macaca_nemestrina"] <- "Macaca nemestrina"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Papio_hamadryas"] <- "Papio anubis" #Genus 
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Chlorocebus_sabaeus"] <- "Chlorocebus sabaeus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Saimiri_sciureus"] <- "Saimiri boliviensis boliviensis" #Genus 
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Sapajus_apella"] <- "Sapajus apella"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Callithrix_jacchus"] <- "Callithrix jacchus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Aotus_trivirgatus"] <- "Aotus nancymaae" #Genus 
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Otolemur_crassicaudatus"] <- "Otolemur garnettii" #Genus 
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Microcebus_murinus"] <- "Microcebus murinus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Tupaia_glis*"] <- "Tupaia belangeri" #Genus 
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Mus_musculus"] <- "Mus musculus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Rattus_norvegicus"] <- "Rattus norvegicus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Heterocephalus_glaber"] <- "Heterocephalus glaber"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Urocitellus_parryii"] <- "Urocitellus parryii"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Oryctolagus_cuniculus*"] <- "Oryctolagus cuniculus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Mustela_putorius"] <- "Mustela putorius furo" #Species
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Canis_latrans"] <- "Canis latrans"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Felis_catus"] <- "Felis catus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Sus_scrofa_domesticus"] <- "Sus scrofa" #Domestic
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Dasypus_novemcinctus*"] <- "Dasypus novemcinctus"
Lewitus_etal_2014_TableS1$species_sci[Lewitus_etal_2014_TableS1$Species == "Monodelphis_domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
Lewitus_etal_2014_TableS1 <- Lewitus_etal_2014_TableS1[, c("species_sci", setdiff(names(Lewitus_etal_2014_TableS1), "species_sci"))]

# Write the dataframe to an Excel file
write_xlsx(Lewitus_etal_2014_TableS1, "glia_gyrification.xlsx")

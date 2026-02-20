setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"

library(tidyverse)
library(writexl)

# Read data
cellcounts_long <- read.csv("./__merging_cellcounts/cellcounts_long.csv", check.names=FALSE)

# For Project M1 Evo: Export CerebralCortex Mass.g, N.n, O.n, I.p.N and their Sources
# cellcounts_selected_long <- filter(cellcounts_long, Variable %in% c("CerebralCortex_Mass.g","CerebralCortex_N.n", "CerebralCortex_O.n", "CerebralCortex_I.p.C", "WholeBrain_Mass.g","WholeBrain_N.n", "WholeBrain_O.n", "WholeBrain_I.p.C",  "SpinalCord_Mass.g","SpinalCord_N.n", "SpinalCord_O.n"))
cellcounts_selected_long <- cellcounts_long
# # Pivot for variables and values
cellcounts_selected_values <- pivot_wider(cellcounts_selected_long, id_cols = Species, names_from = Variable, values_from = Value)
# Pivot for sources
cellcounts_selected_sources <- pivot_wider(cellcounts_selected_long, id_cols = Species, names_from = Variable, values_from = Source)
# Rename source columns
colnames(cellcounts_selected_sources)[-1] <- paste0(colnames(cellcounts_selected_sources)[-1], "_Source")
# Combine the two datasets based on the Species column and Arrange by Species
cellcounts_selected <- arrange(bind_cols(cellcounts_selected_values, cellcounts_selected_sources[,-1]), Species)
# # Rename columns for values
# colnames(cellcounts_selected) <- gsub("_N.n", "_Neuron.n", colnames(cellcounts_selected))
# colnames(cellcounts_selected) <- gsub("_O.n", "_OtherCells.n", colnames(cellcounts_selected))
# colnames(cellcounts_selected) <- gsub("_I.p.C", "_Microglia.per.mg", colnames(cellcounts_selected))

# Add Species names to use based on Genus level match or better
cellcounts_selected$species_sci <- NA 
cellcounts_selected$species_sci[cellcounts_selected$Species == "Homo sapiens"] <- "Homo sapiens"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Pan troglodytes"] <- "Pan troglodytes"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Gorilla gorilla"] <- "Gorilla gorilla gorilla"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Macaca mulatta"] <- "Macaca mulatta"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Macaca nemestrina"] <- "Macaca nemestrina"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Papio cynocephalus"] <- "Papio anubis"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Chlorocebus sabaeus"] <- "Chlorocebus sabaeus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Saimiri sciureus"] <- "Saimiri boliviensis boliviensis"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Sapajus apella"] <- "Sapajus apella"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Callithrix jacchus"] <- "Callithrix jacchus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Aotus trivirgatus"] <- "Aotus nancymaae"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Otolemur garnettii"] <- "Otolemur garnettii"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Microcebus murinus"] <- "Microcebus murinus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Tupaia glis"] <- "Tupaia belangeri"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Mus musculus"] <- "Mus musculus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Rattus norvegicus"] <- "Rattus norvegicus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Heterocephalus glaber"] <- "Heterocephalus glaber"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Urocitellus parryii"] <- "Urocitellus parryii"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Oryctolagus cuniculus"] <- "Oryctolagus cuniculus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Mustela putorius furo"] <- "Mustela putorius furo"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Canis lupus familiaris"] <- "Canis latrans"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Felis catus"] <- "Felis catus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Sus scrofa domesticus"] <- "Sus scrofa"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Dasypus novemcinctus"] <- "Dasypus novemcinctus"
cellcounts_selected$species_sci[cellcounts_selected$Species == "Monodelphis domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
cellcounts_selected <- cellcounts_selected[, c("species_sci", setdiff(names(cellcounts_selected), "species_sci"))]

# Write the dataframe to an Excel file
write_xlsx(cellcounts_selected, paste0(folder_path, "cellcounts_selected.xlsx"))

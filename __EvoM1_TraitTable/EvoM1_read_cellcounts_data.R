library(tidyverse)
library(writexl)

# Read data
cellcounts_long <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cellcounts/cellcounts_long.csv", check.names=FALSE)

# For Project M1 Evo: Export CerebralCortex Mass.g, N.n, O.n, I.p.N and their Sources
Cx_Massg_Nn_On_IpC_long <- filter(cellcounts_long, Variable %in% c("CerebralCortex_Mass.g","CerebralCortex_N.n", "CerebralCortex_O.n", "CerebralCortex_I.p.C"))
# Pivot for variables and values
Cx_Massg_Nn_On_IpC_values <- pivot_wider(Cx_Massg_Nn_On_IpC_long, id_cols = Species, names_from = Variable, values_from = Value)
# Pivot for sources
Cx_Massg_Nn_On_IpC_sources <- pivot_wider(Cx_Massg_Nn_On_IpC_long, id_cols = Species, names_from = Variable, values_from = Source)
# Rename source columns
colnames(Cx_Massg_Nn_On_IpC_sources)[-1] <- paste0(colnames(Cx_Massg_Nn_On_IpC_sources)[-1], "_Source")
# Combine the two datasets based on the Species column and Arrange by Species
Cx_Massg_Nn_On_IpC <- arrange(bind_cols(Cx_Massg_Nn_On_IpC_values, Cx_Massg_Nn_On_IpC_sources[,-1]), Species)
# # Rename columns for values
# colnames(Cx_Massg_Nn_On_IpC) <- gsub("_N.n", "_Neuron.n", colnames(Cx_Massg_Nn_On_IpC))
# colnames(Cx_Massg_Nn_On_IpC) <- gsub("_O.n", "_OtherCells.n", colnames(Cx_Massg_Nn_On_IpC))
# colnames(Cx_Massg_Nn_On_IpC) <- gsub("_I.p.C", "_Microglia.per.mg", colnames(Cx_Massg_Nn_On_IpC))

# Add Species names to use based on Genus level match or better
Cx_Massg_Nn_On_IpC$species_sci <- NA 
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Homo sapiens"] <- "Homo sapiens"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Pan troglodytes"] <- "Pan troglodytes"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Gorilla gorilla"] <- "Gorilla gorilla gorilla"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Macaca mulatta"] <- "Macaca mulatta"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Macaca nemestrina"] <- "Macaca nemestrina"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Papio cynocephalus"] <- "Papio anubis"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Chlorocebus sabaeus"] <- "Chlorocebus sabaeus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Saimiri sciureus"] <- "Saimiri boliviensis boliviensis"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Sapajus apella"] <- "Sapajus apella"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Callithrix jacchus"] <- "Callithrix jacchus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Aotus trivirgatus"] <- "Aotus nancymaae"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Otolemur garnettii"] <- "Otolemur garnettii"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Microcebus murinus"] <- "Microcebus murinus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Tupaia glis"] <- "Tupaia belangeri"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Mus musculus"] <- "Mus musculus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Rattus norvegicus"] <- "Rattus norvegicus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Heterocephalus glaber"] <- "Heterocephalus glaber"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Urocitellus parryii"] <- "Urocitellus parryii"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Oryctolagus cuniculus"] <- "Oryctolagus cuniculus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Mustela putorius furo"] <- "Mustela putorius furo"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Canis lupus familiaris"] <- "Canis latrans"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Felis catus"] <- "Felis catus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Sus scrofa domesticus"] <- "Sus scrofa"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Dasypus novemcinctus"] <- "Dasypus novemcinctus"
Cx_Massg_Nn_On_IpC$species_sci[Cx_Massg_Nn_On_IpC$Species == "Monodelphis domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
Cx_Massg_Nn_On_IpC <- Cx_Massg_Nn_On_IpC[, c("species_sci", setdiff(names(Cx_Massg_Nn_On_IpC), "species_sci"))]

# Write the dataframe to an Excel file
write_xlsx(Cx_Massg_Nn_On_IpC, "brain_cortex_neurons_other_microglia.xlsx")

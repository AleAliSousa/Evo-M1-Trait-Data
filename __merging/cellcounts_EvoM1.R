# Read standardized terms
cellcounts_long <- read.csv("cellcounts_long.csv", check.names=FALSE)

# For Project M1 Evo: Export WholeBrain and CerebralCortex N.n., I.mg and Source
Br_Cx_Nn_On_Img_long <- filter(cellcounts_long, Variable %in% c("WholeBrain_N.n", "WholeBrain_O.n", "WholeBrain_I.p.mg", "CerebralCortex_N.n", "CerebralCortex_O.n", "CerebralCortex_I.p.mg"))
# Pivot for variables and values
Br_Cx_Nn_On_Img_values <- pivot_wider(Br_Cx_Nn_On_Img_long, id_cols = Species, names_from = Variable, values_from = Value)
# Pivot for sources
Br_Cx_Nn_On_Img_sources <- pivot_wider(Br_Cx_Nn_On_Img_long, id_cols = Species, names_from = Variable, values_from = Source)
# Rename source columns
colnames(Br_Cx_Nn_On_Img_sources)[-1] <- paste0(colnames(Br_Cx_Nn_On_Img_sources)[-1], "_Source")
# Combine the two datasets based on the Species column and Arrange by Species
Br_Cx_Nn_On_Img <- arrange(bind_cols(Br_Cx_Nn_On_Img_values, Br_Cx_Nn_On_Img_sources[,-1]), Species)
# Rename columns for values
colnames(Br_Cx_Nn_On_Img) <- gsub("_N.n", "_Neuron.n", colnames(Br_Cx_Nn_On_Img))
colnames(Br_Cx_Nn_On_Img) <- gsub("_O.n", "_OtherCells.n", colnames(Br_Cx_Nn_On_Img))
colnames(Br_Cx_Nn_On_Img) <- gsub("_I.p.mg", "_Microglia.per.mg", colnames(Br_Cx_Nn_On_Img))

# Add Species names to use based on Genus level match or better
Br_Cx_Nn_On_Img$species_sci <- NA 
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Homo sapiens"] <- "Homo sapiens"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Pan troglodytes"] <- "Pan troglodytes"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Gorilla gorilla"] <- "Gorilla gorilla gorilla"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Macaca mulatta"] <- "Macaca mulatta"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Macaca nemestrina"] <- "Macaca nemestrina"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Papio cynocephalus"] <- "Papio anubis"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Chlorocebus sabaeus"] <- "Chlorocebus sabaeus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Saimiri sciureus"] <- "Saimiri boliviensis boliviensis"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Sapajus apella"] <- "Sapajus apella"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Callithrix jacchus"] <- "Callithrix jacchus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Aotus trivirgatus"] <- "Aotus nancymaae"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Otolemur garnettii"] <- "Otolemur garnettii"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Microcebus murinus"] <- "Microcebus murinus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Tupaia glis"] <- "Tupaia belangeri"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Mus musculus"] <- "Mus musculus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Rattus norvegicus"] <- "Rattus norvegicus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Heterocephalus glaber"] <- "Heterocephalus glaber"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Urocitellus parryii"] <- "Urocitellus parryii"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Oryctolagus cuniculus"] <- "Oryctolagus cuniculus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Mustela putorius furo"] <- "Mustela putorius furo"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Canis lupus familiaris"] <- "Canis latrans"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Felis catus"] <- "Felis catus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Sus scrofa domesticus"] <- "Sus scrofa"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Dasypus novemcinctus"] <- "Dasypus novemcinctus"
Br_Cx_Nn_On_Img$species_sci[Br_Cx_Nn_On_Img$Species == "Monodelphis domestica"] <- "Monodelphis domestica"

# Reorder the columns to make "species_sci" the first column
Br_Cx_Nn_On_Img <- Br_Cx_Nn_On_Img[, c("species_sci", setdiff(names(Br_Cx_Nn_On_Img), "species_sci"))]

# Write the dataframe to an Excel file
library(writexl)
write_xlsx(Br_Cx_Nn_On_Img, "brain_cortex_neurons_other_microglia.xlsx")
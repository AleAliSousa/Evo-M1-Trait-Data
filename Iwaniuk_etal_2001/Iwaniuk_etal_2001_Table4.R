# Source
setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institue/Evo-M1-Trait-Data/")

# Table 2
##1. Read direct from xl
library(readxl)
folder_path <- "./Iwaniuk_etal_2001/"
tabledirectxl <- read_excel(paste0(folder_path,"Iwaniuk_etal_2001_Table4_snapshot.xlsx"))

##2. Update Species Names
tabledirectxl[which(tabledirectxl$Species == "C. capucinus"), "Species"] <- "Cebus capucinus"
tabledirectxl[which(tabledirectxl$Species == "C. diana"), "Species"] <- "Cercopithecus diana"
tabledirectxl[which(tabledirectxl$Species == "C. neglectus"), "Species"] <- "Cercopithecus neglectus"
tabledirectxl[which(tabledirectxl$Species == "C. guereza"), "Species"] <- "Colobus guereza"
tabledirectxl[which(tabledirectxl$Species == "M.fuscata"), "Species"] <- "Macaca fuscata"
tabledirectxl[which(tabledirectxl$Species == "M. mulatta"), "Species"] <- "Macaca mulatta"
tabledirectxl[which(tabledirectxl$Species == "M. nigra"), "Species"] <- "Macaca nigra"
tabledirectxl[which(tabledirectxl$Species == "M. radiata"), "Species"] <- "Macaca radiata"
tabledirectxl[which(tabledirectxl$Species == "P. cynocephalus"), "Species"] <- "Papio cynocephalus"
tabledirectxl[which(tabledirectxl$Species == "P. hamadrayas"), "Species"] <- "Papio hamadrayas"
tabledirectxl[which(tabledirectxl$Species == "P. ursinus"), "Species"] <- "Papio ursinus"
tabledirectxl[which(tabledirectxl$Species == "P. johnii"), "Species"] <- "Presbytis johnii"
tabledirectxl[which(tabledirectxl$Species == "H. syndactylus"), "Species"] <- "Hylobates syndactylus"
tabledirectxl[which(tabledirectxl$Species == "P. troglodytes"), "Species"] <- "Pan troglodytes"
tabledirectxl[which(tabledirectxl$Species == "A. occidentalis"), "Species"] <- "Avahi occidentalis"
tabledirectxl[which(tabledirectxl$Species == "E. mongoz"), "Species"] <- "Eulemur mongoz"
tabledirectxl[which(tabledirectxl$Species == "T. syrichta"), "Species"] <- "Tarsius syrichta"

##3. Adding Family 
tabledirectxl$Family[2:12] <- "Atelidae"
tabledirectxl$Family[14:17] <- "Callitrichidae"
tabledirectxl$Family[19:38] <- "Cercopithecidae"
tabledirectxl$Family[40] <- "Cheirogaleidae"
tabledirectxl$Family[43:48] <- "Hominidae"
tabledirectxl$Family[50:51] <- "Indridae"
tabledirectxl$Family[53:56] <- "Lemuridae"
tabledirectxl$Family[58:62] <- "Loridae"
tabledirectxl$Family[64] <- "Tarsiidae"

# Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
library(readxl) 
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "./__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)

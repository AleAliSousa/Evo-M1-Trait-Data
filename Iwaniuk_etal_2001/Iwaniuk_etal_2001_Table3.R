#1. Source
setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institue/Evo-M1-Trait-Data/")

#2. Table 1

## 1. Read direct from xl
library(readxl)
folder_path <- "./Iwaniuk_etal_2001/"
tabledirectxl <- read_excel(paste0(folder_path,"Iwaniuk_etal_2001_Table3_snapshot.xlsx"))

## 2. Adding Family 
tabledirectxl$Family[3] <- "Burramyidae"
tabledirectxl$Family[5:15] <- "Dasyuridae"
tabledirectxl$Family[17] <- "Didelphidae"
tabledirectxl$Family[19:43] <- "Macropodidae"
tabledirectxl$Family[46:47] <- "Peramelidae"
tabledirectxl$Family[49:53] <- "Petauridae"
tabledirectxl$Family[58] <- "Vombatidae"



#To-Do List - Superscript C and right alignments 
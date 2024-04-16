## 1. Source
setwd("C:/Users/MILONI/OneDrive - University of Bath/Research Schemes/Allen Institue/Evo-M1-Trait-Data/")

## 2. Table 2
#1. Read direct from xl
library(readxl)
folder_path <- "./Iwaniuk_etal_1999/"
tabledirectxl <- read_excel(paste0(folder_path,"Iwaniuk_etal_1999_Table1_snapshot.xlsx"))

#2. Change header name of column 1 and 2
colnames(tabledirectxl)[1] <- "Species Generic Name"
colnames(tabledirectxl)[2] <- "Species Scientific Name"


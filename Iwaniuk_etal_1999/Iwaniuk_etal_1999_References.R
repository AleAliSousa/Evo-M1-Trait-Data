## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./Iwaniuk_etal_1999/"

#Load readr
library(readr)
# Read the text version 
sheetfromtxt <- read_delim("Iwaniuk_etal_1999_References.txt", 
                           delim = "\t", escape_double = FALSE, 
                           trim_ws = TRUE, skip = 1)

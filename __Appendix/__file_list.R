setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")


# Get FileList list of files in comparative-data

library(openxlsx)
# List all files in the directory
list.files("./__Public/comparative-data")

# Get and write the list of files to Excel
write.xlsx(data.frame(Files = list.files("./__Public/comparative-data")), 
           "./__file_list.xlsx", sheetName = "FileList", colNames = TRUE)


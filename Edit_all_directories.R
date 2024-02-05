# Editing directories
#### ALREADY DONE 
# install.packages("xfun")
# library(xfun)
# # Update directory name in all R files in the directory and its subdirectories
# gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Evo M1 Trait Data", replacement = "Evo-M1-Trait-Data")

# # Update data pipeline step name in all R files in the directory and its subdirectories
# gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Primary or Equivalent", replacement = "Snapshot")
# gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "primary_or_equivalent", replacement = "snapshot")

# # Update data pipeline step name in all md in the directory and its subdirectories
# gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Primary or Equivalent", replacement = "Snapshot")
# gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "primary_or_equivalent", replacement = "snapshot")
#### ALREADY DONE  


# Get list of files in comparative-data
library(openxlsx)

# List all files in the directory
list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data")

# Get and write the list of files to Excel
write.xlsx(data.frame(Files = list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data")), 
           "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/file_list.xlsx", sheetName = "FileList", colNames = TRUE)

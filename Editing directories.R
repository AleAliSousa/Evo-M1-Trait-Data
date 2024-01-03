#Editing directories


install.packages("xfun")

library(xfun)

gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Evo M1 Trait Data", replacement = "Evo-M1-Trait-Data")

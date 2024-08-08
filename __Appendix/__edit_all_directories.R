## Editing directories : before running, move this outside of the directory to edit

# Update directory name in all R files in the directory and its subdirectories
library(xfun)
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging", recursive = TRUE, pattern = "__merging", replacement = "__merging_cellcounts")
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__EvoM1_TraitTable", recursive = TRUE, pattern = "__merging", replacement = "__merging_cellcounts")

# Get a report of each instance where a change was made
# library(xfun)
# # Perform the directory name substitution
# changed_paths <- gsub_dir(
#   ext = "R", 
#   dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/__merging", 
#   recursive = TRUE, 
#   pattern = "__merging", 
#   replacement = "__merging_cellcounts"
# )
# 
# # Check if any changes were made
# if (length(changed_paths) > 0) {
#   cat("Changes were made to the following paths:\n")
#   
#   # Print each changed path
#   for (path in changed_paths) {
#     cat(path, "\n")
#   }
# } else {
#   cat("No changes were made.\n")
# }

## PAST STEPS TAKEN
# Update directory name Evo-M1-Trait-Data
library(xfun)
getwd()
# Update directory name in all R files in the directory and its subdirectories
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Evo M1 Trait Data", replacement = "Evo-M1-Trait-Data")


# Update data pipeline step name in all R files in the directory and its subdirectories
library(xfun)
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Primary or Equivalent", replacement = "Snapshot")
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "primary_or_equivalent", replacement = "snapshot")
# Update data pipeline step name in all md in the directory and its subdirectories
gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "Primary or Equivalent", replacement = "Snapshot")
gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "primary_or_equivalent", replacement = "snapshot")

# Update directory names ____Unpublished__ProjectKaskan and ____EvoM1_TraitTable
library(xfun)
getwd()
# Update directory name in all R, Rmd and md files in the directory and its subdirectories
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "_ProjectKaskan__Unpublished", replacement = "____Unpublished__ProjectKaskan")
gsub_dir(ext = "Rmd", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "_ProjectKaskan__Unpublished", replacement = "____Unpublished__ProjectKaskan")
gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "_ProjectKaskan__Unpublished", replacement = "____Unpublished__ProjectKaskan")
# gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "__EvoM1_TraitTable", replacement = "____EvoM1_TraitTable")
gsub_dir(ext = "Rmd", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "__EvoM1_TraitTable", replacement = "____EvoM1_TraitTable")
gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "__EvoM1_TraitTable", replacement = "____EvoM1_TraitTable")
### NOte thsi resulted in too many hashtags!

# REDO # Update directory names with: Unpublished__ProjectKaskan and EvoM1_TraitTable
getwd()
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/____EvoM1_TraitTable")
library(xfun)
# Update EvoM1_TraitTable directory name in all R, Rmd and md files in the directory and its subdirectories
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "(_*)EvoM1_TraitTable", replacement = "____EvoM1_TraitTable")
gsub_dir(ext = "Rmd", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "(_*)EvoM1_TraitTable", replacement = "____EvoM1_TraitTable")
gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "(_*)EvoM1_TraitTable", replacement = "____EvoM1_TraitTable")

# Update Unpublished__ProjectKaskan directory name in all R, Rmd and md files in the directory and its subdirectories
gsub_dir(ext = "R", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "(_*)Unpublished__ProjectKaskan", replacement = "____Unpublished__ProjectKaskan")
gsub_dir(ext = "Rmd", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "(_*)Unpublished__ProjectKaskan", replacement = "____Unpublished__ProjectKaskan")
gsub_dir(ext = "md", dir = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data", recursive = TRUE, pattern = "(_*)Unpublished__ProjectKaskan", replacement = "____Unpublished__ProjectKaskan")


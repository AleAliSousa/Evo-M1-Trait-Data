# I. Read the published dataset from the source, and DO NOT pivot wider
## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____Unpublished__CellProportions/"

# I. Read the unpublished dataset
library(readxl)
library(dplyr)
library(writexl)

tabledirect <- read_excel(paste0(folder_path,"M1_cross_species_study_FACS_proportions.xlsx"))

#a = tabledirect %>% summarise(across(everything(), mean,na.rm=T), .by = c("Species_full"))
# Summarize "%NeuN+" and "%NeuN-" based on the mean of "Species_full"
summary_data <- tabledirect %>%
  group_by(Species_full) %>%
  summarise(
    "%NeuN+" = mean(`%NeuN+`, na.rm = TRUE),
    "%NeuN-" = mean(`%NeuN-`, na.rm = TRUE)
  )
  
# Write summarized data to Excel file
write_xlsx(summary_data, paste0(folder_path, "CellProportions_summary_data.xlsx"))

###################

# Adjust proportions in CellVariables after ____Unpublished__CellProportions

##Merge Unpublished__CellProportions with CellVariables
CellVariablesScaled <- merge(CellVariables, summary_data, by.x = "Species", by.y = "Species_full", all = TRUE)

# Get unique predicted.ids for each class 
excitatory_predicted_ids <- unique(subset(meta_m1, class == "Excitatory")$predicted.id)
inhibitory_predicted_ids <- unique(subset(meta_m1, class == "Inhibitory")$predicted.id)
nonneuronal_predicted_ids <- unique(subset(meta_m1, class == "Non-neuronal")$predicted.id)
# Combine unique predicted.ids for both classes
neuronal_predicted_ids <- unique(subset(meta_m1, class == c("Excitatory", "Inhibitory"))$predicted.id)

# The correction factor for each predicted.id is 
predicted.id (observed) * 

  
# Count occurrences of each category
count_non_neuronal <- sum(CellVariablesScaled$class == "Non-neuronal")
count_excitatory <- sum(CellVariablesScaled$class == "Excitatory")
count_inhibitory <- sum(CellVariablesScaled$class == "Inhibitory")  

# To determine the proportion of each cell type from the  %NeuN+ : %NeuN- data you need to multiply the observed count for a predicted.id by a correction factor
# The correction factor is the ratio which varies for each predicted.id
# for neuronal, (observed predicted.id cells count / observed total cells count) / %NeuN+
# for nonneuronal, (observed predicted.id cells count / observed total cells count) / %NeuN-
# Note: the numerator corrects for the observed ratio; the denominator applies the actual ratio

# e.g. Neuronal
for i in neuronal_predicted_ids
CellVariablesScaled$`L5 IT_scaled`  <-  count(CellVariablesScaled$`L5 IT`) * ((count("Excitatory", "Inhibitory")/count("Excitatory", "Inhibitory", "Non-neuronal"))/"%NeuN+")

# e.g. Nonneuronal
for i in nonneuronal_predicted_ids
CellVariablesScaled$Astro_scaled  <-  count(CellVariablesScaled$Astro) * ((count("Non-neuronal")/count("Excitatory", "Inhibitory", "Non-neuronal"))/"%NeuN-")


# For each predicted.id colname in CellVariablesScaled create a new column
# The new column should be called named with the predicted.id name, then underscore, then "scaled"


# Create an empty vector to store the results
result <- numeric(nrow(CellVariablesScaled))
# Iterate over each row
for (i in 1:nrow(CellVariablesScaled)) {
  # Check if the value in the "Astro" column is not NA
  if (!is.na(CellVariablesScaled$Astro[i])) {
    # Perform the multiplication
    result[i] <- CellVariablesScaled$Astro[i] * CellVariablesScaled$scaling[i]
  } else {
    # If the value in the "Astro" column is NA, assign NA to the result
    result[i] <- NA
  }
}
# Add the result as a new column to the dataframe
CellVariablesScaled$`Astro_%NeuN-` <- result
# Print the updated dataframe
CellVariablesScaled


# Create an empty vector to store the results
result <- numeric(nrow(CellVariablesScaled))
# Iterate over each row
for (i in 1:nrow(CellVariablesScaled)) {
  # Check if the value in the `L2/3 IT` column is not NA
  if (!is.na(CellVariablesScaled$`L2/3 IT`[i])) {
    # Perform the multiplication
    result[i] <- CellVariablesScaled$`L2/3 IT`[i] * CellVariablesScaled$`%NeuN+`[i]
  } else {
    # If the value in the `L2/3 IT` column is NA, assign NA to the result
    result[i] <- NA
  }
}
# Add the result as a new column to the dataframe
CellVariablesScaled$`L2/3 IT` <- result
# Print the updated dataframe
CellVariablesScaled

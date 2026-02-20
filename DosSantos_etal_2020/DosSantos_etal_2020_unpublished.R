setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./DosSantos_etal_2020/"

library(tidyr)
library(dplyr)
library(readxl)
library(readr)

# Set options to turn off scientific notation
options(scipen = 999)

# 1. Read the published dataset (reformatted but before species names were updated)
DosSantos_etal_2020_Table1 <- read_csv(paste0(folder_path,"DosSantos_etal_2020_Table1.csv"))

# 2. Read the unpublished dataset  
tabledirectxl <- read_excel(paste0(folder_path,"2020-PublishedDataMammalsMicroglia - cópia.xlsx"))

# I. Simplify unpublished dataset for comparison
# A. Calculate Missing averages
# Define the specific structure values to check
valid_structures <- c("Cerebral cortex, total (GM+WM+hippoc)", "Whole brain", "Hippocampus")

# Loop over the rows where 'Animal Common Name' is 'Elephant shrew (Average)' and '%Iba1+' is NA
for (i in which(tabledirectxl$`Animal Common Name` == "Elephant shrew (Average)" & is.na(tabledirectxl$`%Iba1+`))) {
  
  # Get the structure of the current row
  structure <- tabledirectxl$Structure[i]
  
  # Check if the structure is one of the valid structures
  if (structure %in% valid_structures) {
    
    # Calculate the average %Iba1+ for rows where 'Animal Common Name' is 'Elephant shrew' and the structure matches
    average_value <- mean(tabledirectxl$`%Iba1+`[tabledirectxl$`Animal Common Name` == "Elephant shrew" &
                                                         tabledirectxl$Structure == structure], na.rm = TRUE)
    # Assign the calculated average to the current row (if a valid average was found)
    if (!is.na(average_value)) {
      tabledirectxl$`%Iba1+`[i] <- average_value
    }
  }
}

# B. Delete all rows where Structure 2 numeric is NA AND Structure is NOT Hippocampus
# Remove rows where 'Structure 2 numeric' is NA and 'Structure' is not 'Hippocampus'
tabledirect_summary <- tabledirectxl[!(is.na(tabledirectxl$`Structure 2 numeric`) & 
                                      tabledirectxl$Structure != "Hippocampus"), ]

# Remove rows where 'Animal Common Name' matches  values which are not needed because there are already averages
to_remove <- c("Dog Golden", "Dog RNI2", "Ferret 2", "Ferret 850", "Rock hyrax", "Elephant shrew", "Four-toed elephant")
tabledirect_summary <- tabledirect_summary[!tabledirect_summary$`Animal Common Name` %in% to_remove, ]

# Remove rows where 'Animal Latin Name' not published
to_remove <- c("Hyaena hyaena", "Amblysomus hottentotus")
tabledirect_summary <- tabledirect_summary[!tabledirect_summary$`Animal Latin Name` %in% to_remove, ]

# Remove rows where 'Structure' is either only grey or white matter
structure_to_remove <- c("Cerebral cortex GM, all", "Cerebral cortex WM, all", "Cerebral cortex GM", "Cerebral cortex WM")
tabledirect_summary <- tabledirect_summary[!tabledirect_summary$Structure %in% structure_to_remove, ]

# Duplicate 'Animal Latin Name' and rename it 'Species'
tabledirect_summary$Species <- tabledirect_summary$`Animal Latin Name`

# Move 'Species' to the first column
tabledirect_summary <- tabledirect_summary[, c("Species", setdiff(names(tabledirect_summary), "Species"))]

# Rename 'Marmosops sp.' to 'Marmosops incanus' in the 'Species' column
tabledirect_summary$Species[tabledirect_summary$Species == "Marmosops sp."] <- "Marmosops incanus"

# C. Extract only the data needed
# Remove the single row where 'Structure is "Cerebral cortex GM, all +hp"
structure_to_remove <- "Cerebral cortex GM, all +hp"
tabledirect_summary <- tabledirect_summary[!tabledirect_summary$Structure %in% structure_to_remove, ]

# Extract the columns to compare
tabledirect_filtered <- tabledirect_summary[, c("Animal Latin Name", "Animal Common Name", "Species", "Structure", "Structure 2 numeric","%Iba1+")]
unique(tabledirect_filtered$Structure)

# Delete rows where '%Iba1+' is NA
tabledirect_filtered <- tabledirect_filtered[!is.na(tabledirect_filtered$`%Iba1+`), ]

# Duplicate 'Structure' column and call it 'Structure_Code'
tabledirect_filtered$Structure_Code <- tabledirect_filtered$Structure

# Rename 'Structure_Code' based on the mappings provided
tabledirect_filtered$Structure_Code[tabledirect_filtered$Structure_Code %in% c("Hippocampus")] <- "Hp"
tabledirect_filtered$Structure_Code[tabledirect_filtered$Structure_Code %in% c("Cerebellum", "Cerebellum total")] <- "Cb"
tabledirect_filtered$Structure_Code[tabledirect_filtered$Structure_Code %in% c("Whole brain")] <- "Br"
tabledirect_filtered$Structure_Code[tabledirect_filtered$Structure_Code %in% c("Rest of brain")] <- "RoB"
tabledirect_filtered$Structure_Code[tabledirect_filtered$Structure_Code %in% c("Cerebral cortex, total (GM+WM+hippoc)", 
                                                                               "Cx total (GM+WM+Hp+Ent+Amyg)")] <- "Cx"
tabledirect_filtered$Structure_Code[tabledirect_filtered$Structure_Code %in% c("Cerebral Cx, total - hp", 
                                                                               "Cerebral cortex, total -hp")] <- "Ctx"

unique(tabledirect_filtered$Structure_Code)

# D. Extract only the columns needed
unpublished <- tabledirect_filtered[, c("Species", "Structure_Code", "%Iba1+")]
unique(unpublished$Structure)

# add a suffix "_I/C"after each string in unpublished$Structure_Code
unpublished$Structure_Code <- paste0(unpublished$Structure_Code, "_I/C")

# Sort the dataframe by Species, then by Structure_Code, then by %Iba1+
unpublished <- unpublished %>%
  arrange(Species, Structure_Code, `%Iba1+`)

## II. Get comparable data from the publication dataset 

# Calculate new I/C columns for publication dataset
# Get the column names (excluding the first column)
column_names <- colnames(DosSantos_etal_2020_Table1)[-1]

# Split column names by the underscore
split_names <- strsplit(column_names, "_")

# Extract prefixes and suffixes
prefixes <- sapply(split_names, `[`, 1)  # Get the first element (prefix)
suffixes <- sapply(split_names, `[`, 2)  # Get the second element (suffix)

# Get unique prefixes and suffixes
unique_prefixes<-unique(prefixes)
unique_suffixes<-unique(suffixes)

unique_prefixes
unique_suffixes

# Loop through each unique prefix
for (prefix in unique_prefixes) {
  # Create column names for 'I' and 'C' suffixes for the current prefix
  I_col <- paste0(prefix, "_I")
  C_col <- paste0(prefix, "_C")
  
  # Check if both columns (I and C) exist in the dataset
  if (I_col %in% colnames(DosSantos_etal_2020_Table1) & C_col %in% colnames(DosSantos_etal_2020_Table1)) {
    # Create a new column with the ratio I / C
    new_col <- paste0(prefix, "_I/C")
    DosSantos_etal_2020_Table1[[new_col]] <- DosSantos_etal_2020_Table1[[I_col]] / DosSantos_etal_2020_Table1[[C_col]]
  }
}

# Create a new df with only Species name and all the column with suffix "_I/C"
# Subset the dataframe to include only 'Species name' and columns ending with '_I/C'
I_C_columns <- grep("_I/C$", colnames(DosSantos_etal_2020_Table1), value = TRUE)

# Create a new dataframe with 'Species name' and the '_I/C' columns
publication_dataset <- DosSantos_etal_2020_Table1[, c("Species name", I_C_columns)]

# Rename 'Species name' to 'Species'
colnames(publication_dataset)[colnames(publication_dataset) == "Species name"] <- "Species"

# Pivot the dataframe to long format, ensuring 'Species' is the first column
publication <- pivot_longer(
  publication_dataset,
  cols = -Species,       # All columns except 'Species
  names_to = "Structure_Code",      # Create a column for the column names
  values_to = "%Iba1+"            # Create a column for the values
)

# Ensure 'Species' is the first column
publication <- publication[, c("Species", "Structure_Code", "%Iba1+")]

# Remove rows where %Iba1+ is NA
publication <- publication %>%
  filter(!is.na(`%Iba1+`))

# Sort the dataframe by Species, then by Structure_Code, then by %Iba1+
publication <- publication %>%
  arrange(Species, Structure_Code, `%Iba1+`)

# View the resulting long dataframe
head(unpublished)
head(publication)

# III Compare unpublished to published version (bonus check)

# Remove published rows which were the only ones of their measurement type in the unpublished dataset, and those might be different structures than reported or at least not comparable to any other species

## Identify and print rows to be removed
rows_to_remove <- publication %>%
  filter((Species == "Homo sapiens sapiens" & Structure_Code == "Ctx_I/C") |
           (Species == "Macropus rufus" & Structure_Code == "P+M_I/C"))

print("Rows to be removed:")
print(rows_to_remove)

# Filter out the rows
publication<- publication %>%
  filter(!(Species == "Homo sapiens sapiens" & Structure_Code == "Ctx_I/C") &
           !(Species == "Macropus rufus" & Structure_Code == "P+M_I/C"))

merged_df <- merge(unpublished, publication, by = c("Species", "Structure_Code"), suffixes = c("_unpublished", "_publication"), all = TRUE)

# Calculate the percent difference
merged_df$Percent_Difference <- abs(merged_df$`%Iba1+_unpublished` - merged_df$`%Iba1+_publication`) / 
  ((merged_df$`%Iba1+_unpublished` + merged_df$`%Iba1+_publication`) / 2) * 100

## IV Set up the unpublished data
# Pivot the dataframe to wide format, ensuring 'Species' is the first column
unpublished_wide <- unpublished %>%
  pivot_wider(names_from = Structure_Code,
              values_from = `%Iba1+`,
              #names_glue = "{Structure_Code}",
              values_fill = NA) %>%
  select(Species, everything())


## V Save the unpublished data

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. Save

# Finalize dataframe (UPDATE!!!)
final.dataframe <- unpublished_wide

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

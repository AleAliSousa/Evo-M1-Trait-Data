# Set Working Directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging")

## 1. Get data
## 1.1 Create a list with all the dataframes for cell count analyses
## 1.2 Change to standardized terminology for all variables in those dataframes
## 1.3 Calculate variables to match them across datasets (if needed) 
## 1.4 Rename species to NCBI Taxonomy (if needed) 
# - are species and subspecies both represented for any given species?
## 1.5 Combine all data in all dataframes in cellcounts_data_list 
## 1.6 Check for and address any conflicting datapoints across datasets 

## 2. Examine WholeBrain dataset
## 2.1 Get a full list of WholeBrain_N.n from all dataframes in the list cellcounts_data_list.
## 2.2 Compile total of all datasets on Whole Brain cellular composition
# 2a. Create a regression of whole brain cell count on body mass for all species 
# - compile all data on whole brain cell count, brain mass, brain volume, body mass.  Compare the sample size for brain mass versus brain volume
# 2b. Create vectors for WholeBrain from all dfs with reference to term list: see if it can search all dfs in a folder? 

# 3. Impute missing data
# 3Qa. What data should be included/excluded when doing an imputation?

    
# 1. Get data
library(tidyverse)
library(readxl)

## 1.1 Create a list with all the dataframes for cell count analyses

# List of item names
item_name <- c(
  "DosSantos_etal_2017_TableS1",
  "DosSantos_etal_2020_Table1",
  "HerculanoHouzel_etal_2015_Table1",
  "HerculanoHouzel_etal_2015_Table2",
  "HerculanoHouzel_etal_2015_Table3",
  "HerculanoHouzel_etal_2015_Table4",
  "HerculanoHouzel_etal_2015_Table5",
  "HerculanoHouzel_etal_2020_TABLE1",
  "HerculanoHouzel_etal_2020_TABLE2",
  "JardimMesseder_etal_2017_Table1",
  "Kverkova_etal_2018_TableS1",
  "Kverkova_etal_2018_TableS5"
)

# Initialize an empty list to store data frames with cell counts data
cellcounts_data_list <- list()

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")

# Loop through item names, read tables from TSVs, and store as dataframes in the list
for (i in seq_along(item_name)) {
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  item_data <- read.table(file = paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/", item_encoded, ".tsv"), 
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

  # Store the data frame in the list with the corresponding item name
  cellcounts_data_list[[item_name[i]]] <- item_data
}

# list2env(cellcounts_data_list, envir = environment()) # Make the dataframes available in the environment

## 1.2 Change to standardized terminology for all variables in those dataframes

# Read standardized terms
standardized_term_cellcounts <- read.csv("standardized_term_cellcounts.csv", check.names=FALSE)

# Loop through each data frame to apply standardized terms
for (i in seq_along(item_name)) {
  df <- cellcounts_data_list[[item_name[i]]]
  indices <- match(colnames(df), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == item_name[i]])
  colnames(df) <- (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == item_name[i]])[indices]
  cellcounts_data_list[[item_name[i]]] <- df
}

## 1.3 Calculate variables to match them across datasets (if needed)

# 1.3.1 Inspect data: Get an alphabetized list of variables from all datasets in alphabetical order to examine. Q. Can any variables be converted?
# Initialize an empty vector to store all column names
all_variables <- character(0)
# Loop through each data frame
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- cellcounts_data_list[[item_name[i]]]
  # Extract column names (variables) from the current data frame
  variables_in_df <- colnames(df)
  # Combine unique column names with the existing vector
  all_variables <- unique(c(all_variables, variables_in_df))
}
# Sort the column names alphabetically and view
all_variables <- sort(all_variables)
all_variables

# 1.3.2 Calculate variables to make comparisons
# Different terms were used to show that in Kverkova et al 2018 included olfactory bulb in Whole brain, but in the other datasets it did not (see definitions).
# "WholeBrainOlfactoryBulb" denotes the whole brain including the olfactory bulb
# To standardize create new variables starting with "WholeBrain" before the first underscore by subtracting the "OlfactoryBulb" component from "WholeBrainOlfactoryBulb" and naming the new variable as "WholeBrain_X."
# The formula is "WholeBrain_X"="WholeBrainOlfactoryBulb_X"−"OlfactoryBulb_X"

# Loop: Calculate "WholeBrain_" from differences between "WholeBrainOlfactoryBulb_" and "OlfactoryBulb_" columns
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- cellcounts_data_list[[i]]
  
  # Check if there are columns starting with "WholeBrainOlfactoryBulb_"
  wholebrainolfactorybulb <- grep("^WholeBrainOlfactoryBulb_", colnames(df), value = TRUE)
  
  # Loop through matching columns and calculate differences
  for (matching in wholebrainolfactorybulb) {
    # Extract the common suffix
    suffix <- sub("^WholeBrainOlfactoryBulb_", "", matching)
    
    # Check if corresponding "OlfactoryBulb_" column exists
    olfactorybulb_check <- paste0("OlfactoryBulb_", suffix)
    
    if (olfactorybulb_check %in% colnames(df)) {
      # Calculate the differences and store in the corresponding "WholeBrain_" columns
      new_col_wholebrain <- paste0("WholeBrain_", suffix)
      df[[new_col_wholebrain]] <- df[[matching]] - df[[olfactorybulb_check]]
    }
  }
  
  # Update the data frame in the list
  cellcounts_data_list[[i]] <- df
}

## 1.4 Compare Species to NCBI Taxonomy and rename to this standard

# 1.4.1 Compare full source_species_list to NCBI Taxonomy ID 
library(taxizedb)

# Get a full list of species in alphabetical order to examine
source_species_list <- character(0)
for (i in seq_along(cellcounts_data_list)) {
  source_species_list <- sort(unique(c(source_species_list, cellcounts_data_list[[i]]$Species)))
}

# Get NCBI Taxonomic IDs for source_species_list
ids <- name2taxid(source_species_list, out_type = "summary")
# Get NCBI Preferred Names for those Taxonomic IDs
preferred_names <- taxid2name(ids$id, out_type = "summary")

# Identify any names not listed
names_not_listed <- setdiff(source_species_list, ids$name)

# Create a data frame with Species Name in Source, Preferred Name and Taxonomic ID
source_species_ids <- data.frame(
  Species_Name_Source = source_species_list,
  Preferred_Name = NA,
  Taxonomic_ID = NA
)

# Update Taxonomic_Name and Taxonomic_ID for listed species
source_species_ids$Taxonomic_ID[source_species_list %in% ids$name] <- ids$id
source_species_ids$Preferred_Name[source_species_list %in% ids$name] <- preferred_names

# Include names_not_listed in the Species_Name_Source column with "NA"
source_species_ids <- rbind(source_species_ids, data.frame(
  Species_Name_Source = names_not_listed,
  Preferred_Name = NA,
  Taxonomic_ID = NA
))

# Sort source_species_ids by the same order as source_species_list
source_species_ids <- source_species_ids[match(source_species_list, source_species_ids$Species_Name_Source), ]

# Add a column to check if Preferred_Name is different from Original_Species_Name or if it's NA and Original_Species_Name is from names_not_listed
source_species_ids$different <- ifelse(source_species_ids$Preferred_Name != source_species_ids$Species_Name_Source | (is.na(source_species_ids$Preferred_Name) & source_species_ids$Species_Name_Source %in% names_not_listed), TRUE, "")

# Add a column to check if Preferred_Name is exactly the same as Species_Name_Source
source_species_ids$exact <- ifelse(source_species_ids$Preferred_Name == source_species_ids$Species_Name_Source, TRUE, "")

# Add a column called Reference_Note to source_species_ids
source_species_ids$Reference_Note <- ifelse(
  source_species_ids$Preferred_Name == source_species_ids$Species_Name_Source, 
  "NCBI exact",
  ifelse(
    !is.na(source_species_ids$Preferred_Name),
    "NCBI",
    NA
  )
)

## 1.4.2 Create a new column for updated species names if they are not all the NCBI default Preferred Name for their Taxonomic ID

# Add a column called Species_Name with the Preferred_Name. If NA, leave blank (for now).
source_species_ids$Species_Name <- ifelse(
  !is.na(source_species_ids$Preferred_Name), 
  source_species_ids$Preferred_Name,
  NA
)

# Add information about the remaining species: Species_Name to use and reference note
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Cryptomys pretoriae"] <- "Cryptomys hottentotus pretoriae"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Cryptomys pretoriae"] <- "ITIS invalid synonym"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Cynomys sp."] <- "Cynomys sp."
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Cynomys sp."] <- "Genus, species unknown"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Dasyprocta prymnolopha"] <- "Dasyprocta prymnolopha"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Dasyprocta prymnolopha"] <- "ITIS valid, missing from NCBI"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Homo sapiens sapiens"] <- "Homo sapiens"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Homo sapiens sapiens"] <- "GBIF for subspecies"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Papio anubis cynocephalus"] <- "Papio cynocephalus"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Papio anubis cynocephalus"] <- "referenced papers call these Papio cynocephalus (Gabi 2010), Papio sp (HH 2008)"

# Automatically add Taxonomic_IDs and Preferred_Name if NA (unless exempt from this step)
# These are exempt, because NCBI Taxon ID doesn't apply at species level: Dasyprocta prymnolopha, Cynomys sp.
# Create species_list with updated names
species_list <- source_species_ids$Species_Name
# Update Taxonomic IDs for species_list
ids <- name2taxid(species_list, out_type = "summary")
# Update Preferred Names for those Taxonomic IDs
preferred_names <- taxid2name(ids$id, out_type = "summary")
# Update Taxonomic_ID for listed species
source_species_ids$Taxonomic_ID <- ifelse(
  is.na(source_species_ids$Taxonomic_ID),
  ids$id[match(source_species_ids$Species_Name, ids$name)],
  source_species_ids$Taxonomic_ID
)
# Update Preferred_Name for listed species
source_species_ids$Preferred_Name <- ifelse(
  is.na(source_species_ids$Preferred_Name),
  ids$name[match(source_species_ids$Taxonomic_ID, ids$id)],
  source_species_ids$Preferred_Name
)

# Save the data frame as a CSV file
write.csv(source_species_ids, "source_species_ids.csv", row.names = FALSE)

# 1.4.3 If there are species without NCBI ID, duplicate "Species" in all dataframes in cellcounts_data_list and call it "Species_Source", so that "Species" can be edited
# Loop through each data frame in the list
for (i in seq_along(cellcounts_data_list)) {
  # Duplicate the "Species" column and rename it to "Species_Source"
  cellcounts_data_list[[i]]$Species_Source <- cellcounts_data_list[[i]]$Species
}

# Loop through each data frame in the list cellcounts_data_list and the "Species" column by matching cellcounts_data_list "Species_Source"  to source_species_ids "Species_Name_Source", and then using the value from source_species_ids "Species_Name"
for (i in seq_along(cellcounts_data_list)) {
  cellcounts_data_list[[i]]$Species <- source_species_ids$Species_Name[match(cellcounts_data_list[[i]]$Species_Source, source_species_ids$Species_Name_Source)]
}

# Check species list versions it #Here, Homo sapiens sapiens was collapsed with Homo sapiens
species_list_update2 <- character(0)
for (i in seq_along(cellcounts_data_list)) {
  # Combine the unique species names with the existing vector in alphabetical order
  species_list_update2 <- sort(unique(c(species_list_update2, cellcounts_data_list[[i]]$Species)))
}
species_list_update2
species_list
source_species_list


## 1.5 Combine all data in all dataframes in cellcounts_data_list as a long dataframe
library(dplyr)
library(tidyr)

# Assuming cellcounts_data_list is your list of dataframes
combined_data <- lapply(names(cellcounts_data_list), function(source) {
  df <- cellcounts_data_list[[source]]
  
  # Convert all columns to character strings
  df[] <- lapply(df, as.character)
  
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  
  return(df_long)
})
# Combine all dataframes in the list into a single dataframe
combined_data <- bind_rows(combined_data)

## 1.6 Check for and address any conflicting datapoints across datasets 

## 1.6.1 Determine worth order for dataframes to give priority
# Initialize an empty dataframe to store the summary
worth_dataframe <- data.frame(source = character(),
                              date = numeric(),
                              number_species = numeric(),
                              stringsAsFactors = FALSE)

# Iterate over the dataframes in cellcounts_data_list
for (df_name in names(cellcounts_data_list)) {
  
  # Extract date from the dataframe name
  date <- as.numeric(str_extract(df_name, "[0-9]+"))
  
  # Extract number of species from the dataframe
  number_species <- nrow(cellcounts_data_list[[df_name]]) - 1  # Subtract 1 for the header
  
  # Append the information to the summary dataframe
  worth_dataframe <- rbind(worth_dataframe, data.frame(source = df_name,
                                                       date = date,
                                                       number_species = number_species))
}

# Sort (highest to lowest) by date first , then by number_species
worth_dataframe <- worth_dataframe[order(-worth_dataframe$date, -worth_dataframe$number_species), ]

# Reset row names
rownames(worth_dataframe) <- NULL

# Add a new column called "priority" with row numbers as values
worth_dataframe$priority <- seq_len(nrow(worth_dataframe))

# Append a "priority" column to the "combined_data" dataframe by matching "Source" values with "source" in "worth_dataframe"
combined_data$priority <- match(combined_data$Source,  worth_dataframe$source, worth_dataframe$priority)

write_csv(combined_data, "combined_data.csv")

## 1.6.2 Limit dataset to best available data
# remove any NA values in combined_data
intermediate_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
write_csv(intermediate_data, "intermediate_data.csv")

## TESTING ZONE START
# Example dataframe
df <- data.frame(
  Species = c('HS', 'HS', 'HS', 'HS', 'LA', 'LA', 'LA'),  
  Variable = c('WBNN', 'WBNN', 'WBNN', 'CNN', 'CNN', 'WBNN', 'CNN'),
  Source = c('JM', 'HH', 'DS', 'DS', 'JM', 'JM', 'HH'),
  priority = c('3', '1', '2', '2', '3', '3', '1'),
  Value = c(10, 10, 20, 30, 40, 50, 60)
)

# Add a blank column "DECISION"
df$DECISION <- ""

# Convert dataframe to a list of dataframes
df_list <- split(df, list(df$Species, df$Variable))

# Create a loop to update "DECISION" based on the specified condition
for (i in seq_along(df_list)) {
  priority_values <- df_list[[i]]$priority
  df_list[[i]]$DECISION[df_list[[i]]$priority > min(priority_values)] <- "WORSE"
}

# See the updated list of matrices
df_list

# Combine all rows from df_list into one dataframe excluding rows with DECISION:WORSE
updated_df <- do.call(rbind, df_list)
updated_df <- updated_df[updated_df$DECISION != "WORSE", ]

# See the updated dataframe
updated_df
## TESTING ZONE END

## APPLY TESTING ZONE START
# Add a blank column "DECISION"
intermediate_data$DECISION <- ""

# Convert dataframe to a list of dataframes
df_list <- split(intermediate_data, list(intermediate_data$Species, intermediate_data$Variable))

# Create a loop to update "DECISION" based on the specified condition
for (i in seq_along(df_list)) {
  priority_values <- df_list[[i]]$priority
  df_list[[i]]$DECISION[df_list[[i]]$priority > min(priority_values)] <- "WORSE"
}

# See the updated list of matrices
df_list

# Combine all rows from df_list into one dataframe excluding rows with DECISION:WORSE
updated_df <- do.call(rbind, df_list)
updated_df <- updated_df[updated_df$DECISION != "WORSE", ]

# See the updated dataframe
updated_df
## APPLY TESTING ZONE END
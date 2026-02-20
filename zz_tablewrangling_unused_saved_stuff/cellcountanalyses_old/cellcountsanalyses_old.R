# Set Working Directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging")

## 1. Get data
## 1.1 Create a list with all the dataframes for cell count analyses
## 1.2 Change to standardized terminology for all variables in those dataframes
## 1.3 Calculate variables to match them across datasets (if needed) 
## 1.4 Calculate species to match them across datasets (if needed) 
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

## 1.4 Calculate species to match them across datasets (if needed)

## 1.4.1 Inspect data: Get a full list of species in alphabetical order to examine
# Initialize an empty vector to store species names
species_list <- character(0)

# Loop through each data frame in the list
for (i in seq_along(cellcounts_data_list)) {
  # Combine the unique species names with the existing vector in alphabetical order
  species_list <- sort(unique(c(species_list, cellcounts_data_list[[i]]$Species)))
}

## 1.4.2 Check if Species overlap between dataframe pairs
# Get the unique Species names for each dataframe in the list
all_species <- lapply(cellcounts_data_list, function(df) unique(df$Species))

# # Compare all pairs of dataframes for repeated Species names
# repeated_species_pairs <- list()
# for (i in 1:(length(cellcounts_data_list) - 1)) {
#   for (j in (i + 1):length(cellcounts_data_list)) {
#     repeated_species <- intersect(all_species[[i]], all_species[[j]])
#     if (length(repeated_species) > 0) {
#       pair_name <- paste("Pair", item_name[i], "-", item_name[j], sep="-")
#       repeated_species_pairs[[pair_name]] <- repeated_species
#     }
#   }
# }
# 
# # Print the result
# if (length(repeated_species_pairs) > 0) {
#   print("Pairs with repeated species:")
#   print(repeated_species_pairs)
# } else {
#   print("No pairs with repeated species.")
# }

## 1.5 Combine all data in all dataframes in cellcounts_data_list

# 1.5.1 Create a new list to store dataframes with suffixes
suffix_data_list <- list()

# Add suffix to each dataframe and store in the new list
for (i in 1:length(cellcounts_data_list)) {
  current_df <- cellcounts_data_list[[i]]
  suffix <- names(cellcounts_data_list)[i]
  
  # Add suffix to variables in the dataframe
  current_df <- setNames(current_df, c("Species", paste(names(current_df)[-1], paste("__", suffix, sep = ""), sep = "")))
  
  # Store the dataframe in the new list
  suffix_data_list[[i]] <- current_df
}

## 1.5.2 Combine all data in all dataframes in suffix_data_list, "Species" is the common identifier
combined_data <- suffix_data_list[[1]]

for (i in 2:length(suffix_data_list)) {
  # Merge based on the "Species" column
  combined_data <- full_join(combined_data, suffix_data_list[[i]], by = "Species")
}

# Sort columns alphabetically
combined_data <- combined_data[, order(names(combined_data))]

# Ensure "Species" is the first column
combined_data <- combined_data[, c("Species", setdiff(names(combined_data), "Species"))]

# Sort rows by the "Species" column
combined_data <- combined_data[order(combined_data$Species), ]

# Reset row names
rownames(combined_data) <- NULL

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

## 1.6.2 Limit dataset to best available data

# Create an intermediate dataframe where lesser-ranked source values are marked as "WORSE."
intermediate_data <- combined_data

write.csv(intermediate_data, "Intermediata_data.csv")
write.csv(worth_dataframe, "Worth_dataframe.csv")
# # ## ## #TRY SOMETHING
# get_info_for_cell <- function(data, species_index, column_index) {
#   species <- data$Species[species_index]
#   column_name <- colnames(data)[column_index]
#   
#   # Extract variable and source from the column name
#   variable_source <- strsplit(column_name, "__")[[1]]
#   variable <- variable_source[1]
#   source <- variable_source[2]
#   
#   # Extract all column names with the same variable
#   variable_colnames <- grep(paste0("^", variable, "__"), colnames(data), value = TRUE)
#   
#   # Extract all valid, non-"NA" non-"WORSE" sources for the same variable and species
#   variable_sources_valid <- (sapply(strsplit(variable_colnames, "__"), function(x) x[2]))[!is.na(data[species_index, variable_colnames]) & data[species_index, variable_colnames] != "WORSE"]
#   
#   # Extract all ranks for valid sources for the same variable and species
#   variable_sources_valid_ranks <- worth_dataframe$priority[match(variable_sources_valid, worth_dataframe$source)]
#   
#   # Extract the BEST rank for valid sources for the same variable and species
#   variable_sources_best_rank <- min(worth_dataframe$priority[match(variable_sources_valid, worth_dataframe$source)])
#   
#   # Extract all WORSE ranks for valid sources for the same variable and species  # Filter for ranks greater than the minimum rank
#   variable_sources_worse_ranks <- variable_sources_valid_ranks[variable_sources_valid_ranks > min(worth_dataframe$priority[match(variable_sources_valid, worth_dataframe$source)])]
#   
#   # Get the values for the specified cell and sources
#   cell_value <- data[species_index, column_index]
#   variable_values <- data[species_index, variable_colnames]
#   
#   result <- list(
#     species = species,
#     column_name = column_name,
#     variable = variable,
#     source = source,
#     variable_colnames = variable_colnames,
#     variable_sources_valid = variable_sources_valid,
#     variable_sources_valid_ranks = variable_sources_valid_ranks,
#     variable_sources_best_rank = variable_sources_best_rank,
#     variable_sources_worse_ranks = variable_sources_worse_ranks,
#     cell_value = cell_value,
#     variable_values = variable_values
#   )
#   
#   return(result)
# }
# 
# # Example usage:
# result <- get_info_for_cell(intermediate_data, species_index = 44, column_index = 258)
# print(result)
# 
# # ## ## #END SOMETHING



# # Your function to mark values as "WORSE" based on the condition
# mark_worse <- function(data, variable_colnames, source_col, rank_col, worth_dataframe) {
#   # Extract variable and source from the column name
#   data %>%
#     mutate(across(
#       .cols = -c(Species),
#       .fns = ~ifelse(
#         !is.na(.x) & .x != "" & .x != "WORSE" & worth_dataframe$source[which.min(worth_dataframe$priority)] != .x,
#         "WORSE",
#         .x
#       )
#     ))
# }

# Apply the function to your dataframe
variable_source <- strsplit(colnames(intermediate_data), "__")[2:length(colnames(intermediate_data))]
variable <- lapply(variable_source,function(x) x[1])
source <- lapply(variable_source,function(x) x[2])

# intermediate_data <- mark_worse(
#   data = intermediate_data,
# 
#   variable_col = colnames(intermediate_data),
#   source_col = intermediate_data %>%
#     select(matches("__source")) %>%
#     colnames(),
#   rank_col = worth_dataframe$priority,  # Use the correct column name from worth_dataframe
#   worth_dataframe = worth_dataframe
# )



# #### CODE BELOW IS FINE ####
# 
# ## 2. Examine WholeBrain dataset
# ## 2.1 Get a full list of WholeBrain_N.n from all dataframes in the list cellcounts_data_list.
# WholeBrain_N.n <- character(0)
# 
# # Loop through each data frame in the list
# for (i in seq_along(cellcounts_data_list)) {
#   # Extract the "Species" column from the current data frame
#   species_col <- cellcounts_data_list[[i]]$Species
#   
#   # Combine the unique species names with the existing vector
#   all_species <- unique(c(all_species, species_col))
# }
# 
# # Sort the vector in alphabetical order
# all_species <- sort(all_species)
# all_species
# 
# ## 2.2 Compile total of all datasets on Whole Brain cellular composition
# 
# # Initialize an empty dataframe
# combined_df <- data.frame(Species = character(), WholeBrain_N.n = numeric())
# 
# # Loop through each data frame in the list
# for (i in seq_along(cellcounts_data_list)) {
#   # Check if "WholeBrain_N.n" and "Species" columns exist in the current data frame
#   if ("WholeBrain_N.n" %in% colnames(cellcounts_data_list[[i]]) &&
#       "Species" %in% colnames(cellcounts_data_list[[i]])) {
#     # Extract the relevant columns and append to the combined dataframe
#     combined_df <- rbind(combined_df, cellcounts_data_list[[i]][c("Species", "WholeBrain_N.n")])
#   }
# }
# 
# # View the combined dataframe
# combined_df
# 
# #### CODE ABOVE IS FINE ####

## 1.7 Check for and address any conflicting datapoints across datasets (if problems found, redo and repeat steps above, e.g., 1.5-)
## To run this, first run cellcountanalyses.R and then borrow that environment. Note that this could alter the environment.

## EITHER 1.7a USING FILTERED Combine all data in all dataframes in cellcounts_data_list as a long dataframe
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

## OR 1.7b USING UN-FILTERED Combine all data in all dataframes in filtered_cellcounts_data_list as a long dataframe
combined_data <- lapply(names(filtered_cellcounts_data_list), function(source) {
  df <- filtered_cellcounts_data_list[[source]]
  
  # Convert all columns to character strings
  df[] <- lapply(df, as.character)
  
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  
  return(df_long)
})

## 1.7.1 Comparisons to do with the previously created list of dfs df_list (1.7a Original version or 1.7b Filtered version) 

## 1.7.1.1 Check if there are values that differ, and check if any differ by than 1% 

# Filter the list of dataframes to only include those with more than one row
comp_df_list <- lapply(df_list, function(df) {
  if (nrow(df) > 1) {
    return(df)
  } else {
    return(NULL)  # Returning NULL for dataframes with one or fewer rows
  }
})

# Remove NULL elements from the list
comp_df_list <- comp_df_list[!sapply(comp_df_list, is.null)]

# See the filtered list of dataframes
comp_df_list

# Filter the list of dataframes to only include those where the "Value" column differs between rows
comp_df_list_diff <- lapply(comp_df_list, function(df) {
  if (anyDuplicated(df$Value) == 0) {
    return(df)
  } else {
    return(NULL)  # Returning NULL for dataframes with duplicate "Value" values
  }
})
comp_df_list_diff <- comp_df_list_diff[!sapply(comp_df_list_diff, is.null)] # Remove NULL elements from the list

# See the filtered list of dataframes with differing "Value" values
comp_df_list_diff

# Convert the "Value" column to numerical in comp_df_list_diff
comp_df_list_diff <- lapply(comp_df_list_diff, function(df) {
  df$Value <- as.numeric(df$Value)
  return(df)
})

## 1.7.1.2 Check if any differ by more than 1% 

# Filter the list of dataframes to only include those where the "Value" column differs between rows by more than 1% (absolute value)
comp_df_list_diff_more_than_1_percent <- lapply(comp_df_list_diff, function(df) {
  if (all(abs(diff(df$Value) / df$Value[-length(df$Value)]) > 0.01)) {
    return(df)
  } else {
    return(NULL)  # Returning NULL for dataframes that don't meet the criteria
  }
})
comp_df_list_diff_more_than_1_percent <- comp_df_list_diff_more_than_1_percent[!sapply(comp_df_list_diff_more_than_1_percent, is.null)] # Remove NULL elements from the list

# See the filtered list of dataframes with differing "Value" values by more than 1%
comp_df_list_diff_more_than_1_percent

# 1.7.1.3 Compare specific datasets  
#### NOTE: Conflicts that differ by > 1% are all between HerculanoHouzel_etal_2015 and DosSantos_etal_2020 (different method), or Kverkova (different specimens) 

# Check for species in filtered_cellcounts_data_list$DosSantos_etal_2020* but not in filtered_cellcounts_data_list$HerculanoHouzel_etal_2015*
# Initialize an empty list to store dataframes
dataframes_list <- list()

# Create a list of dataframes for DosSantos_etal_2020
dos_santos_df_names <- grep(paste0("^", "DosSantos_etal_2020"), names(filtered_cellcounts_data_list), value = TRUE)
for (dos_santos_df_name in dos_santos_df_names) {
  dataframes_list[[length(dataframes_list) + 1]] <- filtered_cellcounts_data_list[[dos_santos_df_name]]
}

# Create a list of dataframes for HerculanoHouzel_etal_2015
herculano_houzel_df_names <- grep(paste0("^", "HerculanoHouzel_etal_2015"), names(filtered_cellcounts_data_list), value = TRUE)
for (herculano_houzel_df_name in herculano_houzel_df_names) {
  dataframes_list[[length(dataframes_list) + 1]] <- filtered_cellcounts_data_list[[herculano_houzel_df_name]]
}

# Get species from DosSantos_etal_2020 dataframes
dos_santos_2020_species <- unique(unlist(lapply(dataframes_list[grepl("DosSantos_etal_2020", names(filtered_cellcounts_data_list))], function(df) df$Species)))
dos_santos_2020_species

# Get species from HerculanoHouzel_etal_2015 dataframes
herculano_houzel_2015_species <- unique(unlist(lapply(dataframes_list[grepl("HerculanoHouzel_etal_2015", names(filtered_cellcounts_data_list))], function(df) df$Species)))
herculano_houzel_2015_species

# Identify unique species from these combined
unique_species <- unique(c(dos_santos_2020_species, herculano_houzel_2015_species))
unique_species

# Identify species in DosSantos_etal_2020 but not in HerculanoHouzel_etal_2015
species_only_in_dos_santos <- setdiff(dos_santos_2020_species, herculano_houzel_2015_species)
species_only_in_dos_santos

# Identify species in HerculanoHouzel_etal_2015 but not in DosSantos_etal_2020
species_only_in_herculano_houzel <- setdiff(herculano_houzel_2015_species, dos_santos_2020_species)
species_only_in_herculano_houzel
## Check for and address any conflicting datapoints across datasets (if problems found, redo and repeat steps)

# 1 Compare unfiltered datasets 

# Read unfiltered data
cellcounts_unfiltered <- read.csv("cellcounts_unfiltered.csv", check.names=FALSE)
  
# Remove any NA values in dataframe cellcounts_unfiltered
intermediate_data <- cellcounts_unfiltered[!is.na(cellcounts_unfiltered$Value), , drop = FALSE]

# Convert dataframe to a list of dataframes
df_list <- split(intermediate_data, list(intermediate_data$Species, intermediate_data$Variable))

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

## 2 Check if any differ by more than 1% 

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

 
#### NOTE: Conflicts that differ by > 1% are all between HerculanoHouzel_etal_2015 and DosSantos_etal_2020 (different method), or Kverkova (different specimens) 
## Specific notes:
## HerculanoHouzel_etal_2015_Table5$WholeBrain_Mass.g for Loxodonta africana matches primary source Herculano-Houzel et al., 2014
## HerculanoHouzel_etal_2015_Table2$Cerebellum_N.n for Procavia capensis matches primary source Neves et al., 2014
## HerculanoHouzel_etal_2015_Table1$CerebralCortex_N.n for Macaca fascicularis matches primary source Gabi et al., 2010 (where it is rounded)
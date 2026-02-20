###TESTING MICROGLIA

# Why are Dendrohyrax dorsalis values for I.n so different after flagging & filtering DosSantos 2020 I.n, and recalculating using Herculano Houzel I.n?

#Comparing I.n calculations (Dos Santos 2020 versus in the script)
subset_1_I.n <- cellcounts_data_list$DosSantos_etal_2020_Table1[, c("Species", "WholeBrain_I.n")]
subset_2_I.n <- best_data_wide[, c("Species", "WholeBrain_I.n")]
compare_I.n <- merge(subset_1_I.n, subset_2_I.n, "Species")
compare_I.n$Percent_Difference <- with(compare_I.n, ((WholeBrain_I.n.x - WholeBrain_I.n.y) / WholeBrain_I.n.y) * 100)
options(scipen = 999)
View(compare_I.n)
# Conclusion:

#Comparing N.n calculations (Dos Santos 2020 versus in the script)
subset_1_N.n <- cellcounts_data_list$DosSantos_etal_2020_Table1[, c("Species", "WholeBrain_N.n")]
subset_2_N.n <- best_data_wide[, c("Species", "WholeBrain_N.n")]
compare_N.n <- merge(subset_1_N.n, subset_2_N.n, "Species")
compare_N.n$Percent_Difference <- with(compare_N.n, ((WholeBrain_N.n.x - WholeBrain_N.n.y) / WholeBrain_N.n.y) * 100)
options(scipen = 999)
View(compare_N.n)
# Conclusion: N.n is the same, so it is not the cause of the problem

#Comparing N.n calculations (Dos Santos 2020 versus in the script)
subset_1_N.p.mg <- cellcounts_data_list$DosSantos_etal_2020_Table1[, c("Species", "WholeBrain_N.p.mg")]
subset_2_N.p.mg <- best_data_wide[, c("Species", "WholeBrain_N.p.mg")] # Does not exist -- other papers did not report this
compare_N.p.mg <- merge(subset_1_N.p.mg, subset_2_N.p.mg, "Species")
compare_N.p.mg$Percent_Difference <- with(compare_N.p.mg, ((WholeBrain_N.p.mg.x - WholeBrain_N.p.mg.y) / WholeBrain_N.p.mg.y) * 100)
options(scipen = 999)
View(compare_N.p.mg)
# Conclusion: Only Dos Santos 2020 reported WholeBrain_N.p.mg so no comparison possible
# Could try to recalculate it after getting Mass.g


# # Load required library
# library(dplyr)
# # Assuming cellcounts_data_list is a list of data frames
# # First, filter out the columns with the name "WholeBrain_N.n" from each data frame
# filtered_data <- lapply(cellcounts_data_list, function(df) {
#   df %>%
#     select(Species, WholeBrain_N.n)
# })
# # Then merge the data frames by the column "Species"
# merged_data_N.n <- Reduce(function(x, y) {
#   merge(x, y, by = "Species", all = TRUE)
# }, filtered_data)
# # Print or return the merged data frame
# print(merged_data_N.n)


# Load required library
library(dplyr)

# Assuming cellcounts_data_list is a list of data frames
# First, filter out the columns with the name "WholeBrain_N.n" from each data frame
filtered_data <- lapply(cellcounts_data_list, function(df) {
  if (exists("WholeBrain_N.n", where = colnames(df))) {
    df %>%
      select(Species, WholeBrain_N.n)
  } else {
    message("Column 'WholeBrain_N.n' does not exist in the dataframe.")
    NULL
  }
})

# Filter out NULL values
filtered_data <- filtered_data[!sapply(filtered_data, is.null)]

if (length(filtered_data) == 0) {
  message("None of the data frames contain the column 'WholeBrain_N.n'.")
} else {
  # Then merge the data frames by the column "Species"
  merged_data_N.n <- Reduce(function(x, y) {
    merge(x, y, by = "Species", all = TRUE)
  }, filtered_data)
  
  # Print or return the merged data frame
  print(merged_data_N.n)
}

###TESTING MASS
#Compare the Mass calculations in 

compare3<-HerculanoHouzel_Team_data_long[HerculanoHouzel_Team_data_long$Variable == "WholeBrain_N.p.mg", c("Species", "Source", "Variable", "Value")]


# # 1.3.2.4 Calculate _N.p.mg where not reported (e.g. WholeBrain)
# # For each dataframe in the list cellcounts_data_list
# # Extract unique prefixes from the column names in the dataframe where where the prefix is the portion of the column name before "_".
# # For each unique prefix, 
# ### if a corresponding _N.p.mg column does exist,
# ### if also the corresponding _N.p.mg column has NA values,
# ### if also the corresponding _N.n column has non-NA values,
# ### if also the corresponding _Mass.g column has non-NA values,
# #### then calculate _N.p.mg
# ### Otherwise, if a corresponding _N.p.mg column does not exist
# ### if also the corresponding _N.p.mg column has NA values,
# ### if also the corresponding _N.n column has non-NA values,
# ### if also the corresponding _Mass.g column has non-NA values,
# #### then create _N.p.mg column
# #### then calculate _N.p.mg
# # Formula: _N.p.mg = (_N.n /_Mass.g) * 1000
# 
# ### Alternative: manually create the columns first in the table that lacks them

# # 1.3.2.4

# Initialize a list to store indices of dataframes with missing N.p.mg values
missing_npm_indices <- list()

# Loop through each dataframe in the list cellcounts_data_list
for (i in seq_along(cellcounts_data_list)) {
  # Extract the dataframe
  df <- cellcounts_data_list[[i]]
  
  # Extract unique suffix terms before `_` in column names
  suffix_terms <- unique(sub(".*_", "", colnames(df)))
  
  # Initialize a list to store indices of rows with missing N.p.mg values in this dataframe
  missing_npm_indices_df <- list()
  
  # Loop through each unique suffix term
  for (suffix in suffix_terms) {
    # Create column names for Mass.g, N.n, and N.p.mg
    mass_column <- paste0(suffix, "_Mass.g")
    nn_column <- paste0(suffix, "_N.n")
    npm_column <- paste0(suffix, "_N.p.mg")
    
    # Check if there are rows with non-NA Mass.g and N.n values but NA N.p.mg value
    missing_npm_rows <- which(!is.na(df[[mass_column]]) & !is.na(df[[nn_column]]) & is.na(df[[npm_column]]))
    
    # If there are missing N.p.mg rows, store their indices
    if (length(missing_npm_rows) > 0) {
      missing_npm_indices_df[[suffix]] <- missing_npm_rows
    }
  }
  
  # If there are any missing N.p.mg rows in this dataframe, store its index
  if (length(missing_npm_indices_df) > 0) {
    missing_npm_indices[[i]] <- missing_npm_indices_df
  }
}

# Check if any dataframes have missing N.p.mg values
if (length(missing_npm_indices) > 0) {
  print("Dataframes with missing N.p.mg values:")
  print(missing_npm_indices)
} else {
  print("No dataframes have missing N.p.mg values.")
}
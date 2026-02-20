# Initialize metadata_flags for each dataframe with a common suffix
metadata_flags <- list()

for (df in item_name) {
  metadata_flags[[df]] <- data.frame(
    Flag_Description = c(NA),
    Flag_Condition = c(NA)
  )
}

## Extract suffixes from DosSantos_etal_2020_Table1 to determine secondary data variables to exclude.
suffixes <- unique(sub(".*_", "", grep(".*_.*", colnames(cellcounts_data_list$DosSantos_etal_2020_Table1), value = TRUE)))
# Ignore '_I.p.mg' which is primary and Species_Source which is not a variable.
suffixes <- suffixes[!(suffixes %in% c("I.p.mg", "Source"))]
# Create a string to paste in the R code below
paste0("_",suffixes, collapse = "|")

# Define the changes for metadata_flags$DosSantos_etal_2020_Table1_metadata_flags
# metadata_flags$DosSantos_etal_2020_Table1$Flag_Condition <- c("!grepl('_I.p.mg', colnames(filtered_cellcounts_data_list[[df_name]]))")
metadata_flags$DosSantos_etal_2020_Table1$Flag_Condition <- c("grepl('_C.n|_I.n|_I.p.N|_N.n|_N.p.mg|_n|_Mass.g', colnames(filtered_cellcounts_data_list[[df_name]]))")
metadata_flags$DosSantos_etal_2020_Table1$Flag_Description <- c("Secondary data variables omitted as some data found to be typos inconsistent with primary sources. Only keep I.mg")


# There are two lists, cellcounts_data_list and metadata_flags
# Look into list cellcounts_data_list and loop through every dataframe. 
# Find the cellcounts_data_list dataframe name that matches the metadata_flags dataframe name.
# If the Flag_Condition value is NA, skip 
# If the Flag_Condition value is a string, use the string (without quotes) as an R script designating a set of datapoints in that dataframe, and delete all values in the dataframe thatare in that  set of datapoints



# Loop through every dataframe in filtered_cellcounts_data_list
for (df_name in names(filtered_cellcounts_data_list)) {
  # df_name <- "DosSantos_etal_2020_Table1"
  # Find the corresponding metadata_flags dataframe
  flag_df <- metadata_flags[[df_name]]
  
  # If Flag_Condition is a string, use it as an R script
  if (is.character(flag_df$Flag_Condition)) {
    
    # Assuming your R script is a valid condition
    delete_datapoints <- flag_df$Flag_Condition
    
    # Designate a set of datapoints in the dataframe and delete them
    subset_condition <- eval(parse(text = delete_datapoints))
    matching_indices <- which(subset_condition)
    
    # Determine if rows or columns should be excluded
    if (length(matching_indices) > 1) {
      # Exclude matching columns from the copy
      filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][, -matching_indices]
    } else if (length(matching_indices) == 1) {
      # Exclude matching rows from the copy
      filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][-matching_indices, ]
    } else {
      # Handle the case when no indices are found (no exclusions needed)
      cat("No matching indices found for exclusion in", df_name, "\n")
    }
  }
}

# View the modified list of dataframes outside the loop
View(filtered_cellcounts_data_list)

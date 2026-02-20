# Make dataframe
```{r}
# # Initialize an empty list to store modified data frames
# clean_df_list_3 <- list()
# # Loop through each data frame in clean_df_list_3
# for (df_name in names(transposed_df_list)) {
#   # Get the current data frame
#   df <- transposed_df_list[[df_name]]
#   # Convert to sataframe
#   df <- as.data.frame(df)
#   # Store the modified data frame in the new list
#   clean_df_list_3[[df_name]] <- df
# }
```
# Delete Row 1
```{r}
# # Initialize an empty list to store modified data frames
# clean_df_list_2 <- list()
# # Loop through each data frame in clean_df_list_2
# for (df_name in names(clean_df_list)) {
#   # Get the current data frame
#   df <- clean_df_list[[df_name]]
#   # Delete Row 1
#   df <- df[-1, ]
#   # Store the modified data frame in the new list
#   clean_df_list_2[[df_name]] <- df
# }
```
# # Transpose all data frames in updated_df_list_information
# transposed_df_list <- lapply(updated_df_list_information, function(df) t(df))

# # Transpose all data frames in updated_df_list_information
# transposed_df_list <- lapply(updated_df_list_information, function(df) as.data.frame(t(df)))


# # Combine the sheet names with the basename of the file
# df_names <- paste0(basename(file), "__", sheet_names)


# # Check if each data frame in df_list has any of the specified column names
# has_comp <- sapply(df_list, function(df) any(grepl("^Results Rachael krubitzer_kaas_1993_marmoset and owl monkey.xlsx", names(df)))
# # Filter df_list to include only data frames with NO column whose name starts with "Results Rachael krubitzer_kaas_1993_marmoset and owl monkey.xlsx" 
# no_comp_df_list <- df_list[sapply(df_list, function(df) !any(grepl("^Results Rachael krubitzer_kaas_1993_marmoset and owl monkey.xlsx", names(df))))]

new_area_column_name <- "Area.mm2"
new_region_column_name <- "Region.Kaskan"
rename_columns <- function(df) {
  area_columns <- c("AREA CONVERTED To mm2", "AREA CONVERTED TO (mm2)", "AREA CONVERTED To cm2")
  for (col_name in area_columns) {
    if (col_name %in% names(df)) {
      names(df)[names(df) == col_name] <- new_area_column_name
    }
  }
  if ("REGION (Kaskan 2005)" %in% names(df)) {
    names(df)[names(df) == "REGION (Kaskan 2005)"] <- new_region_column_name
  }
  return(df)
}
modified_df_list <- lapply(area_df_list, rename_columns)

# Calculate sum of Area.mm2 for each Region.Kaskan
calculate_sum_by_region <- function(df) {
  sum_by_region <- aggregate(df[[new_area_column_name]], by = list(df[[new_region_column_name]]), sum)
  names(sum_by_region) <- c(new_region_column_name, "Sum.Area.mm2")
  return(sum_by_region)
}
# Apply the function to each data frame in area_df_list
sum_by_region_list <- lapply(modified_df_list, calculate_sum_by_region)





# # Check if each data frame in df_list has any of the specified column names
# area_has_area_column_check <- sapply(area_df_list, function(df) any(area_column_names %in% names(df)))
# area_has_area_column_check



# # Check that there is only one column per dataframe with the new names
# # Initialize variables to store counts
# area_counts <- numeric(length(modified_df_list))
# region_counts <- numeric(length(modified_df_list))
# # Loop through each modified data frame in modified_df_list
# for (i in seq_along(modified_df_list)) {
#   # Count occurrences of "Area.mm2" and "Region.Kaskan" in the current data frame
#   area_counts[i] <- sum(names(modified_df_list[[i]]) == "Area.mm2")
#   region_counts[i] <- sum(names(modified_df_list[[i]]) == "Region.Kaskan")
# }
# # Summarize counts across all data frames
# total_area_count <- sum(area_counts)
# total_region_count <- sum(region_counts)
# # Print individual and total counts
# print(area_counts)
# print(region_counts)
# print(total_area_count)
# print(total_region_count)

# # Read all Rachael xlsx files into R
# directory <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/____Unpublished__ProjectKaskan/Rachael_Robinson_dissertation_file_copies/Brains data for animals"
# excel_files <- list.files(directory, pattern = "\\.xlsx$", full.names = TRUE)
# df_list <- lapply(excel_files, read_excel)
# names(df_list) <- basename(excel_files)

# # Initialize an empty list to store data frames with area columns
# area_df_list <- list()
# # Loop through each data frame in df_list
# for (i in seq_along(df_list)) {
#   # Check if the data frame has any of the specified column names
#   if (any(area_column_names %in% names(df_list[[i]]))) {
#     # If yes, assign the data frame to the same name in area_df_list
#     area_df_list[[i]] <- df_list[[i]]
#     # Rename the data frame to its original name
#     names(area_df_list)[i] <- names(df_list)[i]
#   }
# }
# area_df_list
# Check if each sheet has REGION (Kaskan 2005) column
region_column_names <- c("REGION (Kaskan 2005)")
has_region_column <- sapply(area_df_list, function(df) any(region_column_names %in% names(df)))
has_region_column
#good!

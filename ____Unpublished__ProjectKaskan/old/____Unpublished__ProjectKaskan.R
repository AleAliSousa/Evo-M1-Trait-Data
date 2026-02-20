# Check if each dataframe in updated_df_list has a column called "Information about brain"
has_info_column <- lapply(updated_df_list, function(df) "Information about brain" %in% names(df))
for (i in seq_along(has_info_column)) {
  cat("Data frame", i, ": Has 'Information about brain' column? ", has_info_column[[i]], "\n") # Print the result for each dataframe
}


# Check if "Information about brain" is not the last column
 check_info_position <- function(df) {
   # Check if "Information about brain" is in the column names
   if ("Information about brain" %in% names(df)) {
     # Find the index of "Information about brain"
     info_index <- which(names(df) == "Information about brain")
     # Check if "Information about brain" is not the last column
     if (info_index < ncol(df)) {
       return(TRUE)  # "Information about brain" is not the last column
     }
   }
   return(FALSE)  # "Information about brain" is the last column or not present
 }
 # Apply the function to each dataframe in updated_df_list
 all_info_not_last <- all(sapply(updated_df_list, check_info_position))
 # Print the result
 if (all_info_not_last) {
   print("In all dataframes, 'Information about brain' is not the last column.")
 } else {
   print("In at least one dataframe, 'Information about brain' is the last column or not present.")
 }

 
 # Check if all dataframes have a column called "REGION MEASURED"
 all_have_region_measured <- all(sapply(updated_df_list, function(df) "REGION MEASURED" %in% colnames(df)))
 all_have_region_measured

# library(myTAI)
# 
# # Initialize an empty data frame to store results
# result_df <- data.frame(Species = character(0), Taxonomy_ID = character(0), stringsAsFactors = FALSE)
# 
# # If stuck: Start from the nth species on the list
# start_index <- 18
# species_list <- species_list[start_index:length(species_list)]
# 
# 
# # Loop through each species name in the list
# for (species_name in species_list) {
#   # Search NCBI taxonomy for the current species name
#   result <- myTAI::taxonomy(organism = species_name,
#                              db       = "ncbi",
#                              output   = "taxid" )
# 
#   # Check if there is a match
#   if (!is.null(result)) {
#     # Add a row to the result data frame
#     result_df <- rbind(result_df, data.frame(Species = species_name, Taxonomy_ID = result, stringsAsFactors = FALSE))
#   } else {
#     # If no match, add a row with FALSE
#     result_df <- rbind(result_df, data.frame(Species = species_name, Taxonomy_ID = "FALSE", stringsAsFactors = FALSE))
#   }
# }

# # Loop through unique variables and species to mark "WORSE" for lesser-ranked sources
# for (variable in unique_variables) {
#   for (species_index in seq_along(unique_species)) {
#     species <- unique_species[species_index]
#     
#     # Identify sources (dataframes) related to the current variable
#     
#     column_headers <- grep(paste0("^", variable, "__"), names(intermediate_data), value = TRUE)
#     sources <- sub("^.*?__", "", grep(paste0("^", variable, "__"), names(intermediate_data), value = TRUE))
#     ranked_sources <- worth_dataframe$source[worth_dataframe$source %in% sources]
#     
#     # Find the source with the minimum rank
#     if (length(ranked_sources) > 0) {
#       min_rank_source <- ranked_sources[which.min(worth_dataframe$priority[worth_dataframe$source %in% ranked_sources])]
#     } else {
#       min_rank_source <- NULL
#     }
#     
#     # Loop through identified sources
#     for (source in sources) {
#       # Check if the source is the one with the minimum rank
#       if (!is.null(min_rank_source) && source == min_rank_source) {
#         # Do nothing, keep the original value
#       } else {
#         # Mark as "WORSE" for sources other than the one with the minimum rank
#         intermediate_data[species_index, grep(source, names(intermediate_data))] <- "WORSE"
#       }
#     }
#   }
# }
# view(intermediate_data)


# #####TEST
# # Assuming 44th species and 258th column index
# species_index <- 44
# column_index <- 258
# 
# # Step 1: Print the value
# value <- intermediate_data[species_index, column_index]
# if (!is.na(value)) {
#   print(paste("Value:", value))
#   # Step 2: Obtain sources with non-NA values for the same species and variable
#   species_name <- rownames(intermediate_data)[species_index]
#   variable <- gsub("__.*", "", colnames(intermediate_data)[column_index])
#   #sources_with_values <- names(intermediate_data[species_index, ][!is.na(intermediate_data[species_index, ])])
#   #Select the row corresponding to the specified species index
#   selected_row <- intermediate_data[species_index, ]
#   #Filter out elements in the selected row that are not NA (not missing values) and 
#   non_na_elements <- selected_row[!is.na(selected_row)]
#   #Get Names of columns with elements in the selected row that are not NA (not missing values)
#   column_names <- colnames(non_na_elements)
#   
#   # #retrieve the names of the resulting non-NA elements
#   # sources_with_values <- names(non_na_elements)
#   
#   print(paste("All in Row:", selected_row))
#   print(paste("Has Value in Row:", non_na_elements))
#   print(paste("B Values in Row:", sources_with_values))
#   print(paste("Species:", species_name))
#   print(paste("Variable:", variable))
#   print(paste("Sources with non-NA values:", sources_with_values))
#   
#   # Step 3: Print column names and values for these sources
#   values_for_sources <- intermediate_data[species_index, sources_with_values]
#   print(paste("Column names:", names(values_for_sources)))
#   print(paste("Values for sources:", values_for_sources))
#   
#   # Step 4: Print the whole group of sources for the variable with non-NA values
#   sources_for_variable <- grep(paste0("^", variable, "__"), names(intermediate_data), value = TRUE)
#   print(paste("All sources for the variable:", sources_for_variable))
#   
#   # Step 5: Obtain ranks of sources based on worth_dataframe$source
#   ranks_for_sources <- worth_dataframe$priority[worth_dataframe$source %in% sources_for_variable]
#   print(paste("Ranks for sources:", ranks_for_sources))
#   
#   # Step 6: Identify the highest-ranked source
#   highest_ranked_source <- sources_for_variable[which.max(ranks_for_sources)]
#   print(paste("Highest-ranked source:", highest_ranked_source))
# } else {
#   print("Value is NA.")
# }
# 
# #####END

## OLD TRY ##

# # Extract unique species names 
# unique_species <- combined_data$Species
# 
# # Extract unique variable names without suffixes with double underscore as separator
# unique_variables <- unique(sapply(strsplit(names(combined_data)[-1], "__"), function(x) x[1]))
# 
# # Extract all included variable names with sources, with double underscore as separator
# variable__source <- colnames(combined_data)[-1]
# 
# # # Extract unique source names, the suffixes with double underscore as separator
# # unique_suffixes <- unique(sapply(strsplit(names(combined_data)[-1], "__"), function(x) ifelse(length(x) > 1, x[2], "")))


# Loop through unique variables and species to mark "WORSE" for lesser-ranked sources
for (variable in unique_variables) {
  for (species in unique_species) {
    ranked_sources <- worth_dataframe$source[worth_dataframe$source %in% unique_suffixes]
    # Loop through identified suffix
    for (suffix in unique_suffixes) {
      # Check if the suffix is among the ranked sources
      if (suffix %in% ranked_sources) {
        # Get the rank value for the suffix
        rank_value <- worth_dataframe$priority[worth_dataframe$source == suffix]
        # Replace values in intermediate_data based on rank
        intermediate_data[species, grep(suffix, names(intermediate_data))] <-
          ifelse(rank_value == 1, intermediate_data[species, grep(suffix, names(intermediate_data))], "WORSE")
      }
    }
  }
}

# Replace all cells marked "WORSE" with NA.
intermediate_data <- intermediate_data %>% mutate_all(~ ifelse(. == "WORSE", NA, .))

# Create a final dataframe with only one value per variable per species.
final_data <- intermediate_data %>%
  group_by(Species) %>%
  summarise(across(starts_with(unique_variables), ~ first(na.omit(.))))
## OLD TRY ##





# troubleshoot cellcountanalyses

# Assuming a_cellcounts_data_list is a list of dataframes
# Replace df1, df2, etc. with the actual dataframes in your list

# Example dataframes
df1 <- data.frame(Species = c('A', 'B', 'C'), Value = c(1, 2, 3))
df2 <- data.frame(Species = c('A', 'B', 'D'), Value = c(4, 5, 6))
df3 <- data.frame(Species = c('A', 'C', 'D'), Value = c(7, 8, 9))

a_cellcounts_data_list <- list(df1, df2, df3)

# ## 1.5 Combine all data in all dataframes in cellcounts_data_list, "Species" is the common identifier
# combined_data <- cellcounts_data_list[[1]]
# 
# for (i in 2:length(cellcounts_data_list)) {
#   # Merge based on the "Species" column
#   combined_data <- full_join(combined_data, cellcounts_data_list[[i]], by = "Species")
# }
# 
# # Sort columns alphabetically
# combined_data <- combined_data[, order(names(combined_data))]
# 
# # Sort rows by the "Species" column
# combined_data <- combined_data[order(combined_data$Species), ]
# 
# # View
# combined_data
# colnames(combined_data)

# inconsistencies <- list()
# 
# for (i in 2:length(cellcounts_data_list)) {
#   inconsistencies[[i - 1]] <- setdiff(names(cellcounts_data_list[[i]]), names(cellcounts_data_list[[1]]))
# }
# 
# # Identify common variables
# common_variables <- Reduce(intersect, lapply(cellcounts_data_list, names))
# 
# # Initialize combined_data with the first dataframe
# combined_data <- cellcounts_data_list[[1]]
# 
# # Flag inconsistencies before merging
# for (i in 2:length(cellcounts_data_list)) {
#   inconsistent_rows <- apply(cellcounts_data_list[[i]][common_variables], 1, function(row) {
#     any(!row %in% combined_data[, common_variables])
#   })
#   
#   # Create a new column to flag inconsistencies
#   cellcounts_data_list[[i]]$Inconsistency <- ifelse(inconsistent_rows, "Inconsistent", "Consistent")
# }
# 
# # Merge on all variables
# for (i in 2:length(cellcounts_data_list)) {
#   # Merge based on all common variables
#   combined_data <- merge(combined_data, cellcounts_data_list[[i]], by = common_variables, all = TRUE, suffixes = c("", paste0("_", i)))
# }
# 
# # Sort rows by the "Species" column
# combined_data <- combined_data[order(combined_data$Species), ]
# 
# # View
# combined_data
# colnames(combined_data)

# ## 1.7.2 Merge all the dataframes in cellcounts_data_list while resolving conflicts based on the ranking of dataframes in worth_dataframe, you can use the dplyr package in R. Here's an example code:
# 
# # Combine all dataframes in cellcounts_data_list using reduce
# merged_dataframe <- purrr::reduce(cellcounts_data_list, dplyr::full_join, by = "Species")
# 
# # In worth_dataframe, create a variable that gives database rank based on row number
# worth_dataframe <- worth_dataframe %>% mutate(Dataframe_Rank = row_number())
# 
# # Modify column names in merged_dataframe to include source information as suffix
# colnames(merged_dataframe) <- paste0(colnames(merged_dataframe), "_", names(cellcounts_data_list))
# 
# # Arrange the merged_dataframe based on the ranking in worth_dataframe
# merged_dataframe <- dplyr::arrange(merged_dataframe, match(names(merged_dataframe), worth_dataframe$Dataframe_Rank))
# 
# # Extract the dataframe names from the column names
# dataframe_names <- str_extract(names(merged_dataframe), "_(.*)$")
# 
# # Remove the source information from column names
# colnames(merged_dataframe) <- sub("_(.*)$", "", names(merged_dataframe))
# 
# # Print the ordered dataframe_names to verify
# print(dataframe_names)

## 1.7.2 Merge all the dataframes
# Define a function to merge dataframes in a list with a suffix
merge_dataframes_with_suffix <- function(dataframes_list) {
  # Use Reduce to apply the merge function iteratively to all dataframes in the list
  merged_df <- Reduce(function(df1, df2) {
    suffix_df1 <- names(df1)
    suffix_df2 <- names(df2)
    print(paste("Merging:", suffix_df1, "and", suffix_df2))
    
    merge(df1, df2, by = 'Species', all = TRUE,
          suffixes = c(suffix_df1, suffix_df2))
  }, dataframes_list)
  
  return(merged_df)
}

# Call the function with the list of dataframes
merged_result <- merge_dataframes_with_suffix(cellcounts_data_list)

# Display the merged dataframe
print(merged_result)


# ## 1.5 Combine all data in all dataframes in cellcounts_data_list, "Species" is the common identifier, dataframe name is suffix
# suffix <- names(cellcounts_data_list)[i]
# 
# combined_data <- cellcounts_data_list[[1]]
# 
# for (i in 2:length(cellcounts_data_list)) {
#   # Merge based on the "Species" column
#   combined_data <- merge(combined_data, cellcounts_data_list[[i]], by = "Species", all = TRUE, suffixes = c("", paste("_", names(cellcounts_data_list)[i], sep = "")))
# }
# 
# # Sort columns alphabetically
# combined_data <- combined_data[, order(names(combined_data))]
# 
# # Sort rows by the "Species" column
# combined_data <- combined_data[order(combined_data$Species), ]
# 
# # View
# combined_data

# ## 1.5 Combine all data in all dataframes in cellcounts_data_list, "Species" is the common identifier
# combined_data <- NULL
# 
# # Add suffix to variables in all dataframes
# for (i in 1:length(cellcounts_data_list)) {
#   current_df <- cellcounts_data_list[[i]]
#   suffix <- names(current_df)[i]
#   current_df <- setNames(current_df, c("Species", paste(names(current_df)[-1], paste("_", suffix, sep = ""), sep = "")))
#   
#   # If it's the first dataframe, initialize combined_data
#   if (is.null(combined_data)) {
#     combined_data <- current_df
#   } else {
#     # Merge with combined_data based on the "Species" column
#     combined_data <- merge(combined_data, current_df, by = "Species", all = TRUE)
#   }
# }
# 
# # Ensure "Species" is the first column
# combined_data <- combined_data[, c("Species", setdiff(names(combined_data), "Species"))]
# 
# # Sort rows by the "Species" column
# combined_data <- combined_data[order(combined_data$Species), ]
# 
# # View
# print(combined_data)
# colnames(combined_data)
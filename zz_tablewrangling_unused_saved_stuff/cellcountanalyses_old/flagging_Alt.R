# Creating the first dataframe (5x2)
HerculanoHouzel_etal_2015_Table1 <- data.frame(
  SPECIES = c("a", "b", "c","d", "e"),
  B = c(12, 12, 11, 10, 10)
)
# Creating the second dataframe (3x3)
HerculanoHouzel_etal_2015_Table2 <- data.frame(
  SPECIES = c("a", "b", "c"),
  B = c(10, 20, 30),
  D = c(12, 12, 11)
)
# Creating the third dataframe (4x4)
DosSantos_etal_2020_Table1 <- data.frame(
  SPECIES = c("a", "b", "d"),
  WholeBrain_I.n = c(0.1, 0.2, 0.3),
  WholeBrain_C.n = c(100, 200, 300),
  D = c(14, 1, 12),
  CerebralCortex_I.n = c(14, 1, 12)
)

# Joining the dataframes into a list
cellcounts_data_list <- mget(c("HerculanoHouzel_etal_2015_Table1", "HerculanoHouzel_etal_2015_Table2", "DosSantos_etal_2020_Table1"))

# Create a copy of cellcounts_data_list to filter
filtered_cellcounts_data_list <- lapply(cellcounts_data_list, data.frame)

# Initialize metadata_flags for each dataframe with names from filtered_cellcounts_data_list
metadata_flags <- list()
for (df_name in names(filtered_cellcounts_data_list)) {
  metadata_flags[[df_name]] <- data.frame(
    Flag_Description = c(NA),
    Flag_Condition = c(NA),
    Condition_Type = c(NA)
  )
}

# Modify metadata_flags DosSantos_etal_2020_Table1 to include multiple rows for flag conditions and descriptions
metadata_flags$DosSantos_etal_2020_Table1 <- list(
  Flag_Condition = c(
    "filtered_cellcounts_data_list[[df_name]]$SPECIES == 'Tragelaphus strepsiceros'",
    "grepl('_C.n|_I.n|_I.p.mg|_I.p.N|_N.n|_N.p.mg|_n.S|_Mass.g', colnames(filtered_cellcounts_data_list[[df_name]]))"
  ),
  Flag_Description = c(
    "Omit Row SPECIES == Tragelaphus strepsiceros due to impossible numbers",
    "Omit secondary data columns due to some typos/conflicts with primary sources, and illogical values."
  ),
  Condition_Type = c(
    "row",
    "column"
  )
)

# Loop through every dataframe in filtered_cellcounts_data_list
for (df_name in names(filtered_cellcounts_data_list)) {
  # Find the corresponding metadata_flags dataframe
  flag_df <- metadata_flags[[df_name]]
  # Loop through each Flag_Condition in the flag_df
  for (i in seq_along(flag_df$Flag_Condition)) {  
    # Extract Flag_Condition, Flag_Description, and Condition_Type
    condition <- flag_df$Flag_Condition[i]
    description <- flag_df$Flag_Description[i]
    condition_type <- flag_df$Condition_Type[i]
    # If Flag_Condition is a string, use it as an R script
    if (is.character(condition)) {
      # Assuming your R script is a valid condition
      subset_condition <- eval(parse(text = condition), envir = filtered_cellcounts_data_list[[df_name]])
      # Determine if columns, rows or values should be excluded based on Condition_Type
      if (length(subset_condition) > 0) {
        if (condition_type == "column") {
          if (is.logical(subset_condition)) {
            if (any(subset_condition)) {
              # Exclude matching columns
              filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][, !subset_condition]
            } else {}
          } else {}
        } else if (condition_type == "row") {
          if (is.logical(subset_condition)) {
            if (any(subset_condition)) {
              # Exclude matching rows
              filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][!subset_condition, ]
            } else {}
          } else {}
        } else if (condition_type == "value") {
            if (any(subset_condition)) {
              # Make matching values NA to exclude them
              indices <- filtered_cellcounts_data_list[[df_name]] == subset_condition
              filtered_cellcounts_data_list[[df_name]][indices] <- NA
            } else {}
          } else {}
        } else {}
     }
  }
}


# Create a copy of cellcounts_data_list
filtered_cellcounts_data_list <- lapply(cellcounts_data_list, data.frame)

# Loop through every dataframe in filtered_cellcounts_data_list
for (df_name in names(filtered_cellcounts_data_list)) {
  
  # Find the corresponding metadata_flags dataframe
  flag_df <- metadata_flags[[df_name]]
  
  # If Flag_Condition is a string, use it as an R script
  if (is.character(flag_df$Flag_Condition)) {
    
    # Assuming your R script is a valid condition
    condition_script <- flag_df$Flag_Condition
    
    # Designate a set of datapoints in the dataframe and delete them
    subset_condition <- eval(parse(text = condition_script))
    
    # Filter the dataframe using subset on the copy
    filtered_cellcounts_data_list[[df_name]] <- subset(filtered_cellcounts_data_list[[df_name]], !subset_condition)
  }
}

# View the modified list of dataframes outside the loop
View(filtered_cellcounts_data_list)







# # Create an independent copy using data.frame of DosSantos_etal_2020_Table1  data frame in filtered_cellcounts_data_list
# DosSantos_etal_2020_Table1 <- data.frame(filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]])
# 
# # Delete the identified columns in the independent dataframe DosSantos_etal_2020_Table1
# DosSantos_etal_2020_Table1 <- DosSantos_etal_2020_Table1[, !(colnames(DosSantos_etal_2020_Table1) %in% colnames(DosSantos_etal_2020_Table1)[grepl('_C.n|_I.n|_I.p.N|_N.n|_N.p.mg|_n|_Mass.g', colnames(DosSantos_etal_2020_Table1))])]
# 
# # Delete the identified columns directly in filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]]
# filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]] <-
#   filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]][,!(
#     colnames(filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]]) %in%
#       colnames(filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]])[grepl(
#         '_C.n|_I.n|_I.p.N|_N.n|_N.p.mg|_n|_Mass.g',
#         colnames(filtered_cellcounts_data_list[["DosSantos_etal_2020_Table1"]])
#       )]
#   )]


# Load necessary libraries
library(dplyr)

# List of dataframes
dataframes <- c(
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

# Initialize metadata_flags for each dataframe with a common suffix
suffix <- "_metadata_flags"
metadata_flags <- list()

for (df in dataframes) {
  metadata_flags[[paste0(df, suffix)]] <- data.frame(
    Flag_Description = c(""),
    Flag_Condition = c("")
  )
}

# Define the changes for metadata_flags$DosSantos_etal_2020_Table1_metadata_flags
metadata_flags$DosSantos_etal_2020_Table1_metadata_flags$Flag_Condition <- c("!grepl('_I.p.mg', colnames(variable))")
metadata_flags$DosSantos_etal_2020_Table1_metadata_flags$Flag_Description <- c("Secondary data variables omitted as some data found to be typos inconsistent with primary sources. Only keep I.mg")

# There are two lists cellcounts_data_list and metadata_flags
# Look into list cellcounts_data_list and loop through every dataframe. If the cellcounts_data_list[[i]] dataframe name matches any metadata_flags[i]$Flag_Condition = !na, 
# delete all values in the dataframe that match Flag_Condition 

# for (variable in dataframes) {
#   for (condition in paste0("metadata_flags[",dataframes,"]_metadata_flags$Flag_Condition") {
#     for (column in cellcounts_data_list[[variable]]) {
# if condition = TRUE{column=NULL}
#     }
#   }
# }
#   # !grepl('_I.p.mg', colnames(cellcounts_data_list$DosSantos_etal_2020_Table1))

# Assuming cellcounts_data_list is a list of dataframes
for (variable in dataframes) {
  condition <- eval(parse(text = metadata_flags[[paste0(variable, suffix)]]$Flag_Condition))
  if (!is.na(condition) && condition) {
    cellcounts_data_list[[variable]] <- lapply(cellcounts_data_list[[variable]], function(column) {
      if (condition) {
        column <- NULL
      }
      return(column)
    })
  }
}
# Set Working Directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging")

## 1 Get data for cell count analyses
## 2 Change to standardized terminology for all variables in those dataframes
## 3 Calculate variables to match them across datasets before filtering
## 4 Rename Species using NCBI Taxonomy as the standard
## 5 Filter: Remove flagged data in cellcounts_data_list
## 6 Filter: Annex to Metadata any contingent variables
## 7 Filter: Consider averaging variables if samples differ between teams  ## Check for variables measured by more than one team
## 8 Filter: Melt dataframe and address conflicting datapoints across datasets using priority  ## Within each team ## And across team averaging
## 9.1 Calculate: within-team between-tables values using filtered dataset
## 9.2 Calculate: between-team averages using filtered dataset

## 1 Get data for cell count analyses
library(tidyverse)
library(readxl)

## Create a list with all the dataframes for cell count analyses
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

## 2 Change to standardized terminology for all variables in those dataframes

# Read standardized terms
standardized_term_cellcounts <- read.csv("standardized_term_cellcounts.csv", check.names=FALSE)

# Loop through each data frame to apply standardized terms
for (i in seq_along(item_name)) {
  df <- cellcounts_data_list[[item_name[i]]]
  indices <- match(colnames(df), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == item_name[i]])
  colnames(df) <- (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == item_name[i]])[indices]
  cellcounts_data_list[[item_name[i]]] <- df
}

## 3 Calculate variables to match them across datasets before filtering

# 3.1 Inspect data: Get an alphabetized list of variables from all datasets in alphabetical order to examine. Q. Can any variables be converted?
# Initialize an empty vector to store all column names
all_variables <- character(0)
# Loop through each data frame
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- cellcounts_data_list[[item_name[i]]]
  # Extract column names (variables) from the current data frame
  variables_in_df <- colnames(df)
  # Combine unique column names with the existing vector # Sort the column names alphabetically and view
  all_variables <- sort(unique(c(all_variables, variables_in_df)))
}

# 3.2 Different "whole brain" definitions were used by different teams. Kverkova Team included olfactory bulb, whereas Herculano-Houzel Team did not (see definitions).
# "WholeBrainOlfactoryBulb" denotes the whole brain including the olfactory bulb
# Formula: "WholeBrain_" = "WholeBrainOlfactoryBulb_" - "OlfactoryBulb_"

# Loop: Calculate "WholeBrain_" from "WholeBrainOlfactoryBulb_" and "OlfactoryBulb_" columns
for (i in seq_along(item_name)) {
  # Extract the dataframe
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

# 3.3 Add a column converting mass from kg to g
# Formula: "_Mass.g" = "_Mass.kg" x 1000

# Loop: Calculate "_Mass.g" from "_Mass.kg" columns
for (i in seq_along(item_name)) {
  # Extract the dataframe
  df <- cellcounts_data_list[[i]]
  # Check if there are columns ending with "_Mass.kg"
  Mass.kg <- grep("_Mass.kg$", colnames(df), value = TRUE)
  # Loop through matching columns and calculate differences
  for (matching in Mass.kg) {
    # Extract the prefix, the part of the string that appears before "_Mass.kg"
    prefix <- sub("_Mass.kg$", "", matching)
    # Calculate the Mass in g and store in new and corresponding "_Mass.g" columns
    new_col_Mass.g <- paste0(prefix, "_Mass.g")
    df[[new_col_Mass.g]] <- df[[matching]] * 1000
  }
  # Update the data frame in the list
  cellcounts_data_list[[i]] <- df
}

# 3.4 Calculate Mass.g data which was not reported in Herculano-Houzel et al. 2020 TABLE 2 but can be calculated within it: CerebralCortex_Mass.g, Cerebellum_Mass.g, RoB_Mass.g
# Extract unique prefixes from the column names in the dataframe where where the prefix is the portion of the column name before "_".
# For each unique prefix, Check if:
### The corresponding _Mass.g column has NA values,
### The corresponding _N.n column has non-NA values,
### The corresponding _N.p.mg column has non-NA values,
# Formula: _Mass.g = (_N.n /_N.p.mg) * 1000
# Extract the specific dataframe
  df <- cellcounts_data_list$HerculanoHouzel_etal_2020_TABLE2
  # Extract unique prefixes from column names
  prefixes <- unique(sub("_.*", "", colnames(df)))
  # Loop through each unique prefix
  for (prefix in prefixes) {
    # Check if the corresponding "_Mass.g" column exists
    mass_column <- paste0(prefix, "_Mass.g")
    if (!(mass_column %in% colnames(df))) {
      # Check if corresponding "_N.n" and "_N.p.mg" columns are not NA
      nn_column <- paste0(prefix, "_N.n")
      npm_column <- paste0(prefix, "_N.p.mg")
      if (nn_column %in% colnames(df) && npm_column %in% colnames(df) &&
          !any(is.na(df[[nn_column]])) && !any(is.na(df[[npm_column]]))) {
        # Calculate Mass.g based on the given formula
        df[[mass_column]] <- (df[[nn_column]] / df[[npm_column]]) * 1000
      }
    }
  # Update the dataframe in the list
  cellcounts_data_list$HerculanoHouzel_etal_2020_TABLE2 <- df
}

# 3.5 Calculate microglia per cells (I/C) data which was not reported in Dos Santos et al. 2020 Table 1 but must have been their primary data
# Formula: _I.p.C = _I.n/_C.n
  
  # Extract the specific dataframe
  df <- cellcounts_data_list$DosSantos_etal_2020_Table1
  # Extract unique prefixes from column names
  prefixes <- unique(sub("_.*", "", colnames(df)))
  # Add an initial step to create the _I.p.C column if the condition is satisfied
  for (prefix in prefixes) {
    In_column <- paste0(prefix, "_I.n")
    Cn_column <- paste0(prefix, "_C.n")
    IpC_column <- paste0(prefix, "_I.p.C")
    if (In_column %in% colnames(df) && Cn_column %in% colnames(df) && 
        !any(is.na(df[[In_column]])) && !any(is.na(df[[Cn_column]]))) {
      df[[IpC_column]] <- df[[In_column]] / df[[Cn_column]]
    }
  }
  # Loop through each unique prefix to handle remaining rows
  for (prefix in prefixes) {
    # Define column names
    In_column <- paste0(prefix, "_I.n")
    Cn_column <- paste0(prefix, "_C.n")
    IpC_column <- paste0(prefix, "_I.p.C")
    # Check if both In_column and Cn_column exist
    if (In_column %in% colnames(df) && Cn_column %in% colnames(df)) {
      # Check for NA values in both columns
      if (!any(is.na(df[[In_column]])) && !any(is.na(df[[Cn_column]]))) {
        # Skip rows with NA values and already calculated _I.p.C values
        next
      }
      # Calculate _I.p.C based on the given formula
      df[[IpC_column]] <- df[[In_column]] / df[[Cn_column]]
    }
  }
  # Update the dataframe in the list
  cellcounts_data_list$DosSantos_etal_2020_Table1 <- df
  cellcounts_data_list$DosSantos_etal_2020_Table1$WholeBrain_I.p.C

# Note: there is a big problem with Tragelaphus strepsiceros cell counts in Dos Santos et al., 2020. Do not use it.
    
# 3.6 Calculate Cell number where not already available (it was only reported in Dos Santos et al., 2020)
# Formula _C.n = _N.n + _O.n
  
  # Extract unique prefixes from column names
  prefixes <- unique(sub("_.*", "", colnames(df)))
  # Loop through each dataframe in the list
  for (i in seq_along(cellcounts_data_list)) {
    # Extract the dataframe
    df <- cellcounts_data_list[[i]]
    # Loop through each unique prefix
    for (prefix in prefixes) {
      # Define column names
      Nn_column <- paste0(prefix, "_N.n")
      On_column <- paste0(prefix, "_O.n")
      Cn_column <- paste0(prefix, "_C.n")
      # Check if both _N.n and _O.n columns exist and there are no NA values
      if (Nn_column %in% colnames(df) && On_column %in% colnames(df) && 
          !any(is.na(df[[Nn_column]])) && !any(is.na(df[[On_column]]))) {
        # Calculate _C.n based on the given formula
        df[[Cn_column]] <- df[[Nn_column]] + df[[On_column]]
        # Update the dataframe in the list
        cellcounts_data_list[[i]] <- df
      }
    }
  }

# Note: there is a big problem with Tragelaphus strepsiceros cell counts in Dos Santos et al., 2020. Do not use it.
    
## 4 Rename Species using NCBI Taxonomy as the standard

# 4.1 Compare full source_species_list to NCBI Taxonomy ID 
library(taxizedb)
# Get a full list of species in alphabetical order to examine
source_species_list <- character(0)
for (i in seq_along(cellcounts_data_list)) {
  source_species_list <- sort(unique(c(source_species_list, cellcounts_data_list[[i]]$Species)))
}

# Get NCBI Taxonomic IDs for source_species_list
ids <- name2taxid(source_species_list, out_type = "summary")
# Get NCBI Preferred Names for those Taxonomic IDs
preferred_names <- taxid2name(ids$id, out_type = "summary")

# Identify any names not listed
names_not_listed <- setdiff(source_species_list, ids$name)

# Create a data frame with Species Name in Source, Preferred Name and Taxonomic ID
source_species_ids <- data.frame(
  Species_Name_Source = source_species_list,
  Preferred_Name = NA,
  Taxonomic_ID = NA
)

# Update Taxonomic_Name and Taxonomic_ID for listed species
source_species_ids$Taxonomic_ID[source_species_list %in% ids$name] <- ids$id
source_species_ids$Preferred_Name[source_species_list %in% ids$name] <- preferred_names

# Include names_not_listed in the Species_Name_Source column with "NA"
source_species_ids <- rbind(source_species_ids, data.frame(
  Species_Name_Source = names_not_listed,
  Preferred_Name = NA,
  Taxonomic_ID = NA
))

# Sort source_species_ids by the same order as source_species_list
source_species_ids <- source_species_ids[match(source_species_list, source_species_ids$Species_Name_Source), ]

# Add a column to check if Preferred_Name is different from Original_Species_Name or if it's NA and Original_Species_Name is from names_not_listed
source_species_ids$different <- ifelse(source_species_ids$Preferred_Name != source_species_ids$Species_Name_Source | (is.na(source_species_ids$Preferred_Name) & source_species_ids$Species_Name_Source %in% names_not_listed), TRUE, "")

# Add a column called Reference_Note to source_species_ids
source_species_ids$Reference_Note <- ifelse(
  source_species_ids$Preferred_Name == source_species_ids$Species_Name_Source, 
  "NCBI exact",
  ifelse(
    !is.na(source_species_ids$Preferred_Name),
    "NCBI",
    NA
  )
)

# Add a column with the dataframes that are the source of the 
source_species_source <- list()
# Loop through each dataframe in cellcounts_data_list
for (i in seq_along(cellcounts_data_list)) {
  current_species <- sort(unique(cellcounts_data_list[[i]]$Species))
  source_species_list <- sort(unique(c(source_species_list, current_species)))
  # Create a mapping of species to the dataframes that include them
  for (species in current_species) {
    if (!(species %in% names(source_species_source))) {
      source_species_source[[species]] <- character(0)
    }
    source_species_source[[species]] <- sort(unique(c(source_species_source[[species]], names(cellcounts_data_list)[i])))
  }
}
source_species_ids$Source_Species = sapply(source_species_list, function(species) paste(source_species_source[[species]], collapse = ", "))

## 4.2 Create a new column for updated species names if they are not all are the NCBI default Preferred Name for their Taxonomic ID

# Add a column called Species_Name with the Preferred_Name. If NA, leave blank.
source_species_ids$Species_Name <- ifelse(
  !is.na(source_species_ids$Preferred_Name), 
  source_species_ids$Preferred_Name,
  NA
)

# Add information about the remaining species: Species_Name to use and reference note
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Cryptomys pretoriae"] <- "Cryptomys hottentotus pretoriae"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Cryptomys pretoriae"] <- "ITIS invalid synonym"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Cynomys sp."] <- "Cynomys sp."
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Cynomys sp."] <- "Genus, species unknown"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Dasyprocta prymnolopha"] <- "Dasyprocta prymnolopha"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Dasyprocta prymnolopha"] <- "ITIS valid, missing from NCBI"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Homo sapiens sapiens"] <- "Homo sapiens"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Homo sapiens sapiens"] <- "GBIF for subspecies"
source_species_ids$Species_Name[source_species_ids$Species_Name_Source == "Papio anubis cynocephalus"] <- "Papio cynocephalus"
source_species_ids$Reference_Note[source_species_ids$Species_Name_Source == "Papio anubis cynocephalus"] <- "referenced papers call these Papio cynocephalus (Gabi 2010), Papio sp (HH 2008)"

# Automatically add Taxonomic_IDs and Preferred_Name if NA (unless exempt from this step)
# These are exempt, because NCBI Taxon ID doesn't apply at species level: Dasyprocta prymnolopha, Cynomys sp.
# Create species_list with updated names
species_list <- source_species_ids$Species_Name
# Update Taxonomic IDs for species_list
ids <- name2taxid(species_list, out_type = "summary")
# Update Preferred Names for those Taxonomic IDs
preferred_names <- taxid2name(ids$id, out_type = "summary")
# Update Taxonomic_ID for listed species
source_species_ids$Taxonomic_ID <- ifelse(
  is.na(source_species_ids$Taxonomic_ID),
  ids$id[match(source_species_ids$Species_Name, ids$name)],
  source_species_ids$Taxonomic_ID
)
# Update Preferred_Name for listed species
source_species_ids$Preferred_Name <- ifelse(
  is.na(source_species_ids$Preferred_Name),
  ids$name[match(source_species_ids$Taxonomic_ID, ids$id)],
  source_species_ids$Preferred_Name
)

# Save the data frame as a CSV file
write.csv(source_species_ids, "cellcounts_source_species_ids.csv", row.names = FALSE)

# 4.3 If there are species without NCBI ID, duplicate "Species" in all dataframes in cellcounts_data_list and call it "Species_Source", so that "Species" can be edited
# Loop through each data frame in the list. Duplicate the "Species" column and rename it to "Species_Source"
for (i in seq_along(cellcounts_data_list)) {
  cellcounts_data_list[[i]]$Species_Source <- cellcounts_data_list[[i]]$Species
}

# Loop through each data frame in the list and update the "Species" column by matching cellcounts_data_list "Species_Source" to source_species_ids "Species_Name_Source", and then using the value from source_species_ids "Species_Name"
for (i in seq_along(cellcounts_data_list)) {
  cellcounts_data_list[[i]]$Species <- source_species_ids$Species_Name[match(cellcounts_data_list[[i]]$Species_Source, source_species_ids$Species_Name_Source)]
}

# 4.4 Save a long unfiltered list for conflict check
cellcounts_unfiltered <- lapply(names(cellcounts_data_list), function(source) {
  df_uf <- cellcounts_data_list[[source]]
  # Convert all columns to character strings
  df_uf[] <- lapply(df_uf, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df_uf %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
cellcounts_unfiltered <- bind_rows(cellcounts_unfiltered)
write.csv(cellcounts_unfiltered, file = "cellcounts_unfiltered.csv", row.names = FALSE)

## 5 Filter: Remove flagged data in cellcounts_data_list

# Create a copy of cellcounts_data_list to filter
filtered_cellcounts_data_list <- lapply(cellcounts_data_list, data.frame)

# Extract suffixes from DosSantos_etal_2020_Table1 to determine secondary data variables to exclude.
suffixes <- unique(sub(".*_", "", grep(".*_.*", colnames(cellcounts_data_list$DosSantos_etal_2020_Table1), value = TRUE)))
# Ignore '_I.p.C' and '_S.n' which estimates the primary data and Species_Source which is not really a variable.
suffixes <- suffixes[!(suffixes %in% c("I.p.C", "Source", "S.n"))]
paste0("_",suffixes, collapse = "|") # Manually change the double quotes for single in the script

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

# ## 5.1 Flag problematic data for removal
# # Initialize metadata_flags for each dataframe with a common suffix
# metadata_flags <- list()
# 
# for (df in item_name) {
#   metadata_flags[[df]] <- data.frame(
#     Flag_Description = c(NA),
#     Flag_Condition = c(NA)
#   )
# }
# 
# # Flag data in any relevant datasets
# 
#
# # Modify metadata_flags DosSantos_etal_2020_Table1 to include multiple rows for flag conditions and descriptions
# metadata_flags$DosSantos_etal_2020_Table1 <- list(
#   Flag_Condition = c(
#     "grepl('_C.n', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_I.n', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_I.p.mg', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_I.p.N', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_N.n', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_N.p.mg', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_n.S', colnames(filtered_cellcounts_data_list[[df_name]]))",
#     "grepl('_Mass.g', colnames(filtered_cellcounts_data_list[[df_name]]))"
#   ),
#   Flag_Description = c(
#     "Omit secondary data due to _C.n",
#     "Omit secondary data due to _I.n",
#     "Omit secondary data due to _I.p.mg",
#     "Omit secondary data due to _I.p.N",
#     "Omit secondary data due to _N.n",
#     "Omit secondary data due to _N.p.mg",
#     "Omit secondary data due to _n.S",
#     "Omit secondary data due to _Mass.g"
#   )
# )
# 
# # # Define the changes for metadata_flags$DosSantos_etal_2020_Table1_metadata_flags
# # metadata_flags$DosSantos_etal_2020_Table1$Flag_Condition <- c("grepl('_C.n|_I.n|_I.p.mg|_I.p.N|_N.n|_N.p.mg|_n.S|_Mass.g', colnames(filtered_cellcounts_data_list[[df_name]]))")
# # metadata_flags$DosSantos_etal_2020_Table1$Flag_Description <- c("Omit secondary data due to some typos/conflicts with primary sources, and illogical values.")
# 
# # Loop through metadata_flags to save each dataframe as a separate CSV file
# for (df_name in names(metadata_flags)) {
#   # Save the dataframe as a CSV file
#   write.csv(metadata_flags[[df_name]], file = paste0(df_name, "_metadata_flags.csv"), row.names = FALSE)
# }
# 
# # Loop through every dataframe in filtered_cellcounts_data_list
# for (df_name in names(filtered_cellcounts_data_list)) {
#   # Find the corresponding metadata_flags dataframe
#   flag_df <- metadata_flags[[df_name]]
#   
#   # Check if flag_df is not empty
#   if (!is.null(flag_df) && nrow(flag_df) > 0) {
#     # Loop through each row in flag_df
#     for (row_index in 1:nrow(flag_df)) {
#       # Extract Flag_Condition and Flag_Description for this row
#       delete_datapoints <- flag_df$Flag_Condition[row_index]
#       flag_description <- flag_df$Flag_Description[row_index]
#       
#       # If Flag_Condition is a string, use it as an R script
#       if (is.character(delete_datapoints)) {
#         # Evaluate the condition
#         subset_condition <- eval(parse(text = delete_datapoints))
#         
#         # Determine if rows or columns should be excluded
#         if (length(subset_condition) > 0) {
#           if (length(subset_condition) > 1) {
#             # Exclude matching columns from the copy
#             filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][, -subset_condition]
#           } else {
#             # Exclude matching rows from the copy
#             filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][-subset_condition, ]
#           }
#         }
#       }
#     }
#   } else {
#     cat("No flag conditions found for", df_name, "\n")
#   }
# }
#
# # If metadata_flags dataframe Flag_Condition is a string, treat it as R script to identify a set of values in the corresponding dataframe in filtered_cellcounts_data_list, then delete that set
# # Loop through every dataframe in filtered_cellcounts_data_list
# for (df_name in names(filtered_cellcounts_data_list)) {
#   # Find the corresponding metadata_flags dataframe
#   flag_df <- metadata_flags[[df_name]]
# 
#   # If Flag_Condition is a string, use it as an R script
#   if (is.character(flag_df$Flag_Condition)) {
# 
#     # Assuming your R script is a valid condition
#     delete_datapoints <- flag_df$Flag_Condition
# 
#     # Designate a set of datapoints in the dataframe and delete them
#     subset_condition <- eval(parse(text = delete_datapoints))
#     matching_indices <- which(subset_condition)
# 
#     # Determine if rows or columns should be excluded
#     if (length(matching_indices) > 1) {
#       # Exclude matching columns from the copy
#       filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][, -matching_indices]
#     } else if (length(matching_indices) == 1) {
#       # Exclude matching rows from the copy
#       filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][-matching_indices, ]
#     } else {
#       # Handle the case when no indices are found (no exclusions needed)
#       cat("No matching indices found for exclusion in", df_name, "\n")
#     }
#   }
# }

## 6 Filter: Annex to Metadata any contingent variables

# Initialize an empty vector to store all column names, filtered
filtered_all_variables <- character(0)
# Loop through each data frame
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- filtered_cellcounts_data_list[[item_name[i]]]
  # Extract column names (variables) from the current data frame
  variables_in_df <- colnames(df)
  # Combine unique column names with the existing vector
  filtered_all_variables <- unique(c(filtered_all_variables, variables_in_df))
}
# Sort the column names alphabetically and view
filtered_all_variables <- sort(filtered_all_variables)
filtered_all_variables

# Move specific variables from the main dataset, filtered_cellcounts_data_list, to the list annexed_metadata.
# Redundant variables created here: "Body_Mass.kg"
# Extra taxonomic variables: "Species_Source", "Family", "Order", "Clade", "CommonName", "Micro.or.mega"    
# Data Sources variables: variables ending in "_Source"
# Sample information: "SampleInfo"
# Derived variables created from datasets: variables ending in "_p.C.N", "_p.C.Brain", "_N.p.mg", "_O.p.mg", "_O.p.N"   
# Statistics around means: "_SD", _n", "_S.n"

# Initialize annexed_metadata as a named list
annexed_metadata <- setNames(vector("list", length(filtered_cellcounts_data_list)), names(filtered_cellcounts_data_list))
# Initialize variables_to_move as an empty vector
variables_to_move <- character(0)
# Iterate through the dataframes
for (i in seq_along(filtered_cellcounts_data_list)) {
  # Update variables_to_move including variables ending in "_Source" for each dataframe
  variables_to_move <- c("Body_Mass.kg", "Family", "Order", "Clade", "CommonName", "Micro.or.mega", "SampleInfo",
                         grep("_Source$", names(filtered_cellcounts_data_list[[i]]), value = TRUE), 
                         grep("_S.n$", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         grep("_SD$", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         grep("_n$", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         # grep("_N.p.mg", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         # grep("_O.p.mg", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         # grep("_O.p.N", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         grep("_p.C.N", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         grep("_p.C.Brain", names(filtered_cellcounts_data_list[[i]]), value = TRUE))

  # Check if any of the variables to move are present in the dataframe
  present_variables <- intersect(variables_to_move, names(filtered_cellcounts_data_list[[i]]))
  if (length(present_variables) > 0) {
    # Create a new dataframe with only the specified variables
    annexed_data <- filtered_cellcounts_data_list[[i]][, present_variables, drop = FALSE]
    # Remove the specified variables from the original dataframe
    filtered_cellcounts_data_list[[i]] <- filtered_cellcounts_data_list[[i]][, !(names(filtered_cellcounts_data_list[[i]]) %in% present_variables), drop = FALSE]
    # Add the new dataframe to annexed_metadata list
    annexed_metadata[[names(filtered_cellcounts_data_list)[i]]] <- annexed_data
  } else {
    # Skip if none of the variables are present in the dataframe
  }
}

## 7 Filter: Consider averaging variables if samples differ between teams ## Check for variables measured by more than one team

## Check for variables found in dataframes both from Kverkova team and Herculano-Houzel team, which are different teams

# Create a full dataframe to inspect Kverkova Team variables
Kverkova_etal_2018_variables <- data.frame(Dataframe_Name = character(), Variable_Name = character(), stringsAsFactors = FALSE)
# Loop through each dataframe in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  df_name <- names(filtered_cellcounts_data_list)[i]  # Get the name of the dataframe
  df <- filtered_cellcounts_data_list[[i]]  # Get the dataframe itself
  # Check if the dataframe name starts with "Kverkova_etal_2018"
  if (startsWith(df_name, "Kverkova_etal_2018")) {
    # Extract variables in "Kverkova_etal_2018", which are all the column names except the first one
    selected_vars <- colnames(df)[-1]
    # Create a data frame with the results for the current dataframe
    df_result <- data.frame(Dataframe_Name = rep(df_name, length(selected_vars)),
                            Team_Name = rep("Kverkova_etal_2018", length(selected_vars)),
                            Variable_Name = selected_vars,
                            stringsAsFactors = FALSE)
    # Append the results to the overall Kverkova_etal_2018_variables
    Kverkova_etal_2018_variables <- rbind(Kverkova_etal_2018_variables, df_result)
  }
}
Kverkova_etal_2018_variables
# Create a list of Kverkova Team dataframes 
Kverkova_Team_dataframes <- unique(Kverkova_etal_2018_variables$Dataframe_Name)
# Create a reduced Kverkova Team variables list for comparison
Kverkova_Team_variables <- unique(Kverkova_etal_2018_variables[, !names(Kverkova_etal_2018_variables) %in% "Dataframe_Name"])
Kverkova_Team_variables

# Create a full dataframe to inspect the other team's variables
Other_Team_variables <- data.frame(Dataframe_Name = character(), Team_Name = character(), Variable_Name = character(), stringsAsFactors = FALSE)
# Loop through each dataframe in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  df_name <- names(filtered_cellcounts_data_list)[i]  # Get the name of the dataframe
  df <- filtered_cellcounts_data_list[[i]]  # Get the dataframe itself
  # Check if the dataframe name does not start with "Kverkova_etal_2018"
  if (!startsWith(df_name, "Kverkova_etal_2018")) {
    # Extract variables, excluding the first column
    selected_vars <- colnames(df)[-1]
    # Create a data frame with the results for the current dataframe
    df_result <- data.frame(Dataframe_Name = rep(df_name, length(selected_vars)),
                            Team_Name = rep("NOT_Kverkova_etal_2018", length(selected_vars)),
                            Variable_Name = selected_vars,
                            stringsAsFactors = FALSE)
    # Append the results to the overall Other_Team_variables
    Other_Team_variables <- rbind(Other_Team_variables, df_result)
  }
}
Other_Team_variables
# Create a list of HerculanoHouzel Team dataframes 
HerculanoHouzel_Team_dataframes <- unique(Other_Team_variables$Dataframe_Name)
# Create a reduced HerculanoHouzel Team variables list for comparison
HerculanoHouzel_Team_variables <- unique(Other_Team_variables[, !names(Other_Team_variables) %in% "Dataframe_Name"])
HerculanoHouzel_Team_variables

# Merge and compare
Variables_shared_across_teams <- merge(Kverkova_Team_variables, HerculanoHouzel_Team_variables, "Variable_Name")
Variables_in_both_teams <- Variables_shared_across_teams$Variable_Name

## 8 Filter: Melt dataframe and address conflicting datapoints across datasets using priority ## Within each team ## And across team averaging

# Create a new list of dataframes from the list of dataframes filtered_cellcounts_data_list with only Kverkova_Team dataframes
# Initialize an empty list to store matching dataframes
Kverkova_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(Kverkova_Team_dataframes)) {
  # Use match to find the dataframe in filtered_cellcounts_data_list with the same name as  i in seq_along(Kverkova_Team_dataframes
  Kverkova_Team_dfmatch <- filtered_cellcounts_data_list[[i]][, names(filtered_cellcounts_data_list[[i]]) %in% Kverkova_Team_dataframes]
  # Store the data frame in the list with the corresponding name
  Kverkova_Team_df_list[[Kverkova_Team_dataframes[i]]] <- Kverkova_Team_dfmatch
}

# Create a new list of dataframes from the list of dataframes filtered_cellcounts_data_list with only Kverkova_Team dataframes
# Initialize an empty list to store matching dataframes
Kverkova_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  # Check if the name of the dataframe is in Kverkova_Team_dataframes
  if (names(filtered_cellcounts_data_list)[i] %in% Kverkova_Team_dataframes) {
    # Assign the entire dataframe to Kverkova_Team_dfmatch
    Kverkova_Team_dfmatch <- filtered_cellcounts_data_list[[i]]
    # Store the data frame in the list with the corresponding name
    Kverkova_Team_df_list[[names(filtered_cellcounts_data_list)[i]]] <- Kverkova_Team_dfmatch
  }
}

# Create a new list of dataframes from the list of dataframes filtered_cellcounts_data_list with only HerculanoHouzel_Team dataframes
# Initialize an empty list to store matching dataframes
HerculanoHouzel_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  # Check if the name of the dataframe is in HerculanoHouzel_Team_dataframes
  if (names(filtered_cellcounts_data_list)[i] %in% HerculanoHouzel_Team_dataframes) {
    # Assign the entire dataframe to HerculanoHouzel_Team_dfmatch
    HerculanoHouzel_Team_dfmatch <- filtered_cellcounts_data_list[[i]]
    # Store the data frame in the list with the corresponding name
    HerculanoHouzel_Team_df_list[[names(filtered_cellcounts_data_list)[i]]] <- HerculanoHouzel_Team_dfmatch
  }
}

###### 8.1 - 8.3 KVERKOVA TEAM
## 8.1.K Combine all data in all dataframes in Kverkova_Team_df_list as a long dataframe
combined_data <- lapply(names(Kverkova_Team_df_list), function(source) {
  df <- Kverkova_Team_df_list[[source]]
  # Convert all columns to character strings
  df[] <- lapply(df, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
# Combine all dataframes in the list into a single dataframe
combined_data <- bind_rows(combined_data)

## 8.2.K Address conflicting datapoints across datasets using priority
# Determine worth order for dataframes to give priority
worth_dataframe <- data.frame(source = character(),
                              date = numeric(),
                              number_species = numeric(),
                              stringsAsFactors = FALSE)
# Iterate over the dataframes in Kverkova_Team_df_list
for (df_name in names(Kverkova_Team_df_list)) {
  # Extract date from the dataframe name
  date <- as.numeric(str_extract(df_name, "[0-9]+"))
  # Extract number of species from the dataframe
  number_species <- nrow(Kverkova_Team_df_list[[df_name]]) - 1  # Subtract 1 for the header
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
# Append a "priority" column to the "combined_data" dataframe by matching "Source" values with "source" in "worth_dataframe"
combined_data$priority <- match(combined_data$Source,  worth_dataframe$source, worth_dataframe$priority)

## 8.3.K Limit dataset to best available data
# remove any NA values in combined_data
intermediate_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
# Add a blank column "DECISION"
intermediate_data$DECISION <- ""
# Convert dataframe to a list of dataframes
df_list <- split(intermediate_data, list(intermediate_data$Species, intermediate_data$Variable))
# Create a loop to update "DECISION" based on the priority condition
for (i in seq_along(df_list)) {
  priority_values <- df_list[[i]]$priority
  # Check if there are non-missing values in priority_values
  if (any(!is.na(priority_values))) {
    # Update "DECISION" based on the specified condition
    df_list[[i]]$DECISION[df_list[[i]]$priority > min(priority_values, na.rm = TRUE)] <- "WORSE"
  } else {
    # Handle the case where all values are missing
    df_list[[i]]$DECISION <- NA
  }
}

# Combine all rows from df_list into one dataframe excluding rows with DECISION:WORSE
Kverkova_Team_data_long <- do.call(rbind, df_list)
Kverkova_Team_data_long <- Kverkova_Team_data_long[Kverkova_Team_data_long$DECISION != "WORSE", ]
# Delete the 'priority' and 'DECISION' columns if they will not be used again # These are not available for mixed sources 
Kverkova_Team_data_long <- Kverkova_Team_data_long[, !(names(Kverkova_Team_data_long) %in% c("priority", "DECISION"))]

###### 8.1 - 8.3 HH TEAM  
# 8.1.H Combine all data in all dataframes in HerculanoHouzel_Team_df_list as a long dataframe
combined_data <- lapply(names(HerculanoHouzel_Team_df_list), function(source) {
  df <- HerculanoHouzel_Team_df_list[[source]]
  # Convert all columns to character strings
  df[] <- lapply(df, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
# Combine all dataframes in the list into a single dataframe
combined_data <- bind_rows(combined_data)

## 8.2.H Address conflicting datapoints across datasets using priority
# Determine worth order for dataframes to give priority
# Initialize an empty dataframe to store the summary
worth_dataframe <- data.frame(source = character(),
                              date = numeric(),
                              number_species = numeric(),
                              stringsAsFactors = FALSE)

# Iterate over the dataframes in HerculanoHouzel_Team_df_list
for (df_name in names(HerculanoHouzel_Team_df_list)) {
  # Extract date from the dataframe name
  date <- as.numeric(str_extract(df_name, "[0-9]+"))
  # Extract number of species from the dataframe
  number_species <- nrow(HerculanoHouzel_Team_df_list[[df_name]]) - 1  # Subtract 1 for the header
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
# Append a "priority" column to the "combined_data" dataframe by matching "Source" values with "source" in "worth_dataframe"
combined_data$priority <- match(combined_data$Source,  worth_dataframe$source, worth_dataframe$priority)

## 8.3.H Limit dataset to best available data
# remove any NA values in combined_data
intermediate_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
# Add a blank column "DECISION"
intermediate_data$DECISION <- ""
# Convert dataframe to a list of dataframes
df_list <- split(intermediate_data, list(intermediate_data$Species, intermediate_data$Variable))
# Create a loop to update "DECISION" based on the priority condition
for (i in seq_along(df_list)) {
  priority_values <- df_list[[i]]$priority
  # Check if there are non-missing values in priority_values
  if (any(!is.na(priority_values))) {
    # Update "DECISION" based on the specified condition
    df_list[[i]]$DECISION[df_list[[i]]$priority > min(priority_values, na.rm = TRUE)] <- "WORSE"
  } else {
    # Handle the case where all values are missing
    df_list[[i]]$DECISION <- NA
  }
}

# Combine all rows from df_list into one dataframe excluding rows with DECISION:WORSE
HerculanoHouzel_Team_data_long <- do.call(rbind, df_list)
HerculanoHouzel_Team_data_long <- HerculanoHouzel_Team_data_long[HerculanoHouzel_Team_data_long$DECISION != "WORSE", ]
# Delete the 'priority' and 'DECISION' columns if they will not be used again # These are not available for mixed sources 
HerculanoHouzel_Team_data_long <- HerculanoHouzel_Team_data_long[, !(names(HerculanoHouzel_Team_data_long) %in% c("priority", "DECISION"))]

#### 9.1 Calculate: within-team between-tables values using filtered dataset
# For each species with available data on microglia density ("_I.p.mg"), calculate the number of microglia ("_I.n") for each brain structure. 
# For a given species (identified by the column "Species") and a particular brain structure (identified by the prefix in the "Variable" column), the corresponding "_I.n" is computed by multiplying the microglia density ("_I.p.mg") by the mass ("_Mass.g") .
# Note the Source for "_I.p.mg" and "_Mass.g". The new value should combine BOTH Sources
# The result is then scaled by a factor of 1000 to convert from g to mg.
# Formula: "_I.n" = "_I.p.mg" "_Mass.g" x 1000

# Make Values numeric
HerculanoHouzel_Team_data_long$Value <- as.numeric(HerculanoHouzel_Team_data_long$Value)

# Shorthand for the dataframe name
df_long <- HerculanoHouzel_Team_data_long

# Split the Variable column into Type and Measure
df_widen <- df_long %>%
  separate(Variable, into = c("Type", "Measure"), sep = "_", remove = TRUE)

# Filter groups
filtered_groups <- df_widen %>%
  group_by(Species, Type) %>%
  filter(any(Measure == "I.p.mg") & any(Measure == "Mass.g"))

# Add new rows to the filtered groups
new_rows <- filtered_groups %>%
  group_by(Species, Type) %>%
  do(add_row(., 
             Species = unique(.$Species), 
             # Variable = paste0(unique(.$Type[.$Measure == "I.n"]), "_I.n"), 
             Type = unique(.$Type), 
             Measure = "I.n", 
             Source = paste0(unique(.$Source[.$Measure == "I.p.mg"]), "_", unique(.$Source[.$Measure == "Mass.g"])), 
             Value = sum(.$Value[.$Measure == "I.p.mg"]) * sum(.$Value[.$Measure == "Mass.g"]) * 1000))

# Remove rows with Measure "I.p.mg" or "Mass.g"
new_rows <- new_rows %>%
  filter(Measure != "I.p.mg" & Measure != "Mass.g")

# Re-unite Variable column
new_rows <- new_rows %>%
  unite(Variable, Type, Measure, sep = "_", remove = TRUE)

# Combine the original dataframe with the new rows
final_df <- bind_rows(df_long, new_rows)

# Return to previous name
HerculanoHouzel_Team_data_long <- final_df

#### 9.2 Calculate: between-team averages using filtered dataset
## Finalize dataset
# Stack the dataframes lengthwise
stacked_long_dataframe <- rbind(HerculanoHouzel_Team_data_long, Kverkova_Team_data_long)
# remove any NA values in stacked_long_dataframe
stacked_long_dataframe <- stacked_long_dataframe[!is.na(stacked_long_dataframe$Value), , drop = FALSE]
# make Values numeric in stacked_long_dataframe
stacked_long_dataframe$Value <- as.numeric(stacked_long_dataframe$Value)

# Calculate averages and create the new long dataframe
cellcounts_long <- stacked_long_dataframe %>%
  group_by(Species, Variable) %>%
  summarize(Value = mean(Value),
            Source = paste0(unique(Source), collapse = "_"))
write_csv(cellcounts_long, "cellcounts_long.csv")

# Convert to wide dataframe
cellcounts_wide <- arrange(pivot_wider(cellcounts_long, id_cols = Species, names_from = Variable, values_from = Value), Species)
# # keep a record of sources for the datapoints
# cellcounts_sources_wide <- arrange(pivot_wider(cellcounts_long, id_cols = Species, names_from = Variable, values_from = Source), Species)
write_csv(cellcounts_wide, "cellcounts_wide.csv")


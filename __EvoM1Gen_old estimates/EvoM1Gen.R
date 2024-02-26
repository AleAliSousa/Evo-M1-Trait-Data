setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data")

# Get data
library(tidyverse)
library(readxl)

# Get all filenames from directory 
tsv_directory_list <- list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data")

# Filter files to include only those that end with ".tsv" 
tsv_names <- tsv_directory_list[grep("\\.tsv$", tsv_directory_list)]

# Maybe - Eliminate problematic ones
# tsv_names <- tsv_names[tsv_names != "10.1016%2Fj.jhevol.2008.08.004_Table2.tsv"]

# Get Item Code by removing end with ".tsv"
item_encoded_names <-  sub("\\.tsv$", "", tsv_names)

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")

# List of item names
item_name <- filecodes$"Item name"[match(item_encoded_names,filecodes$"Item encoded")]

# Initialize an empty list to store tsvs as data frames
tsv_data_list <- list()

# Loop through item names, read tables from TSVs, and store as data frames in the list, row.names = NULL
for (i in seq_along(item_name)) {
  cat("Processing item:", item_name[i], "\n")  # Print item name
  
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  
  # Construct the file path
  file_path <- paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/", item_encoded, ".tsv")
  
  # Read the first few lines to check if it starts with "table"
  first_lines <- readLines(file_path, n = 5)
  starts_with_table <- any(startsWith(tolower(first_lines), "table"))
  
  # Apply different rules based on whether the file starts with "table"
  if (starts_with_table) {
    item_data <- read.delim(file = file_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, row.names = NULL, skip = 1)
  } else {
    item_data <- read.delim(file = file_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, row.names = NULL)
  }
  
  # Store the data frame in the list with the corresponding item name
  tsv_data_list[[item_name[i]]] <- item_data
}

list2env(tsv_data_list, envir = environment()) # Make the dataframes available in the environment


# ######OLDVERSIONHIDE
# # Loop through item names, read tables from TSVs, and store as dataframes in the list, row.names = NULL
# for (i in seq_along(item_name)) {
#   cat("Processing item:", item_name[i], "\n")  # Print item name
# 
#   
#   item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
#   item_data <- read.table(file = paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/", item_encoded, ".tsv"), sep = "\t", 
#                           header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, row.names = NULL)
#   
#   # Store the data frame in the list with the corresponding item name
#   tsv_data_list[[item_name[i]]] <- item_data
# }
######OLDVERSIONHIDE
# ## TROUBLESHOOTING TESTS
# # List all files in the directory ending with .tsv
# tsv_directory_list <- list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data", pattern = "\\.tsv$", full.names = FALSE)
# # Remove the .tsv extension
# tsv_directory_list <- tools::file_path_sans_ext(tsv_directory_list)
# tsv_directory_list
# 
# # Read tsv files using read.delim() method
# tsvtesting<-read.delim("10.1126%2Fscience.aaa9101_TableS1.tsv", sep = "\t", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
# ## TROUBLESHOOTINGTESTSEND


# # Initialize a list to store counts for each species list
# species_counts <- list()
# 
# # Iterate through the data frames in tsv_data_list
# for (i in seq_along(tsv_data_list)) {
#   tsv_data <- tsv_data_list[[i]]
#   
#   # Print the column names for debugging
#   cat("Column names in Data:", i, ":", colnames(tsv_data), "\n")
#   
#   # Identify relevant columns in the current data frame
#   relevant_columns <- colnames(tsv_data) %>%
#     tolower() %>%
#     grep("species|genus species|binomial", ignore.case = TRUE, value = TRUE)
#   
#   # Print relevant columns for debugging
#   cat("Relevant columns in Data:", i, ":", relevant_columns, "\n")
#   
#   # Iterate through the relevant columns
#   for (col in relevant_columns) {
#     # Extract species names, treating "_" as " "
#     species_names <- gsub("_", " ", tolower(tsv_data[[col]]))
#     
#     # Match with "species_sci" column in the "Traits" data
#     match_counts <- stringdist::stringdistmatrix(species_names, traits_data$species_sci, method = "jaccard") %>%
#       apply(2, function(x) sum(x == 0))
#     
#     # Store the count for the current data frame and column
#     species_counts[[paste("Data:", i, "Column:", col)]] <- match_counts
#   }
# }
# 
# # View the results
# print(species_counts)

# One by one version
# Read the "Traits" sheet from the Excel file
traits_data <- read_excel("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Mammalian M1 Evo - Species metadata.xlsx", sheet = "Traits")
# Read the
traits_data$species_sci

# # One by one - replace number
# tsv_data_list[[4]]
# # What is the name of the dataframe that corresponds to tsv_data_list[[i]]?
# names(tsv_data_list)[4]
# # Is there a column "Species" in colnames(tsv_data_list[[i]])? 
# "Species" %in% colnames(tsv_data_list[[4]])
# # Match (tsv_data_list[[i]]$Species) to traits_data$species_sci
# match(tsv_data_list[[4]]$Species, traits_data$species_sci)
# # See the matched values in tsv_data_list[[i]]$Species
# na.omit(traits_data$species_sci[match(tsv_data_list[[4]]$Species, traits_data$species_sci)])
# # Count the number of matched values
# sum(!is.na(traits_data$species_sci[match(tsv_data_list[[4]]$Species, traits_data$species_sci)]))
# # Print a summary stating the dataframe name, whether there is a column "Species", and the number of matched values

# "Species" column exists in i <- 1:5
i <- 5  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Species" column BUT needs to be combined with "Genus" column in i <- 6 (DO LATER)
i <- 6  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Species" column exists in i <- 7 (DUPLICATES -- CANNOT HAVE A BACKWARDS MATCH) 
i <- 7  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Species" column exists in i <- 7 (BACKWARDS MATCH CORRECTED HERE ONLY) 
i <- 7  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(tsv_data_list[[i]]$Species[match(traits_data$species_sci, tsv_data_list[[i]]$Species)])), ". This is the list matched at the level of subspecies:", na.omit(tsv_data_list[[i]]$Species[match(traits_data$species_sci, tsv_data_list[[i]]$Species)]))

# "Genus species" column in i <- 8
i <- 8  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Genus species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Genus species' exists:", "Genus species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$"Genus species", traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$"Genus species", traits_data$species_sci)]))

# "Species" column exists in i <- 9 BUT replace underscores "_" with spaces when performing the match
i <- 9  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species",
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(gsub("_", " ", tsv_data_list[[i]]$Species), traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(gsub("_", " ", tsv_data_list[[i]]$Species), traits_data$species_sci)]))

# "Species" column exists in i <- 10,11 
i <- 11  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Binomial" column exists in i <- 12 AND BUT replace underscores "_" with spaces when performing the match
i <- 12  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Binomial",
cat("For", names(tsv_data_list)[i], ", a column called 'Binomial' exists:", "Binomial" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(gsub("_", " ", tsv_data_list[[i]]$Binomial), traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(gsub("_", " ", tsv_data_list[[i]]$Binomial), traits_data$species_sci)]))

# "Species" column exists in i <- 13:15
i <- 15  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# Individual values in i <- 16:17 (DO LATER)
i <- 17  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Species" column exists in i <- 18:23
i <- 23  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Species" column exists in i <- 24 BUT replace underscores "_" with spaces and replace "*" with "" when performing the match
i <- 24  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species",
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(gsub("*", "", gsub("_", " ", tsv_data_list[[i]]$Species)), traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(gsub("_", " ", tsv_data_list[[i]]$Species), traits_data$species_sci)]))

# "Species name" column exists in i <- 25:26
i <- 26  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species name", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species name' exists:", "Species name" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$"Species name", traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$"Species name", traits_data$species_sci)]))

# "Species" column exists in i <- 27:29 AREA DATA NOT SPECIES
i <- 29  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# "Species" column exists in i <- 31:33
i <- 33  # Change this to the desired index
# Print a summary stating the dataframe name, the existence of a column "Species", and the number of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and the number of matched values at the level of subspecies is:", sum(!is.na(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)])), ". This is the list matched at the level of subspecies:", na.omit(traits_data$species_sci[match(tsv_data_list[[i]]$Species, traits_data$species_sci)]))

# GENUS
# "Species" column exists in i <- 1:5
i <- 4  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 7 (CORRECTED FOR BACKWARDS MATCH FROM HERE ON)
i <- 7  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Genus species" column in i <- 8
i <- 8  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$"Genus species" and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$"Genus species")
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Genus species' exists:", "Genus species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 9 BUT replace underscores "_" with spaces when performing the match
i <- 9  # Change this to the desired index
# Extract the first term before the UNDERSCORE in tsv_data_list[[i]]$"Species" and the first term before the space in traits_data$species_sci
genus_terms_tsv <- gsub("_.*", "", tsv_data_list[[i]]$"Species")
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 10:11 (CORRECTED FOR BACKWARDS MATCH FROM HERE ON)
i <- 11  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Binomial" column exists in i <- 12 AND BUT replace underscores "_" with spaces when performing the match
i <- 12  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$"Binomial" and traits_data$species_sci
genus_terms_tsv <- gsub("_.*", "", tsv_data_list[[i]]$"Binomial")
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Binomial' exists:", "Binomial" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 13 (CORRECTED FOR BACKWARDS MATCH FROM HERE ON)
i <- 15  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# Individual values in i <- 16:17 (DO LATER)

# "Species" column exists in i <- 18:23 (CORRECTED FOR BACKWARDS MATCH FROM HERE ON)
i <- 23  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 24 BUT replace underscores "_" with spaces and replace "*" with "" when performing the match
i <- 24  # Change this to the desired index
# Extract the first term before the UNDERSCORE in tsv_data_list[[i]]$"Species" and the first term before the space in traits_data$species_sci
genus_terms_tsv <- gsub("*", "",gsub("_.*", "", tsv_data_list[[i]]$"Species"))
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 25:26 (CORRECTED FOR BACKWARDS MATCH FROM HERE ON)
i <- 26  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

# "Species" column exists in i <- 27:29 AREA DATA NOT SPECIES

# "Species" column exists in i <- 30:33 (CORRECTED FOR BACKWARDS MATCH FROM HERE ON)
i <- 33  # Change this to the desired index
# Extract the first term before the space in tsv_data_list[[i]]$Species and traits_data$species_sci
genus_terms_tsv <- gsub(" .*", "", tsv_data_list[[i]]$Species)
genus_terms_traits <- gsub(" .*", "", traits_data$species_sci)
# Check if there are any matches at the Genus level
has_genus_matches <- any(genus_terms_traits %in% genus_terms_tsv)
# Get the number of matched values at the Genus level
num_genus_matches <- sum(genus_terms_traits %in% genus_terms_tsv)
# Print the result with the list of matched values
cat("For", names(tsv_data_list)[i], ", a column called 'Species' exists:", "Species" %in% colnames(tsv_data_list[[i]]), "and there are", num_genus_matches, "matches at the Genus level:", has_genus_matches, ". This is the list matched at the level of genus:", toString(genus_terms_traits[genus_terms_traits %in% genus_terms_tsv]), "\n")

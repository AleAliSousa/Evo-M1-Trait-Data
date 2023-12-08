#source
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging")

##MERGE TERM LISTS

# Check the names of all files in the folder
file_names <- list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging")
print(file_names)

# Read all CSVs
DosSantos_etal_2017_TableS1 <- read.csv("DosSantos_etal_2017_TableS1_terms.csv", stringsAsFactors = FALSE)
DosSantos_etal_2020_Table1 <- read.csv("DosSantos_etal_2020_Table1_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2015_Table1 <- read.csv("HerculanoHouzel_etal_2015_Table1_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2015_Table2 <- read.csv("HerculanoHouzel_etal_2015_Table2_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2015_Table3 <- read.csv("HerculanoHouzel_etal_2015_Table3_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2015_Table4 <- read.csv("HerculanoHouzel_etal_2015_Table4_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2015_Table5 <- read.csv("HerculanoHouzel_etal_2015_Table5_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2020_Table1 <- read.csv("HerculanoHouzel_etal_2020_Table1_terms.csv", stringsAsFactors = FALSE)
HerculanoHouzel_etal_2020_Table2 <- read.csv("HerculanoHouzel_etal_2020_Table2_terms.csv", stringsAsFactors = FALSE)
JardimMesseder_etal_2017_Table1 <- read.csv("JardimMesseder_etal_2017_Table1_terms.csv", stringsAsFactors = FALSE)
Kverkova_etal_2018_TableS1 <- read.csv("Kverkova_etal_2018_TableS1_terms.csv", stringsAsFactors = FALSE)
Kverkova_etal_2018_TableS5 <- read.csv("Kverkova_etal_2018_TableS5_terms.csv", stringsAsFactors = FALSE)

# Merge all terms into one dataframe
merged_terms <- rbind(
  DosSantos_etal_2017_TableS1,
  DosSantos_etal_2020_Table1,
  HerculanoHouzel_etal_2015_Table1,
  HerculanoHouzel_etal_2015_Table2,
  HerculanoHouzel_etal_2015_Table3,
  HerculanoHouzel_etal_2015_Table4,
  HerculanoHouzel_etal_2015_Table5,
  HerculanoHouzel_etal_2020_Table1,
  HerculanoHouzel_etal_2020_Table2,
  JardimMesseder_etal_2017_Table1,
  Kverkova_etal_2018_TableS1,
  Kverkova_etal_2018_TableS5
)

##COMPARE MERGED TERMS TO OLD KEY  

# Read old key of terms
old_key <- read.csv("old_key.csv")

# merge pair
merged_terms_combined_key <- merge(merged_terms, old_key, by = "Original_Term", all = TRUE)

# # Improve"Standardized_Term.x" column by moving data from "Standardized_Term.y" and deleting and renaming
# Step 1: Write over "Standardized_Term.y" in place of "Standardized_Term.x"
merged_terms_combined_key$Standardized_Term.x <- merged_terms_combined_key$Standardized_Term.y
# Step 2: Delete old last column
merged_terms_combined_key$Standardized_Term.y <- NULL
# Step 3: Rename "Standardized_Term.x" to "Standardized_Term"
colnames(merged_terms_combined_key)[colnames(merged_terms_combined_key) == "Standardized_Term.x"] <- "Standardized_Term"

## Match JardimMessender2017_old to Original_Term from JardimMesseder_2017_key
# Replace missing values in the Standardized_Term column with values from rows where Original_Term matches the JardimMessender2017_old column.
# Loop through each row in the dataframe. If Standardized_Term is NA or empty, proceed.
# Identify rows where JardimMessender2017_old matches the current row's Original_Term.
# Replace missing Standardized_Term with the matching value from JardimMessender2017_old.
library(dplyr)
for (i in 1:(nrow(merged_terms_combined_key) - 1)) {
  if (is.na(merged_terms_combined_key$Standardized_Term[i])) {
    original_term_value <- merged_terms_combined_key$Original_Term[i]
    matching_row_index <- which(merged_terms_combined_key$JardimMessender2017_old != "" &
                                  !is.na(merged_terms_combined_key$JardimMessender2017_old) &
                                  merged_terms_combined_key$JardimMessender2017_old == original_term_value)
    
    if (length(matching_row_index) > 0) {
      # Replace Standardized_Term with the value from the matching row in JardimMessender2017_old
      merged_terms_combined_key$Standardized_Term[i] <- 
        merged_terms_combined_key$Standardized_Term[matching_row_index[1]]
    }
  }
}

## Match DosSantos2017_old to Original_Term from dossantos_2017_key
# Replace missing values in the Standardized_Term column with values from rows where Original_Term matches the DosSantos2017_old column.
# Loop through each row in the dataframe. If Standardized_Term is NA or empty, proceed.
# Identify rows where DosSantos2017_old matches the current row's Original_Term.
# Replace missing Standardized_Term with the matching value from DosSantos2017_old.
for (i in 1:(nrow(merged_terms_combined_key) - 1)) {
  if (is.na(merged_terms_combined_key$Standardized_Term[i])) {
    original_term_value <- merged_terms_combined_key$Original_Term[i]
    matching_row_index <- which(merged_terms_combined_key$DosSantos2017_old != "" &
                                  !is.na(merged_terms_combined_key$DosSantos2017_old) &
                                  merged_terms_combined_key$DosSantos2017_old == original_term_value)
    
    if (length(matching_row_index) > 0) {
      # Replace Standardized_Term with the value from the matching row in DosSantos2017_old
      merged_terms_combined_key$Standardized_Term[i] <- 
        merged_terms_combined_key$Standardized_Term[matching_row_index[1]]
    }
  }
}

## Match Original_Term from HerculanoHouzel_2020* tables to Standardized_Term, and making list to update
# Define the mapping rules
term_mapping <- c("Clade" = "Clade",
                  "Family" = "Family",
                  "MBODY, g" = "Body_Mass,g",
                  "MBRAIN, g" = "WholeBrain_Mass,g",
                  "Micro/mega" = "Micro/mega",
                  "n" = "WholeBrain_n",
                  "NBRAIN" = "WholeBrain_N,n",
                  "Species" = "Species",
                  "DN,Cb" = "Cerebellum_N/mg",
                  "DN,CX" = "CerebralCortex_N/mg",
                  "DN,RoB" = "RoB_N/mg",
                  "Common Name" = "Common Name")
# Filter rows where Reference starts with "HerculanoHouzel_etal_2020"
filtered_rows <- merged_terms_combined_key[grep("^HerculanoHouzel_etal_2020", merged_terms_combined_key$Reference), ]
# Loop through rows and apply the mapping
for (i in 1:nrow(filtered_rows)) {
  original_term <- filtered_rows$Original_Term[i]
  # Check if the original term is in the mapping
  if (original_term %in% names(term_mapping)) {
    # Update Standardized_Term based on the mapping
    filtered_rows$Standardized_Term[i] <- term_mapping[original_term]
  }
}
# Update the original dataframe with the modified rows
merged_terms_combined_key[grep("^HerculanoHouzel_etal_2020", merged_terms_combined_key$Reference), ] <- filtered_rows

## SORT OUT TAXONOMIC HEADERS
# Update Standardized_term to "Species" for rows where Original_term is "Species" or "Species name" and Standardized_term is NA
merged_terms_combined_key$Standardized_Term <- ifelse(merged_terms_combined_key$Original_Term %in% c("Species", "Species name") & is.na(merged_terms_combined_key$Standardized_Term), "Species", merged_terms_combined_key$Standardized_Term)
# Update Standardized_term to "CommonName" for rows where Original_term is "Common Name" and Standardized_term is NA
merged_terms_combined_key$Standardized_Term <- ifelse(merged_terms_combined_key$Original_Term == "Common Name" & is.na(merged_terms_combined_key$Standardized_Term), "CommonName", merged_terms_combined_key$Standardized_Term)

## FILL OUT STRUCTURE_MEASURE FROM THE DEFINITIONS FILES THAT LIST THEM SEPARATELY

# Use stucture and measure list to match Kverkova_etal_2018
Kverkova_etal_2018_definitions <- read.csv("Kverkova_etal_2018_definitions.csv")
fillStandardizedTerm <- function(merged_terms_combined_key, Kverkova_etal_2018_definitions) {
  # Filter rows in merged_terms_combined_key where Standardized_Term is NA and Reference starts with "Kverkova_etal_2018"
  rows_to_process <- merged_terms_combined_key$Standardized_Term %in% NA & grepl("^Kverkova_etal_2018", merged_terms_combined_key$Reference)
  # Loop through the rows to process
  for (i in which(rows_to_process)) {
    # Extract Original_Term and split into Structure_string and Measure_string
    original_term <- merged_terms_combined_key$Original_Term[i]
    strings <- strsplit(original_term, "_")[[1]]
    Structure_string <- strings[1]
    Measure_string <- strings[2]
    # Search for Structure_string in Kverkova_etal_2018_definitions$Code and copy corresponding "Structure" term
    structure_term <- Kverkova_etal_2018_definitions$Structure[Kverkova_etal_2018_definitions$Code == Structure_string]
    # Search for Measure_string in Kverkova_etal_2018_definitions$Code and copy corresponding "Measure" term
    measure_term <- Kverkova_etal_2018_definitions$Measure[Kverkova_etal_2018_definitions$Code == Measure_string]
    # Combine Structure_string and Measure_string to form the Standardized_Term
    standardized_term <- paste(structure_term, measure_term, sep="_")
    # Update the merged_terms_combined$Standardized_Term with the newly formed term
    merged_terms_combined_key$Standardized_Term[i] <- standardized_term
  }
  # Rename string1 and string2 columns
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "Structure_string"] <- "Structure"
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "Measure_string"] <- "Measure"
  return(merged_terms_combined_key)
}
merged_terms_combined_key <- fillStandardizedTerm(merged_terms_combined_key, Kverkova_etal_2018_definitions)

# Use stucture and measure list to match DosSantos_etal_2020 
DosSantos_etal_2020_definitions <- read.csv("DosSantos_etal_2020_definitions.csv")
fillStandardizedTerm <- function(merged_terms_combined_key, DosSantos_etal_2020_definitions) {
  # Filter rows in merged_terms_combined_key where Standardized_Term is NA and Reference starts with "DosSantos_etal_2020"
  rows_to_process <- merged_terms_combined_key$Standardized_Term %in% NA & grepl("^DosSantos_etal_2020", merged_terms_combined_key$Reference)
  # Loop through the rows to process
  for (i in which(rows_to_process)) {
    # Extract Original_Term and split into Structure_string and Measure_string
    original_term <- merged_terms_combined_key$Original_Term[i]
    strings <- strsplit(original_term, "_")[[1]]
    Structure_string <- strings[1]
    Measure_string <- strings[2]
    # Search for Structure_string in DosSantos_etal_2020_definitions$Code and copy corresponding "Structure" term
    structure_term <- DosSantos_etal_2020_definitions$Structure[DosSantos_etal_2020_definitions$Code == Structure_string]
    # Search for Measure_string in DosSantos_etal_2020_definitions$Code and copy corresponding "Measure" term
    measure_term <- DosSantos_etal_2020_definitions$Measure[DosSantos_etal_2020_definitions$Code == Measure_string]
    # Combine Structure_string and Measure_string to form the Standardized_Term
    standardized_term <- paste(structure_term, measure_term, sep="_")
    # Update the merged_terms_combined$Standardized_Term with the newly formed term
    merged_terms_combined_key$Standardized_Term[i] <- standardized_term
  }
  # Rename string1 and string2 columns
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "Structure_string"] <- "Structure"
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "Measure_string"] <- "Measure"
  return(merged_terms_combined_key)
}
# Updated variable names
merged_terms_combined_key <- fillStandardizedTerm(merged_terms_combined_key, DosSantos_etal_2020_definitions)

# Save to a CSV file
write.csv(merged_terms_combined_key, "merged_terms_combined_key.csv", row.names = FALSE)


#source
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging")

## Summary: This is for merging all variables in datasets from papers about cell counts into a list, and then matching them with Standardized terms, via so reference to the the old key.

##MERGE TERM LISTS FROM HEADERS

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

## HerculanoHouzel_etal_2015 tables 1-5
# Read old key of terms and merge pair. In old_key, "Original_Term" based on HerculanoHouzel_etal_2015.
old_key <- read.csv("old_key.csv")
merged_terms_combined_key <- merge(merged_terms, old_key, by = "Original_Term", all = TRUE)

## JardimMesseder_etal_2017_Table1 
# Match JardimMessender2017_old column to Original_Term, to capture rows from JardimMesseder_etal_2017_Table1 
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
# Irregular case of Common Name
merged_terms_combined_key$Standardized_Term <- ifelse(
  merged_terms_combined_key$Original_Term %in% c("CommonName", "Common Name") & is.na(merged_terms_combined_key$Standardized_Term),
  "CommonName",
  merged_terms_combined_key$Standardized_Term
)



## DosSantos_etal_2017_TableS1
# Match to DosSantos2017_old to Original_Term, to capture rows from DosSantos_etal_2017_TableS1
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

## HerculanoHouzel_2020 tables 1-2
# Match Original_Term from HerculanoHouzel_2020* tables to Standardized_Term (or provide new one if not available)
# Define the mapping rules for existing terms and (if available) Standardized Terms. These are irregular so done one by one.
term_mapping <- c("Clade" = "Clade",
                  "Family" = "Family",
                  "MBODY, g" = "Body_Mass.g",
                  "MBRAIN, g" = "WholeBrain_Mass.g",
                  "Micro/mega" = "Micro.or.mega",
                  "n" = "WholeBrain_n",
                  "NBRAIN" = "WholeBrain_N.n",
                  "DN,Cb" = "Cerebellum_N.p.mg",
                  "DN,CX" = "CerebralCortex_N.p.mg",
                  "DN,RoB" = "RoB_N.p.mg"
                  )
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
merged_terms_combined_key[grep("^HerculanoHouzel_etal_2020", merged_terms_combined_key$Reference), ] <- filtered_rows # Update the original dataframe with the modified rows
# Update Standardized_term to "Species" for rows where Original_term is "Species" or "Species name" and Standardized_term is NA
merged_terms_combined_key$Standardized_Term <- ifelse(merged_terms_combined_key$Original_Term %in% c("Species", "Species name") & is.na(merged_terms_combined_key$Standardized_Term), "Species", merged_terms_combined_key$Standardized_Term)

## FILL OUT STRUCTURE_MEASURE FROM THE DEFINITIONS FILES THAT LIST THEM SEPARATELY

## Kverkova_etal_2018 table S1,S5
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
    SD_string <- strings[3]
    # Search for Structure_string in Kverkova_etal_2018_definitions$Code and copy corresponding "Structure" term
    structure_term <- Kverkova_etal_2018_definitions$Structure[Kverkova_etal_2018_definitions$Code == Structure_string]
    # Search for Measure_string in Kverkova_etal_2018_definitions$Code and copy corresponding "Measure" term
    measure_term <- Kverkova_etal_2018_definitions$Measure[Kverkova_etal_2018_definitions$Code == Measure_string]
    # Search for Measure_string in Kverkova_etal_2018_definitions$Code and copy corresponding "SD" term
    SD_term <- Kverkova_etal_2018_definitions$SD[Kverkova_etal_2018_definitions$Code == SD_string]
    # Combine Structure_string and Measure_string to form the Standardized_Term
    standardized_term <- paste(structure_term, measure_term, SD_term[!is.na(SD_term)==T], sep="_")
    # remove trailing underscores
    standardized_term = sub("_$", "",standardized_term)
    # Update the merged_terms_combined$Standardized_Term with the newly formed term
    merged_terms_combined_key$Standardized_Term[i] <- standardized_term
  }
   # Rename string1, string2 and string3 columns
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "Structure_string"] <- "Structure"
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "Measure_string"] <- "Measure"
  names(merged_terms_combined_key)[names(merged_terms_combined_key) == "SD_string"] <- "SD"
  return(merged_terms_combined_key)
}
merged_terms_combined_key <- fillStandardizedTerm(merged_terms_combined_key, Kverkova_etal_2018_definitions)

## DosSantos_etal_2020_Table1
# Use stucture and measure list to match DosSantos_etal_2020 
DosSantos_etal_2020_definitions <- read.csv("DosSantos_etal_2020_definitions.csv")
fillStandardizedTerm <- function(merged_terms_combined_key, DosSantos_etal_2020_definitions) {
  # Filter rows in merged_terms_combined_key where Standardized_Term is NA and Reference starts with "DosSantos_etal_2020"
  rows_to_process <- merged_terms_combined_key$Standardized_Term %in% NA & grepl("^DosSantos_etal_2020", merged_terms_combined_key$Reference)
  # Loop through the rows to process
  for (i in which(rows_to_process)) {
    # Extract Original_Term and split into Structure_string and Measure_string
    original_term <- merged_terms_combined_key$Original_Term[i]
    strings <- strsplit(original_term, "_")[[1]] #Get rid of trailing "_"
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

# Tidy up Standardized Term list
# Delete unnecessary columns: Standard_old, DosSantos2017_old, JardimMessender2017_old
standardized_term_cellcounts <- merged_terms_combined_key[, -which(names(merged_terms_combined_key) %in% c("Standard_old", "DosSantos2017_old", "JardimMessender2017_old"))]
# Delete any rows where Reference is NA
standardized_term_cellcounts <- standardized_term_cellcounts[complete.cases(standardized_term_cellcounts$Reference), ]
# Sort rows, first by Reference and then by Original_Term
library(dplyr)
standardized_term_cellcounts <- standardized_term_cellcounts %>%
  arrange(Reference, Original_Term)

# CHECKS
# The number of observations in dataframe X should match the number of observations where Reference is X in standardized_term_cellcounts   
# List of dataframe names
dataframe_names <- c(
  "DosSantos_etal_2017_TableS1",
  "DosSantos_etal_2020_Table1",
  "HerculanoHouzel_etal_2015_Table1",
  "HerculanoHouzel_etal_2015_Table2",
  "HerculanoHouzel_etal_2015_Table3",
  "HerculanoHouzel_etal_2015_Table4",
  "HerculanoHouzel_etal_2015_Table5",
  "HerculanoHouzel_etal_2020_Table1",
  "HerculanoHouzel_etal_2020_Table2",
  "JardimMesseder_etal_2017_Table1",
  "Kverkova_etal_2018_TableS1",
  "Kverkova_etal_2018_TableS5"
)
# Check for each dataframe
for (df_name in dataframe_names) {
  df <- get(df_name)  # Assuming the dataframes are in the global environment
  if (nrow(df) == sum(standardized_term_cellcounts$Reference == df_name)) {
    cat("The number of observations in", df_name, "matches the number of observations in standardized_term_cellcounts with the same name in Reference.\n")
  } else {
    cat("The number of observations in", df_name, "DOES NOT match the number of observations in standardized_term_cellcounts with the same name in Reference.\n")
  }
}

# Check for consistency between Original_Term and Standardized_Term. If no inconsistencies are found, the code will not print anything. 
reference_groups2 <- split(standardized_term_cellcounts, standardized_term_cellcounts$Reference)
for (group in reference_groups2) {
  for (col_name in c("Original_Term", "Standardized_Term")) {
    if (any(duplicated(group$Original_Term) & duplicated(group$Standardized_Term) | 
            duplicated(group$Original_Term, fromLast = TRUE) & duplicated(group$Standardized_Term, fromLast = TRUE))) {
      cat("Inconsistent values in group with Reference:", group$Reference[1], "for column:", col_name, "\n")
      cat("Original_Term values:", toString(group$Original_Term), "\n")
      cat("Standardized_Term values:", toString(group$Standardized_Term), "\n\n")
    }
  }
}


# Save to a CSV file
write.csv(standardized_term_cellcounts, "standardized_term_cellcounts.csv", row.names = FALSE)

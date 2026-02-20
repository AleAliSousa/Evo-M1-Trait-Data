# CHECKS in standardized_term_cellcounts.R

# CHECKS
# The number of observations in dataframe X should match the number of observations where Reference is X in standardized_term_cellcounts   

# Make the dataframes available in the environment
list2env(item_data_list, envir = environment())

# Check for each dataframe
for (df_name in item_name) {
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

# CHECK AGAINST OLD OUTPUT BEFORE EDITED SCRIPT
# Read Old saved version
standardized_term_cellcounts_save <- read.csv("standardized_term_cellcounts_save.csv")
# TRANFORMATIONS to Make equal and compare
standardized_term_cellcounts$Reference <- sub("TABLE", "Table", standardized_term_cellcounts$Reference)
standardized_term_cellcounts_save$Reference <- sub("TABLE", "Table", standardized_term_cellcounts_save$Reference)
# Sort by Reference and Original_term for both
standardized_term_cellcounts <- standardized_term_cellcounts[order(standardized_term_cellcounts$Reference, standardized_term_cellcounts$Original_Term),]
standardized_term_cellcounts_save <- standardized_term_cellcounts_save[order(standardized_term_cellcounts_save$Reference, standardized_term_cellcounts_save$Original_Term),]
# Remove rownames for both
rownames(standardized_term_cellcounts) <- NULL
rownames(standardized_term_cellcounts_save) <- NULL

# Compare data frames with arsenal
library(arsenal)
standardized_term_cellcounts_save <- read.csv("standardized_term_cellcounts_save.csv")
summary(comparedf(standardized_term_cellcounts_save, standardized_term_cellcounts))

# Check if the data frames are identical
summary(identical(standardized_term_cellcounts_save, standardized_term_cellcounts))

# Check if the data frames are identical
library(compare)
compare(standardized_term_cellcounts_save, standardized_term_cellcounts)

# Save both to a CSV file for visual inspection
write.csv(standardized_term_cellcounts_save, "standardized_term_cellcounts_save1.csv", row.names = FALSE)
write.csv(standardized_term_cellcounts, "standardized_term_cellcounts1.csv", row.names = FALSE)


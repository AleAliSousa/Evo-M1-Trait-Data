##troubleshooting

# Specify the column name to investigate
column_name_to_match <- "Species names"  # Replace with the actual column name

# DosSantos_etal_2020_Table1
DosSantos_etal_2020_Table1_indices <- match(
  column_name_to_match,
  standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2020_Table1"]
) 

# Print relevant information for troubleshooting
print(paste("Column name:", column_name_to_match))
print("Before renaming DosSantos_etal_2020_Table1:")
print(colnames(DosSantos_etal_2020_Table1))

# Check the matching index
print(paste("Matching index:", DosSantos_etal_2020_Table1_indices))

# Check the standardized term
print(paste("Standardized term:", standardized_term_cellcounts$Standardized_Term[DosSantos_etal_2020_Table1_indices]))

# Rename the specific column
colnames(DosSantos_etal_2020_Table1)[DosSantos_etal_2020_Table1_indices] <- standardized_term_cellcounts$Standardized_Term[DosSantos_etal_2020_Table1_indices]

# Print relevant information after renaming
print("After renaming DosSantos_etal_2020_Table1:")
print(colnames(DosSantos_etal_2020_Table1))


# Extract the "Species name" terms from each data frame
species_name_in_dos_santos <- colnames(DosSantos_etal_2020_Table1)[1]  # Assuming it's the first column
colnames(DosSantos_etal_2020_Table1)[1]
# species_name_in_standardized <- standardized_term_cellcounts$Original_Term[101]  # Assuming it's in the 101st row
# standardized_term_cellcounts$Original_Term[101]
species_name_in_standardized <- standardized_term_cellcounts$Original_Term[57]  # Assuming it's in the 101st row
standardized_term_cellcounts$Original_Term[57]

# Compare the terms
if (identical(species_name_in_dos_santos, species_name_in_standardized)) {
  print("Terms match.")
} else {
  print("Terms do not match.")
  print(paste("Species name in DosSantos_etal_2020_Table1:", species_name_in_dos_santos))
  print(paste("Species name in standardized_term_cellcounts:", species_name_in_standardized))
}

# 
# 
# # Extract the "Species name" terms from each data frame
# species_name_in_dos_santos <- colnames(DosSantos_etal_2020_Table1)[1]  # Assuming it's the first column
# species_name_in_standardized <- standardized_term_cellcounts$Original_Term[101]  # Assuming it's in the 101st row
# 
# # Compare the terms
# if (species_name_in_dos_santos == species_name_in_standardized) {
#   print("Terms match.")
# } else {
#   print("Terms do not match.")
#   print(paste("Species name in DosSantos_etal_2020_Table1:", species_name_in_dos_santos))
#   print(paste("Species name in standardized_term_cellcounts:", species_name_in_standardized))
# }
 

#The non-function way 
renamer <- function(i){
m = match (colnames(i), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "i"])
colnames(i) = (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == "i"])[m]
}
res <- sapply(df_names, renamer(df_names))




## troubleshooting DosSantos_etal_2017_TableS1
# DosSantos_etal_2017_TableS1
DosSantos_etal_2017_TableS1_indices <- match(
  colnames(DosSantos_etal_2017_TableS1),
  standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2017_TableS1"]
) 

# Print relevant information for troubleshooting
print("Before renaming DosSantos_etal_2017_TableS1:")
print(colnames(DosSantos_etal_2017_TableS1))

colnames(DosSantos_etal_2017_TableS1) <- standardized_term_cellcounts$Standardized_Term[DosSantos_etal_2017_TableS1_indices]

# Print relevant information after renaming
print("After renaming DosSantos_etal_2017_TableS1:")
print(colnames(DosSantos_etal_2017_TableS1))

## troubleshooting DosSantos_etal_2020_Table1
# DosSantos_etal_2020_Table1
DosSantos_etal_2020_Table1_indices <- match(
  colnames(DosSantos_etal_2020_Table1),
  standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2020_Table1"]
) 

# Print relevant information for troubleshooting
print("Before renaming DosSantos_etal_2020_Table1:")
print(colnames(DosSantos_etal_2020_Table1))

colnames(DosSantos_etal_2020_Table1) <- standardized_term_cellcounts$Standardized_Term[DosSantos_etal_2020_Table1_indices]

# Print relevant information after renaming
print("After renaming DosSantos_etal_2020_Table1:")
print(colnames(DosSantos_etal_2020_Table1))


#######
# DosSantos_etal_2017_TableS1
colnames(DosSantos_etal_2017_TableS1) <- standardized_term_cellcounts$Standardized_Term[match(
  colnames(DosSantos_etal_2017_TableS1),
  standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2017_TableS1"]
)]
# DosSantos_etal_2020_Table1
colnames(DosSantos_etal_2020_Table1) <- standardized_term_cellcounts$Standardized_Term[match(
  colnames(DosSantos_etal_2020_Table1),
  standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2020_Table1"]
)]



# # DosSantos_etal_2017_TableS1
# colnames(DosSantos_etal_2017_TableS1) <- lapply(colnames(DosSantos_etal_2017_TableS1), function(col_name) {
#   match_index <- match(
#     col_name,
#     standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2017_TableS1"]
#   )
#   return(standardized_term_cellcounts$Standardized_Term[match_index])
# })
# 
# # DosSantos_etal_2020_Table1
# colnames(DosSantos_etal_2020_Table1) <- lapply(colnames(DosSantos_etal_2020_Table1), function(col_name) {
#   match_index <- match(
#     col_name,
#     standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2020_Table1"]
#   )
#   return(standardized_term_cellcounts$Standardized_Term[match_index])
# })


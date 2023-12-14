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


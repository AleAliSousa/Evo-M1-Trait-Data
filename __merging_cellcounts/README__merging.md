These were the steps in merging cell types counts data
1. Standardized term list creation
Inputs: one file per table
Outputs:"standardized_term_cellcounts.csv"

2. Cell counts compiled
cellcounts_compiled.R: for merging, filtering, and calculating variables in related datasets
Inputs: comparative_data tsv files, __ReadMe.xlsx, "standardized_term_cellcounts_matching.R" 
Outputs: "cellcounts_long.csv", "cellcounts_wide.csv"   
Related for checks: "cellcounts_unfiltered.csv" 
--- cellcounts_conflictcheck.R: used for checking on some conflicts
Related for species names: "cellcounts_source_species_ids.csv"
Related for tracking flagged datasets: _metadata_flags.csv files

4. Imputations 
cellcounts_imputations_diagnostic.R
imp30x10.RData

# List all files in the directory
list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging")

There were the steps in mergeing cell types counts data
1. Old Key creation
old_key_matching.R:  for merging, comparing, and summarizing old KEY files found in "Do expensive brain ..." that were hand-compiled into term lists. Refers to: "old_DosSantos_2017_key.csv", "old_HerculanoHouzel_2015_key.csv", "old_JardimMesseder_2017_key.csv", "old_key_matching.R"                   
Resulting in: an old key file: "old_key.csv" 
(This was done PRIOR to creation of the current standard terms, which is why these old files can be archived.)

2. Standardized term list creation
standardized_term_cellcounts_matching.R: for merging all variables in all datasets used here from papers about cell counts into a list, and then matching them with Standardized terms, via so reference to the the old key.
Refers to: comparative_data tsv files, __ReadMe.xlsx, old_key.csv and some _definitions.csv files
Resulting in:"standardized_term_cellcounts.csv"

3. Cell counts compiled
cellcounts_compiled.R: for merging, filtering, and calculating variables in related datasets
Refers to: comparative_data tsv files, __ReadMe.xlsx, "standardized_term_cellcounts_matching.R" 
Resulting in: "cellcounts_long.csv", "cellcounts_wide.csv"   
Related for checks: "cellcounts_unfiltered.csv" 
--- cellcounts_conflictcheck.R: used for checking on some conflicts
Related for species names: "cellcounts_source_species_ids.csv"
Related for tracking flagged datasets: _metadata_flags.csv files

4. Imputations 
cellcounts_imputations_diagnostic.R
imp30x10.RData

# List all files in the directory
list.files("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging")

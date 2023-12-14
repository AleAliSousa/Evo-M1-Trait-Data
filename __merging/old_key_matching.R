#source
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging")

## Summary: This is for merging, comparing, and summarizing old KEY files found in "Do expensive brain ..." that were hand-compiled into term lists
# typo in old_HerculanoHouzel_2015_key Struct.Descrip_old "\\*neurol\\*", "\\*neuronal\\*"  was done by hand first

## COMBINE PARTS INTO OLD KEY

# Read all CSVs
old_DosSantos_2017_key <- read.csv("old_DosSantos_2017_key.csv", stringsAsFactors = FALSE)
old_HerculanoHouzel_2015_key <- read.csv("old_HerculanoHouzel_2015_key.csv", stringsAsFactors = FALSE)
old_JardimMesseder_2017_key <- read.csv("old_JardimMesseder_2017_key.csv", stringsAsFactors = FALSE)

# merge in pairs
old_DosSantos_2017_HerculanoHouzel_2015_key <- merge(old_DosSantos_2017_key, old_HerculanoHouzel_2015_key, all = TRUE)
old_key <- merge(old_DosSantos_2017_HerculanoHouzel_2015_key, old_JardimMesseder_2017_key, all = TRUE)

# Remove the unnecessary "X_" column
old_key$X_ <- NULL

# trim whitespace in all columns of a data frame
old_key[] <- lapply(old_key, trimws)

# remove duplicated rows 
old_key <- unique(old_key)

# Remove rows where all columns are empty
old_key <- old_key[rowSums(is.na(old_key) | old_key == "") != ncol(old_key), ]

# Standard_old will be used as the basis of Original_Term and Standardized_term  
# Standard_old -> Original_Term
# Extend key by editing Standard_oldterms in this "...key" to match new terms listed as "Original_Term" with a few changes so these can be compared.
# 1st change to match the names from Herculano-Houzel et al. 2015 which are close to the desired standard and called "Standard_old"
# Duplicate column to edit
old_key$"Standard_old_edit" <- old_key$"Standard_old"

# Replace special ones
old_key$Standard_old_edit <- gsub("WholeBrain_Mass_g", "Brain mass, g", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("WholeBrain_N_n", "Whole brain Neurons", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("WholeBrain_O_n", "Whole brain Other cells", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("CerebralCortexGreyMatter", "Cerebral cortex Grey matter", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("MesencephalonDiencephalonStriatum", "Mesencephalon+Diencephalon+Striatum", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("DiencephalonStriatum", "Diencephalon+Striatum", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("PonsMedulla", "Pons+Medulla", old_key$Standard_old_edit)

# Replace measurements
old_key$Standard_old_edit <- gsub("O_n", "O, n", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("N_n", "N, n", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("Omg", "O/mg", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("Nmg", "N/mg", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("ON", "O/N", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("Mass_g", "Mass, g", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("percent_Neurons", "% Neurons", old_key$Standard_old_edit)

# Replace anatomy
old_key$Standard_old_edit <- gsub("CerebralCortex", "Cerebral cortex", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("OlfactoryBulb", "Olfactory bulb", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("WholeBrain", "Whole brain", old_key$Standard_old_edit)
old_key$Standard_old_edit <- gsub("Body_Mass", "Body mass", old_key$Standard_old_edit)

# Replace underscore
old_key$Standard_old_edit <- gsub("_", " ", old_key$Standard_old_edit)

# Rename the column "Standard_old_edit" to "Original_Term"
colnames(old_key)[colnames(old_key) == "Standard_old_edit"] <- "Original_Term"
##HERE1_End

# CREATE Standardized_Term using underscore as a separator and avoiding problematic symbols
# Standard_old -> Standardized_Term
## Make a new version which is better for Standardized_Term
# Duplicate column to edit
old_key$Standardized_Term <- old_key$Standard_old

# Replace special ones
old_key$Standardized_Term <- gsub("CerebralCortexGreyMatter", "CerebralCortexGrey", old_key$Standardized_Term)

# Replace measurements
old_key$Standardized_Term <- gsub("O_n", "O.n", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("N_n", "N.n", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("Omg", "O.p.mg", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("Nmg", "N.p.mg", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("ON", "O.p.N", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("Mass_g", "Mass.g", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("Mass_kg", "Mass.kg", old_key$Standardized_Term)
old_key$Standardized_Term <- gsub("percent_Neurons", "p.C.N", old_key$Standardized_Term)

# Identify duplicates in each column
duplicates <- apply(old_key, 2, function(x) any(duplicated(x) | duplicated(x, fromLast = TRUE)))
# Print columns with duplicates along with the duplicated values
for (col_name in names(duplicates[duplicates])) {
  duplicated_values <- old_key[duplicated(old_key[[col_name]]) | duplicated(old_key[[col_name]], fromLast = TRUE), col_name]
  cat("Column:", col_name, "\n")
  cat("Duplicated Values:", toString(duplicated_values), "\n\n")
}
# These are all due to empty cells with "" or "NA" so do not cause conflicts

# Save to a CSV file
write.csv(old_key, "old_key.csv", row.names = FALSE)




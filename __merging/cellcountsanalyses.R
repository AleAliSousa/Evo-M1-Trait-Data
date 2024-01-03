# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging/")

# Working with cell counts data (
# 1. Create a regression of whole brain cell count on body size for all species 
# 1a. Create for Kverkova WholeBrain data from WholeBrainOlfactoryBulb by subtracting OlfactoryBulb for all variables including Neuron number and Mass cell count data in all files
# 1b. Create vectors for WholeBrain from all dfs with reference to term list: see if it can search all dfs in a folder? 
# 1c. Compile and view. Then, check which species are there.

# Read the relevant database files. Do not check names because some of the characters are not accepted by R.
DosSantos_etal_2017_TableS1 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/DosSantos_etal_2017/DosSantos_etal_2017_TableS1.csv", stringsAsFactors = FALSE, check.names=FALSE)
DosSantos_etal_2020_Table1 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/DosSantos_etal_2020/DosSantos_etal_2020_Table1.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2015_Table1 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table1.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2015_Table2 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table2.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2015_Table3 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table3.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2015_Table4 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table4.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2015_Table5 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_Table5.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2020_Table1 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2020/HerculanoHouzel_etal_2020_Table1.csv", stringsAsFactors = FALSE, check.names=FALSE)
HerculanoHouzel_etal_2020_Table2 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2020/HerculanoHouzel_etal_2020_Table2.csv", stringsAsFactors = FALSE, check.names=FALSE)
JardimMesseder_etal_2017_Table1 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/JardimMesseder_etal_2017/JardimMesseder_etal_2017_Table1.csv", stringsAsFactors = FALSE, check.names=FALSE)
Kverkova_etal_2018_TableS1 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Kverkova_etal_2018/Kverkova_etal_2018_TableS1.csv", stringsAsFactors = FALSE, check.names=FALSE)
Kverkova_etal_2018_TableS5 <- read.csv("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Kverkova_etal_2018/Kverkova_etal_2018_TableS5.csv", stringsAsFactors = FALSE, check.names=FALSE)

setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging/cellcountsanalyses")
df_names <- dir(pattern = "csv$")

## Change to standardized term for all variables in those dfs

# Read standardized terms
standardized_term_cellcounts <- read.csv("standardized_term_cellcounts.csv", check.names=FALSE)

# List of data frame names
df_names <- c(
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

# Loop through each data frame
for (df_name in df_names) {
  df <- get(df_name)
  indices <- match(colnames(df), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == df_name])
  colnames(df) = (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == df_name])[indices]
  assign(df_name, df)
}

# # one at a time alternative
# m = match (colnames(DosSantos_etal_2017_TableS1), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2017_TableS1"])
# colnames(DosSantos_etal_2017_TableS1) = (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2017_TableS1"])[m]
# m = match (colnames(DosSantos_etal_2020_Table1), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2020_Table1"])
# colnames(DosSantos_etal_2020_Table1) = (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == "DosSantos_etal_2020_Table1"])[m]

# 2. Compile total of all datasets on cellular composition
# 2Qa. What data should be included/excluded when doing an imputation?
# 2Qb. Should data be converted if there is an equation for exact conversion? e.g. WholeBrain ; BodyMasskg

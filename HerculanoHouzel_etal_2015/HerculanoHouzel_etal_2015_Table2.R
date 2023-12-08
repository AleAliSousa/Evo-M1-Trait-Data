## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/HerculanoHouzel_etal_2015")

# Table 2
## 1. Read direct from xl
library(readxl)
tabledirectxl <- read_excel("HerculanoHouzel_etal_2015_Table2_primary_or_equivalent.xlsx")

## 2. Check Table name
# Assuming the first column header is "Table 2. Cerebellum"
first_column_name <- colnames(tabledirectxl)[1]
# Specify the prefix to remove
prefix_to_remove <- "Table 2. "
# Extract the part after the prefix
structure_name <- sub(paste0("^", prefix_to_remove), "", first_column_name)

## 3. Remove table name header and bottom note
# Set the next row as the new header
colnames(tabledirectxl) <- as.character(unlist(tabledirectxl[1, ]))
# Remove the first row since it's now the header
tabledirectxl <- tabledirectxl[-1, ]
# Remove the last two rows which are notes
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-2), ]

# ## 3. Correct (possible) error
# # There seems to be a " + " in place of " ± " in 	column "N,n" row "Rattus norvegicus"
# # Replace " + " with " ± " in the entire dataset
# tabledirectxl[] <- lapply(tabledirectxl, function(x) gsub("\\s*\\+\\s*", " ± ", x))

## 4. Split 6 columns containing average ± standard deviation into 12 different columns.
# Load the 'tidyr' package
library(tidyr)
# Define the columns to split and their corresponding new column names
cols_to_split <- c("Mass, g", "N, n", "O, n", "N/mg",	"O/mg",	"O/N")
new_col_names <- c("Mass, g", "Mass, g SD", "N, n", "N, n SD", "O, n", "O, n SD", "N/mg", "N/mg SD", "O/mg",	"O/mg SD",	"O/N", "O/N SD")
# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], " SD")),  # New column names with space before SD
    #sep = " ± ",  # Specify the separator as a regular expression to split on ' ±'
    sep = "\\s*±\\s*",  # Specify the separator as a regular expression to split on ' ±' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

## 5. Convert columns to numeric (taking away commas)
columns_to_convert <- c("Mass, g", "Mass, g SD", "N, n", "N, n SD", "O, n", "O, n SD", "N/mg", "N/mg SD", "O/mg", "O/mg SD", "O/N", "O/N SD")
for (column in columns_to_convert) {
  tabledirectxl[[column]] <- as.numeric(gsub(",", "", tabledirectxl[[column]]))
}

## 6. Name columns after the structure
# Specify the columns to rename
columns_to_rename <- c("Mass, g", "Mass, g SD", "N, n", "N, n SD", "O, n", "O, n SD", "N/mg", "N/mg SD", "O/mg", "O/mg SD", "O/N", "O/N SD", "Source")
# Add structure at the beginning of each column name
colnames(tabledirectxl)[match(columns_to_rename, colnames(tabledirectxl))] <- paste0(structure_name, " ", columns_to_rename)

## 7. Save
# Save the dataframe to a CSV file
write.csv(tabledirectxl, file = "HerculanoHouzel_etal_2015_Table2.csv", row.names = FALSE)

# Save the data frame to a TSV file for online database
write.csv(tabledirectxl, file = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__Public/comparative-data/10.1159%2F000437413_Table2.tsv", row.names = FALSE)

## Export colnames to merge terms
# Edit for your existing DATAFRAME and TABLE
# Create a new dataframe with the desired structure
new_dataframe <- data.frame(
  Original_Term = colnames(tabledirectxl),  # Column headers from tabledirectxl
  Reference = rep("HerculanoHouzel_etal_2015_Table2", ncol(tabledirectxl))  # Reference column
)

# Save the new dataframe to a CSV file
file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging/HerculanoHouzel_etal_2015_Table2_terms.csv"
write.csv(new_dataframe, file_path, row.names = FALSE)

# Print the new dataframe
print(new_dataframe)
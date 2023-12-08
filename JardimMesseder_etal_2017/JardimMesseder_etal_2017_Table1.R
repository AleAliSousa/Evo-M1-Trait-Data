## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/JardimMesseder_etal_2017")

# Table 1
# Open pdf in Adobe Acrobat
# Export >  Microsoft Excel Workbook > Settings: Create Worksheet for each Table
# Copy and paste all rows containing Table 1

# Read direct from xl
library(readxl)
tabledirectxl <- read_excel("Jardim-Messeder-2017-Dogs Have the Most N_Tables.xlsx", sheet=6)

# Remove table name header and bottom note
# Set the next row as the new header
colnames(tabledirectxl) <- as.character(unlist(tabledirectxl[1, ]))
# Remove the first row since it's now the header
tabledirectxl <- tabledirectxl[-1, ]
# Remove the last 4 rows which are notes and other things
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-4), ]

# Delete empty columns that contain only NA values and have no header names.
tabledirectxl <- tabledirectxl[, colSums(is.na(tabledirectxl)) != nrow(tabledirectxl), drop = FALSE]

# Save the dataframe to a CSV file #symbol not formatted for Excel, open in Numbers
write.csv(tabledirectxl, file = "JardimMesseder_etal_2017_Table1_primary_or_equivalent.csv", row.names = FALSE)

## MAKE DATA READABLE


# TRANSPOSE
# transpose the dataframe to a matrix
m <- t(tabledirectxl)
# convert from matrix to dataframe
tabledirectxl <- as.data.frame(m)
# Set column names to values in the first row of matrix
colnames(tabledirectxl) <- m[1, ]
# Delete the first row of a dataframe by subsetting it to exclude the first row.
tabledirectxl <- tabledirectxl[-1, , drop = FALSE]
# Create a new column 'Species' with values copied from row names
tabledirectxl$Species <- rownames(tabledirectxl)
# Reorder the columns with "Species" as the first column
tabledirectxl <- tabledirectxl[, c("Species", setdiff(names(tabledirectxl), "Species"))]
# Add a new column with row numbers
tabledirectxl$Row_Numbers <- 1:nrow(tabledirectxl)
# Replace rownames (species names) with Row_numbers
rownames(tabledirectxl) <- tabledirectxl$Row_Numbers
# Delete the "Row_Numbers" column using subset
tabledirectxl <- subset(tabledirectxl, select = -Row_Numbers)

# remove unnecessary string in the whole dataset
tabledirectxl <- data.frame(sapply(tabledirectxl,function(x) gsub("n.a.","",as.character(x))))
tabledirectxl <- data.frame(lapply(tabledirectxl,function(x) gsub(",","",as.character(x))))

## CALCULATE DATA
# Assuming your data frame is named 'tabledirectxl'
for (row in 1:nrow(tabledirectxl)) {
  for (col in 1:ncol(tabledirectxl)) {
    if (grepl(" × 106", tabledirectxl[row, col], fixed = TRUE)) {
      tabledirectxl[row, col] <- gsub(" × 106", "", tabledirectxl[row, col])
      tabledirectxl[row, col] <- as.numeric(tabledirectxl[row, col]) * 10^6
    }
  }
}

# Loop through the columns to convert all values to numeric, except for the first column (Species)
for (col in names(tabledirectxl)) {
  if (col != "Species") {
    tabledirectxl[[col]] <- as.numeric(tabledirectxl[[col]])
  }
}

#SPLIT COLUMN
# Split the Species names (common and scientific) into two columns

# Load the 'tidyr' package
library(tidyr)
library(dplyr)

# Define the column to split and its corresponding new column names
cols_to_split <- c("Species")
new_col_names <- c("Common Name", "Species")

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i], new_col_names[i + 1]),  # New column names without duplication
    sep = "\\s*\\.\\.\\s*",  # Specify the separator as a regular expression to split on '..' with or without space
    extra = "drop"  # Drop any extra pieces
  )
}

#MOVE SPECIES COLUMN, TIDY CHARACTERS, RESTORE ABBREVIATED TERMS
# Identify the column indices for "Species" and "Common Name"
species_col_index <- which(colnames(tabledirectxl) == "Species")
common_name_col_index <- which(colnames(tabledirectxl) == "Common Name")

# Specify the order of all columns
column_order <- c(species_col_index, common_name_col_index, setdiff(seq_along(tabledirectxl), c(species_col_index, common_name_col_index)))

# Reorder the columns
tabledirectxl <- tabledirectxl[, column_order]

# Rename the columns to ensure "Species" is the first column and "Common Name" is the second column
colnames(tabledirectxl) <- c("Species", "Common Name", colnames(tabledirectxl)[-c(species_col_index, common_name_col_index)])

# Replace "." with " " in the "Species", "Common Name" columns
tabledirectxl$Species <- gsub("\\.", " ", tabledirectxl$Species)
tabledirectxl$"Common Name" <- gsub("\\.", " ", tabledirectxl$"Common Name")
# Remove leading and trailing whitespace from the "Species" column
tabledirectxl$Species <- trimws(tabledirectxl$Species)

# Restore original abbreviated terms in column names
colnames(tabledirectxl) <- gsub("O.N", "O/N", colnames(tabledirectxl))
# # replace ".g" with "..g" and ".kg" with "..kg"
colnames(tabledirectxl) <- gsub("\\.\\.(g|kg)", ".\\1", colnames(tabledirectxl))

##SAVE

# Save the dataframe to a CSV file
write.csv(tabledirectxl, file = "JardimMesseder_etal_2017_Table1.csv", row.names = FALSE)

# Save the dataframe to a TSV file for online database
write.csv(tabledirectxl, file = "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__Public/comparative-data/10.3389%2Ffnana.2017.00118_Table1.tsv", row.names = FALSE)

## Export colnames to merge terms
# Edit for your existing DATAFRAME and TABLE
# Create a new dataframe with the desired structure
new_dataframe <- data.frame(
  Original_Term = colnames(tabledirectxl),  # Column headers from tabledirectxl
  Reference = rep("JardimMesseder_etal_2017_Table1", ncol(tabledirectxl))  # Reference column
)

# Save the new dataframe to a CSV file
file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/__merging/JardimMesseder_etal_2017_Table1_terms.csv"
write.csv(new_dataframe, file_path, row.names = FALSE)

# Print the new dataframe
print(new_dataframe)

## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./Burish_etal_2010/"

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)
library(stringr)

# Define the PDF file path
pdf_file <- "https://karger.com/bbe/article-pdf/76/1/45/2262181/000319019.pdf"

# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = 3)

## 2. FIX FORMATTING AND SAVE SNAPSHOT
# Convert the matrices into data frames
df1 <- as.data.frame(tables1[[1]])

# Combine the top two rows and set as the header row, adding line break where collapsed
header <- paste0(df1[1, ], "\n", df1[2, ])
# Trim whitespace from the header
header=trimws(header)
# Use the now first row as column names for the first matrix in tables1
colnames(df1) <- header
# Remove the rows that were combined
df1 <- df1[-c(1, 2), ]

# Define the columns to check
columns_to_check <- c("MSC", "LSC", "%NSC", "NSC", "OSC", "DN", "DO", "MBD")

# Identify rows where column "n" > 1
rows_to_replace <- df1$n > 1

# Loop through the specified columns and replace string end with "±" where applicable
df1[rows_to_replace, columns_to_check] <- lapply(df1[rows_to_replace, columns_to_check], function(x) {
  str_replace(x, "8$", "±")
})

# Subset the rows where "Species" column is equal to "Variation"
variation_rows <- df1$Species == "Variation"

# Replace string end with "×" where a string ends with "!" in the subsetted rows across the entire dataframe
df1[variation_rows, ] <- apply(df1[variation_rows, ], 2, function(x) {
  ifelse(str_ends(x, "!"), str_replace(x, "!$", "×"), x)
})

# Save snapshot as a CSV file
write.csv(df1, paste0(folder_path, file = "Burish_etal_2010_Table1_snapshot.csv"), row.names = FALSE)

# 3. Make data readable
result_df <- df1

# Replace "n.a." with NA in the entire dataframe
result_df <- as.data.frame(sapply(result_df, function(x) gsub("n\\.a\\.", NA, x)))

# Delete the row where Species = "Variation"
result_df <- result_df[-which(result_df$Species == "Variation"), , drop = FALSE]

# Reset row names of the data frame to NA
row.names(result_df) <- NULL

# Iterate over column names
for (col in colnames(result_df)) {
  # Check if the column contains strings that end in "±"
  if (any(grepl("±$", result_df[[col]]))) {
    # Create an empty column with the name from the left and "_SD"
    new_col_name <- paste0(col, "_SD")
    result_df[[new_col_name]] <- NA
  }
}

# Iterate over each row except the last one
for (i in 1:(nrow(result_df) - 1)) {
  # Check if any cell in the current row ends with "±"
  if (any(sapply(result_df[i, ], function(cell) grepl("±$", cell)))) {
    # Get the column names ending in "±" in the current row
    cols_with_pm <- colnames(result_df)[sapply(result_df[i, ], function(cell) grepl("±$", cell))]

    # Iterate over the columns ending in "±" in the current row
    for (col_pm in cols_with_pm) {
      # Get the corresponding "_SD" column name
      col_sd <- paste0(col_pm, "_SD")

      # Copy the value from the row below to the "_SD" column
      result_df[i, col_sd] <- result_df[i + 1, col_pm]

      # # Check if there's already a row with the same prefix plus the suffix "_SD"
      # if (any(grepl(paste0("^", col_pm, "_SD$"), colnames(result_df)))) {
      #   # Get the row index where the "_SD" column exists
      #   row_sd <- which(grepl(paste0("^", col_pm, "_SD$"), colnames(result_df)))
      # 
      #   # Copy the value to the row with the same prefix plus the suffix "_SD"
      #   result_df[row_sd, col_pm] <- result_df[i + 1, col_pm]
      # }
    }
  }
}

# Delete rows where Species is NA
result_df <- result_df[!is.na(result_df$Species), ]

# Replace "±$" with "" in the whole dataframe
result_df[] <- lapply(result_df, function(x) gsub("±$", "", x))

# Delete rows where Species is blank
result_df <- result_df[result_df$Species != "", ]

# Reset row names of the data frame to NA
row.names(result_df) <- NULL

# Get the column names except "Species"
columns_to_convert <- names(result_df)[names(result_df) != "Species"]

# Remove commas from numeric columns
result_df[columns_to_convert] <- lapply(result_df[, columns_to_convert], function(x) gsub(",", "", x))

# Convert selected columns to numeric
result_df[columns_to_convert] <- lapply(result_df[columns_to_convert], as.numeric)

## 4. Correct species name
result_df$Species[result_df$Species == "Otolemur garnetti"] <- "Otolemur garnettii"

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 5. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- result_df

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
library(readxl) 
filecodes <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "./__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)

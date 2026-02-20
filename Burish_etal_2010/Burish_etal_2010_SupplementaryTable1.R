## 1. SOURCE
#downloaded pdf from https://ndownloader.figstatic.com/files/8705821

setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./Burish_etal_2010/"

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)
library(dplyr)

# Define the PDF file path
pdf_file <- paste0("https://ndownloader.figstatic.com/files/8705821")

# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = c(1:4))

## 2. FIX FORMATTING AND SAVE SNAPSHOT
# Convert the matrices into data frames
df1 <- as.data.frame(tables1[[1]])
df2 <- as.data.frame(tables1[[2]])
df3 <- as.data.frame(tables1[[3]])
df4 <- as.data.frame(tables1[[4]])

# Stack dataframes into a new combined data frame
combined_df <- bind_rows(df1, df2, df3, df4)

# Combine the top two rows and set as the header row, adding spaces where collapsed
header <- paste(combined_df[1, ], combined_df[2, ])
# Trim whitespace from the header
header=trimws(header)
# Use the now first row as column names for the first matrix in tables1
colnames(combined_df) <- header
# Remove the rows that were combined
combined_df <- combined_df[-c(1, 2), ]

# Identify rows where Case is "07-" and the row below does not start with "07-"
rows_to_combine <- which(combined_df$Case == "07-" & !startsWith(lead(combined_df$Case), "07-"))

# Loop through the identified rows and combine with the row below
for (i in rows_to_combine) {
  combined_df[i, ] <- paste0(combined_df[i, ], combined_df[i+1, ], sep="")
}

# Remove the rows that were combined
combined_df <- combined_df[-(rows_to_combine + 1), ]

# Reset row names of the data frame to NA
row.names(combined_df) <- NULL

#combine column 1 in rows 8 and 9 then delete row 9
combined_df[9, 1] <- paste(combined_df[8, 1], combined_df[9, 1], sep=" ")
combined_df <- combined_df[-c(8), ]

# Save snapshot as a CSV file
write.csv(combined_df, paste0(folder_path, file = "Burish_etal_2010_SupplementaryTable1_snapshot.csv"), row.names = FALSE)

# 3. Make data readable

cleaned_df <- combined_df

# Find rows where all strings are ""
all_empty_rows <- rowSums(cleaned_df == "") == ncol(cleaned_df)

# Subset the dataframe to exclude rows where all strings are ""
cleaned_df <- cleaned_df[!all_empty_rows, , drop = FALSE]

# Reset row numbers in translating_time_dataset
rownames(cleaned_df) <- NULL

# Define the columns to convert to numeric
columns_to_convert <- c(3:9, 11)

# Loop through the columns and convert them to numeric
for (col in columns_to_convert) {
  cleaned_df[[col]] <- as.numeric(cleaned_df[[col]])
}


# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. Species Update

## 5. SAVE

# Finalize dataframe (UPDATE!!!)
final.dataframe <- cleaned_df

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


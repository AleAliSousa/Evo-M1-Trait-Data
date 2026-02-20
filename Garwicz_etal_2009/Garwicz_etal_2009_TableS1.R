## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./Garwicz_etal_2009/"

# Load the tabulizer library and rJava
library(rJava)
library(tabulapdf) #newer package that works 16/10/2024
library(tabulizerjars)
library(dplyr)
library(tidyr)
library(stringr)


# Define the PDF file path
pdf_file <- paste0(folder_path,"0905777106si.pdf")
# Use extract_tables to get all tables on the specified page
tables2 <- extract_tables(pdf_file,pages = c(5,6))

# Convert the matrix into a dataframe
df1 <- as.data.frame(tables2[[2]])
df2 <- as.data.frame(tables2[[1]])


## 2. FIX FORMATTING AND SAVE SNAPSHOT

## A. Table S1
# Save the current column names
current_colnames <- colnames(df2)

# Insert the column names as the first row
df2 <- rbind(current_colnames, df2)

# Change the first four column names
colnames(df2)[1:4] <- c("Lay term", "Order/suborder", "Family", "Genus/species")

## B. Table S2
# Rename the column "PC" to "WO, days_PC"
df1 <- df1 %>%
  rename(`WO, days_PC` = PC) %>%
 rename(`WO, days_PN` = PN)

# Save snapshot to a CSV file 
write.csv(df1, file = paste0(folder_path,"Garwicz_etal_2009_TableS2_snapshot.csv"), row.names = FALSE)
write.csv(df2, file = paste0(folder_path,"Garwicz_etal_2009_TableS1_snapshot.csv"), row.names = FALSE)

## 3. MAKE DATA READABLE

## Merge tables and df2 on 
# Rename the species common names columns to a common name
colnames(df2)[colnames(df2) == "Lay term"] <- "Common name"
colnames(df1)[colnames(df1) == "Species (lay term)"] <- "Common name"

# Merge df1 and the "Genus/species" column from df2
tog <- merge(df1, df2[, c("Common name", "Genus/species")], by = "Common name", all.x = TRUE)


# Improve column names by spelling out all abbreviations
tog <- tog %>%
  rename(
    `Absolute Brain Mass (g)` = `AbsBrM, g`,
    `Neonatal Brain Mass (g)` = `NeoBrM (1), g`,
    `Body Mass (g)` = `BoM, g`,
    `Gestation (days)` = `Gest., days`,
    `Walking onset (Postnatal days)`  = `WO, days_PN`,
    `Walking onset (Postconception days)` = `WO, days_PC`,
    `Precocial/Altricial` = `Pre/Alt`,
    `Hindlimb Standing Position` = `HSP`,
    Species = `Genus/species`
  ) %>%
  select(Species, everything())

# Split out the references from the values in strings
# Function to separate values and references
separate_ref <- function(df, col) {
  df %>%
    mutate(
      !!sym(paste0(col, " Ref")) := str_extract(!!sym(col), "\\(([^)]+)\\)"),
      !!sym(col) := str_remove(!!sym(col), " \\([^)]*\\)")
    )
}

# Apply the function to the specified columns
tog <- tog %>%
  separate_ref("Absolute Brain Mass (g)") %>%
  separate_ref("Body Mass (g)") %>%
  separate_ref("Gestation (days)") %>%
  separate_ref("Walking onset (Postnatal days)")

# Replace "—" with NA in the specified column
tog$`Neonatal Brain Mass (g)` <- ifelse(tog$`Neonatal Brain Mass (g)` == "—", NA, tog$`Neonatal Brain Mass (g)`)

# Loop through columns and remove commas in numbers
for (col in 3:8) {
  tog[[col]] <- gsub(",", "", tog[[col]])
}
# Convert specified columns to numeric
tog[, 3:8] <- lapply(tog[, 3:8], as.numeric)


# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)


## 5. SAVE
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tog

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

# Table 1

## 1. Read direct from xl
library(readxl)
tabledirectxl <- read_excel("caspar_etal_2022_table1_primary_or_equivalent.xlsx")

## 2. Table name / header removal

# Delete the current header and the following three rows
tabledirectxl <- tabledirectxl[-c(1:3), ]

# Set the next row as the new header
colnames(tabledirectxl) <- as.character(unlist(tabledirectxl[1, ]))

# Remove the first row since it's now the header
tabledirectxl <- tabledirectxl[-1, ]

## 3. Where there were merged cells, copy value into all cells included in the merger

# Load the 'zoo' package
library(zoo)

# Fill empty cells with values from the row above
# The na.locf() function in R stands for "Last Observation Carried Forward." (It can be done for the whole dataframe or for specific columns.)
tabledirectxl[c("nGenus", "Genus direction bias (HI), p value", "Genus L/R/A distribution, p value")] <- na.locf(tabledirectxl[c("nGenus", "Genus direction bias (HI), p value", "Genus L/R/A distribution, p value")])

# Note: "Genus direction bias (HI), p value" for "Pithecia pithecia" is a genuine "NA" and was not changed

## 4. Split 3 columns containing both frequency (#) and percentage (%) into 6 different columns.

# Load the 'tidyr' package
library(tidyr)

# Modify all occurrences of "0" in the "# Ambipreferent (%)" column to "0(0)"
tabledirectxl$`# Ambipreferent (%)` <- gsub("^0$", "0 (0)", tabledirectxl$`# Ambipreferent (%)`, perl = TRUE)

# Define the columns to split and their corresponding new column names
cols_to_split <- c("# Left (%)", "# Right (%)", "# Ambipreferent (%)")
new_col_names <- c("# Left", "Left %", "# Right", "Right %", "# Ambipreferent", "Ambipreferent %")

# Loop through the columns and split each one
for (i in seq_along(cols_to_split)) {
  tabledirectxl <- separate(
    tabledirectxl,
    col = cols_to_split[i],  # Specify the column to split
    into = c(new_col_names[i * 2 - 1], paste0(new_col_names[i * 2 - 1], " %")),  # New column names with space before %
    sep = " \\(|\\)",  # Specify the separator as a regular expression to split on ' (' and ')'
    extra = "drop"  # Drop any extra pieces
  )
}

## 5. Species note 
# paper indicates the Gorilla gorilla is Western gorilla.
# Add a new column "Species note" and set the value for "Gorilla gorilla"
tabledirectxl$`Species note` <- NA  # Create a new column with NAs
tabledirectxl[tabledirectxl$Species == "Gorilla gorilla", "Species note"] <- "Western gorilla"

## 6. Correct signs and make numerical data usable
# Replace non-standard minus signs with standard minus sign character
tabledirectxl$MeanHI <- gsub("–", "-", tabledirectxl$MeanHI)

# Convert individual columns to numeric
tabledirectxl$N <- as.numeric(tabledirectxl$N)
tabledirectxl$`# Left` <- as.numeric(tabledirectxl$`# Left`)
tabledirectxl$`# Left %` <- as.numeric(tabledirectxl$`# Left %`)
tabledirectxl$`# Right` <- as.numeric(tabledirectxl$`# Right`)
tabledirectxl$`# Right %` <- as.numeric(tabledirectxl$`# Right %`)
tabledirectxl$`# Ambipreferent` <- as.numeric(tabledirectxl$`# Ambipreferent`)
tabledirectxl$`# Ambipreferent %` <- as.numeric(tabledirectxl$`# Ambipreferent %`)
tabledirectxl$MeanHI <- as.numeric(tabledirectxl$MeanHI)
tabledirectxl$MeanAbsHI <- as.numeric(tabledirectxl$MeanAbsHI)
tabledirectxl$nGenus <- as.numeric(tabledirectxl$nGenus)

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 7. Save as csv

# Save the dataframe to a CSV file
write.csv(tabledirectxl, file = "caspar_etal_2022_table1.csv", row.names = FALSE)

## 8. Save as tsv with DOI file name

# Save the dataframe to a TSV file
write.csv(tabledirectxl, file = "10.7554%2FeLife.77875_table1.tsv", row.names = FALSE)


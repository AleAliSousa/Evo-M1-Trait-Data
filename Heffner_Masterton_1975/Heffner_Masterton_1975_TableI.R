setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/Heffner_Masterton_1975")

## 1. Read from xl
library(readxl)
tabledirectxl <- read_excel("Heffner_Masterton_1975_TableI_primary_or_equivalent.xlsx")

## 2. Make column headings readable

# Rename columns 1-16
colnames(tabledirectxl)[1:17] <- c(
  "Animal",
  "Species",
  "Digital dexterity",
  "Body weight kg",
  "Number of fibers per tract",
  "Number of fibers per tract ref",
  "Largest fiber diameter µm",
  "Largest fiber diameter µm ref",
  "Average fiber size x 10ˆ5 K",
  "Area of tract mmˆ2",
  "Area of tract mmˆ2 ref",
  "Penetration down spinal cord",
  "Penetration down spinal cord ref",
  "Lamina of axon terminals deepest",
  "Lamina of axon terminals deepest ref",
  "Lamina of axon terminals densest",
  "Lamina of axon terminals densest ref"
)

## 3. Compile data into row per species and remove empty rows 

# Remove rows where the "Animal" value starts with "Table I", "Animal", or numbers in the range of 160-179. 
tabledirectxl <- tabledirectxl[!(grepl("^Table I|^Animal|^16[0-9]|^17[0-9]", tabledirectxl$Animal)), ]

# Use single square bracket subsetting with the apply function to remove rows that contain the specific text "deepest" in the column "Lamina of axon terminals deepest".
tabledirectxl <- tabledirectxl[apply(tabledirectxl, 1, function(row) !("deepest" %in% row["Lamina of axon terminals deepest"])), ]

# Split rows into two dataframes then merge them
# Make two dataframes from one
oddrows <- tabledirectxl[seq(1, nrow(tabledirectxl), by = 2), ]
evenrows <- tabledirectxl[seq(2, nrow(tabledirectxl), by = 2), ]

# Create merged_df with data from oddrows
merged_df <- oddrows

# Convert columns to numerical values
merged_df$`Digital dexterity` <- as.numeric(merged_df$`Digital dexterity`)
merged_df$`Body weight kg` <- as.numeric(merged_df$`Body weight kg`)
merged_df$`Number of fibers per tract` <- as.numeric(merged_df$`Number of fibers per tract`)
merged_df$`Largest fiber diameter µm` <- as.numeric(merged_df$`Largest fiber diameter µm`)
merged_df$`Average fiber size x 10ˆ5 K` <- as.numeric(merged_df$`Average fiber size x 10ˆ5 K`)
merged_df$`Area of tract mmˆ2` <- as.numeric(merged_df$`Area of tract mmˆ2`)
merged_df$`Area of tract mmˆ2 ref` <- as.numeric(merged_df$`Area of tract mmˆ2 ref`)
merged_df$`Lamina of axon terminals deepest` <- as.numeric(merged_df$`Lamina of axon terminals deepest`)
merged_df$`Lamina of axon terminals densest` <- as.numeric(merged_df$`Lamina of axon terminals densest`)

# Replace columns in merged_df with the corresponding column from evenrows
merged_df[["Species"]] <- evenrows[["Species"]]
merged_df[["Number of fibers per tract ref"]] <- evenrows[["Number of fibers per tract ref"]]
merged_df[["Largest fiber diameter µm ref"]] <- evenrows[["Largest fiber diameter µm ref"]]
merged_df[["Penetration down spinal cord ref"]] <- evenrows[["Penetration down spinal cord ref"]]
merged_df[["Lamina of axon terminals deepest ref"]] <- evenrows[["Lamina of axon terminals deepest ref"]]
merged_df[["Lamina of axon terminals densest ref"]] <- evenrows[["Lamina of axon terminals densest ref"]]

# Delete rows where the header column is empty or NA
merged_df <- merged_df[!is.na(merged_df$Animal), ]

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 4. Save as csv

# Save the data frame to a CSV file
write.csv(merged_df, file = "Heffner_Masterton_1975_TableI.csv", row.names = FALSE)

## 5. Save as tsv with DOI file name

# Save the data frame to a TSV file
write.csv(merged_df, file = "10.1159%2F000124401_tableI.tsv", row.names = FALSE)

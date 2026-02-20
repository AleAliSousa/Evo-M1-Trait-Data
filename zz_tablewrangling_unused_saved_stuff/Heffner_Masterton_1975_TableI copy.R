# Table I (across several pages of pdf)

setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Heffner_Masterton_1975")

# This extracts most of the table, but the Loxodota africana row at the end is missing!
# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "Heffner-1975-Variation in form of the pyramida.pdf"
  
# Use extract_tables to get all tables on the specified page
#tablessome <- extract_tables(pdf_file, pages = c(4:14))
tablessome <- extract_tables(pdf_file)
tablessome

# Convert the matrices into data frames
df1 <- as.data.frame(tablessome[[1]])
df2 <- as.data.frame(tablessome[[2]])
df3 <- as.data.frame(tablessome[[3]])
df4 <- as.data.frame(tablessome[[4]])
df5 <- as.data.frame(tablessome[[5]])
df6 <- as.data.frame(tablessome[[6]])
df7 <- as.data.frame(tablessome[[7]])
df8 <- as.data.frame(tablessome[[8]])
df9 <- as.data.frame(tablessome[[9]])
df10 <- as.data.frame(tablessome[[10]])

# Find and delete empty columns
empty_columns <- which(sapply(df1, function(col) all(col == "")))
new_df1 <- df1[, -empty_columns]

# Combine the top four rows and set as the header row, adding spaces where collapsed
header <- apply(new_df1[1:4, ], 2, function(x) paste(x, collapse = " "))

# Create a new dataframe with the combined header and the remaining rows
new_df1 <- new_df1[-(1:4), ]
colnames(new_df1) <- header  # Set the combined text as column names

# Reset the row names starting from 1
rownames(new_df1) <- 1:nrow(new_df1)

# Extract meaningful species names and remove trailing spaces
new_df1 <- setNames(new_df1, gsub("\\s+$", "", names(new_df1)))

# Duplicate the "Animal" column and rename it as "Species"
new_df1$Species <- NA

# Reorder the columns with "Species" as the first column
new_df1 <- new_df1[, c("Species", setdiff(names(new_df1), "Species"))]

# Move the values and delete from new_df1$Animal
new_df1$Species[c(1, 4, 7)] <- new_df1$Animal[c(2, 5, 8)]



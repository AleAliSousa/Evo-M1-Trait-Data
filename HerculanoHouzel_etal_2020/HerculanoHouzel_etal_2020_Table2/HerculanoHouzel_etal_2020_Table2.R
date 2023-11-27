## 1. SOURCE
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/HerculanoHouzel_etal_2020/HerculanoHouzel_etal_2020_Table2")

# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/HerculanoHouzel_etal_2020/Herculano-Houze-2020-Microchiropterans have a.pdf"
# Use extract_tables to get all tables on the specified page
tables1 <- extract_tables(pdf_file,pages = c(4))

# Convert the matrix into a dataframe
df1 <- as.data.frame(tables1[[1]])

# Set the first row as the header
colnames(df1) <- df1[1,]

# Remove the first row (which is now the header)
df1 <- df1[-1,]

# Renumber the rows
rownames(df1) <- NULL

# Save the data frame to a "primary or equivalent" to a CSV file
write.csv(df1, file = "HerculanoHouzel_etal_2020_Table2_primary_or_equivalent.csv", row.names = FALSE)

# Loop through columns and remove commas in numbers
columns_to_clean <- c("NCX","NCB","NRoB","DN,CX","DN,Cb","DN,RoB")
for (col in columns_to_clean) {
  df1[[col]] <- gsub(",", "", df1[[col]])
}

# Convert specified columns to numeric
columns_to_convert <- c("NCX","NCB","NRoB","DN,CX","DN,Cb","DN,RoB")
df1[, columns_to_convert] <- lapply(df1[, columns_to_convert], as.numeric)

# Save the data frame to a CSV file
write.csv(df1, file = "HerculanoHouzel_etal_2020_Table2.csv", row.names = FALSE)

# Save the data frame to a TSV file for online database
write.csv(df1, file = "10.1002%2Fcne.24985_table2.tsv", row.names = FALSE)
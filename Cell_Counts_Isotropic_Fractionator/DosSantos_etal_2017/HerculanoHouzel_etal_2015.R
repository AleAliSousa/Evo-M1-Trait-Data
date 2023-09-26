# Original file:
# Suzana Herculano-Houzel, Kenneth Catania, Paul R. Manger, Jon H. Kaas; Mammalian Brains Are Made of These: A Dataset of the Numbers and Densities of Neuronal and Nonneuronal Cells in the Brain of Glires, Primates, Scandentia, Eulipotyphlans, Afrotherians and Artiodactyls, and Their Relationship with Body Mass. Brain Behav Evol 1 December 2015; 86 (3-4): 145–163. 
# https://doi.org/10.1159/000437413
# embedded in main paper


# 1. "Downloaded all" from figshare link:
# https://figshare.com/articles/journal_contribution/Supplementary_Material_for_Cellular_Scaling_Rules_for_the_Brains_of_Marsupials_Not_as_Primitive_as_Expected/4588471?file=7428211
# 2. Unzip zipped file 4588471.zip (double click it)
# 3. Open 4588471/452856_sm10.doc in MS Word (double click it)
# 4. Save as Plain Text (.txt)

## PART ONE: READ FILE
# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/Cell_Counts_Isotropic_Fractionator/HerculanoHouzel_etal_2015")
#Load pdftools
library(pdftools)

###FROM :
https://www.youtube.com/watch?v=bJH-S2iaxNo
# Read the pdf version 
sheetfromtxt <- pdf_text("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")


#Load pdftools
library(pdftools)
library(tidyverse)
library(ggplot2)
# Read the pdf version 
# download and load to- online alternative
url <- c("https://karger.com/bbe/article-pdf/86/3-4/145/2264694/000437413.pdf")
raw_text <- map(url,pdf_text)

#function to scrape data and clean
clean_table1 <- function(raw) {
  
  # Split the single pages
  raw <- map(raw, ~ str_split(.x, "\\n") %>% unlist ())
  # Concatenate the split pages
  raw <- reduce(raw, c)
  
  # specify the starts and end of the table data #must use unique terms
  table_start <- stringr::str_which(tolower(raw), "Table 1. Cerebral cortex")
  table_end <- stringr::str_which(tolower(raw), "All values refer to the sum of gray matter")
  table_end <- table_end[min(which(table_end > table_start))]
  
  #Build the table and remove specal characters
  table <- raw[(table_start):(table_end)]
  table <- str_replace_all(table, "\\s{2,}", "|")
  text_con <- textConnection(table)
  data_table <- read.csv(text_con, sep = "|")

  #Create a list of column names
  colnames(data_table) <- c("Species", "Order", "Mass,g", "N,n", "O,n", "N/mg", "O/mg", "O/N", "Source") #
  data_table
}
results <-map_df(raw_text, clean_table1)
head(results)



install.packages("tabulizer")

# Load the tabulizer library
library(tabulizer)

# Define the PDF file path
pdf_file <- "Herculano-Houze-2015-Mammalian Brains Are Made.pdf"

# Extract the table using tabulizer
extracted_tables <- extract_tables(pdf_file, pages = 1)

# Find the table that matches the header "Table 1. Cerebral cortex"
table_index <- which(sapply(extracted_tables, function(table) table[1, 1]) == "Table 1. Cerebral cortex")

# Extract the table data
table_data <- extracted_tables[[table_index]]

# Convert the table data to a data frame
table_df <- as.data.frame(table_data, stringsAsFactors = FALSE)

# Set the column names based on your specified headers
colnames(table_df) <- c("Species", "Order", "Mass, g", "N, n", "O, n", "N/mg", "O/mg", "O/N", "Source")

# Remove the header row from the data frame
table_df <- table_df[-1, ]

# Print the resulting data frame
print(table_df)

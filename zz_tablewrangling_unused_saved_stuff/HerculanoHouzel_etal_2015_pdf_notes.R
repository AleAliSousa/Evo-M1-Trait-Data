# Original file:
# Suzana Herculano-Houzel, Kenneth Catania, Paul R. Manger, Jon H. Kaas; Mammalian Brains Are Made of These: A Dataset of the Numbers and Densities of Neuronal and Nonneuronal Cells in the Brain of Glires, Primates, Scandentia, Eulipotyphlans, Afrotherians and Artiodactyls, and Their Relationship with Body Mass. Brain Behav Evol 1 December 2015; 86 (3-4): 145–163. 
# https://doi.org/10.1159/000437413
# embedded in main paper

# 

## PART ONE: READ FILE
# Set Working Directory. Store with the spreadsheet.
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Cell_Counts_Isotropic_Fractionator/HerculanoHouzel_etal_2015")



############### IS READING PDF FROM ONLINE DIFFERENT? START #####################
# online alternative
"https://karger.com/bbe/article-pdf/86/3-4/145/2264694/000437413.pdf"

# This extracts all the page text from tabulizer, but it is formatted horribly with line breaks throughout
# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)

# Define the PDF file path
pdf_file <- "https://karger.com/bbe/article-pdf/86/3-4/145/2264694/000437413.pdf"

# Use extract_words to get all the words on page 5
page_text <- extract_text(pdf_file, pages = 5)

# Print the words
cat(page_text)

# This extracts most of the table, but the Loxodota africana row at the end is missing!
# Load the tabulizer library and rJava
library(rJava)
library(tabulizer)
library(tabulizerjars)

# Define the PDF file path
pdf_file <- "https://karger.com/bbe/article-pdf/86/3-4/145/2264694/000437413.pdf"

# Use extract_tables to get all tables on the specified page
tables <- extract_tables(pdf_file, pages = 5)

# Assuming the table of interest is the first one, access it
table_df <- tables[[1]]

# Specify the column names manually
colnames(table_df) <- c("Species", "Order", "Mass, g", "N, n", "O, n", "N/mg", "O/mg", "O/N", "Source")

# Now, you have the table in 'table_df' with the specified column names
table_df

## Try different methods to extract tables in tabulizer

############### IS READING PDF FROM ONLINE DIFFERENT? END #####################
# Use extract_tables to get all tables on the specified page
tables5 <- extract_tables(pdf_file, pages = 5)
tables5



# Use extract_tables to get all tables on the specified page
tablesdecide <- extract_tables(pdf_file, pages = 5, method = "decide")
tablesdecide

# Use extract_tables to get all tables on the specified page
tableslattice <- extract_tables(pdf_file, pages = 5, method = "lattice")
tableslattice

# Use extract_tables to get all tables on the specified page
tablesstream <- extract_tables(pdf_file, pages = 5, method = "stream")
tablesstream

# Use extract_tables to get all tables on the specified page
tablesall <- extract_tables(pdf_file, method = "decide")
tablesall


# Use extract_tables to get all tables on the specified page
tablessome <- extract_tables(pdf_file, pages = c(5:8))
tablessome

############### TABULIZER START #####################
# TABULIZER is an old package that is not available from CRAN. 
# See https://stackoverflow.com/questions/70036429/having-issues-installing-tabulizer-package-in-r

# NEED JAVA, MAYBE OLD VERSION
# Note that tabulizer depends on rJava, which may require some setup.
# See https://stackoverflow.com/questions/67849830/how-to-install-rjava-package-in-mac-with-m1-architecture
# Install the latest stable version of R from CRAN (tested on 4.3.1 (2023-06-16))
# Install a x86_64 build of Java (version 17 - it does not seem to work with versions 8 or 11) with brew tap homebrew/cask-versions && brew install --cask temurin17
# Add it to PATH with export JAVA_HOME=$(/usr/libexec/java_home -v 17)
# run sudo -E R CMD javareconf
install.packages("rJava")

#You have to install tabulizer from github using devtools
install.packages("devtools")
library(devtools)
devtools::install_github("ropensci/tabulizer") 

# # This extracts all the page text from tabulizer, but it is formatted horribly with line breaks throughout 
# # Load the tabulizer library and rJava
# library(rJava)
# library(tabulizer)
# 
# # Define the PDF file path
# pdf_file <- "Herculano-Houze-2015-Mammalian Brains Are Made.pdf"
# 
# # Use extract_words to get all the words on page 5
# page_text <- extract_text(pdf_file, pages = 5)
# 
# # Print the words
# cat(page_text)

# # This extracts most of the table, but the Loxodota africana row at the end is missing!
# # Load the tabulizer library and rJava
# library(rJava)
# library(tabulizer)
# library(tabulizerjars)
# 
# # Define the PDF file path
# pdf_file <- "Herculano-Houze-2015-Mammalian Brains Are Made.pdf"
# 
# # Use extract_tables to get all tables on the specified page
# tables <- extract_tables(pdf_file, pages = 5)
# 
# # Assuming the table of interest is the first one, access it
# table_df <- tables[[1]]
# 
# # Specify the column names manually
# colnames(table_df) <- c("Species", "Order", "Mass, g", "N, n", "O, n", "N/mg", "O/mg", "O/N", "Source")
# 
# # Now, you have the table in 'table_df' with the specified column names
# table_df

library(tabulizer)
tablesW <- extract_tables("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")
tablesW

# This extracts most of the table, but the Loxodota africana row at the end is missing! Still! 
library(tabulizer)

# Define the PDF file path
pdf_file <- "Herculano-Houze-2015-Mammalian Brains Are Made.pdf"

# Use extract_tables to get all tables on the specified page range (covers the entire table)
tables <- extract_tables(pdf_file, pages = 5:6)

# Assuming the table of interest is on the first page, access it
table_df <- tables[[1]]

# Specify the column names manually
colnames(table_df) <- c("Species", "Order", "Mass, g", "N, n", "O, n", "N/mg", "O/mg", "O/N", "Source")

# Now, you should have all rows including row 40 in 'table_df' with the specified column names
table_df

# You can search for the row with "Loxodonta africana" in the "Species" column
desired_row <- table_df[table_df$Species == "Loxodonta africana", ]
# View
table_df
############### TABULIZER END #####################
############### TABULIZER HARD START #####################

# load pdf
pdf_file <- "Herculano-Houze-2015-Mammalian Brains Are Made.pdf"
# find out page dimensions
get_page_dims(pdf_file)
# Now that we have the dimensions for each page we can specify a rectangular region as a vector containing the top, left, bottom and right coordinates of the rectangle:
region <- c(250, 0, 450, 595.276)
# 
mat <- extract_tables(
  file = pdf_file, 
  pages = 5, 
  guess = FALSE,
  area = list(region)
)[[1]]


# look at the PDF directly
library(shiny)
library(miniUI)
extract_areas("Herculano-Houze-2015-Mammalian Brains Are Made.pdf", pages = 5)

table1 <- extract_tables(pdf_file, pages = 5)
table1
############### TABULIZER HARD END #####################
############### PDFTOOLS W/ TABULIZER START #####################
############### PDFTOOLS W/ TABULIZER END #####################

############### TABULIZER TUTORIAL START #####################
# check tabulizer is working with example data https://blog.djnavarro.net/posts/2023-06-16_tabulizer/

library(tabulizer)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)
library(janitor)

pdf_data <- system.file("examples", "data.pdf", package = "tabulizer")

pdf_tables <- pdf_data |> 
  extract_tables(output = "data.frame") |>
  map(as_tibble)

pdf_tables
############### TABULIZER TUTORIAL END #####################
############### TABULIZER OTHER TUTORIAL START #####################
# https://www.r-bloggers.com/2019/09/pdf-scraping-in-r-with-tabulizer/
# PDF Scrape Tables
endangered_species_scrape <- extract_tables(
  file   = "Herculano-Houze-2015-Mammalian Brains Are Made.pdf", 
  method = "decide",
  output = "data.frame")
############### TABULIZER OTHER TUTORIAL END #####################

############### PDFTOOLS TUTORIAL START #####################
#Load pdftools
library(pdftools)
library(tidyverse)
library(ggplot2)
# Read the pdf version 
# download and load to- online alternative
url <- c("http://www.cicad.oas.org/oid/pubs/JamaicaNationalHouseholdDrugSurvey2017ENG.pdf")
raw_text <- map(url,pdf_text)

#function to scrape data and clean
clean_table1 <- function(raw) {
  
  # Split the single pages
  raw <- map(raw, ~ str_split(.x, "\\n") %>% unlist ())
  # Concatenate the split pages
  raw <- reduce(raw, c)
  
  # specify the start and end of the table data #must use unique terms
  table_start <- stringr::str_which(tolower(raw), "alcohol use pattern")
  table_end <- stringr::str_which(tolower(raw), "never used")
  table_end <- table_end[min(which(table_end > table_start))]
  
  #Build the table and remove special characters
  table <- raw[(table_start):(table_end)]
  table <- str_replace_all(table, "\\s{2,}", "|")
  text_con <- textConnection(table)
  data_table <- read.csv(text_con, sep = "|")
  
  #Create a list of column names
  colnames(data_table) <- c("x", "Alcohol Use Pattern", "Males", "Females", "Total") #
  data_table
}
results <-map_df(raw_text, clean_table1)
head(results)
############### PDFTOOLS TUTORIAL END #####################

############### PDFTOOLS AND READR START  #####################
library(pdftools)
library(tidyverse)
library(ggplot2)

# Read the pdf  
sheetfrompdf <- pdf_text("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")
# # first page
# cat(sheetfrompdf[1])
# fifth page
cat(sheetfrompdf[5])
table1=cat(sheetfrompdf[5])
# table1=pdf_data(sheetfrompdf)[[5]]

#import directly from pdf
table1=pdf_data("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")[[5]]
table1

#import directly from pdf as text
txt=pdf_text("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")[[5]]
txt

#Load readr
library(readr)
# Read the text version 
sheetfromtxt <- read_delim(txt, 
                           delim = "\t", escape_double = FALSE, 
                           trim_ws = TRUE, skip = 1, col_names = TRUE, col_select = c("Species", "Order", "Mass, g", "N, n", "O, n", "N/mg", "O/mg", "O/N", "Source"))
View(sheetfromtxt)
############### PDFTOOLS AND READR  END #####################

############### PDFTOOLS AND OTHER STUFF START #####################
library(pdftools)
library(stringr)
library(xlsx)

tx <- pdf_text("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")
tx2 <- unlist(str_split(tx, "[\\r\\n]+"))
tx3 <- str_split_fixed(str_trim(tx2), "\\s{2,}", 5)

write.xlsx(tx3, file="ds.xlsx")


library(pdftools)
tx<-pdf_text("Herculano-Houze-2015-Mammalian Brains Are Made.pdf")

library(xlsx)
write.xlsx(tx,file="ds.xlsx")

############### PDFTOOLS AND OTHER STUFF END #####################
############### GIVE UP AND TRY THE XLSX START #####################
library(readxl)
test_Herculano_Houze_2015_Mammalian_Brains_Are_Made <- read_excel("test_Herculano-Houze-2015-Mammalian Brains Are Made.xlsx", range = "d18:aj58")
test_Herculano_Houze_2015_Mammalian_Brains_Are_Made
############### GIVE UP AND TRY THE XLSX END #####################

############### READ WEBPAGE START #####################
# Install and load the 'magick' package for image processing
install.packages("magick")
library(magick)

# Define the URL of the GIF image containing the table

#url <- "https://karger.silverchair-cdn.com/karger/content_public/journal/bbe/86/3-4/10.1159_000437413/2/000437413_t01.gif?Expires=1699046401&Signature=WsQFtFW1DaJVmzuSAcvwkzieDtGuEl7yIn~BVABYm0SF89UwfVTlyGVutIyrI5L~Loem0bEoOqR8jLbZHrby~GXtoDaQv2P96hZjFlSIKaYT7WSHzkO5UL8aeOQ~ceV2A2NFNPqS5zI0Vsmd0~NfcFGpRQ9ClDixHgjfaqIWKQ0Zp6ydwhDan-EUnV~6M5blABhDzR739H23uNq5H5oXh3a2~TFFNlz0Hn-rE-offnpr7wMhTnlXeP4PXmJCBbOnsKV5SzlchvrpyV3hw6oexVk~CmVoCjiAo6DYGKNv1BROISdbGRmN9dgCp7ywTkQnBvBuZbHFAsZhpCR2RS-J0w__&Key-Pair-Id=APKAIE5G5CRDK6RD3PGA"
#url <- "https://karger.com/bbe/article/86/3-4/145/47190/Mammalian-Brains-Are-Made-of-These-A-Dataset-of"
url <- "https://doi.org/10.1159/000437413"
#url <- "https://karger.com/bbe/article-pdf/86/3-4/145/2264694/000437413.pdf"
#url <- "https://sites.google.com/a/bathspa.ac.uk/brain-behaviour-seminars/archive/2021-2022"
#url <- "https://karger.com/view-large/figure/6949511/000437413_T01.gif"

webpage <-read_html(url)

# Select the table using CSS selector
table_node <- html_nodes(webpage, "table")

# Extract the table content
table_content <- html_table(table_node)[[2]]

# Print the table
head(table_content)

# Download the GIF image to a local file
download.file(url, destfile = "sample-table.gif", mode = "wb")

# Read the GIF image
image <- image_read("sample-table.gif")

# Extract the frames from the GIF (if it's an animated GIF)
frames <- image_data(image)

# Assuming the table is in the first frame, convert it to a data frame
table_df <- as.data.frame(frames[[1]])

# Now 'table_df' should contain the table data as a data frame
# You may need to clean and manipulate the data further as needed

# Print the data frame
print(table_df)

############### READ WEBPAGE END #####################

## READ FILE
# Set Working Directory. Store with the spreadsheet.

setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo M1 Trait Data/merging")
install.packages("rhandsontable")
install.packages("htmlwidgets")

library(rhandsontable)
library(htmlwidgets)

# Load the CSV into a data frame
term_key <- read.csv("cellcountsterms.csv", stringsAsFactors = FALSE)

# Create an interactive table
table_widget <- rhandsontable(term_key)

# Display the interactive table
table_widget

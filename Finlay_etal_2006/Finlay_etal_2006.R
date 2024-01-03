## 1. Read direct from xl
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Finlay_etal_2006")

library(readxl)
tablefromxl <- read_excel("Finlay_etal_2006_primary_or_equivalent.xlsx", col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

# Create a new data frame with "Species" as the first column copied from Species Name #double square brackets to prevent converting spaces
tablefromxl$Species <- tablefromxl[["Species Name"]]

# rename row names with typos 
tablefromxl$Species <- gsub("Felis cattus", "Felis catus", tablefromxl$Species)
tablefromxl$Species <- gsub("Echinops telfairi", "Echinops telfari", tablefromxl$Species)

# # rename row names based on text, refs, also see Kaskan et al 2005, Changizi 2001
# tablefromxl$Species <- gsub("Mouse sp.", "Mus sp.", tablefromxl$Species)
# # Changizi 2011 cites Krubitzer 1995 which only mentions Sciurus carolinensis
# tablefromxl$Species <- gsub("Squirrel sp.", "Squirrel check species", tablefromxl$Species)

## Save as csv

# Save the tabledirectxl data frame to a CSV file
write.csv(tablefromxl, file = "finlay_etal_2022_table6.1.csv", row.names = FALSE)






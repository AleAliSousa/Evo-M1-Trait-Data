# 1. Data comes from Fig 3 caption and was not tabulated, so a table was created, Changizi_2001_fig3.csv
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Changizi_2001")

# open file and read last two columns as numeric
figdata <- read.csv("Changizi_2001_fig3_primary_or_equivalent.csv", check.names = FALSE)


# 2. Make data readable
# Add unlogged data

#make numerical
figdata[, 2:3] <- lapply(figdata[, 2:3], as.numeric)

# Unlogged values of columns 2 and 3 which are log-transformed
figdata[, 4] <- 10^figdata[, 2]  # Add a new column with unlogged values of column 2
figdata[, 5] <- 10^figdata[, 3]  # Add a new column with unlogged values of column 3

# Rename columns 4 and 5 to match the headings of columns 2 and 3 without "log"
colnames(figdata)[4:5] <- sub("log ", "", colnames(figdata)[2:3])

# Remove all digits after the decimal point in columns 4 and 5 #these are not maningful since they were produced by logging
figdata[, 4:5] <- lapply(figdata[, 4:5], function(x) trunc(x))

## 3. Save as csv

# Save the tabledirectxl data frame to a CSV file
write.csv(figdata, "changizi_2001_fig3.csv", row.names = FALSE)



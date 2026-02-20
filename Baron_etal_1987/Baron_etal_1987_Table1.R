setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Baron_etal_1987")

## Tasks
# - [ ] Read from csv
# - [ ] Arrange headers as clade column
# - [ ] Separate columns for values and notes
# - [ ] Make numeric
# - [ ] Save

## Load packages
library(tidyverse)

## Read file
tabledirectxl <- read.csv("baron_etal_1987.csv",
                          check.names = FALSE)

## 0. Reverse engineer to create a snapshot while extracting Key columns 
## Header is key for the first row, save it at as that in a dataframe and save as csv

## 0.1 Save key then Replace header with Row 1
## 0.1.1 Save anatomy key from header and 1st row
Baron87_structures <- tabledirectxl[1, 4:ncol(tabledirectxl)]
write.csv(
  Baron87_structures,
  file = "Baron87_structures.csv",
  row.names = FALSE,
  na = ""
)
## 0.1.2 Replace header with Row 1
tabledirectxl_rev1 <- tabledirectxl %>%
  setNames(as.character(tabledirectxl[1, ])) %>%  # Row 1 becomes header
  slice(-1)                                       # Remove former header row

## 0.1.1 Save Species key from two columns 
Baron87_species <- tabledirectxl_rev1[, c("Species", "Species_Baron1987")]
write.csv(
  Baron87_species,
  file = "Baron87_species.csv",
  row.names = FALSE,
  na = ""
)

## 0.2 Remove Species key column
tabledirectxl_rev2 <- tabledirectxl_rev1 %>%
  select(-Species_Baron1987)

## 0.3 Reinstate clade column 
tabledirectxl_rev3 <- tabledirectxl_rev2 %>%
  mutate(
    # Identify contiguous blocks of the same Order_Baron1987
    .ord_key = tidyr::replace_na(Order_Baron1987, "__NA__"),
    .grp = cumsum(.ord_key != dplyr::lag(.ord_key, default = dplyr::first(.ord_key)))
  ) %>%
  group_by(.grp) %>%
  group_modify(~{
    ord <- .x$Order_Baron1987[1]
    
    # New blank row that carries the order label
    header <- .x[1, ]
    header[] <- NA
    header$Order_Baron1987 <- ord
    
    # Original rows: remove the repeated order labels
    data <- .x
    data$Order_Baron1987 <- NA_character_
    
    bind_rows(header, data)
  }) %>%
  ungroup() %>%
  select(-.ord_key, -.grp)



## 0.5 Remove header names in first two columns (saving names to be restored)
# Save original column names
orig_names <- names(tabledirectxl_rev3)

# Blank first two headers
names(tabledirectxl_rev3)[1:2] <- ""

## 0.6 Save snapshot 
write.csv(
  tabledirectxl_rev3,
  file = "Baron_etal_1987_Table1_snapshot.csv",
  row.names = FALSE,
  na = ""
)

# Named version derived from snapshot
tabledirectxl_rev4 <- tabledirectxl_rev3
names(tabledirectxl_rev4)[1:2] <- orig_names[1:2]

## 1. Progress forward

## 2. Arrange headers as clade column
tabledirectxl_1 <- tabledirectxl_rev4 %>%
  mutate(
    Order_Baron1987 = if_else(
      is.na(Species) & !is.na(Order_Baron1987),
      as.character(Order_Baron1987),
      NA_character_
    )
  ) %>%
  fill(Order_Baron1987) %>%
  filter(!is.na(Species))

## 3. Make numeric
tabledirectxl_2 <- tabledirectxl_1 %>%
  mutate(
    across(
      .cols = 3:ncol(.),
      ~ parse_number(na_if(as.character(.x), "__"))
    )
  )

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 5. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl_2

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path))

# Get Item encoded
library(readxl) 
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/"
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)

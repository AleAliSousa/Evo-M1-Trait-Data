setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Baron_etal_1983")

## Tasks
# - [ ] Read from csv
# - [ ] Arrange headers as clade column
# - [ ] Separate columns for values and notes
# - [ ] Make numeric
# - [ ] Save

## 1. Read from csv
library(tidyverse)
tabledirectxl <- read.csv("Baron_etal_1983_Table1_snapshot.csv",
                          check.names = FALSE)

## 2. Arrange headers as clade column
tabledirectxl_1 <- tabledirectxl %>%
  mutate(
    # Identify clade rows (non-digit values)
    clade = if_else(
      !is.na(`code number of species`) &
        !grepl("^[0-9]+$", `code number of species`),
      `code number of species`,
      NA_character_
    )
  ) %>%
  # Propagate clade labels downward
  fill(clade) %>%
  # Remove the original clade-source rows
  filter(grepl("^[0-9]+$", `code number of species`))

## 3. separate columns for values and notes
tabledirectxl_2 <- tabledirectxl_1 %>%
  mutate(
    # n: split value vs note
    n_chr  = as.character(n),
    n_note = if_else(!is.na(n_chr) & grepl("\\*", n_chr), "*", NA_character_),
    n      = suppressWarnings(as.integer(gsub("[^0-9]", "", n_chr)))
  ) %>%
  select(-n_chr) %>%
  mutate(
    # volume in mm3: split value vs note
    vol_chr       = as.character(`volume in mm3`),
    vol_note      = if_else(!is.na(vol_chr) & grepl("\\+", vol_chr), "+", NA_character_),
    `volume in mm3` = suppressWarnings(as.numeric(gsub("[^0-9.]", "", vol_chr)))
  ) %>%
  select(-vol_chr)

## 4. Make numeric
tabledirectxl_3 <- tabledirectxl_2 %>%
  mutate(`SEM in %` = parse_number(na_if(`SEM in %`, "__")))

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 5. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl_3

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

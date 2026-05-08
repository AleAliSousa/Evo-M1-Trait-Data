## 0. PATHS (NO setwd) -------------------------------------------------------
library(rstudioapi)

script_path   <- rstudioapi::getActiveDocumentContext()$path
paper_dir     <- dirname(script_path)
dataset_root  <- dirname(paper_dir)
table_name    <- tools::file_path_sans_ext(basename(script_path))

# outputs
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")

## --- YOU SET THIS MANUALLY ---
pdf_file <- file.path(
  paper_dir,
  "Eagleman-2021-The Defensive Activation Theory_.pdf"
)

## 1. PACKAGES ---------------------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)
library(stringr)
library(readxl)

## 2. EXTRACT TABLE 1 --------------------------------------------------------
tables1 <- extract_tables(
  pdf_file,
  pages = 3,
  guess = FALSE
)

df0 <- as.data.frame(tables1[[1]])

# check the name of the columns
colnames(df0)

# Only keep rows from 7 to 31 and delete the 2nd column
df1 <- df0 %>%
  slice(7:31) %>%                          # rows 7 to 31
  filter(str_detect(.[[1]], "^[A-Za-z]")) %>%  # first column
  select(-2)                               # drop 2nd column

# Add three columns and rename columns 
df2 <- df1 %>%
  add_column(.col4 = NA, .col5 = NA, .col6 = NA, .after = 3) %>%
  `colnames<-`(c(
    "Coloquial name",
    "Time to \nlocomotion\n(Days)",
    "Time to\n weaning\n (Days)",
    "Time to\n adolescence\n (Months)",
    "Percentage of \nsleep in REM",
    "Phylogenetic\n distance from\n humans (M\n years)"
  ))
# check the name of the columns after adding and renaming
colnames(df2) # check the name of the columns before separating
df2[ , 3:6]
# separate the space delimited value from column 3 into 4 columns and convert to numeric, if the value is "–" then convert to NA

df3 <- df2 %>%
  tidyr::separate(
    col = 3,
    into = colnames(df2)[3:6],
    sep = "\\s+",
    fill = "right",
    convert = FALSE
)
# check
df3[ , 3:6]
     
write.csv(df3, snapshot_csv, row.names = FALSE)

df<-df3

## 3. REMOVE PDF ARTIFACT COLUMNS --------------------------------------------
df <- df[, !grepl("^\\.\\.\\.", colnames(df)), drop = FALSE]

## 4. CHECK & RENAME COLUMNS SAFELY ------------------------------------------

n_cols <- ncol(df)

# Expected column meaning in order (Table 1)
expected_names <- c(
  "Species",
  "Time_to_locomotion_days",
  "Time_to_weaning_days",
  "Time_to_adolescence_months",
  "REM_sleep_percent",
  "Phylogenetic_distance_Mya"
)

# Assign only as many names as columns that exist
colnames(df) <- expected_names[seq_len(n_cols)]

## 5. REMOVE NON-TABLE TEXt --------------------------------------------------
df <- df %>%
  filter(
    !is.na(Species),
    str_detect(Species, "^[A-Za-z]"),
    !str_detect(
      Species,
      "METHODS|Supplementary|sleep time|Table|Material"
    )
  )

## 5.5 REPLACE DASHES WITH NA ------------------------------------------------
df <- df %>%
  mutate(
    across(
      -Species,
      ~ .x %>%
        str_trim() %>%                      # remove spaces
        str_replace_all("[^0-9.]", "") %>% # keep ONLY numbers + decimal
        na_if("")                          # blank → NA
    )
  )


## 6. CLEAN NUMERIC VALUES ---------------------------------------------------

final.dataframe <- df %>%
  mutate(
    Time_to_locomotion_days = as.numeric(Time_to_locomotion_days),
    Time_to_weaning_days = as.numeric(Time_to_weaning_days),
    Time_to_adolescence_months = as.numeric(Time_to_adolescence_months),
    REM_sleep_percent = as.numeric(str_remove(REM_sleep_percent, "%")),
    Phylogenetic_distance_Mya = as.numeric(Phylogenetic_distance_Mya)
  )

## 7. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- final.dataframe

# Item encoded lookup uses table_name (script filename)
filecodes <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]

# Local output next to the paper
write.csv(final.dataframe, final_csv, row.names = FALSE)

# Public TSV output
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(final.dataframe,
file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
sep = "\t", row.names = FALSE)


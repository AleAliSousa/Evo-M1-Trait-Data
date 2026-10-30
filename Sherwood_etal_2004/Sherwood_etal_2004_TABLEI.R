## 0. PATHS ---------------------------------------------------------------

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

library(tidyverse)
library(readxl)

script_path  <- .sp
paper_dir    <- dirname(script_path)                 
dataset_root <- dirname(paper_dir)                   # Evo-M1-Trait-Data
table_name   <- tools::file_path_sans_ext(basename(script_path))

# Outputs
snapshot_xlsx <- file.path(paper_dir, paste0(table_name, "_snapshot.xlsx"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. LOAD SNAPSHOT AND SET HEADERS ---------------------------------------

# Load the data into a variable.
data <- read_xlsx(snapshot_xlsx)

# Change headers to the strings from Row 2.
raw_headers <- data %>%
  slice(2) %>%
  unlist(use.names = FALSE) %>%
  as.character()

clean_one_header <- function(x, index) {
  x <- str_squish(as.character(x))
  if (is.na(x) || x == "" || str_to_lower(x) == "na") {
    x <- paste0("column_", index)
  }
  x
}

clean_headers <- map2_chr(raw_headers, seq_along(raw_headers), clean_one_header)
clean_headers <- make.unique(clean_headers, sep = "_")

column_equivalencies <- tibble(
  column_index = seq_along(clean_headers),
  original_header_from_row_2 = raw_headers,
  final_header = clean_headers
)

# Delete rows 1 and 2.
result_df <- data %>%
  slice(-(1:2))

names(result_df) <- clean_headers

# Remove completely blank rows introduced by formatting in the snapshot.
result_df <- result_df %>%
  mutate(across(everything(), ~ str_squish(as.character(.x)))) %>%
  mutate(across(everything(), ~ na_if(.x, ""))) %>%
  filter(if_any(everything(), ~ !is.na(.x)))


## 2. JOIN SPLIT SUBSPECIES EPITHETS --------------------------------------

# The first column has some separate rows for the subspecies epithets.
# These start with lowercase letters. Move them up to join the species names
# or binomials that start with capital letters.
first_col <- names(result_df)[1]

is_blank_cell <- function(x) {
  length(x) == 0 || is.na(x) || str_squish(as.character(x)) == ""
}

starts_with_lowercase <- function(x) {
  !is_blank_cell(x) && str_detect(str_squish(as.character(x)), "^[a-z]")
}

join_split_subspecies <- function(df, species_col) {
  if (nrow(df) == 0) {
    return(list(
      data = df,
      log = tibble(
        snapshot_row = integer(),
        moved_epithet = character(),
        joined_to_before = character(),
        joined_to_after = character()
      )
    ))
  }
  
  out_rows <- list()
  join_log <- list()
  last_kept <- 0L
  
  for (i in seq_len(nrow(df))) {
    row_i <- df[i, , drop = FALSE]
    sp_i <- row_i[[species_col]][1]
    
    if (starts_with_lowercase(sp_i) && last_kept > 0L) {
      before <- out_rows[[last_kept]][[species_col]][1]
      after  <- str_squish(paste(before, sp_i))
      out_rows[[last_kept]][[species_col]][1] <- after
      
      # If the split epithet row contains values in other columns, move those
      # values up only where the previous retained row is blank. This protects
      # existing measurements in the species row.
      for (nm in setdiff(names(df), species_col)) {
        prev_value <- out_rows[[last_kept]][[nm]][1]
        this_value <- row_i[[nm]][1]
        if (is_blank_cell(prev_value) && !is_blank_cell(this_value)) {
          out_rows[[last_kept]][[nm]][1] <- this_value
        }
      }
      
      join_log[[length(join_log) + 1L]] <- tibble(
        snapshot_row = i + 2L,
        moved_epithet = as.character(sp_i),
        joined_to_before = as.character(before),
        joined_to_after = as.character(after)
      )
    } else {
      out_rows[[length(out_rows) + 1L]] <- row_i
      last_kept <- length(out_rows)
    }
  }
  
  list(
    data = bind_rows(out_rows),
    log = if (length(join_log) == 0) {
      tibble(
        snapshot_row = integer(),
        moved_epithet = character(),
        joined_to_before = character(),
        joined_to_after = character()
      )
    } else {
      bind_rows(join_log)
    }
  )
}

joined <- join_split_subspecies(result_df, first_col)
result_df <- joined$data
split_subspecies_log <- joined$log


## 2B. FILL SPECIES SUBHEADERS DOWN ---------------------------------------

# In the snapshot, Species is used like a subheader: the first row in a
# block contains the species name, and following rows in that same block
# have blank Species cells. Fill those blanks from the most recent Species
# value above so every observation has an explicit Species value.
if (!"Species" %in% names(result_df)) {
  stop("Column 'Species' was not found in result_df. Check the header spelling.")
}

species_before_fill <- result_df$Species

result_df <- result_df %>%
  fill(Species, .direction = "down")

species_fill_log <- tibble(
  row_after_subspecies_join = seq_along(species_before_fill),
  before = species_before_fill,
  after = result_df$Species
) %>%
  filter(is.na(before) & !is.na(after))


## 3. CLEAN NUMERIC VALUES IN AGE COLUMN ----------------------------------

# In the Age column:
# - remove the tilde before a number, e.g. "~10" -> "10"
# - where there is a range with a hyphen/en dash/em dash, get the average,
#   e.g. "2-4" -> "3", "25–30" -> "27.5"

clean_age_value <- function(x) {
  if (is_blank_cell(x)) return(NA_character_)
  
  x0 <- str_squish(as.character(x))
  
  # Remove leading tilde before a number.
  # Handles "~" plus common Unicode tilde-like characters.
  x1 <- str_replace(
    x0,
    "^[~\u223C\uFF5E\u02DC]\\s*(?=[0-9])",
    ""
  )
  
  # Normalize dash variants to ordinary hyphen.
  # Handles en dash "–", em dash "—", Unicode minus, etc.
  x1 <- str_replace_all(
    x1,
    "[\u2010\u2011\u2012\u2013\u2014\u2015\u2212]",
    "-"
  )
  
  # Remove commas only for numeric range detection/calculation.
  x_for_range <- str_replace_all(x1, ",", "")
  
  range_match <- str_match(
    x_for_range,
    "^([0-9]+(?:\\.[0-9]+)?)\\s*-\\s*([0-9]+(?:\\.[0-9]+)?)$"
  )
  
  if (!is.na(range_match[1, 1])) {
    low  <- as.numeric(range_match[1, 2])
    high <- as.numeric(range_match[1, 3])
    avg  <- mean(c(low, high), na.rm = TRUE)
    
    return(format(avg, scientific = FALSE, trim = TRUE))
  }
  
  x1
}

if (!"Age" %in% names(result_df)) {
  stop("Column 'Age' was not found in result_df. Check the header spelling.")
}

age_before <- result_df$Age
age_after  <- map_chr(age_before, clean_age_value)

age_numeric_cleanup <- tibble(
  row_after_header_cleanup = seq_along(age_before),
  column = "Age",
  before = age_before,
  after = age_after
) %>%
  filter(coalesce(as.character(before), "<NA>") != coalesce(as.character(after), "<NA>"))

result_df$Age <- age_after

# Convert columns that are now cleanly numeric to numeric while leaving text
# columns, such as species names, as character.
result_df <- type_convert(
  result_df,
  na = c("", "NA", "N/A", "n/a", "NaN", "NULL")
)

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)


## 4. CLEAN SPECIFIC COLUMN NAMES --------------------------------------------

names(result_df)[names(result_df) == "Neo-cortex"]   <- "Neocortex"
names(result_df)[names(result_df) == "Hippo-campus"] <- "Hippocampus"

## 5. SAVE ---------------------------------------------------------------

final.dataframe <- result_df

filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")

item_encoded <- filecodes$`Item encoded`[
  match(table_name, filecodes$`Item name`)
]

# Local CSV (paper folder)
write.csv(final.dataframe, final_csv, row.names = FALSE)

# Public TSV
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  final.dataframe,
  file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
  sep = "\t",
  row.names = FALSE
)
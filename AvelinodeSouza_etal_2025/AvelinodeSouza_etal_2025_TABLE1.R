## 0. PATHS ---------------------------------------------------------------
library(rstudioapi)
library(readxl)

script_path  <- rstudioapi::getActiveDocumentContext()$path
paper_dir    <- dirname(script_path)                 # AvelinodeSouza_etal_2025
dataset_root <- dirname(paper_dir)                   # Evo-M1-Trait-Data
table_name   <- tools::file_path_sans_ext(basename(script_path))

# --- PDF SOURCE (manual, per your rule) ---
pdf_file <- file.path(
  paper_dir,
  "Avelino-de-Souz-2025-Cellular Composition of t.pdf"
)

# Outputs
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")


# Load the tabulizer library and rJava
## 1. SOURCE ---------------------------------------------------------------
library(rJava)
library(tabulapdf)
library(tidyverse)

tables1 <- extract_tables(pdf_file, pages = c(5))

## 2. FIX FORMATTING AND SAVE SNAPSHOT
# Convert the matrices into data frames
df1 <- as.data.frame(tables1[[1]])

# Remove the the text rows after row 21
df1 <- df1[1:min(21, nrow(df1)), , drop = FALSE]
row.names(df1) <- NULL  # reset row names

# Split the 4th column at the first space
library(dplyr); library(tidyr)
n4 <- names(df1)[4]
df1 <- df1 %>%
  separate_wider_delim({{ n4 }}, delim = " ", names = c(n4, "...0"), too_many = "merge")

# Fix up the headers
# Combine colnames (headings) with first row
header <- paste(names(df1), as.character(unlist(df1[1, ], use.names = FALSE)))
# Strip the "...<number>" (e.g., "...1", "...3") in any column name (there may be a space, but wait to eliminate in next step)
header <- gsub("\\.{3}\\d+", "", header)
# Trim whitespace from the names
header=trimws(header)
# Use the header as column names for the first matrix in tables1
colnames(df1) <- header

# Remove the redundant first row and the text rows after row 21
df1 <- df1[2:min(21, nrow(df1)), , drop = FALSE]
row.names(df1) <- NULL  # reset row names

# Combine rows where row label (in the first column) gets broken across multiple lines.
# Treat NA as not-text; only non-empty strings are text
is_text <- function(x) !is.na(x) & nzchar(trimws(x))
# continuation rows: first col has text AND every other col has no text
others_have_text <- rowSums(as.data.frame(lapply(df1[-1], is_text))) > 0
cont <- is_text(df1[[1]]) & !others_have_text
# Group index: increases at each "real" row, so continuations share parent’s group
g <- cumsum(!cont)
# Merge text in first column across each group, separated by space
df1[[1]] <- ave(df1[[1]], g, FUN = function(v) paste(v[is_text(v)], collapse = " "))
# Keep only the non-continuation (parent) rows
df1 <- df1[!cont, , drop = FALSE]
row.names(df1) <- NULL

# Save snapshot as a CSV file
write.csv(df1, snapshot_csv, row.names = FALSE)

## 3. MAKE DATA READABLE
clean_df<-df1

# Assuming clean_df is your data frame
columns_to_clean <- 2:ncol(clean_df)

# Clean spaces and commas, then convert to numeric
for (col in columns_to_clean) {
  clean_df[[col]] <- gsub(" ", "", clean_df[[col]])
  clean_df[[col]] <- gsub(",", "", clean_df[[col]])
  clean_df[[col]] <- as.numeric(clean_df[[col]])
}



## 4. MATCH NAME AND PIVOT
result_df <- clean_df %>%
  pivot_wider(
    names_from = Structure,
    values_from = -Structure,
    names_glue = "{Structure}_{.value}",
    values_fill = NA
  ) %>%
  mutate(`Species name` = "Balaenoptera acutorostrata") %>%
  select(`Species name`, everything())


# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 5. EQULIVALENCIES TABLE


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


# ------------- EDIT HERE IF YOU WANT DIFFERENT REGION TOKENS -------------
colnames_vec<-colnames(result_df)

.region_map <- c(
  "Whole brain"                                                        = "WholeBrain",
  "Cerebral cortex (including Hp + amygdala)"                          = "CerebralCortexIncHpAmygdala",
  "Cerebral cortical grey matter"                                      = "CerebralCorticalGrey",
  "Cerebral cortical white matter"                                     = "CerebralCorticalWhite",
  "Cerebellum"                                                         = "Cerebellum",
  "Rest of brain (diencephalon+striatum, mesencephalon, pons and medulla)" = "RestOfBrain",
  "Amygdala"                                                           = "Amygdala",
  "Hippocampus"                                                        = "Hippocampus",
  "Diencephalon + Striatum"                                            = "DiencephalonStriatum",
  "Mesencephalon"                                                      = "Mesencephalon",
  "Pons"                                                               = "Pons",
  "Medulla oblongata"                                                  = "Medulla"
)

# Measurement → suffix mapping matching your previous spinal-cord scheme
.measure_map <- c(
  "Mass, g"                        = "Mass.g",
  "Neurons"                        = "N.n",
  "Non-neuronal cells"            = "O.n",
  "Neurons/mg"                    = "N.p.mg",
  "Non-neuronal cells/mg"         = "O.p.mg",
  "Non-neuronal cells/neuron"     = "O.N" 
)

# Build a mapping from your current verbose headers → standardized names
build_brain_term_mapping <- function(colnames_vec) {
  # Keep "Species name" as is (if present)
  species_keep <- "Species name" %in% colnames_vec
  species_map  <- if (species_keep) c("Species name" = "Species name") else character(0)
  
  # Parse everything that matches "<Region>_<Measure>"
  brain_cols <- setdiff(colnames_vec, "Species name")
  pieces <- str_match(brain_cols, "^(.*)_(.*)$")
  # pieces[,2] = region label, pieces[,3] = measure label
  valid <- which(!is.na(pieces[,1]))
  
  # Map regions and measures using the dictionaries
  region_std  <- .region_map[ pieces[valid, 2] ]
  measure_std <- .measure_map[ pieces[valid, 3] ]
  
  # Keep only rows that map cleanly (both region and measure recognized)
  ok <- which(!is.na(region_std) & !is.na(measure_std))
  
  std_names <- paste0(region_std[ok], "_", measure_std[ok])
  old_names <- brain_cols[valid][ok]
  
  # Named vector: names = standardized, values = old columns
  c(species_map, stats::setNames(old_names, std_names))
}

# Inspect what mapped and what didn’t
inspect_mapping <- function(colnames_vec, mapping) {
  tibble(
    old = colnames_vec,
    mapped_to = names(mapping)[match(colnames_vec, mapping)]
  ) %>%
    mutate(mapped = !is.na(mapped_to))
}

# Apply the renaming to a data frame `df` (only for columns that exist in mapping)
rename_using_mapping <- function(df, mapping) {
  existing <- intersect(names(df), unname(mapping))
  if (length(existing) == 0L) return(df)
  df %>%
    rename_with(~ names(mapping)[match(., mapping)], .cols = all_of(existing))
}
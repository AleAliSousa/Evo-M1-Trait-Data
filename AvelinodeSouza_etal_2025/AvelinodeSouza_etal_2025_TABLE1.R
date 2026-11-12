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

library(readxl)

paper_dir    <- folder
dataset_root <- base
table_name   <- item_name


# Output
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
library(tidyverse)
## 1. SOURCE: read the frozen snapshot (written by AvelinodeSouza_etal_2025_TABLE1_snapshot.R) ---------
library(dplyr); library(tidyr)
df1 <- read.csv(snapshot_csv, colClasses = "character", check.names = FALSE)
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
  mutate(`Species` = "Balaenoptera acutorostrata") %>%
  select(`Species`, everything())
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
message("Wrote ", final_csv, "  (", nrow(final.dataframe), " rows)")
# Public TSV (only if a DOI code was found for this item in __ReadMe.xlsx)
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", table_name,
          "' in __ReadMe.xlsx; TSV copy skipped.")
} else {
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  tsv_path <- file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
  write.table(final.dataframe, file = tsv_path, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_path)
}
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

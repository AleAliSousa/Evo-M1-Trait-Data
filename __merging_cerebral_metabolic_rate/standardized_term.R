library(tidyverse)

# Resolve relative to this script (Rscript or a saved RStudio source file).
.script_path <- local({
  args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(args)) return(normalizePath(sub("^--file=", "", args[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(path)) return(normalizePath(path))
  }
  stop("Run with Rscript, or save and Source this file in RStudio.", call. = FALSE)
})
setwd(dirname(.script_path))

# Define the folder containing the per-reference term files
folder_path <- "standardized_term_by_reference"

# Get list of CSV files in the folder
csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read and stack all files, keeping all columns
combined_df <- csv_files |>
  map(~ readr::read_csv(.x, show_col_types = FALSE)) |>
  list_rbind()

# Write output
readr::write_csv(combined_df, "standardized_term_cerebral_metabolic_rate.csv")

# For checking: line up equivalent terms across references
pivot_df <- combined_df %>%
  select(Original_Term, Reference, Standardized_Term) %>%
  distinct() %>%
  pivot_wider(names_from = Reference, values_from = Standardized_Term)

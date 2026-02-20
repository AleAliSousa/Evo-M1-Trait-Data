# Set working directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Alt_merging_cellcounts")

library(tidyverse)

# Read the CSV file
input_file <- "standardized_term_cellcounts.csv"
df <- read.csv(input_file)

# Create output directory for split files
output_dir <- "split_by_reference"
dir.create(output_dir, showWarnings = FALSE)

# Split and save CSVs by unique Reference values
unique_refs <- unique(df$Reference)

for (ref in unique_refs) {
  ref_df <- df %>% filter(Reference == ref)
  # Sanitize filename
  safe_ref <- gsub("[^A-Za-z0-9_]", "_", ref)
  output_file <- paste0(output_dir, "/", safe_ref, "_standardized_terms.csv")
  write_csv(ref_df, output_file)
}

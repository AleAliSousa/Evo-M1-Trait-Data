library(tidyverse)

# Set working directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_volumes")

# Define the folder containing the CSV files
folder_path <- "standardized_term_by_reference"

# Get list of CSV files in the folder
csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read and stack all files, keeping all columns
combined_df <- csv_files |>
  map(~ readr::read_csv(.x, show_col_types = FALSE)) |>
  list_rbind()  # same as dplyr::bind_rows but faster in tidyverse 1.3+

# Write output
readr::write_csv(combined_df, "standardized_term_volumes.csv")

# For checking:

# arrange each equivalent term
pivot_df <- combined_df %>%
  select(Original_Term, Reference, Standardized_Term) %>%
  distinct() %>%  # remove duplicates if any
  pivot_wider(
    names_from = Reference,
    values_from = Standardized_Term
  )

# check a term for equivalent terms (e.g. which papers measure the neocortex)
combined_df[combined_df$Standardized_Term == "Neocortex_Vol.mm3", ]

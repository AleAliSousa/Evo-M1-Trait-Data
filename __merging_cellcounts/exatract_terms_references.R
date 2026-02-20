library(tidyverse)

# Set working directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cellcounts")

# ---- User inputs ----
paper_name  <- "AvelinodeSouza__2025"   # change as needed
figure_name <- "TABLE1"                # change as needed

# Input CSV: paper/paper_figure.csv
input_csv <- file.path(
  "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data",
  paper_name,
  paste0(paper_name, "_", figure_name, ".csv")
)

# Folder containing prior standardized term tables
standardized_dir <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cellcounts/standardized_term_by_reference/"

# Output path (in current wd)
reference_id <- paste0(paper_name, "_", figure_name)
out_csv <- file.path(getwd(), paste0(reference_id, "_term_mapping.csv"))

# ---- I. Load, extract rownames, transpose to a term list ----
# Read with base to preserve rownames (common when first column is row names)
raw_tbl <- read.csv(input_csv, check.names = FALSE, stringsAsFactors = FALSE)

# If first column looks like rownames (often unnamed or called X), use it as rownames.
# Otherwise, rownames() will just be 1:n and we fall back to colnames.
first_col_name <- names(raw_tbl)[1]
has_real_rownames <- first_col_name %in% c("", "X") || anyDuplicated(raw_tbl[[1]]) == 0

if (has_real_rownames) {
  rn <- raw_tbl[[1]] %>% as.character()
  # If these are just 1:n (auto rownames), treat as not real.
  if (all(rn == as.character(seq_len(nrow(raw_tbl))))) {
    has_real_rownames <- FALSE
  }
}

if (has_real_rownames) {
  terms <- raw_tbl[[1]] %>% as.character()
} else {
  # Fallback: use existing rownames or colnames if the table was saved without rownames
  # This tries rownames() first, then colnames() if rownames are 1:n
  rn2 <- rownames(raw_tbl)
  if (!is.null(rn2) && !all(rn2 == as.character(seq_len(nrow(raw_tbl))))) {
    terms <- rn2
  } else {
    terms <- colnames(raw_tbl)
  }
}

new_terms <- tibble(
  Original_Term = terms %>% as.character() %>% na_if("") %>% unique(),
  Reference = reference_id,
  Standardized_Term = NA_character_
) %>%
  filter(!is.na(Original_Term))

# ---- II. Read ALL prior term lists and fill matches ----
standard_files <- list.files(
  standardi
  



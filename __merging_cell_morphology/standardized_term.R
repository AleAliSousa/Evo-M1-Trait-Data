## Stack the per-reference standardized-term maps for the CELL MORPHOLOGY merge.
## Same pattern as __merging_gyrification/standardized_term.R, but the term files carry
## extra columns (cell_type, region, layer, statistic, unit, hemisphere, note) because a
## cell-morphology column encodes cell type x region x measure x statistic in one header
## (e.g. Sherwood 2003 `betz_soma_um3_mean`). Every column of every source TSV must appear
## exactly once (Standardized_Term = a measure code, a key role, DROP, or FILTER).
suppressWarnings(suppressMessages(library(tidyverse)))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  "."
})
setwd(dirname(.sp))

folder_path <- "standardized_term_by_reference"
csv_files <- list.files(folder_path, pattern = "_standardized_terms\\.csv$", full.names = TRUE)

combined_df <- csv_files |>
  map(~ readr::read_csv(.x, show_col_types = FALSE,
                        col_types = readr::cols(.default = readr::col_character()))) |>
  list_rbind()

dup <- combined_df |> count(Reference, Original_Term) |> filter(n > 1)
if (nrow(dup)) stop("Duplicate Original_Term within a reference: ",
                    paste(dup$Reference, dup$Original_Term, collapse = "; "))

readr::write_csv(combined_df, "standardized_term_cell_morphology.csv", na = "")
message("Stacked ", length(csv_files), " term files -> ", nrow(combined_df), " rows")

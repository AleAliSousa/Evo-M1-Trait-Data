library(tidyverse)

## Self-contained path (Rscript or RStudio)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  "."
})
setwd(dirname(.sp))

folder_path <- "standardized_term_by_reference"
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

combined_df <- csv_files |>
  map(~ readr::read_csv(.x, show_col_types = FALSE)) |>
  list_rbind()

readr::write_csv(combined_df, "standardized_term_gyrification.csv")
message("Stacked ", length(csv_files), " term files -> ", nrow(combined_df), " rows")

# Zilles_Rehkämper_1988_text.R
#
# Preparation step. Converts a hand-transcribed snapshot of summary statistics
# reported in the text of Zilles & Rehkämper (1988), Orang-utan Biology ch. 12,
# into a typed analysis-ready CSV. Output comes from the snapshot only.

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file <- "Zilles_Rehkämper_1988_text_snapshot.csv"
registry_item_name <- "Zilles_Rehkämper_1988_text"

final.dataframe <- read_csv(snapshot_file, show_col_types = FALSE) %>%
  transmute(
    Species = str_squish(Species),
    summary_group = str_squish(summary_group),
    measure = str_squish(measure),
    unit = str_squish(unit),
    reported_mean = as.numeric(reported_mean),
    reported_plus_minus = as.numeric(reported_plus_minus),
    N = as.integer(N),
    provenance_note = na_if(str_squish(provenance_note), "")
  )

write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(registry_item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", registry_item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

# Caspar_etal_2022_Supplementaryfile3.R
#
# Purpose
#   Turn Caspar et al. 2022 eLife Supplementary File 3 (the ecology / female
#   endocranial volume / tool-use table used in their handedness analysis) into a
#   lean, analysis-ready CSV. The supplied xlsx IS the frozen snapshot.
#   Column meanings are in
#   reference_tables/Caspar_etal_2022_Supplementaryfile3_definitions.csv.
#
# Input
#   elife-77875-supp3-v1.xlsx        (one sheet)
#
# Outputs
#   Caspar_etal_2022_Supplementaryfile3.csv        one row per species (38 rows)
#   <DOI>.tsv in __Public/comparative-data/         DOI-named tab-separated copy

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
})

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
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file <- "elife-77875-supp3-v1.xlsx"

# The header has two 'Reference' and two 'Notes' columns, so read by position.
raw <- read_excel(snapshot_file, col_names = FALSE, col_types = "text", skip = 1)
names(raw) <- c("Family","Species","ecology","ecology_ref","female_endocranial_volume_ml",
                "endocranial_volume_ref","endocranial_volume_notes","habitual_tool_use",
                "tool_use_ref","tool_use_notes","name_in_tree")

na_blank <- function(x) ifelse(is.na(x) | x %in% c("", "N.A."), NA_character_, x)

final.dataframe <- raw %>%
  filter(!is.na(Species)) %>%
  mutate(
    female_endocranial_volume_ml = suppressWarnings(as.numeric(female_endocranial_volume_ml)),
    tool_use_ref  = na_blank(tool_use_ref),
    ecology_ref   = na_blank(ecology_ref),
    endocranial_volume_notes = na_blank(endocranial_volume_notes),
    tool_use_notes           = na_blank(tool_use_notes),
    source = "Caspar_etal_2022"
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
message("Rows: ", nrow(final.dataframe))

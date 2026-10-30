# Heldstab_etal_2016_TableS1.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of Heldstab et al. 2016
#   Supplementary Table S1 (Sci Rep 6:24528) into a lean, analysis-ready CSV.
#   Everything in the output comes from the paper via the snapshot only.
#   Column meanings, units and legend symbols are documented in
#   reference_tables/Heldstab_etal_2016_TableS1_definitions.csv, not here.
#
# Input
#   Heldstab_etal_2016_TableS1_snapshot.xlsx        sheet: TableS1_snapshot
#
# Outputs
#   Heldstab_etal_2016_TableS1.csv                  one row per species (37 rows)
#   <DOI>.tsv in __Public/comparative-data/         DOI-named tab-separated copy
#
# Cleaning: the printed "-" (not given) is turned into NA; numeric columns are
# parsed; n_individuals is kept as text because several rows give per-group counts
# (e.g. "3/2", "2/2/5"). Species binomials are taken as printed (already modern).

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

snapshot_file  <- "Heldstab_etal_2016_TableS1_snapshot.xlsx"
snapshot_sheet <- "TableS1_snapshot"

# ---- read snapshot: row 1 = title, row 2 = header ----
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", na = character())
header <- as.character(unlist(raw[2, ], use.names = FALSE))
dat <- raw[-c(1, 2), , drop = FALSE]
names(dat) <- header
dat <- dat[!is.na(dat$Species), , drop = FALSE]

na_dash <- function(x) ifelse(is.na(x) | x == "-", NA_character_, x)
as_num  <- function(x) suppressWarnings(as.numeric(na_dash(x)))

final.dataframe <- dat %>%
  transmute(
    Species                 = trimws(Species),
    MC                      = as_num(MC),
    study_site              = na_dash(study_site),
    n_bouts                 = as.integer(as_num(n_bouts)),
    n_individuals           = na_dash(n_individuals),          # text: can be "3/2", "2/2/5"
    ECV_ml                  = as_num(ECV_ml),
    body_mass_g             = as_num(body_mass_g),
    neocortex_g             = as_num(neocortex_g),
    cerebellum_g            = as_num(cerebellum_g),
    brain_assoc_body_mass_g = as_num(brain_assoc_body_mass_g),
    terrestriality          = as_num(terrestriality),
    diet_quality            = as_num(diet_quality),
    diet_category           = as.integer(as_num(diet_category)),
    tool_use                = as.integer(as_num(tool_use)),
    extractive_foraging     = as.integer(as_num(extractive_foraging)),
    cog_test_1              = as_num(cog_test_1),
    cog_test_2              = as_num(cog_test_2),
    group_size              = as_num(group_size),
    source                  = "Heldstab_etal_2016"
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

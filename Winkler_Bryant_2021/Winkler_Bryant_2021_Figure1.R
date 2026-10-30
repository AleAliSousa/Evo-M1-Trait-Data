# Winkler_Bryant_2021_Figure1.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of Winkler & Bryant 2021
#   (Bioacoustics) into a lean, analysis-ready CSV. The snapshot combines the
#   species list + acoustic data from Table 1 with the two variables coded in
#   Figure 1 (play-vocalisation feature category; loud play vocalisation).
#   Column meanings are documented in
#   reference_tables/Winkler_Bryant_2021_Figure1_definitions.csv.
#
# Input
#   Winkler_Bryant_2021_Figure1_snapshot.xlsx       sheet: Figure1_snapshot
#
# Outputs
#   Winkler_Bryant_2021_Figure1.csv                 one row per species (67 rows)
#   <DOI>.tsv in __Public/comparative-data/          DOI-named tab-separated copy

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

snapshot_file  <- "Winkler_Bryant_2021_Figure1_snapshot.xlsx"
snapshot_sheet <- "Figure1_snapshot"

# ---- read snapshot: row 1 = title, row 2 = header ----
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", na = character())
header <- as.character(unlist(raw[2, ], use.names = FALSE))
dat <- raw[-c(1, 2), , drop = FALSE]
names(dat) <- header
dat <- dat[!is.na(dat$Species), , drop = FALSE]

na_txt <- function(x) ifelse(is.na(x) | x == "N/A", NA_character_, x)
norm_ps <- function(x) {
  m <- regmatches(x, regexpr("(?i)^(yes|no|unclear)", x, perl = TRUE))
  ifelse(nzchar(m), paste0(toupper(substr(m,1,1)), tolower(substr(m,2,nchar(m)))), x)
}

final.dataframe <- dat %>%
  transmute(
    taxa_group               = trimws(taxa_group),
    common_name              = trimws(common_name),
    Species                  = trimws(Species),
    play_specific            = vapply(play_specific, norm_ps, character(1), USE.NAMES = FALSE),
    vocalisation_name        = na_txt(vocalisation_name),
    acoustic_descriptors     = na_txt(acoustic_descriptors),
    reference                = reference,
    figure1_feature_category = figure1_feature_category,
    loud_play_vocalisation   = loud_play_vocalisation,
    source                   = "Winkler_Bryant_2021"
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

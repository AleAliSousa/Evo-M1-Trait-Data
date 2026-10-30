## =============================================================================
## Sherwood et al. (2004) individual gorilla volumes -- UNPUBLISHED individuals,
## recovered via DeCasien & Higham (2019) Supplementary Data (MOESM3, reference 64).
## "Brain structure variation in great apes..." Sherwood et al. 2004,
## Am J Primatol 63:149-164. DOI: 10.1002/ajp.20048
## =============================================================================
##
## WHAT THIS IS / WHY IT EXISTS
##   Sherwood et al. (2004) Table I published four gorilla individuals with whole
##   brain, neocortex, hippocampus, striatum, thalamus and cerebellum volumes
##   (those are already in this repo as Sherwood_etal_2004_TABLEI.*). DeCasien &
##   Higham (2019) list, under reference 64, SIX gorilla individuals. Two of the six
##   are NOT in the published Table I:
##       Gorilla beringei         BV 460600 mm3, Thalamus 8300  mm3
##       Gorilla gorilla gorilla  BV 459400 mm3, Thalamus 11400 mm3
##   Per the DeCasien & Higham supplementary methods, some Sherwood whole-brain /
##   regional values were "provided by the author (Sherwood 2018, personal
##   communication)" -- i.e. never published in the 2004 paper. This dataset recovers
##   just those unpublished individuals. Provenance is "unpublished, via DeCasien".
##
##   NOTE ON SCOPE: only BV and Thalamus are carried here, because in MOESM3 these
##   ref-64 rows are flagged "F" ("did not use cerebellum, neocortex, striatum, or
##   hippocampus measurements, replaced with measurements from [65]") -- so for these
##   individuals only whole-brain and thalamus are genuinely Sherwood-sourced. The
##   four published individuals are intentionally excluded (they live in TABLEI).
##
## Input
##   Sherwood_etal_2004_unpublishedviaDeCasien_snapshot.xlsx
##     (the two unpublished per-specimen rows extracted from DeCasien & Higham 2019
##      MOESM3; already in mm3.)
##
## Output
##   Sherwood_etal_2004_unpublishedviaDeCasien.csv
##   plus a DOI/PMID-coded TSV in __Public/comparative-data/ when run inside the full
##   Evo-M1-Trait-Data repo (encoded name looked up from __ReadMe.xlsx).
##
## Notes
##   - No unit conversion: MOESM3 values are already mm3.
##   - Per-individual (N = 1 each).
## =============================================================================

## ---- setup -------------------------------------------------------------------
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))    # Sherwood_etal_2004_unpublishedviaDeCasien
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_file <- paste0(item_name, "_snapshot.xlsx")
output_file   <- paste0(item_name, ".csv")
if (!file.exists(snapshot_file)) stop("Snapshot file not found: ", snapshot_file, call. = FALSE)

## ---- 1. read the extracted unpublished individuals ---------------------------
df <- readxl::read_excel(snapshot_file)

## ---- 2. tidy -----------------------------------------------------------------
num_cols <- c("brain_volume_mm3","thalamus_mm3")
df <- df %>% mutate(across(all_of(num_cols), ~suppressWarnings(as.numeric(.x))))
df$source     <- "Sherwood et al. 2004 (Am J Primatol 63:149-164); individuals provided by author (Sherwood 2018 pers. comm.) via DeCasien & Higham 2019 MOESM3 (ref 64); NOT in published Table I"
df$provenance <- "unpublished_via_DeCasien_MOESM3"

out_cols <- c("species","species_as_published","moesm3_row","N", num_cols, "source","provenance")
df <- df[, out_cols]

## ---- 3. save the analysis-ready CSV ------------------------------------------
readr::write_csv(df, output_file)

## ---- 4. also write the DOI/PMID-coded TSV to __Public/comparative-data/ ------
if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
  warning("No repository root with __ReadMe.xlsx found; TSV skipped.")
} else {
  tsv_dir   <- file.path(base, "__Public/comparative-data")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    readr::write_tsv(df, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}

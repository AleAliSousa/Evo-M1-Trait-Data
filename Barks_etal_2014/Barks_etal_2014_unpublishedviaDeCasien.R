## =============================================================================
## Barks et al. (2014) individual gorilla regional volumes -- UNPUBLISHED, recovered
## via DeCasien & Higham (2019) Supplementary Data (MOESM3, reference 65).
## "Brain organization of gorillas reflects species differences in ecology"
## Barks et al. 2014, Am J Phys Anthropol 156:252-262. DOI: 10.1002/ajpa.22646
## (DOI per the repo's __ReadMe.xlsx, matching the published Barks_etal_2014_TABLE1 item.)
## =============================================================================
##
## WHAT THIS IS / WHY IT EXISTS
##   Barks et al. (2014) published, for their post-mortem-MRI gorilla sample, only:
##     * per-individual WHOLE-BRAIN volume (Table 1), and
##     * SPECIES-MEAN regional volumes (Figs 4A / 5A).
##   The per-INDIVIDUAL regional volumes (neocortex GM+WM, neocortex GM, cerebellum,
##   striatum, hippocampus, amygdala, insula GM) were never published. DeCasien &
##   Higham (2019) obtained them and list them per specimen in MOESM3
##   ("Brain Region Data (mm3)", reference 65): 33 gorilla brains
##   (16 Gorilla gorilla gorilla, 14 Gorilla beringei, 3 Gorilla gorilla graueri).
##   This dataset recovers those individual values so they can be compared/merged.
##   Provenance is therefore "unpublished, via DeCasien": the numbers are Barks',
##   but they reach us only through the DeCasien & Higham supplement, NOT the paper.
##
## Input
##   Barks_etal_2014_unpublishedviaDeCasien_snapshot.xlsx
##     (the per-specimen rows extracted verbatim from DeCasien & Higham 2019 MOESM3;
##      already in mm3. Each row is linked to its Barks 2014 Table 1 specimen number
##      by exact whole-brain-volume match.)
##
## Output
##   Barks_etal_2014_unpublishedviaDeCasien.csv
##   plus a DOI/PMID-coded TSV in __Public/comparative-data/ when run inside the full
##   Evo-M1-Trait-Data repo (encoded name looked up from __ReadMe.xlsx).
##
## Notes
##   - No unit conversion is applied: MOESM3 values are already mm3 (the repo's
##     canonical unit). This script only reshapes/labels and writes the shared TSV.
##   - Volumes are per-individual (N = 1 each). "species" is the binomial;
##     "species_as_published" keeps DeCasien's underscored subspecies label.
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
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # Barks_etal_2014_unpublishedviaDeCasien
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_file <- paste0(item_name, "_snapshot.xlsx")
output_file   <- paste0(item_name, ".csv")
if (!file.exists(snapshot_file)) stop("Snapshot file not found: ", snapshot_file, call. = FALSE)

## ---- 1. read the extracted individual rows -----------------------------------
df <- readxl::read_excel(snapshot_file)

## ---- 2. tidy: ensure numeric measurement columns, stable column order --------
num_cols <- c("brain_volume_mm3","neocortex_GMWM_mm3","neocortex_GM_mm3","cerebellum_mm3",
              "striatum_mm3","hippocampus_mm3","amygdala_mm3","insula_GM_mm3")
df <- df %>% mutate(across(all_of(num_cols), ~suppressWarnings(as.numeric(.x))))
df$source     <- "Barks et al. 2014 (AJPA 156:252-262) individual gorilla regional volumes, via DeCasien & Higham 2019 MOESM3 (ref 65)"
df$provenance <- "unpublished_via_DeCasien_MOESM3"

out_cols <- c("species","species_as_published","barks_table1_specimen_number","moesm3_row","N",
              num_cols, "source","provenance")
df <- df[, out_cols]

## ---- 3. save the analysis-ready CSV ------------------------------------------
readr::write_csv(df, output_file)

## ---- 4. also write the DOI/PMID-coded TSV to __Public/comparative-data/ ------
## Same pattern as the deSousa / Barks-published converters: the encoded filename is
## looked up from __ReadMe.xlsx ("Item name" -> "Item encoded"), so downstream scripts
## read this table by its stable coded name.
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

## Zilles K & Palomero-Gallagher N (2017) Front. Neuroanat. 11:78 — paper folder used as the home of a
## CONSTRUCTED source: EBRAINS receptor-density fingerprint datasets (Palomero-Gallagher, Zilles, Amunts
## et al.; one Knowledge-Graph dataset per Julich-Brain area / hippocampal stratum, each with its own DOI
## 10.25493/...), fetched through siibra by <item_name>_snapshot.py into <item_name>_snapshot.csv.
## Build: frozen snapshot -> long analysis CSV (+ public TSV).  This script only READS the snapshot.
## SINGLE-SPECIES (Homo sapiens; EBRAINS datasets labelled "[human, vX.Y]").  Data role = primary (the
## datasets are the primary deposition of the Juelich autoradiography values), but the citation that the
## registry derives the TSV code from is the 2017 paper — see README "Owner decision".
## Receptor names are harmonised to the Supplementary Table 2 item where the receptor is the same
## (BZ -> GABAA/BZ; mGluR2_3 / mGluR2/3 -> mGluR2/3, kept as an extra receptor); the EBRAINS label is kept
## in receptor_ebrains (printed-name invariant).

## 0. PATHS -- self-contained ------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  for (i in rev(seq_len(sys.nframe()))) {            # source() / sys.source() (build_dataset_item)
    fn <- as.character(sys.call(i)[[1]])[1]
    if (fn %in% c("source", "sys.source")) {
      f <- get0(if (fn == "source") "ofile" else "file", envir = sys.frame(i), inherits = FALSE)
      if (is.character(f) && length(f) == 1 && file.exists(f)) return(normalizePath(f))
    }
  }
  stop("Run with Rscript file.R, source(file.R), or open in RStudio and click Source (save first).", call. = FALSE)
})
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Zilles_PalomeroGallagher_2017_EBRAINSFingerprints
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv   <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. READ FROZEN SNAPSHOT ---------------------------------------------------
snap <- utils::read.csv(snapshot_csv, colClasses = "character", check.names = FALSE,
                        encoding = "UTF-8", na.strings = character(0))
stopifnot(all(c("anchor", "regions", "feature_id", "dataset_id", "dataset_name", "dataset_doi",
                "ebrains_page", "source_tsv", "receptor", "mean", "std", "unit", "n_receptors") %in% names(snap)))
stopifnot(all(snap$unit == "fmol/mg"))

## 3. REFORMAT snapshot -> analysis data ------------------------------------
harmonise <- c("BZ" = "GABAA/BZ", "mGluR2_3" = "mGluR2/3", "mGluR2/3" = "mGluR2/3")
receptor  <- ifelse(snap$receptor %in% names(harmonise), harmonise[snap$receptor], snap$receptor)
known <- c("AMPA", "NMDA", "kainate", "GABAA", "GABAA/BZ", "GABAB", "M1", "M2", "M3",
           "alpha4beta2", "alpha1", "alpha2", "5-HT1A", "5-HT2", "D1", "mGluR2/3")
if (!all(receptor %in% known)) stop("unexpected receptor label(s): ", paste(unique(setdiff(receptor, known)), collapse = ", "))

# dataset locus and version from the KG dataset name:
#   "Density measurements of different receptors for <locus> [human, v2.0]"
dataset_locus   <- trimws(sub("^Density measurements of different receptors for (.*?)\\s*\\[human.*$", "\\1", snap$dataset_name))
dataset_version <- sub("^.*\\[human,\\s*(v[0-9.]+)\\].*$", "\\1", snap$dataset_name)
dataset_version[!grepl("^v[0-9.]+$", dataset_version)] <- NA_character_

final.dataframe <- data.frame(
  Species                 = "Homo sapiens",
  Species_EBRAINS         = "human",                 # as labelled in the dataset names "[human, vX.Y]"
  julich_area             = snap$anchor,             # Julich-Brain region the fingerprint is anchored to
  dataset_locus           = dataset_locus,           # what the dataset itself measures (e.g. "ventral part of Area 44 (IFG)", "stratum cellulare of CA (Hippocampus)")
  dataset_name            = snap$dataset_name,
  dataset_version         = dataset_version,
  receptor                = receptor,
  receptor_ebrains        = snap$receptor,
  density_fmol_mg_protein = as.numeric(snap$mean),
  sd                      = as.numeric(snap$std),
  n_receptors_in_dataset  = as.integer(snap$n_receptors),
  dataset_doi             = snap$dataset_doi,
  dataset_id              = snap$dataset_id,
  feature_id              = snap$feature_id,
  source_tsv              = snap$source_tsv,
  parcellation            = snap$parcellation,
  stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(!anyNA(final.dataframe$density_fmol_mg_protein), !anyNA(final.dataframe$dataset_version),
          nrow(final.dataframe) == nrow(snap))

## 4. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
utils::write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
filecodes    <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                   sep = "\t", row.names = FALSE, na = "", quote = TRUE)
message("Wrote ", nrow(final.dataframe), " rows -> ", basename(final_csv), " and ", item_encoded, ".tsv")

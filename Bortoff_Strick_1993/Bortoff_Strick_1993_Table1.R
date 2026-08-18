#!/usr/bin/env Rscript
# Bortoff & Strick 1993 - Table 1 (curated): species-specific corticospinal termination
# extent in the spinal ventral horn / lamina IX, and the paper's own inference about a
# corticomotoneuronal (CM) connection.
#
# FROZEN SOURCE -> Bortoff_Strick_1993_Table1_snapshot.xlsx (sheet "Table1"), built by
# Bortoff_Strick_1993_extract_snapshot.R from the PDF in this folder. This script reads
# ONLY that snapshot. The paper prints no species x trait table; the snapshot is a
# curatorial capture of the Results prose and Figures 3-11, one row per species, every cell
# carrying its page/figure. See the extract script and the README for the 0-2 rubric.
#
# Output shape: ONE ROW PER SPECIES (2).
#
# UNITS: none - CST_termination_grade is a 3-level ordinal and CM_connection_inference is a
# category. Nothing to convert (sec 6: no mass, volume or body-weight column here).
#
# CM_monosynaptic is carried as an all-NA column ON PURPOSE: the paper is explicit
# (Discussion pp. 5110-5111) that light microscopy can establish neither the presence nor
# the absence of a direct monosynaptic contact. The column exists so a later study that CAN
# settle it (spike-triggered averaging, intracellular recording) has somewhere to land.
#
# Source: Bortoff, G. A., & Strick, P. L. (1993). J Neurosci 13(12):5105-5118.
#   DOI 10.1523/JNEUROSCI.13-12-05105.1993.

## 0. PATHS --------------------------------------------------------
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
paper_dir     <- dirname(.sp)
item_name     <- "Bortoff_Strick_1993_Table1"
snapshot_xlsx <- file.path(paper_dir, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
suppressWarnings(suppressMessages(library(readxl)))

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
# The paper prints "Cebus apella"; the accepted combination is Sapajus apella (Silva 2001).
# That mapping is NOT hand-coded here - it lives in _keys/Stephan/species_key.csv as a
# Bortoff1993 row, so it is visible and reusable (sec 5). The printed name survives
# untouched in Species_printed (invariant 3).
TOKEN <- "Bortoff1993"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
read_key_rows <- function() {
  out <- list()
  if (!is.na(dataset_root))
    for (kf in list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
                          recursive = TRUE, full.names = TRUE)) {
      k <- read.csv(kf, stringsAsFactors = FALSE)
      if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
      k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
      if (nrow(k)) out[[length(out) + 1L]] <- k[, c("variant_name", "accepted_name")]
    }
  if (length(out)) return(do.call(rbind, out))
  staged <- file.path(paper_dir, "PROPOSED_species_key_rows.csv")
  if (file.exists(staged)) {
    warning("No '", TOKEN, "' rows in _keys/*/species_key.csv - falling back to the staged ",
            "PROPOSED_species_key_rows.csv. Merge it into the key, then delete the staged file.")
    k <- read.csv(staged, stringsAsFactors = FALSE)
    return(k[trimws(k$source_publication) == TOKEN, c("variant_name", "accepted_name")])
  }
  data.frame(variant_name = character(0), accepted_name = character(0))
}
km <- local({
  k <- read_key_rows(); m <- list()
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(m[[v]])) m[[v]] <- k$accepted_name[i]
  }
  m
})
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx
}

## 3. READ SNAPSHOT ------------------------------------------------
d <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table1", .name_repair = "minimal"),
                   check.names = FALSE, stringsAsFactors = FALSE)
required <- c("Species_printed", "CST_termination_grade", "CM_monosynaptic",
              "CM_connection_inference", "Segment_summary", "Method", "Source", "DOI",
              "Source_location", "Evidence_summary", "Curatorial_note")
missing <- setdiff(required, names(d))
if (length(missing)) stop("Snapshot is missing: ", paste(missing, collapse = ", "))

## 4. BUILD --------------------------------------------------------
d$CST_termination_grade <- as.integer(d$CST_termination_grade)
d$species_sci <- vapply(d$Species_printed, resolve, character(1), USE.NAMES = FALSE)
out <- d[, c("Species_printed", "species_sci", "CST_termination_grade", "CM_monosynaptic",
             "CM_connection_inference", "Segment_summary", "Method", "Source", "DOI",
             "Source_location", "Evidence_summary", "Curatorial_note")]

## 4b. CHECKS ------------------------------------------------------
stopifnot(nrow(out) == 2)
if (any(!out$CST_termination_grade %in% 0:2)) stop("CST grades must be integers 0, 1 or 2")
if (any(is.na(out$species_sci) | !nzchar(out$species_sci)))
  stop("Unresolved species name - add a ", TOKEN, " row to _keys/Stephan/species_key.csv")
if (!all(is.na(out$CM_monosynaptic)))
  warning("CM_monosynaptic is no longer all-NA: light microscopy cannot settle it, so a ",
          "non-NA value needs a new source (spike-triggered averaging or intracellular ",
          "recording) named in Source / Source_location.")
unres <- out$Species_printed[out$species_sci == out$Species_printed &
                             !out$Species_printed %in% ref]
if (length(unres)) warning("Not in species_reference.csv: ", paste(unres, collapse = ", "))

## 5. SAVE ---------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", item_name)
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  }
}

## 5b. DOWNSTREAM ---------------------------------------------------
# The trait-table feed for __merging_behaviour is NOT written here: like every other trait
# table it is built by its own reader, ____EvoM1_TraitTable/EvoM1_read_corticospinal_terminations.R,
# which reads the public TSV this script just wrote.

cat(sprintf("Bortoff & Strick 1993 Table 1: %d species; grades %s\n", nrow(out),
            paste(sort(unique(out$CST_termination_grade)), collapse = ", ")))

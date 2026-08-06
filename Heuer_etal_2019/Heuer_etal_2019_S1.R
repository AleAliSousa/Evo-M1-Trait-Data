# Heuer et al. 2019 - Supplementary Table S1: per-specimen MRI scan quality and provenance
#
# DIGITAL-NATIVE SOURCE (no derived snapshot; __HOWTO_build_a_dataset_file.md sec 0a invariant 1):
#   S1_QCtable_mmc1.tsv, unpacked verbatim from the journal supplement
#   1-s2.0-S0010945219301704-mmc1.zip. Both are kept in this folder; neither is edited.
#
# WHAT THIS TABLE IS - AND IS NOT. S1 is the scan-quality/provenance roster: one row per scanned
# specimen with SNR, voxel size, volume dimensions, in vivo flag, extracted flag and archive.
# It carries NO folding measurement. The folding metrics are in the authors' Zenodo archive
# (doi:10.5281/zenodo.2538751) which could not be reached from the authoring environment.
#
# Species: S1 prints COMMON NAMES only. They are resolved through Heuer2019 rows in
# _keys/Stephan/species_key.csv, whose accepted names are read off Table 1 of the same paper.
# The two "Gorilla" rows are deliberately left unresolved - see below.
#
# Source: Heuer, K., et al. (2019). Cortex 118:275-291. DOI 10.1016/j.cortex.2019.04.011.

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
paper_dir <- dirname(.sp)
item_name <- "Heuer_etal_2019_S1"
final_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
TOKEN <- "Heuer2019"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
km <- list()
if (!is.na(dataset_root))
  for (kf in list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
                        recursive = TRUE, full.names = TRUE)) {
    k <- read.csv(kf, stringsAsFactors = FALSE)
    if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
    k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
    for (i in seq_len(nrow(k))) {
      v <- tolower(trimws(k$variant_name[i]))
      if (nzchar(v) && is.null(km[[v]])) km[[v]] <- k$accepted_name[i]
    }
  }
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  NA_character_          # unmapped common name -> NA, never a fake binomial
}

## 3. READ FROZEN SOURCE -------------------------------------------
raw <- read.delim(file.path(paper_dir, "S1_QCtable_mmc1.tsv"), sep = "\t",
                  check.names = FALSE, stringsAsFactors = FALSE,
                  colClasses = "character", fileEncoding = "UTF-8")

## 4. CLEAN --> ANALYSIS TABLE -------------------------------------
# Voxel size and volume dimensions are printed as comma-joined triples in ONE cell; split them
# into x/y/z so they are usable, and keep the printed string as well.
split3 <- function(x, i) {
  suppressWarnings(as.numeric(vapply(strsplit(trimws(x), ",", fixed = TRUE),
                                     function(p) if (length(p) >= i) p[i] else NA_character_,
                                     character(1))))
}
out <- data.frame(
  group_printed      = trimws(raw$Group),
  Specimens_Heuer2019 = trimws(raw$Specimens),   # printed common name (invariant 3)
  species_sci        = vapply(trimws(raw$Specimens), resolve, character(1), USE.NAMES = FALSE),
  SpecimenID         = trimws(raw$SpecimenID),   # the archive's own specimen identifier
  SNR                = suppressWarnings(as.numeric(trimws(raw$SNR))),
  voxel_size_printed = trimws(raw$`Voxel size x,y,z`),
  voxel_size_x_mm    = split3(raw$`Voxel size x,y,z`, 1),
  voxel_size_y_mm    = split3(raw$`Voxel size x,y,z`, 2),
  voxel_size_z_mm    = split3(raw$`Voxel size x,y,z`, 3),
  volume_dims_printed = trimws(raw$`Volume dimensions x,y,z`),
  volume_dim_x       = split3(raw$`Volume dimensions x,y,z`, 1),
  volume_dim_y       = split3(raw$`Volume dimensions x,y,z`, 2),
  volume_dim_z       = split3(raw$`Volume dimensions x,y,z`, 3),
  in_vivo            = trimws(raw$`In vivo`),
  extracted          = trimws(raw$Extracted),
  provenance         = trimws(raw$Provenance),
  stringsAsFactors = FALSE
)
# The two rows printed simply as "Gorilla" are two DIFFERENT species: Table 1 gives
# Gorilla beringei (provenance BC) and Gorilla gorilla (provenance NCBR), and the SpecimenIDs
# agree (GorillaBeringeiG_0854 / Gorilla_kinyani). A name-keyed lookup cannot express that, so
# species_sci stays NA and the disambiguation is recorded here for the curator to place in
# _keys/specimen_crosswalk rather than being guessed inside this script.
out$species_note <- NA_character_
g <- out$Specimens_Heuer2019 == "Gorilla"
out$species_note[g] <- paste0(
  "printed name 'Gorilla' is ambiguous; Table 1 resolves it by provenance - ",
  "BC = Gorilla beringei, NCBR = Gorilla gorilla")
# S1 has 66 scanned specimens but the paper analysed 65 from 34 species. The extra row is the
# red howler monkey, which appears in S1 but has NO row in Table 1 - a scan that was acquired
# and quality-checked but left out of the analysed sample. Recorded, not dropped.
h <- out$Specimens_Heuer2019 == "Red howler monkey"
out$species_note[h] <- paste0(
  "present in S1 but absent from Table 1 - scanned and QC'd but NOT part of the ",
  "34-species / 65-individual analysed sample; binomial is the standard name for the ",
  "common name, not taken from Table 1")

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
cat(sprintf("Heuer S1: %d scanned specimens, %d resolved to a binomial, %d unresolved\n",
            nrow(out), sum(!is.na(out$species_sci)), sum(is.na(out$species_sci))))

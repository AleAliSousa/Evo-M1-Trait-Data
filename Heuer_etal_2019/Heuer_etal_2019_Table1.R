# Heuer et al. 2019 - Table 1: list of species included (34 primate species, 65 individuals)
#
# PRINTED SOURCE -> the frozen copy is Heuer_etal_2019_Table1_snapshot.xlsx (sheet "Table1"),
# a hand-verified transcription built by Heuer_etal_2019_Table1_make_snapshot.py. This script
# reads ONLY that snapshot.
#
# WHAT THIS TABLE IS - AND IS NOT. Table 1 is the sample roster: species, binomial, number of
# individuals, in vivo vs post-mortem, brain extracted or not, and provenance archive. It carries
# NO folding measurement. The absolute gyrification index, folding length, fold wavelength, fold
# depth and cerebral / convex-hull surface areas live in the authors' Zenodo archive
# (doi:10.5281/zenodo.2538751, mirrored at github.com/neuroanatomy/34primates) which could not be
# reached from the authoring environment. See the README.
#
# Sample-composition columns matter here because folding metrics are method-sensitive: in vivo
# scans and extracted (ex-cranio) brains are not directly comparable, and the paper pools them.
#
# Source: Heuer, K., Gulban, O. F., Bazin, P.-L., Osoianu, A., Valabregue, R., Santin, M.,
#   Herbin, M., & Toro, R. (2019). Evolution of neocortical folding: a phylogenetic comparative
#   analysis of MRI from 34 primate species. Cortex 118:275-291. DOI 10.1016/j.cortex.2019.04.011.

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
item_name <- "Heuer_etal_2019_Table1"
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
  cx
}

## 3. READ SNAPSHOT ------------------------------------------------
# Positional read: row 1 = caption, row 2 = header, then grade rows (only col 1 filled)
# interleaved with species rows.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table1", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:2), , drop = FALSE]
names(snap) <- c("Name", "Binomial", "N", "InVivo", "Extracted", "Provenance")
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])

## 4. CLEAN --> ANALYSIS TABLE -------------------------------------
out <- NULL; grade <- NA_character_
for (i in seq_len(nrow(snap))) {
  r <- snap[i, ]
  if (!nzchar(r$Binomial)) { grade <- r$Name; next }        # printed grade row
  out <- rbind(out, data.frame(
    grade_printed        = grade,                # Lemuriformes / Cebidae / Papionini / ...
    Name_Heuer2019       = r$Name,               # printed common name (invariant 3)
    Binomial_Heuer2019   = r$Binomial,           # printed binomial, GenBank naming (invariant 3)
    species_sci          = resolve(r$Binomial),
    n_individuals        = suppressWarnings(as.numeric(r$N)),
    in_vivo_printed      = r$InVivo,             # "No,Yes,Yes" where a row pools archives
    extracted_printed    = r$Extracted,
    provenance_printed   = r$Provenance,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL

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
# The paper states 34 primate species and 65 individuals.
stopifnot(nrow(out) == 34, sum(out$n_individuals) == 65)
cat(sprintf("Heuer Table 1: %d species, %d individuals\n", nrow(out), sum(out$n_individuals)))

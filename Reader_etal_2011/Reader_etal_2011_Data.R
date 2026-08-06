# Reader, Hager & Laland 2011 - primate behavioural flexibility dataset
# House pipeline: frozen source -> resolve species -> analysis CSV + DOI-coded public TSV.
#
# DIGITAL-NATIVE SOURCE (no derived snapshot; __HOWTO_build_a_dataset_file.md sec 0a invariant 1):
#   Data_ReaderHagerLalandPhilTrans2011.csv is the untouched Dryad download
#   (doi:10.5061/dryad.t0q94), kept verbatim alongside its own README .txt and the ESM PDF.
#   NOTE: the file uses classic-Mac CR-only line endings and has one trailing empty column;
#   both are handled on read, neither is "fixed" in the frozen file.
#
# One row per SPECIES (238 primate species). Counts are raw report frequencies from the
# literature survey; research effort is supplied separately so effort-correction stays
# reproducible downstream rather than being baked in here.
#
# Source: Reader, S. M., Hager, Y., & Laland, K. N. (2011). The evolution of primate general
#   and cultural intelligence. Phil Trans R Soc B 366(1567):1017-1027.
#   DOI 10.1098/rstb.2010.0342.  Antecedent: Reader & Laland (2002) PNAS 99(7):4436-4441,
#   whose columns are carried here as the "*_2002" block and are SUPERSEDED by the 2011 columns.

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
item_name <- "Reader_etal_2011_Data"
final_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)   # __ReadMe.xlsx Item-encoded lookup only

## 2. SPECIES RESOLVER (single source of truth = _keys) -------------
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
key_files <- if (!is.na(dataset_root))
  list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
             recursive = TRUE, full.names = TRUE) else character(0)
# Variant rows are keyed by (source_publication, variant_name) - _keys/SPECIES_NAMING.md sec 3.
# Scoping to THIS paper's token matters: the key also holds Stephan-lineage rows mapping the
# printed "Gorilla gorilla"/"Pongo pygmaeus" onto the genus-level "Gorilla sp."/"Pongo sp.".
# Those are decisions about the Dusseldorf specimens; Reader's records are ordinary
# species-level entries and must NOT inherit them.
TOKEN <- "Reader2011"
km <- list()
for (kf in key_files) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (!all(c("variant_name", "accepted_name") %in% names(k))) next
  if (!"source_publication" %in% names(k)) next
  k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(km[[v]])) km[[v]] <- k$accepted_name[i]
  }
}
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)          # 1. this paper's variant rows
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])  # 2. identity anchor
  cx                                                          # 3. printed binomial stands
}

## 3. HELPERS ------------------------------------------------------
# "Cells with no data are left blank" (source README) - blank is the only missing token.
to_num <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub(",", "", x, fixed = TRUE)
  x[x %in% c("", "NA")] <- NA
  suppressWarnings(as.numeric(x))
}

## 4. READ FROZEN SOURCE -------------------------------------------
raw <- read.csv(file.path(paper_dir, "Data_ReaderHagerLalandPhilTrans2011.csv"),
                check.names = FALSE, stringsAsFactors = FALSE,
                colClasses = "character", fileEncoding = "UTF-8")
raw <- raw[, names(raw) != "", drop = FALSE]   # drop the trailing unnamed empty column

## 5. CLEAN --> ANALYSIS TABLE -------------------------------------
out <- data.frame(
  # ---- species (both printed name systems preserved; invariant 3) ----
  Species_Reader2011 = raw$Species,          # the paper's own current-taxonomy name
  Genus_Reader2011   = raw$Genus,
  SpeciesPurvis      = raw$SpeciesPurvis,    # name under Purvis (1995), as printed
  GenusPurvis        = raw$GenusPurvis,
  species_sci        = vapply(raw$Species, resolve, character(1), USE.NAMES = FALSE),
  Taxon              = raw$Taxon,            # Simian / Prosimian / Tarsier
  Great_ape          = raw$`Great ape`,      # sensitivity-analysis grouping printed as Yes/No
  # ---- 2011 raw report counts (the measures of record) ----
  Innovation          = to_num(raw$Innovation),
  Tool_use            = to_num(raw$`Tool use`),
  Extractive_foraging = to_num(raw$`Extractive foraging`),
  Social_learning     = to_num(raw$`Social learning`),
  # ---- 2011 reduced counts: cases that qualified as >1 category removed ----
  Innovation_reduced          = to_num(raw$`Innovation (Reduced)`),
  Tool_use_reduced            = to_num(raw$`Tool use (Reduced)`),
  Extractive_foraging_reduced = to_num(raw$`Extractive foraging (Reduced)`),
  # ---- research effort (the denominator; keep raw so effort-correction is reproducible) ----
  Journal_search_article_count   = to_num(raw$`Journal Search Article Count`),
  Zoological_record_article_count = to_num(raw$`Zoological Record Article Count`),
  # ---- superseded 2002 block (Reader & Laland 2002); same lineage - never average with above ----
  Journal_reports_2002    = to_num(raw$`Journal reports (2002 dataset)`),
  Innovation_2002         = to_num(raw$`Innovation (2002 dataset)`),
  Social_learning_2002    = to_num(raw$`Social learning  (2002 dataset)`),
  Tool_use_2002           = to_num(raw$`Tool use (2002 dataset)`),
  stringsAsFactors = FALSE
)

## 6. SAVE ---------------------------------------------------------
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
cat(sprintf("Reader 2011: %d species, %d with any 2011 report\n",
            nrow(out),
            sum(rowSums(out[, c("Innovation", "Tool_use", "Extractive_foraging",
                                "Social_learning")], na.rm = TRUE) > 0)))

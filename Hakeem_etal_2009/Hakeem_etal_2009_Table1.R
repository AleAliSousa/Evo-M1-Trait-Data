## Hakeem AY, Sherwood CC, Bonar CJ, Butti C, Hof PR, Allman JM (2009).
## Von Economo neurons in the elephant brain. Anat Rec 292(2):242-248. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Input : Hakeem_etal_2009_Table1_snapshot.csv  (2 rows, one per hemisphere,
##         values as printed: thousands commas, "0.78%")
## Output: <script stem>.csv   one row per individual (1)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
##
## The snapshot is a hand transcription: the paper is not open access and has no
## machine-readable copy, so there is nothing to scrape. See the ReadMe for who
## typed it and how it was checked. This script reads that frozen file; no table
## values appear below.
##
## Shape. One row per printed row: right hemisphere then left, in printed order,
## with the printed column order. An earlier version folded the two printed rows
## into a single 22-column row of _L / _R / _total fields, on the reading of
## build HOWTO section 6. That made the CSV impossible to read against the page,
## which is the test that matters, so it is reverted. The combined figures the
## merge needs are recorded in the definitions instead - see Method:combining.
##
## The percentage. ven_pct_FI is recomputed from the printed counts and rounded
## to the precision the paper printed it at, so the column reads exactly as the
## page does (0.78 and 2.6) while still being derived rather than transcribed.
## The script stops if the two disagree.
##
## Note before using the neuron counts: FI holds 1,300,000 neurons in the right
## hemisphere and 348,000 in the left, a 3.7-fold difference within one animal,
## while the VEN counts are close (10,200 and 9,110). Printed as published and
## not reconciled here. Any per-hemisphere density will inherit it.

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder       <- dirname(.sp)
item_name    <- tools::file_path_sans_ext(basename(.sp))
source_name  <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv   <- paste0(item_name, ".csv")
base         <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 2L, ncol(snap) == 8L)
stopifnot(grepl("right", snap[[1]][1]))   # printed row order: right, then left

num <- function(x) suppressWarnings(as.numeric(gsub("[,%]", "", trimws(x))))
hemi <- ifelse(grepl("right", snap[[1]]), "R", "L")
stopifnot(setequal(hemi, c("R", "L")))

## printed precision, so the column reads as the page does
printed_pct <- sub("%$", "", trimws(snap[["VEN %"]]))
dp <- ifelse(grepl("\\.", printed_pct), nchar(sub("^.*\\.", "", printed_pct)), 0)
ven <- num(snap[["VENs in FI"]])
neu <- num(snap[["Neurons in FI"]])
pct <- mapply(function(v, n, d) round(v / n * 100, d), ven, neu, dp)
stopifnot(!anyNA(c(ven, neu, pct)))
stopifnot(all(abs(pct - as.numeric(printed_pct)) < 10^(-dp)))   # agrees with the page

clean <- data.frame(
  species               = NA_character_,       # filled from the key below
  species_as_published  = "African elephant",  # Materials and methods; not in the table
  specimen_as_published = trimws(snap[[1]]),   # the printed row label, verbatim
  specimen              = "Elephant 1",
  hemisphere            = hemi,
  ven_n_FI              = as.integer(ven),
  ven_ce_gundersen      = num(snap[["VEN CE Gunderson m = 1"]]),
  ven_ce_schmitzhof     = num(snap[["VEN CE Schmitz-Hof 1st"]]),
  neuron_n_FI           = as.integer(neu),
  neuron_ce_gundersen   = num(snap[["Neuron CE Gunderson m = 1"]]),
  neuron_ce_schmitzhof  = num(snap[["Neuron CE Schmitz-Hof 1st"]]),
  ven_pct_FI            = pct,
  n_individuals         = 1L,
  source                = source_name,
  stringsAsFactors = FALSE
)
stopifnot(all(unlist(clean[grep("_ce_", names(clean))]) <= 0.1))   # all CEs as printed

## ---- species harmonisation via the collection key (never an inline map) ----
## The table prints only "Elephant 1"; the species is in Materials and methods.
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx. ",
       "Run it from a loose folder and the species column comes out empty - ",
       "which is how the first version of this file was committed with no ",
       "species names in it.", call. = FALSE)
}
{
  key <- read.csv(key_path, stringsAsFactors = FALSE)
  key <- key[key$source_publication == source_name, ]
  lk  <- setNames(key$accepted_name, tolower(key$variant_name))
  clean$species <- unname(lk[tolower(clean$species_as_published)])
  if (anyNA(clean$species)) {
    stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
         paste(clean$species_as_published[is.na(clean$species)], collapse = "; "),
         "\n  Add the rows to the key file, not to this script.", call. = FALSE)
  }
}

stopifnot(!anyNA(clean$species))   # never write a file with an empty species column

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}

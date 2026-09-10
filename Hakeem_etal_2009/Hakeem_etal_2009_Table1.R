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
## Shape. The printed rows are hemispheres, not specimens. Per the build HOWTO
## section 6, left and right are kept as _L / _R columns and a _total is computed,
## so the merge has the combined value it expects.
##
## The percentage. The table prints VEN % per hemisphere; that is a ratio, and
## section 7 says ratios are recomputed rather than transcribed. Here both the
## numerator and the denominator are printed, so ven_pct_* is recomputed from the
## counts and checked against the printed value to the precision it was printed
## at. The combined figure is 19,310 / 1,648,000 = 1.17%. Averaging the two
## printed percentages instead gives 1.69%, which is wrong - do not do that.
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

num <- function(x) suppressWarnings(as.numeric(gsub("[,%]", "", trimws(x))))
side <- function(label) {                      # pick a printed row by hemisphere
  i <- grep(label, snap[[1]], fixed = TRUE)
  stopifnot(length(i) == 1L)
  snap[i, , drop = FALSE]
}
L <- side("left hemisphere")
R <- side("right hemisphere")

ven_L <- num(L[["VENs in FI"]]);     ven_R <- num(R[["VENs in FI"]])
neu_L <- num(L[["Neurons in FI"]]);  neu_R <- num(R[["Neurons in FI"]])
stopifnot(!is.na(c(ven_L, ven_R, neu_L, neu_R)))

pct <- function(v, n) round(v / n * 100, 2)

## the printed percentage is the transcription's own check: recompute and compare
## at the precision each was printed at (0.78% -> 2 dp, 2.6% -> 1 dp)
chk <- function(printed, v, n) {
  p  <- num(printed)
  dp <- nchar(sub("^[^.]*\\.?", "", sub("%$", "", trimws(printed))))
  stopifnot(abs(round(v / n * 100, dp) - p) < 10^(-dp))
}
chk(L[["VEN %"]], ven_L, neu_L)
chk(R[["VEN %"]], ven_R, neu_R)

clean <- data.frame(
  species               = NA_character_,       # filled from the key below
  species_as_published  = "African elephant",  # Materials and methods; not in the table
  specimen              = "Elephant 1",
  ven_n_FI_L            = as.integer(ven_L),
  ven_n_FI_R            = as.integer(ven_R),
  ven_n_FI_total        = as.integer(ven_L + ven_R),
  neuron_n_FI_L         = as.integer(neu_L),
  neuron_n_FI_R         = as.integer(neu_R),
  neuron_n_FI_total     = as.integer(neu_L + neu_R),
  ven_pct_FI_L          = pct(ven_L, neu_L),
  ven_pct_FI_R          = pct(ven_R, neu_R),
  ven_pct_FI_total      = pct(ven_L + ven_R, neu_L + neu_R),
  ven_ce_gundersen_L    = num(L[["VEN CE Gunderson m = 1"]]),
  ven_ce_gundersen_R    = num(R[["VEN CE Gunderson m = 1"]]),
  ven_ce_schmitzhof_L   = num(L[["VEN CE Schmitz-Hof 1st"]]),
  ven_ce_schmitzhof_R   = num(R[["VEN CE Schmitz-Hof 1st"]]),
  neuron_ce_gundersen_L = num(L[["Neuron CE Gunderson m = 1"]]),
  neuron_ce_gundersen_R = num(R[["Neuron CE Gunderson m = 1"]]),
  neuron_ce_schmitzhof_L= num(L[["Neuron CE Schmitz-Hof 1st"]]),
  neuron_ce_schmitzhof_R= num(R[["Neuron CE Schmitz-Hof 1st"]]),
  n_individuals         = 1L,
  source                = source_name,
  stringsAsFactors = FALSE
)
stopifnot(all(unlist(clean[grep("_ce_", names(clean))]) <= 0.1))   # all CEs as printed

## ---- species harmonisation via the collection key (never an inline map) ----
## The table prints only "Elephant 1"; the species is in Materials and methods.
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
if (!is.na(key_path) && file.exists(key_path)) {
  key <- read.csv(key_path, stringsAsFactors = FALSE)
  key <- key[key$source_publication == source_name, ]
  lk  <- setNames(key$accepted_name, tolower(key$variant_name))
  clean$species <- unname(lk[tolower(clean$species_as_published)])
  if (anyNA(clean$species)) {
    warning("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
            paste(clean$species_as_published[is.na(clean$species)], collapse = "; "),
            " -- add the rows there, not here.")
  }
} else {
  warning("_keys/Hof/species_key.csv not reachable; 'species' left empty.")
}

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

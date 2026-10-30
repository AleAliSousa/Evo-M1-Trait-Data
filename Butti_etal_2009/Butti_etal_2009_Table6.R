## Butti C, Sherwood CC, Hakeem AY, Allman JM, Hof PR (2009). Total number and
## volume of Von Economo neurons in the cerebral cortex of cetaceans.
## J Comp Neurol 515(2):243-259. Table 6.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Input : Butti_etal_2009_Table6_snapshot.csv   (4 species; each cell printed
##         "mean +/- SD" in um3, plus the printed VEN index)
## Output: <script stem>.csv   one row per species (4)
##
## Units are kept in um3 as published. The project's mm3 standard is for
## structure volumes; these are somata. Same call as Nimchinsky Table 2.
##
## The VEN index is a ratio. The caption defines it as "the ratio between the
## average volume of VEN and the average volume of pyramidal neurons", and
## recomputing it from the two printed means reproduces all four printed values
## to two decimal places. Carried both as printed and recomputed, and the script
## stops if they disagree.
##
## Region. The caption does not name a cortical region. It is recorded as ACC in
## the definitions because Table 6 covers all four species and ACC is the only
## ROI with data for all four in the paper's Table 2 - an inference, flagged as
## one, and worth confirming against the Results before these volumes are pooled
## with any other ACC measurement.

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
stopifnot(nrow(snap) == 4L, ncol(snap) == 5L)
stopifnot(identical(names(snap), c("Species", "VENs", "Pyramidal neurons",
                                   "Fusiform neurons", "VEN index")))

num  <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
part <- function(x, i) {
  p <- strsplit(trimws(x), "\u00b1", fixed = TRUE)
  num(vapply(p, function(v) { stopifnot(length(v) == 2L); v[i] }, character(1)))
}
sp <- trimws(snap$Species)
ven_m <- part(snap$VENs, 1);                 ven_s <- part(snap$VENs, 2)
pyr_m <- part(snap[["Pyramidal neurons"]], 1); pyr_s <- part(snap[["Pyramidal neurons"]], 2)
fus_m <- part(snap[["Fusiform neurons"]], 1);  fus_s <- part(snap[["Fusiform neurons"]], 2)
idx   <- num(snap[["VEN index"]])
stopifnot(!anyNA(c(ven_m, ven_s, pyr_m, pyr_s, fus_m, fus_s, idx)))

## the caption defines the index; recomputing it checks the transcription
idx_recomputed <- round(ven_m / pyr_m, 2)
stopifnot(all(abs(idx_recomputed - idx) < 0.005))

## ---- species harmonisation via the collection key (never an inline map) ----
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx.",
       call. = FALSE)
}
key <- read.csv(key_path, stringsAsFactors = FALSE)
key <- key[key$source_publication == source_name, ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
species_accepted <- unname(lk[tolower(sp)])
if (anyNA(species_accepted)) {
  stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
       paste(sp[is.na(species_accepted)], collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)
}

clean <- data.frame(
  species                 = species_accepted,
  species_as_published    = sp,
  ven_vol_um3_mean        = as.integer(ven_m),
  ven_vol_um3_sd          = as.integer(ven_s),
  pyramidal_vol_um3_mean  = as.integer(pyr_m),
  pyramidal_vol_um3_sd    = as.integer(pyr_s),
  fusiform_vol_um3_mean   = as.integer(fus_m),
  fusiform_vol_um3_sd     = as.integer(fus_s),
  ven_index_as_published  = idx,
  ven_index_recomputed    = idx_recomputed,
  source                  = source_name,
  stringsAsFactors = FALSE
)
stopifnot(nrow(clean) == 4L, !anyNA(clean$species))

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
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

# Changizi_Shimojo_2005_Table1.R
#
# Purpose
#   Reformat the frozen snapshot of Changizi & Shimojo (2005) table 1 into an
#   analysis-ready CSV.  Table 1: "Data for the average relative size of cortical
#   areas for a number of animals, measured from flattened cortical maps" -- 19
#   animals x {Latin name, areas shown, average relative size (% of neocortex),
#   SD of log10 relative size, brain mass (g), EQ, reference}.
#
# Input   Changizi_Shimojo_2005_Table1_snapshot.xlsx        sheet "Table1"
#         (built from the PDF by Changizi_Shimojo_2005_extract_snapshot.py;
#          row 1 caption, rows 2-3 the two printed header lines, rows 4-22 data,
#          row 23 the printed footnote)
#
# Outputs Changizi_Shimojo_2005_Table1.csv                  19 rows, one per animal
#         <Item encoded>.tsv in __Public/comparative-data/
#
# Units are kept AS PRINTED: relative sizes are percentages of neocortex, brain
# mass is in grams (NOT converted to mg here -- convert x1000 at merge time), EQ is
# a dimensionless index.  See reference_tables/..._Table1_definitions.csv.
#
# Blank cells: four animals (Mouse, Rat, Ferret, Cat) print no SD.  The paper says
# why (methods, p.90): for these only unflattened maps existed, so areas were counted
# and the relative size set to the inverse of twice the counted number, "standard
# deviations are accordingly not provided for these animals".  Blank therefore means
# NOT MEASURED, never zero.  The script records that as `rel_size_basis` and checks
# the arithmetic.

suppressPackageStartupMessages({
  library(readxl)
})

options(scipen = 999)

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
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- helpers ---------------------------------------------------------------
squish <- function(x) trimws(gsub("[[:space:]]+", " ", ifelse(is.na(x), "", as.character(x))))
to_num <- function(x) {
  s <- squish(x)
  s <- gsub(",", "", s)                                  # thousands separators
  s[s %in% c("", "-", "–", "—", "NA", "n.a.", "__", "e")] <- NA_character_
  suppressWarnings(as.numeric(s))
}

## ---- species key: paper-scoped, never hand-coded in this script -------------
## Accepted names live in _keys/Stephan/species_key.csv (accepted_name,
## source_publication, variant_name), filtered to this paper's token so another
## paper's decisions cannot leak in.  Until the proposed rows are merged there, the
## identical three-column PROPOSED_species_key_rows.csv in this folder stands in.
species_token <- "Changizi2005"
species_lookup <- local({
  k <- NULL
  shared <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
  if (!is.na(shared) && file.exists(shared)) {
    k <- read.csv(shared, stringsAsFactors = FALSE, check.names = FALSE)
    k <- k[squish(k$source_publication) == species_token, , drop = FALSE]
  }
  if (is.null(k) || nrow(k) == 0) {
    pend <- file.path(folder, "PROPOSED_species_key_rows.csv")
    if (!file.exists(pend))
      stop("No '", species_token, "' rows in species_key.csv and no ", basename(pend), call. = FALSE)
    message("species_key.csv has no '", species_token, "' rows yet -- reading ", basename(pend))
    k <- read.csv(pend, stringsAsFactors = FALSE, check.names = FALSE)
    k <- k[squish(k$source_publication) == species_token, , drop = FALSE]
  }
  stats::setNames(squish(k$accepted_name), tolower(squish(k$variant_name)))
})
# resolve on the printed common name first, then the printed Latin name
resolve_species <- function(...) {
  cands <- list(...)
  out <- rep(NA_character_, length(cands[[1]]))
  for (v in cands) {
    hit <- unname(species_lookup[tolower(squish(v))])
    out[is.na(out)] <- hit[is.na(out)]
  }
  out
}

## ---- read the frozen snapshot by position -----------------------------------
snap <- read_excel("Changizi_Shimojo_2005_Table1_snapshot.xlsx", sheet = "Table1",
                   col_names = FALSE, col_types = "text")
dat <- snap[4:(nrow(snap) - 1), , drop = FALSE]          # drop caption + 2 header lines + footnote
stopifnot(nrow(dat) == 19)
names(dat) <- c("animal", "latin", "areas", "avg", "sd", "brain", "eq", "ref")

## ---- clean ------------------------------------------------------------------
animal_printed     <- squish(dat$animal)
latin_name_printed <- squish(dat$latin)
areas_shown        <- as.integer(to_num(dat$areas))
avg_rel_size_pct   <- to_num(dat$avg)
sd_log_rel_size    <- to_num(dat$sd)
brain_mass_g       <- to_num(dat$brain)
EQ                 <- to_num(dat$eq)

# Methods, p.90: where only unflattened maps existed the areas were counted and the
# relative size set to 100/(2 x count); those rows print no SD.  Everything else was
# measured off a flattened map.
rel_size_basis <- ifelse(is.na(sd_log_rel_size),
                         "counted: 100/(2 x areas shown)",
                         "measured on flattened cortical map")

# The paper's own extrapolation (p.90): "from an estimate of the average relative
# size of areas within a neocortex, one can compute the extrapolated number of
# areas" -- i.e. 100 / average relative size.
n_areas_extrapolated <- round(100 / avg_rel_size_pct, 3)

final.dataframe <- data.frame(
  animal_printed       = animal_printed,
  latin_name_printed   = latin_name_printed,
  species_sci          = resolve_species(animal_printed, latin_name_printed),
  areas_shown          = areas_shown,
  avg_rel_size_pct     = avg_rel_size_pct,
  sd_log_rel_size      = sd_log_rel_size,
  rel_size_basis       = rel_size_basis,
  n_areas_extrapolated = n_areas_extrapolated,
  brain_mass_g         = brain_mass_g,
  EQ                   = EQ,
  reference_printed    = squish(dat$ref),
  source               = item_name,
  stringsAsFactors     = FALSE
)

## ---- checks -----------------------------------------------------------------
counted <- rel_size_basis == "counted: 100/(2 x areas shown)"
bad <- counted & abs(avg_rel_size_pct - 100 / (2 * areas_shown)) > 0.001
if (any(bad))
  warning("counted rows whose printed average is not 100/(2 x areas shown): ",
          paste(animal_printed[bad], collapse = ", "))
message("counted (no SD) animals: ", paste(animal_printed[counted], collapse = ", "),
        " -- all equal 100/(2 x areas shown): ", !any(bad))
if (any(is.na(final.dataframe$species_sci)))
  warning("unresolved species: ",
          paste(animal_printed[is.na(final.dataframe$species_sci)], collapse = ", "),
          " -- add a row to PROPOSED_species_key_rows.csv / species_key.csv")

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder ----------
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

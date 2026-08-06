# Changizi_Shimojo_2005_Table5.R
#
# Purpose
#   Reformat the frozen snapshot of Changizi & Shimojo (2005) table 5 into an
#   analysis-ready CSV.  Table 5: "Average number of area connections per area (10 to
#   the power of the average base-10 logarithm of the number of area connections per
#   areas), standard deviation of the logarithm of the number of area connections per
#   area, and brain mass for a variety of animals (ordered by brain mass)" -- 11
#   animals.  It is the per-animal summary of table 4.
#
# Input   Changizi_Shimojo_2005_Table5_snapshot.xlsx        sheet "Table5"
#         (row 1 caption, rows 2-5 the four printed header lines, rows 6-16 data,
#          row 17 the printed footnote)
#
# Outputs Changizi_Shimojo_2005_Table5.csv                  11 rows, one per animal
#         <Item encoded>.tsv in __Public/comparative-data/
#
# Units are kept AS PRINTED: the average is a count of area-area connections per area
# (a back-transformed log10 mean), the SD is on the log10 scale, and brain mass is in
# grams (NOT converted to mg here -- convert x1000 at merge time).
#
# No cell in this table is blank.  Rat prints SD 0.00, which is a real zero: rat has
# exactly one entry in table 4 (S1 = 7), so the log10 values have no spread.  It is
# kept as 0, not NA.

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- helpers ---------------------------------------------------------------
squish <- function(x) trimws(gsub("[[:space:]]+", " ", ifelse(is.na(x), "", as.character(x))))
to_num <- function(x) {
  s <- gsub(",", "", squish(x))
  s[s %in% c("", "-", "–", "—", "NA", "n.a.", "__", "e")] <- NA_character_
  suppressWarnings(as.numeric(s))
}

## ---- species key: paper-scoped, never hand-coded in this script -------------
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
snap <- read_excel("Changizi_Shimojo_2005_Table5_snapshot.xlsx", sheet = "Table5",
                   col_names = FALSE, col_types = "text")
dat <- snap[6:(nrow(snap) - 1), , drop = FALSE]          # drop caption + 4 header lines + footnote
stopifnot(nrow(dat) == 11)
names(dat) <- c("animal", "latin", "avg", "sd", "brain")

## ---- clean ------------------------------------------------------------------
animal_printed     <- squish(dat$animal)
latin_name_printed <- squish(dat$latin)

final.dataframe <- data.frame(
  animal_printed                    = animal_printed,
  latin_name_printed                = latin_name_printed,
  species_sci                       = resolve_species(animal_printed, latin_name_printed),
  avg_area_connections_per_area     = to_num(dat$avg),
  sd_log_area_connections_per_area  = to_num(dat$sd),
  brain_mass_g                      = to_num(dat$brain),
  source                            = item_name,
  stringsAsFactors                  = FALSE
)

## ---- checks -----------------------------------------------------------------
if (any(is.na(unlist(final.dataframe[, 4:6]))))
  warning("table 5 prints no blank cells -- a NA here means a parse failure")
if (is.unsorted(final.dataframe$brain_mass_g))
  warning("rows are not in the printed brain-mass order")
message(nrow(final.dataframe), " animals; brain mass ",
        min(final.dataframe$brain_mass_g), "-", max(final.dataframe$brain_mass_g), " g; ",
        "average connections ", min(final.dataframe$avg_area_connections_per_area), "-",
        max(final.dataframe$avg_area_connections_per_area))
if (any(is.na(final.dataframe$species_sci)))
  warning("unresolved species: ",
          paste(animal_printed[is.na(final.dataframe$species_sci)], collapse = ", "))

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

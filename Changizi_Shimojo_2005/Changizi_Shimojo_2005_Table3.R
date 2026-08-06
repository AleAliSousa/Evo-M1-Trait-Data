# Changizi_Shimojo_2005_Table3.R
#
# Purpose
#   Reformat the frozen snapshot of Changizi & Shimojo (2005) table 3 into an
#   analysis-ready CSV.  Table 3: "Number of cortical areas and total number of
#   area-area connections in a variety of neocortical sensory (or sensory-motor)
#   subnetworks" -- 10 subnetworks x {areas, edges, reference}.
#
# Input   Changizi_Shimojo_2005_Table3_snapshot.xlsx        sheet "Table3"
#         (row 1 caption, row 2 header, rows 3-12 data, row 13 the printed footnote)
#
# Outputs Changizi_Shimojo_2005_Table3.csv                  10 rows, one per subnetwork
#         <Item encoded>.tsv in __Public/comparative-data/
#
# The rows are subnetworks, not species: the same animal appears several times
# (macaque 5x, cat 3x).  The printed "Subnetwork" cell packs three things -- the
# animal, the modality, and a trailing "+" whose meaning is given in the footnote
# ("+ indicates that there are other cortical areas included in the subnetwork").
# They are split into their own columns here and the printed string is kept.
# Areas and edges are counts; no unit conversion applies.  No cell in this table is
# blank.

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
snap <- read_excel("Changizi_Shimojo_2005_Table3_snapshot.xlsx", sheet = "Table3",
                   col_names = FALSE, col_types = "text")
dat <- snap[3:(nrow(snap) - 1), , drop = FALSE]          # drop caption + header + footnote
stopifnot(nrow(dat) == 10)
names(dat) <- c("subnetwork", "areas", "edges", "ref")

## ---- clean ------------------------------------------------------------------
subnetwork_printed <- squish(dat$subnetwork)
animal_printed     <- squish(sub(",.*$", "", subnetwork_printed))       # before the comma
rest               <- squish(sub("^[^,]*,", "", subnetwork_printed))    # after the comma
includes_other_areas <- grepl("\\+\\s*$", rest)                         # footnote symbol
modality_printed   <- squish(sub("\\+\\s*$", "", rest))

final.dataframe <- data.frame(
  subnetwork_printed   = subnetwork_printed,
  animal_printed       = animal_printed,
  species_sci          = resolve_species(animal_printed),
  modality_printed     = modality_printed,
  includes_other_areas = includes_other_areas,
  n_areas              = as.integer(to_num(dat$areas)),
  n_edges              = as.integer(to_num(dat$edges)),
  reference_printed    = squish(dat$ref),
  source               = item_name,
  stringsAsFactors     = FALSE
)

## ---- checks -----------------------------------------------------------------
# an undirected network of A areas can hold at most A*(A-1)/2 edges; a directed one
# twice that.  Flag anything impossible either way.
maxdir <- final.dataframe$n_areas * (final.dataframe$n_areas - 1)
if (any(final.dataframe$n_edges > maxdir))
  warning("edges exceed A*(A-1) in: ",
          paste(subnetwork_printed[final.dataframe$n_edges > maxdir], collapse = "; "))
message(nrow(final.dataframe), " subnetworks; areas ",
        min(final.dataframe$n_areas), "-", max(final.dataframe$n_areas), ", edges ",
        min(final.dataframe$n_edges), "-", max(final.dataframe$n_edges), "; ",
        sum(includes_other_areas), " marked '+'")
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

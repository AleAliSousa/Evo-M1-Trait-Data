# Changizi_Shimojo_2005_Table2.R
#
# Purpose
#   Reformat the frozen snapshot of Changizi & Shimojo (2005) table 2 into an
#   analysis-ready CSV.  Table 2: "Data for relative size (as a percentage of
#   neocortex) of selected areas in a number of animals" -- 16 animals x
#   {V1, V2, A1, S1, M1}, each cell a percentage of neocortex.
#
# Input   Changizi_Shimojo_2005_Table2_snapshot.xlsx        sheet "Table2"
#         (row 1 caption, row 2 the "Relative size of area, %" spanner, row 3 the
#          V1/V2/A1/S1/M1 header, rows 4-19 data, row 20 the printed footnote)
#
# Outputs Changizi_Shimojo_2005_Table2.csv                  16 rows, one per animal
#         <Item encoded>.tsv in __Public/comparative-data/
#
# Units are kept AS PRINTED: every value is a percentage of the neocortex.
#
# BLANKS ARE THE POINT OF THIS TABLE.  Most rows print values for only some of the
# five areas; the paper says so in its methods ("In some animals data do not exist
# for some areas", p.90).  Blank therefore means NOT MEASURED and is carried through
# as NA -- never 0.  Mouse prints no value at all and is kept as an all-NA row,
# exactly as printed.  The snapshot was built from word x-positions precisely so that
# a missing V2 cannot slide an A1 value into the V2 column.

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
snap <- read_excel("Changizi_Shimojo_2005_Table2_snapshot.xlsx", sheet = "Table2",
                   col_names = FALSE, col_types = "text")
dat <- snap[4:(nrow(snap) - 1), , drop = FALSE]          # drop caption + 2 header lines + footnote
stopifnot(nrow(dat) == 16)
names(dat) <- c("animal", "V1", "V2", "A1", "S1", "M1")

## ---- clean ------------------------------------------------------------------
animal_printed <- squish(dat$animal)
V1 <- to_num(dat$V1); V2 <- to_num(dat$V2); A1 <- to_num(dat$A1)
S1 <- to_num(dat$S1); M1 <- to_num(dat$M1)

final.dataframe <- data.frame(
  animal_printed    = animal_printed,
  species_sci       = resolve_species(animal_printed),
  V1_pct_neocortex  = V1,
  V2_pct_neocortex  = V2,
  A1_pct_neocortex  = A1,
  S1_pct_neocortex  = S1,
  M1_pct_neocortex  = M1,
  n_areas_reported  = rowSums(!is.na(cbind(V1, V2, A1, S1, M1))),
  source            = item_name,
  stringsAsFactors  = FALSE
)

## ---- checks -----------------------------------------------------------------
message("values printed per area -- V1: ", sum(!is.na(V1)), ", V2: ", sum(!is.na(V2)),
        ", A1: ", sum(!is.na(A1)), ", S1: ", sum(!is.na(S1)), ", M1: ", sum(!is.na(M1)),
        " (of ", nrow(final.dataframe), " animals)")
message("animals with no value at all: ",
        paste(animal_printed[final.dataframe$n_areas_reported == 0], collapse = ", "))
tot <- rowSums(cbind(V1, V2, A1, S1, M1), na.rm = TRUE)
if (any(tot > 100)) warning("row of percentages exceeding 100: ",
                            paste(animal_printed[tot > 100], collapse = ", "))
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

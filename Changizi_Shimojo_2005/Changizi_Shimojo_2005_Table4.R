# Changizi_Shimojo_2005_Table4.R
#
# Purpose
#   Reformat the frozen snapshot of Changizi & Shimojo (2005) table 4 into an
#   analysis-ready CSV.  Table 4: "Number of area connections per area for a variety
#   of areas from a variety of animals, with citations shown" -- 38 printed rows
#   covering 11 animals.
#
# Input   Changizi_Shimojo_2005_Table4_snapshot.xlsx        sheet "Table4"
#         (row 1 caption, rows 2-4 the three printed header lines, rows 5-42 data,
#          row 43 the printed footnote)
#
# Outputs Changizi_Shimojo_2005_Table4.csv                  38 rows, one per printed row
#         <Item encoded>.tsv in __Public/comparative-data/
#
# Granularity is one AREA per row (not one species per row); the per-animal summary
# is table 5.  Values are counts of area-area connections; no unit conversion applies.
#
# Blank cells here are NOT missing data -- the printed table blanks the Animal and
# "Kind of areas" cells whenever they repeat the cell above, so they are filled down
# (last-observation-carried-forward) in the analysis CSV.  The one genuinely empty
# measurement is `area_connections_per_area` for the three aggregate rows (cat 40
# sensory areas; macaque 8 visual areas; macaque 56 sensory-motor areas) whose Area
# cell prints "not shown here": the paper gives only the average for those, in
# table 5.  Those stay NA and are flagged by `area_not_shown`.

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
fill_down <- function(x) {                               # "" repeats the cell above
  for (i in seq_along(x)) if (!nzchar(x[i]) && i > 1) x[i] <- x[i - 1]
  x
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
snap <- read_excel("Changizi_Shimojo_2005_Table4_snapshot.xlsx", sheet = "Table4",
                   col_names = FALSE, col_types = "text")
dat <- snap[5:(nrow(snap) - 1), , drop = FALSE]          # drop caption + 3 header lines + footnote
stopifnot(nrow(dat) == 38)
names(dat) <- c("animal", "kind", "area", "conn", "ref")

## ---- clean ------------------------------------------------------------------
animal_printed <- fill_down(squish(dat$animal))
kind_printed   <- fill_down(squish(dat$kind))
area_printed   <- squish(dat$area)

# the three aggregate rows print "not shown here" in the Area column and nothing in
# the connections column; their Kind cell carries the group size ("40 sensory areas")
area_not_shown   <- grepl("^not shown", area_printed)
n_areas_in_group <- as.integer(to_num(sub("^([0-9]+)\\s.*$", "\\1", kind_printed)))
modality         <- squish(gsub("(^[0-9]+\\s+|\\s+areas$)", "", kind_printed))

final.dataframe <- data.frame(
  animal_printed            = animal_printed,
  species_sci               = resolve_species(animal_printed),
  kind_of_areas_printed     = kind_printed,
  modality                  = modality,
  area_printed              = area_printed,
  area_not_shown            = area_not_shown,
  n_areas_in_group          = n_areas_in_group,
  area_connections_per_area = as.integer(to_num(dat$conn)),
  reference_printed         = squish(dat$ref),
  source                    = item_name,
  stringsAsFactors          = FALSE
)

## ---- checks -----------------------------------------------------------------
# every row must be either a listed area with a count, or an aggregate row with
# neither -- nothing in between
odd <- xor(area_not_shown, is.na(final.dataframe$area_connections_per_area))
if (any(odd)) warning("rows where 'not shown here' and a missing count disagree: ", sum(odd))

# QA against table 5: the paper averages over the LOGARITHMS of these counts
# ("log-transformed averages", p.90), i.e. 10^mean(log10(x)), with the SD of the
# log10 values.  Printed here for comparison with table 5 (cat and macaque cannot be
# recomputed -- their per-area counts are the ones "not shown here").
ok <- !is.na(final.dataframe$area_connections_per_area)
agg <- do.call(rbind, lapply(split(final.dataframe$area_connections_per_area[ok],
                                   final.dataframe$animal_printed[ok]),
                             function(v) data.frame(
                               n   = length(v),
                               avg = round(10^mean(log10(v)), 2),
                               # a single value has no spread; the paper prints 0.00 for rat,
                               # where R's sd() would give NA
                               sd  = round(if (length(v) > 1) stats::sd(log10(v)) else 0, 2))))
message("log-transformed averages recomputed from table 4 (compare table 5):")
print(agg)

if (any(is.na(final.dataframe$species_sci)))
  warning("unresolved species: ",
          paste(unique(animal_printed[is.na(final.dataframe$species_sci)]), collapse = ", "))

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder ----------
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows, ",
        length(unique(animal_printed)), " animals)")

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

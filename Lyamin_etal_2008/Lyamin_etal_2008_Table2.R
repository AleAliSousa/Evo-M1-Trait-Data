## Lyamin OI, Manger PR, Ridgway SH, Mukhametov LM, Siegel JM (2008).
## Cetacean sleep: an unusual form of mammalian sleep. Neurosci Biobehav Rev
## 32(8):1451-1484. Table 2, p. 1455.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Why this script was rewritten (2026-09-17). The snapshot was re-cut in
## September to match the printed table, which sets species as COLUMNS and
## parameters as ROWS. This script still expected the older species-as-rows
## layout, so its first rename() referred to a column that no longer existed and
## it stopped there. The transpose now happens here, in the build, which is
## where reshaping belongs.
##
## The output is unchanged. Lyamin_etal_2008_Table2.csv keeps exactly the column
## names and values it already had. Those names are load-bearing: they are the
## Code column of Lyamin_etal_2008_Table2_definitions.csv and the Original_Term
## column of __merging_sleep/standardized_term_by_reference/
## Lyamin_etal_2008_Table2_standardized_terms.csv. Renaming them would silently
## drop this source out of the sleep merge.
##
## Input : Lyamin_etal_2008_Table2_snapshot.csv
##         col 1 = Parameter, cols 2-5 = the four species as printed, carrying
##         their footnote letters; two rows are unit subheadings with no values
## Output: <script stem>.csv   one row per species (4)
##         <Item encoded>.tsv in __Public/comparative-data/

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
snap[is.na(snap)] <- ""
stopifnot(ncol(snap) == 5L, names(snap)[1] == "Parameter", nrow(snap) == 13L)

## ---- printed parameter row -> the column name the merge and definitions use ----
## Anchored printed literals, not values. If the snapshot's row labels ever
## change, the stopifnot below fails rather than silently dropping a column.
code_for <- c(
  "Number of animals"            = "n_animals",
  "Sex"                          = "sex",
  "Age"                          = "age",
  "Total SWS time^e"             = "total_sws_pct",
  "SWS left hemisphere"          = "sws_left_hemisphere_pct",
  "SWS in right hemisphere"      = "sws_right_hemisphere_pct",
  "Low amplitude USWS"           = "low_amp_usws_pct_tst",
  "High amplitude USWS"          = "high_amp_usws_pct_tst",
  "Asymmetrical SWS"             = "asymmetrical_sws_pct_tst",
  "Low amplitude bilateral SWS"  = "low_amp_bilateral_sws_pct_tst",
  "High amplitude bilateral SWS" = "high_amp_bilateral_sws_pct_tst"
)
param    <- trimws(snap[[1]])
is_head  <- apply(snap[-1], 1, function(r) all(!nzchar(trimws(r))))  # no values = subheading
stopifnot(sum(is_head) == 2L)                                        # the two unit subheadings
stopifnot(setequal(param[!is_head], names(code_for)))                # every data row is mapped

## ---- species columns: strip the footnote letter, keep it for the join ----
printed_cols    <- names(snap)[-1]
species_printed <- trimws(sub("\\^[a-z]$", "", printed_cols))
footnote        <- sub("^.*\\^", "", printed_cols)
stopifnot(length(species_printed) == 4L, all(nchar(footnote) == 1L))

## ---- transpose: one row per species ----
body <- snap[!is_head, , drop = FALSE]
vals <- as.data.frame(t(body[-1]), stringsAsFactors = FALSE)
names(vals)    <- unname(code_for[trimws(body[[1]])])
rownames(vals) <- NULL

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
pct <- grep("_pct$|_pct_tst$", names(vals), value = TRUE)
vals[pct]      <- lapply(vals[pct], num)
vals$n_animals <- as.integer(num(vals$n_animals))
stopifnot(!anyNA(vals[pct]), !anyNA(vals$n_animals))

## Internal check: the five composition figures are percentages of TST, so each
## species must sum to 100.
comp <- grep("_pct_tst$", names(vals), value = TRUE)
stopifnot(length(comp) == 5L, all(abs(rowSums(vals[comp]) - 100) <= 0.2))

## Do NOT check that left + right equals total_sws_pct. It does not, and printed
## footnote e says why: the hemispheres sleep separately, so the two hemisphere
## figures overlap and must never be summed. That is already recorded in the
## definitions file against total_sws_pct.

## ---- species harmonisation via the collection key (never an inline map) ----
key_path <- if (!is.na(base)) file.path(base, "_keys", "Lyamin", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx.",
       call. = FALSE)
}
key <- read.csv(key_path, stringsAsFactors = FALSE)
key <- key[key$source_publication == source_name, ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
species_accepted <- unname(lk[tolower(species_printed)])
if (anyNA(species_accepted)) {
  stop("Not in _keys/Lyamin/species_key.csv for ", source_name, ": ",
       paste(species_printed[is.na(species_accepted)], collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)
}

## ---- per-column citations: footnote letter -> printed reference ----
## The printed table attaches a footnote letter to each species column heading
## and gives the citation below the table. That lookup is data, so it lives in a
## references table rather than in this script.
ref_path <- file.path("reference_tables", paste0(item_name, "_references.csv"))
if (!file.exists(ref_path)) {
  stop("Missing ", ref_path, ", which maps the printed footnote letters to the ",
       "references they cite. Without it the reference column cannot be filled.",
       call. = FALSE)
}
refs <- read.csv(ref_path, stringsAsFactors = FALSE)
reference <- refs$citation[match(footnote, refs$ref_key)]
if (anyNA(reference)) {
  stop("No entry in ", ref_path, " for printed footnote(s): ",
       paste(footnote[is.na(reference)], collapse = ", "), call. = FALSE)
}

clean <- data.frame(
  species     = species_accepted,
  common_name = tolower(species_printed),
  vals,
  reference   = reference,
  stringsAsFactors = FALSE, check.names = FALSE
)
## the column order the definitions and the sleep merge expect
clean <- clean[, c("species", "common_name", "n_animals", "sex", "age",
                   "total_sws_pct", "sws_left_hemisphere_pct", "sws_right_hemisphere_pct",
                   "low_amp_usws_pct_tst", "high_amp_usws_pct_tst",
                   "asymmetrical_sws_pct_tst", "low_amp_bilateral_sws_pct_tst",
                   "high_amp_bilateral_sws_pct_tst", "reference")]
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

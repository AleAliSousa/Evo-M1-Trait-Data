# Lewitus_etal_2014_ExternalDatabaseS1sources.R
#
# Lewitus et al. 2014 -- External Database S1, per-species source table rolled up
# to one row per data item -> CSV + TSV
#   doi:10.1371/journal.pbio.1002000   (supplement pbio.1002000.s021.doc)
#
# SNAPSHOT build (see the references script for why a .doc needs one). This script
# reads ONLY the snapshot, plus the reference list built by
# Lewitus_etal_2014_ExternalDatabaseS1references.R (run that first).
#
# Snapshot layout (sheet "Table"): row 1 the document title, row 2 the printed intro
# paragraph, row 3 the printed header (Species / Data / Reference(s)), then the 93
# printed rows (91 species; Propithecus verreauxi and Pteropus giganteus are printed
# twice). Each Word paragraph is one line of the cell; blank paragraphs are kept,
# trailing ones dropped.
#
# Pairing items with references. The printed numbers are lined up with the data
# items by eye (blank paragraphs pad for wrapped text), so line positions are not
# reliable. Items and references are paired by ORDER instead:
#   Data cell         -> items: a blank line ends an item; a line starting with a
#                        lower-case letter continues the item above
#                        ("... neonate body" / "and brain weight").
#   Reference(s) cell -> one source per non-blank line; its numbers are the
#                        parenthesised integers on that line ("(63), (64)" = two).
#                        Text such as "Wikipedia" or "See text." is a source with
#                        no number.
#   equal counts      -> item k gets source line k.
#   unequal counts    -> not attributable item by item; row left out of the rollup
#                        (Monodelphis virgiana: two items, "(60), (61)" on one line).
#   no references     -> row left out (Tachyglossus aculeatus).
#
# Rollup. Item text is normalised for grouping: lower case, every parenthesised
# value removed (units, values and the "(- corpus callosum)" qualifier), spaces
# squeezed, no space before a comma. For each item printed for 2+ species:
#   n_species                distinct species listing the item
#   n_distinct_refs          distinct reference numbers cited for it
#   dominant_ref_number      number cited by the most species (ties -> lowest)
#   n_species_with_dominant  species citing that number
#   dominant_ref_pct         100 * n_species_with_dominant / n_species, 1 dp
#                            (species with an un-numbered source count in n_species)
#   dominant_ref_citation    from the references CSV
# Sorted by n_species (descending), then item (C-locale order).
#
# Input  : Lewitus_etal_2014_ExternalDatabaseS1sources_snapshot.xlsx   sheet: Table
#          Lewitus_etal_2014_ExternalDatabaseS1references.csv                  (built first)
# Outputs: Lewitus_etal_2014_ExternalDatabaseS1sources.csv             one row per item (19)
#          <Item encoded>.tsv in __Public/comparative-data/                    named from __ReadMe.xlsx
# Checks : restricted repo, restricted_checks/Lewitus_etal_2014/comparison/ (the item-level
#          provenance and the neocortex attribution are kept there).

library(readxl)
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
snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Table"
header_rows    <- 3L   # title, intro paragraph, printed header
refs_csv       <- "Lewitus_etal_2014_ExternalDatabaseS1references.csv"

if (!file.exists(refs_csv))
  stop(refs_csv, " not found: run Lewitus_etal_2014_ExternalDatabaseS1references.R first.", call. = FALSE)
refs <- read.csv(refs_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
n_refs <- max(refs$ref_number)

## ---- read the snapshot (all text, untrimmed) ----
raw <- suppressMessages(read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                                   col_types = "text", trim_ws = FALSE))
dat <- as.data.frame(raw[-seq_len(header_rows), 1:3], stringsAsFactors = FALSE)
names(dat) <- c("species", "data", "refs")
dat <- dat[!is.na(dat$species) & nzchar(trimws(dat$species)), ]

## ---- helpers ----
split_lines <- function(x) if (is.na(x)) character(0) else strsplit(x, "\n", fixed = TRUE)[[1]]

items_of <- function(cell) {
  items <- character(0); prev_blank <- TRUE
  for (p in split_lines(cell)) {
    q <- trimws(p)
    if (!nzchar(q)) { prev_blank <- TRUE; next }
    if (!prev_blank && grepl("^[a-z]", q, perl = TRUE) && length(items)) {
      items[length(items)] <- paste(items[length(items)], q)   # continuation line
    } else {
      items <- c(items, q)
    }
    prev_blank <- FALSE
  }
  items
}

source_lines_of <- function(cell) { q <- trimws(split_lines(cell)); q[nzchar(q)] }

ref_numbers_of <- function(line) {
  m <- regmatches(line, gregexpr("\\((\\d+)\\)", line, perl = TRUE))[[1]]
  as.integer(gsub("[()]", "", m))
}

normalise_item <- function(s) {
  s <- tolower(s)
  repeat {                                    # drop (values/units), innermost first
    t <- gsub("\\([^()]*\\)", "", s, perl = TRUE)
    if (identical(t, s)) break
    s <- t
  }
  s <- gsub("[ \t]+", " ", s, perl = TRUE)
  s <- gsub(" +([,;])", "\\1", s, perl = TRUE)
  gsub("^[ ,;]+|[ ,;]+$", "", s, perl = TRUE)
}

## ---- pair items with sources, one row per species x item x reference ----
pairs <- list(); unpaired <- character(0); no_refs <- character(0); bad_numbers <- 0L
for (i in seq_len(nrow(dat))) {
  its <- items_of(dat$data[i]); src <- source_lines_of(dat$refs[i])
  if (!length(src)) { no_refs <- c(no_refs, dat$species[i]); next }
  if (length(src) != length(its)) { unpaired <- c(unpaired, dat$species[i]); next }
  for (k in seq_along(its)) {
    nums <- ref_numbers_of(src[k])
    bad_numbers <- bad_numbers + sum(nums < 1L | nums > n_refs)
    nums <- nums[nums >= 1L & nums <= n_refs]
    if (!length(nums)) nums <- NA_integer_
    pairs[[length(pairs) + 1L]] <- data.frame(species = trimws(dat$species[i]),
                                              item = normalise_item(its[k]),
                                              ref = nums, stringsAsFactors = FALSE)
  }
}
long <- do.call(rbind, pairs)
if (bad_numbers > 0L) warning(bad_numbers, " reference number(s) outside 1..", n_refs, " ignored.")

## ---- roll up to one row per data item ----
rollup <- lapply(unique(long$item), function(it) {
  d <- long[long$item == it, ]
  n <- length(unique(d$species))
  if (n < 2L) return(NULL)
  dr <- unique(d[!is.na(d$ref), c("species", "ref")])
  if (nrow(dr)) {
    cnt <- table(dr$ref)
    top <- as.integer(max(cnt))
    dom <- min(as.integer(names(cnt)[cnt == top]))
    data.frame(data_item_normalised = it, n_species = n, n_distinct_refs = length(cnt),
               dominant_ref_number = dom, n_species_with_dominant = top,
               dominant_ref_pct = round(100 * top / n, 1),
               dominant_ref_citation = refs$citation[match(dom, refs$ref_number)],
               stringsAsFactors = FALSE)
  } else {
    data.frame(data_item_normalised = it, n_species = n, n_distinct_refs = 0L,
               dominant_ref_number = NA_integer_, n_species_with_dominant = 0L,
               dominant_ref_pct = NA_real_, dominant_ref_citation = NA_character_,
               stringsAsFactors = FALSE)
  }
})
final.dataframe <- do.call(rbind, rollup)
final.dataframe <- final.dataframe[order(-final.dataframe$n_species,
                                         final.dataframe$data_item_normalised,
                                         method = "radix"), ]
rownames(final.dataframe) <- NULL

message(nrow(dat), " table rows; left out of the rollup: ",
        length(unpaired), " unpaired (", paste(unpaired, collapse = ", "), "), ",
        length(no_refs), " without references (", paste(no_refs, collapse = ", "), ").")

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " data items)")

tsv_dir <- if (!is.na(base)) file.path(base, "__Public/comparative-data") else NA_character_
item_encoded <- if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

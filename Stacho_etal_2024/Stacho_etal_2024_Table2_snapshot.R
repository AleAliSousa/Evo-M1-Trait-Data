## ============================================================================
## Stacho_etal_2024_Table2_snapshot.R
##
## Snapshot script for Stacho_etal_2024_Table2 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). Method 2 of __HOWTO_make_a_snapshot.md:
## capture the publisher's own machine-readable table.
##
## Source captured: Table 2 ("Overview of postmortem non-human
## primate brains") of Stacho et al. (2024), "Phylogenetic reduction
## of the magnocellular red nucleus in primates and inter-subject
## variability in humans", Frontiers in Neuroanatomy 18:1331305
## (doi:10.3389/fnana.2024.1331305), from the PubMed Central full text
## frozen in this folder as fulltext.html (PMC10976583). Every value
## in the snapshot was cross-checked against the Frontiers JATS XML
## (fulltext_frontiers.xml, same folder): the two renderings agree on
## every cell (see README).
##
## Output: Stacho_etal_2024_Table2_snapshot.csv -- the table exactly
## as published: the printed headings and the 25 specimen rows in
## printed order, values as printed (including the numeric archive
## names with their printed thousands separators, "1,548", and the
## en dash in "YN 85-38" rendered as printed, U+2013). The table's
## footnote ("The family and species name, brain code, as well as
## sectioning and staining type...") is not part of the table grid
## and is not in the snapshot; it is quoted in the README.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Stacho_etal_2024_Table2_snapshot.R"   # this file's own name
  argv <- commandArgs(trailingOnly = FALSE)
  f    <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f) && basename(f) == me) return(normalizePath(f))
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == me &&
        file.exists(of)) return(normalizePath(of))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me) return(normalizePath(p))
  }
  stop("Cannot locate ", me, " -- run it with Rscript <path>.")
})
folder <- dirname(script_path)
base   <- sub("_snapshot\\.R$", "", basename(script_path))

suppressPackageStartupMessages(library(xml2))

html_path <- file.path(folder, "fulltext.html")
if (!file.exists(html_path))
  stop("fulltext.html not found in ", folder,
       " -- the frozen PMC full text must sit next to this script.")

clean_text <- function(x) {
  x <- gsub("[\u2009\u2007\u00a0]", " ", x)   # thin / figure / no-break spaces
  x <- gsub("\\s+", " ", x)
  trimws(x)
}
cell_text <- function(cell) clean_text(xml_text(cell))

doc <- read_html(html_path)
tab <- xml_find_first(doc, "//*[@id='tab2']//table")
if (inherits(tab, "xml_missing"))
  stop("Table 2 (Overview of postmortem non-human primate brains) not found in fulltext.html.")

rows <- xml_find_all(tab, ".//tr")
if (length(rows) != 26L)
  stop("Expected 26 Table 2 rows (1 heading + 25 specimens), found ",
       length(rows), ".")
grid <- lapply(rows, function(r) {
  cells <- xml_find_all(r, "./td|./th")
  if (length(cells) != 6L)
    stop("Unexpected cell count in a Table 2 row: ", length(cells))
  vapply(cells, cell_text, character(1))
})
snap <- as.data.frame(do.call(rbind, grid[-1]), stringsAsFactors = FALSE)
names(snap) <- unname(unlist(grid[[1]]))
row.names(snap) <- NULL

expected_header <- c("Taxon", "Species", "Name", "Sex", "Section plane", "Staining")
if (!identical(names(snap), expected_header))
  stop("Captured headings do not match the printed table's.")
expected_names <- c("YN81-146", "3_97", "1,548", "YN89-278", "4_97", "YN86-137",
                    "1_97", "2_97", "YN 85\u201338", "5_97", "YN82-140", "P24",
                    "DP1", "A221", "Sixi", "888", "2,408", "1,091", "1,514",
                    "M81", "M192", "M53", "1966/44", "A338", "1,333")
if (!identical(snap$Name, expected_names))
  stop("Captured specimen names do not match the printed table's rows, in order.")
stopifnot(identical(unname(unlist(snap[2, ])),
                    c("Hominidae", "Hylobates lar", "3_97", "NA", "Coronal", "Merker")))

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character")
  if (!identical(as.matrix(old), as.matrix(snap)))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}

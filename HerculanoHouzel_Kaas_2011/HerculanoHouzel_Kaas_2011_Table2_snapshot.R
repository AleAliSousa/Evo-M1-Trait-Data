## ============================================================================
## HerculanoHouzel_Kaas_2011_Table2_snapshot.R
##
## Snapshot script for HerculanoHouzel_Kaas_2011_Table2 -- writes ONLY
## the snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). Method 2 of __HOWTO_make_a_snapshot.md:
## capture the publisher's own machine-readable table.
##
## Source captured: Table 2 of the PubMed Central full text of
## Herculano-Houzel & Kaas (2011), "Gorilla and orangutan brains
## conform to the primate cellular scaling rules: Implications for
## human evolution", Brain, Behavior and Evolution 77(1):33-44
## (doi:10.1159/000322729; PMCID PMC3064932), frozen in this folder as
## fulltext.html. The PMC HTML is the publisher's digital rendering of
## the printed table; every value in the snapshot was cross-checked
## against the publisher PDF (Herculano-Houzel-2011-Gorilla and
## oranguta.pdf, same folder, Table 2 on PDF page 4, journal page 36),
## whose text layer and rendered page agree with the PMC rendering on
## every cell (see README).
##
## Output: HerculanoHouzel_Kaas_2011_Table2_snapshot.csv -- the table
## exactly as published: the printed two-row heading (the two
## "Number of cells expected from ..." group headings, expanded over
## their column spans, become the column names; the
## expected/observed/deviation sub-headings are the first body row),
## then the nine species rows in printed order, values as printed
## ("453.80 x 10^6" with the exponent caret-rendered, "-9.5%" with the
## printed minus). The table's footnote ("Deviation = 100 x
## (observed - expected)/expected") is not part of the table grid and
## is not in the snapshot; it is quoted in the README and used as a
## check in the item script.
##
## Text renderings (digits and wording untouched in every case):
##  - superscripts in the PMC HTML (the powers of ten and the
##    exponents of the two heading equations) are rendered with a
##    caret: "410.86 x 10^6", "MCb^0.987". The multiplication sign is
##    the printed one (U+00D7).
##  - subscripts in the PMC HTML (the "Cb" of CCb and MCb in the two
##    heading equations) are rendered as plain letters: "CCb",
##    "MCb".
##  - the deviation sub-headings carry the printed footnote marker
##    as a superscript: "deviation^a".
##  - minus signs in the deviation column are the printed minus
##    (U+2212), as PMC encodes them.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy. The comparison is on cell
## values and column names (Azevedo_etal_2009 pattern): identical()
## on whole data frames is sensitive to attribute order, which
## carries no meaning here.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "HerculanoHouzel_Kaas_2011_Table2_snapshot.R"   # this file's own name
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

## Cell text with superscripts rendered as "^<sup>": walk the cell's
## child nodes; text nodes verbatim, <sup> prefixed with a caret, any
## other element (em, a, sub, hr) recursed into transparently.
node_text <- function(node) {
  if (xml_type(node) == "text") return(xml_text(node))
  if (xml_name(node) == "sup") return(paste0("^", xml_text(node)))
  kids <- xml_contents(node)
  if (length(kids) == 0L) return(xml_text(node))
  paste0(vapply(kids, node_text, character(1)), collapse = "")
}
cell_text <- function(cell) clean_text(node_text(cell))

doc <- read_html(html_path)
tab <- xml_find_first(doc, "//*[@id='T2']//table")
if (inherits(tab, "xml_missing")) {
  tabs <- xml_find_all(doc, ".//table")
  tab  <- NULL
  for (tb in tabs) {
    txt <- clean_text(xml_text(tb))
    if (grepl("Species and cerebellar mass", txt, fixed = TRUE) &&
        grepl("Pongo pygmaeus", txt, fixed = TRUE)) {
      tab <- tb; break
    }
  }
}
if (is.null(tab) || inherits(tab, "xml_missing"))
  stop("Table 2 (deviation from expected cellular composition) not found ",
       "in fulltext.html.")

rows <- xml_find_all(tab, ".//tr")
if (length(rows) != 11L)
  stop("Expected 11 Table 2 rows (2 heading + 9 species), found ",
       length(rows), ".")

## Heading row 1: three cells, the two group headings spanning three
## columns each; expand the spans so every printed column has its
## group heading (or an empty cell) above it.
hdr_cells <- xml_find_all(rows[[1]], "./td|./th")
if (length(hdr_cells) != 3L)
  stop("Unexpected cell count in Table 2 heading row 1: ", length(hdr_cells))
spans <- as.integer(xml_attr(hdr_cells, "colspan"))
spans[is.na(spans)] <- 1L
if (!identical(spans, c(1L, 3L, 3L)))
  stop("Unexpected column spans in Table 2 heading row 1.")
hdr <- rep(vapply(hdr_cells, cell_text, character(1)), times = spans)
hdr[c(3L, 4L, 6L, 7L)] <- ""   # spanned cells carry no text of their own

body <- lapply(rows[-1], function(r) {
  cells <- xml_find_all(r, "./td|./th")
  if (length(cells) != 7L)
    stop("Unexpected cell count in a Table 2 row: ", length(cells))
  vapply(cells, cell_text, character(1))
})
snap <- as.data.frame(do.call(rbind, body), stringsAsFactors = FALSE)
names(snap) <- hdr
row.names(snap) <- NULL

expected_subhdr <- c("", "expected", "observed", "deviation^a",
                     "expected", "observed", "deviation^a")
if (!identical(unname(unlist(snap[1, ])), expected_subhdr))
  stop("Captured sub-heading row does not match the printed table's.")

expected_labels <- c(
  "Callithrix jacchus (0.73 g)", "Otolemur garnettii (1.20 g)",
  "Aotus trivirgatus (1.73 g)", "Saimiri sciureus (4.30 g)",
  "Cebus apella (4.60 g)", "Macaca mulatta (7.69 g)",
  "Pongo pygmaeus (35.06 g)", "Gorilla gorilla (37.56 g)",
  "Homo sapiens (154.02 g)")
if (!identical(snap[[1]][-1], expected_labels))
  stop("Captured row labels do not match the printed table's rows, in order.")
## The observed column is printed twice (once under each scaling
## rule) with the same value in every row; a capture slip between the
## two printings stops the capture here.
if (!identical(snap[[3]][-1], snap[[6]][-1]))
  stop("The two printed observed columns disagree -- capture has slipped.")
## Positional anchors on values that carry build decisions:
stopifnot(identical(snap[[3]][8],  "28.5 \u00d7 10^9"),   # Pongo observed
          identical(snap[[3]][9],  "29.3 \u00d7 10^9"),   # Gorilla observed
          identical(snap[[3]][10], "85.08 \u00d7 10^9"))  # Homo observed

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character")
  names(old) <- names(snap)   # spanned heading cells are blank; read.csv
                              # may rename them (Azevedo_etal_2009 pattern)
  if (!identical(as.matrix(old), as.matrix(snap)))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}

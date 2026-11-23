## ============================================================================
## HerculanoHouzel_etal_2007_Table1_snapshot.R
##
## Snapshot script for HerculanoHouzel_etal_2007_Table1 -- writes ONLY
## the snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). Method 2 of __HOWTO_make_a_snapshot.md:
## capture the publisher's own machine-readable table.
##
## Source captured: Table 1 of the PubMed Central full text of
## Herculano-Houzel, Collins, Wong & Kaas (2007), "Cellular scaling
## rules for primate brains", Proceedings of the National Academy of
## Sciences 104(9):3562-3567 (doi:10.1073/pnas.0611396104; PMCID
## PMC1805542), frozen in this folder as fulltext.html. The PMC HTML
## is the publisher's digital rendering of the printed table; every
## value in the snapshot was cross-checked against the publisher PDF
## (HerculanoHouzel_etal_2007.pdf, same folder, Table 1 on PDF page 2,
## journal page 3563), whose text layer -- scrambled in reading order
## but complete -- agrees with the PMC rendering on every cell (see
## README). This capture SUPERSEDES the constructed snapshot of the
## 2026-10-21 build, whose values were read by eye from a render of
## the PDF; the two agree on every cell (see README).
##
## Output: HerculanoHouzel_etal_2007_Table1_snapshot.csv -- the table
## exactly as published: the printed heading row, then the seven
## species rows and the printed "Variation, macaque/marmoset" summary
## row, in printed order, values as printed ("172.5 ± 3.5", "n.a.",
## "10.8×"). The table's footnote ("Species ordered by increasing
## brain size. Values are mean ± SD. n.a., not available.") is not
## part of the table grid and is not in the snapshot; it is quoted in
## the README and used as a check in the item script.
##
## Text renderings (digits and wording untouched in every case):
##  - superscripts in the PMC HTML (the powers of ten in the two
##    count headings) are rendered with a caret: "×10^6". The
##    multiplication sign is the printed one (U+00D7).
##  - the ± signs and the × of the Variation row are the printed
##    glyphs (U+00B1, U+00D7), as PMC encodes them.
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
  me   <- "HerculanoHouzel_etal_2007_Table1_snapshot.R"   # this file's own name
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
tab <- xml_find_first(doc, "//*[@id='T1']//table")
if (inherits(tab, "xml_missing")) {
  tabs <- xml_find_all(doc, ".//table")
  tab  <- NULL
  for (tb in tabs) {
    txt <- clean_text(xml_text(tb))
    if (grepl("Comparative cellular composition", txt, fixed = TRUE) &&
        grepl("Macaque monkey", txt, fixed = TRUE)) {
      tab <- tb; break
    }
  }
}
if (is.null(tab) || inherits(tab, "xml_missing"))
  stop("Table 1 (comparative cellular composition) not found in fulltext.html.")

rows <- xml_find_all(tab, ".//tr")
if (length(rows) != 9L)
  stop("Expected 9 Table 1 rows (1 heading + 7 species + 1 variation), found ",
       length(rows), ".")

hdr_cells <- xml_find_all(rows[[1]], "./td|./th")
if (length(hdr_cells) != 5L)
  stop("Unexpected cell count in Table 1 heading row: ", length(hdr_cells))
hdr <- vapply(hdr_cells, cell_text, character(1))
expected_hdr <- c("Species", "Body mass, g", "Brain mass, g",
                  "Total neurons, \u00d710^6", "Total nonneurons, \u00d710^6")
if (!identical(hdr, expected_hdr))
  stop("Captured heading does not match the printed table's.")

body <- lapply(rows[-1], function(r) {
  cells <- xml_find_all(r, "./td|./th")
  if (length(cells) != 5L)
    stop("Unexpected cell count in a Table 1 row: ", length(cells))
  vapply(cells, cell_text, character(1))
})
snap <- as.data.frame(do.call(rbind, body), stringsAsFactors = FALSE)
names(snap) <- hdr
row.names(snap) <- NULL

expected_labels <- c("Tree shrew", "Marmoset", "Galago", "Owl monkey",
                     "Squirrel monkey", "Capuchin monkey", "Macaque monkey",
                     "Variation, macaque/marmoset")
if (!identical(snap[[1]], expected_labels))
  stop("Captured row labels do not match the printed table's rows, in order.")
## Positional anchors on values that carry build decisions:
stopifnot(identical(snap[[5]][5], "2,075.03"),   # Squirrel monkey non-neurons:
                                                 # the candidate-erratum cell --
                                                 # PMC and the publisher PDF
                                                 # both print 2,075.03 (the
                                                 # 2,073.03 reading is HH
                                                 # 2015 Table 5's, not this
                                                 # paper's)
          identical(snap[[2]][5], "n.a."),       # Squirrel monkey body mass
          identical(snap[[4]][7], "6,376.16"))   # Macaque monkey neurons

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character")
  names(old) <- names(snap)   # read.csv may rename duplicate/blank names
                              # (Azevedo_etal_2009 pattern)
  if (!identical(as.matrix(old), as.matrix(snap)))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}

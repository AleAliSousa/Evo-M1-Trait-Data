## ============================================================================
## Stacho_etal_2024_Table1_snapshot.R
##
## Snapshot script for Stacho_etal_2024_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). Method 2 of __HOWTO_make_a_snapshot.md:
## capture the publisher's own machine-readable table.
##
## Source captured: Table 1 ("Overview of postmortem human brains")
## of Stacho et al. (2024), "Phylogenetic reduction of the
## magnocellular red nucleus in primates and inter-subject
## variability in humans", Frontiers in Neuroanatomy 18:1331305
## (doi:10.3389/fnana.2024.1331305), from the PubMed Central full text
## frozen in this folder as fulltext.html (PMC10976583). Every value
## in the snapshot was cross-checked against the Frontiers JATS XML
## (fulltext_frontiers.xml, same folder): the two renderings agree on
## every cell (see README).
##
## Output: Stacho_etal_2024_Table1_snapshot.csv -- the table exactly
## as published: the printed headings and the 11 specimen rows in
## printed order, values as printed (fresh brain weights with their
## printed thousands separators, "1,260"). The table's footnote
## ("*High-resolution brain model BigBrain (Amunts et al., 2013)")
## belongs to the pm20 row label, which the snapshot keeps as printed
## ("pm20*"); the footnote text itself is not part of the table grid
## and is quoted in the README.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Stacho_etal_2024_Table1_snapshot.R"   # this file's own name
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
tab <- xml_find_first(doc, "//*[@id='tab1']//table")
if (inherits(tab, "xml_missing"))
  stop("Table 1 (Overview of postmortem human brains) not found in fulltext.html.")

rows <- xml_find_all(tab, ".//tr")
if (length(rows) != 12L)
  stop("Expected 12 Table 1 rows (1 heading + 11 specimens), found ",
       length(rows), ".")
grid <- lapply(rows, function(r) {
  cells <- xml_find_all(r, "./td|./th")
  if (length(cells) != 5L)
    stop("Unexpected cell count in a Table 1 row: ", length(cells))
  vapply(cells, cell_text, character(1))
})
snap <- as.data.frame(do.call(rbind, grid[-1]), stringsAsFactors = FALSE)
names(snap) <- unname(unlist(grid[[1]]))
row.names(snap) <- NULL

expected_header <- c("ID", "Section type", "Gender", "Age", "Fresh brain weight (g)")
if (!identical(names(snap), expected_header))
  stop("Captured headings do not match the printed table's.")
expected_ids <- c("pm15", "pm16", "pm6", "pm7", "pm11", "pm5", "pm8", "pm9",
                  "pm10", "pm12", "pm20*")
if (!identical(snap$ID, expected_ids))
  stop("Captured row labels do not match the printed table's rows, in order.")
stopifnot(identical(snap$`Fresh brain weight (g)`[1], "1,260"),
          identical(snap$Age[10], "43"))

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

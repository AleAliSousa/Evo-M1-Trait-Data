## ============================================================================
## Neves_etal_2014_Table1_snapshot.R
##
## Snapshot script for Neves_etal_2014_Table1 -- writes ONLY the snapshot
## (house rule: snapshot scripts are separate from item scripts, one per
## item). Method 2 of __HOWTO_make_a_snapshot.md: capture the publisher's
## own machine-readable table.
##
## Source captured: Table 1 of the PubMed Central full text of Neves,
## Ferreira, Tovar-Moll, Gravett, Bennett, Kaswera, Gilissen, Manger &
## Herculano-Houzel (2014), "Cellular scaling rules for the brain of
## afrotherians", Frontiers in Neuroanatomy 8:5
## (doi:10.3389/fnana.2014.00005; PMCID PMC3925844), frozen in this
## folder as fulltext.html. The PMC HTML is the publisher's digital
## rendering of the printed table; every value in the snapshot was
## cross-checked against the publisher PDF (Neves-2014-Cellular
## scaling rul.pdf, same folder, Table 1 on PDF page 4), whose text
## layer and rendered page agree with the PMC rendering on every cell
## (see README).
##
## Output: Neves_etal_2014_Table1_snapshot.csv -- the table exactly as
## published: species as columns in printed order (headed by the
## abbreviated binomials and n as printed), measures as rows in
## printed order under their printed codes (MBD; M, N, O, DN, DO and
## O/N for each of BR, CX, HP, CxT, CB, RoB, OB), mean +/- SD strings
## kept whole, "n.a." cells kept as printed. The item script
## Neves_etal_2014_Table1.R transposes and cleans; it never reads the
## HTML.
##
## Text renderings (digits and wording untouched in every case):
##  - the printed row labels carry subscripts (M with subscript BD,
##    DN with subscript BR, and so on); PMC's HTML flattens them into
##    the plain codes the snapshot uses ("MBD", "DNBR", "O/NBR").
##  - one cell is printed inside typographic double quotes in both
##    the PDF and PMC: the Procavia capensis olfactory-bulb neuron
##    count, "20.909" (U+201C / U+201D around the digits). The
##    snapshot keeps the quotes verbatim; the item script parses the
##    number, guarded on the exact printed string (see its header).
##  - the table's footnote (the code legend printed below the table)
##    is not part of the table grid and is not in the snapshot; it is
##    quoted in the README.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy. The comparison is on cell
## values and column names (Azevedo_etal_2009 pattern): identical() on
## whole data frames is sensitive to attribute order, which carries no
## meaning here.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Neves_etal_2014_Table1_snapshot.R"   # this file's own name
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

## Cell text: walk the cell's child nodes; text nodes verbatim, any
## element (strong, em) recursed into transparently.
node_text <- function(node) {
  if (xml_type(node) == "text") return(xml_text(node))
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
    if (grepl("E. myurus", txt) && grepl("O/NOB", txt)) {
      tab <- tb; break
    }
  }
}
if (is.null(tab) || inherits(tab, "xml_missing"))
  stop("Table 1 (cellular composition) not found in fulltext.html.")

rows <- xml_find_all(tab, ".//tr")
out  <- list()
for (r in rows) {
  cells <- xml_find_all(r, "./td|./th")
  if (length(cells) != 6L)
    stop("Unexpected cell count in a Table 1 row: ", length(cells))
  out[[length(out) + 1L]] <- vapply(cells, cell_text, character(1))
}
stopifnot(length(out) == 44L)                # header + 43 printed rows
hdr <- out[[1]]
stopifnot(identical(hdr[2:6], c("E. myurus (n = 2)", "P. tetradactylus (n = 2)",
                                "A. hottentotus (n = 2)", "P. capensis (n = 2)",
                                "D. dorsalis (n = 1)")))
snap <- as.data.frame(do.call(rbind, out[-1]), stringsAsFactors = FALSE)
names(snap) <- hdr
row.names(snap) <- NULL

expected_labels <- c(
  "MBD",
  "MBR", "MCX", "MHP", "MCxT", "MCB", "MRoB", "MOB",
  "NBR", "NCX", "NHP", "NCxT", "NCB", "NRoB", "NOB",
  "OBR", "OCX", "OHP", "OCxT", "OCB", "ORoB", "OOB",
  "DNBR", "DNCX", "DNHP", "DNCxT", "DNCB", "DNRoB", "DNOB",
  "DOBR", "DOCX", "DOHP", "DOCxT", "DOCB", "DORoB", "DOOB",
  "O/NBR", "O/NCX", "O/NHP", "O/NCxT", "O/NCB", "O/NRoB", "O/NOB")
stopifnot(identical(snap[[1]], expected_labels))
## Positional anchors on values that carry build decisions:
stopifnot(identical(unname(unlist(snap[1, 2:6])),
                    c("45.08", "132.50", "79.00", "2517.00", "1150.00")),
          identical(snap[[5]][15], "\u201c20.909\u201d"),  # NOB, P. capensis:
                                        # printed inside typographic quotes
          identical(snap[[4]][8],  "0.050"),   # MOB, A. hottentotus (no SD)
          identical(snap[[6]][8],  "n.a."),    # MOB, D. dorsalis
          identical(snap[[4]][15], "n.a."))    # NOB, A. hottentotus

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character")
  names(old) <- names(snap)   # the first printed heading is blank; read.csv
                              # may rename it (Azevedo_etal_2009 pattern)
  if (!identical(as.matrix(old), as.matrix(snap)))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}

## ============================================================================
## Gabi_etal_2010_Table1_snapshot.R
##
## Snapshot script for Gabi_etal_2010_Table1 -- writes ONLY the snapshot
## (house rule: snapshot scripts are separate from item scripts, one per
## item). Method 2 of __HOWTO_make_a_snapshot.md: capture the publisher's
## own machine-readable table.
##
## Source captured: Table 1 of the PubMed Central full text of Gabi,
## Collins, Wong, Torres, Kaas & Herculano-Houzel (2010), "Cellular
## scaling rules for the brains of an extended number of primate
## species", Brain, Behavior and Evolution 76(1):32-44
## (doi:10.1159/000319872; PMCID PMC2980814), frozen in this folder as
## fulltext.html. The PMC HTML is the publisher's digital rendering of
## the printed table; every value in the snapshot was cross-checked
## against the publisher PDF (Gabi-2010-Cellular scaling rul.pdf, same
## folder, Table 1 on PDF page 4), whose text layer and rendered page
## agree with the PMC rendering on every cell (see README).
##
## Output: Gabi_etal_2010_Table1_snapshot.csv -- the table exactly as
## published: species as columns in printed order, measures as rows in
## printed order (the printed table is transposed relative to the
## analysis CSV), the four printed structure heading rows kept as rows
## with empty value cells, "n.a." cells kept as printed, and the
## printed fold-variation column (headed by the Greek capital delta)
## kept as the last column. The item script
## Gabi_etal_2010_Table1.R transposes and cleans; it never reads the
## HTML.
##
## Text renderings (digits and wording untouched in every case):
##  - superscripts in the PMC HTML (exponents and the two body-mass
##    footnote markers) are rendered with a caret: "393.66 x 10^6",
##    "480^1", "5,700^2". The multiplication sign is the printed one
##    (U+00D7).
##  - PMC's HTML renders the last column's printed heading, the Greek
##    capital delta (U+0394, confirmed in the publisher PDF), as the
##    letter "A"; the snapshot restores the printed glyph.
##  - the table's footnotes are not part of the table grid and are not
##    in the snapshot; they are quoted in the README ("N = Number of
##    neuronal cells; NN = number of non-neuronal cells";
##    "1 From Stephan et al., 1981"; "2 From Burish et al., 2010").
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
  me   <- "Gabi_etal_2010_Table1_snapshot.R"   # this file's own name
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
## other element (em, a) recursed into transparently.
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
    if (grepl("Microcebus murinus", txt) && grepl("Remaining areas", txt)) {
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
  if (length(cells) == 1L) {
    cs <- xml_attr(cells[[1]], "colspan")   # printed rule line: skip
    if (!is.na(cs) && cs == "7") next
  }
  if (length(cells) != 7L)
    stop("Unexpected cell count in a Table 1 row: ", length(cells))
  out[[length(out) + 1L]] <- vapply(cells, cell_text, character(1))
}
stopifnot(length(out) == 37L)                # header + 36 printed rows
hdr <- out[[1]]
stopifnot(identical(hdr[2:6], c("Microcebus murinus", "Callimico goeldii",
                                "Macaca fascicularis", "Macaca radiata",
                                "Papio cynocephalus")),
          identical(hdr[7], "A"))            # PMC's rendering of the delta
hdr[7] <- "\u0394"                           # printed heading (publisher PDF)
snap <- as.data.frame(do.call(rbind, out[-1]), stringsAsFactors = FALSE)
names(snap) <- hdr
row.names(snap) <- NULL

expected_labels <- c(
  "n", "Body mass, g",
  "Whole brain", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N",
  "Cerebral cortex", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N", "Neuronal density, N/mg",
  "Non-neuronal density, NN/mg",
  "Cerebellum", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N", "Neuronal density, N/mg",
  "Non-neuronal density, NN/mg",
  "Remaining areas", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N", "Neuronal density, N/mg",
  "Non-neuronal density, NN/mg")
stopifnot(identical(snap[[1]], expected_labels))
## Positional anchors on values that carry build decisions:
stopifnot(identical(snap[[3]][2],  "480^1"),          # Callimico body mass, fn 1
          identical(snap[[4]][2],  "5,700^2"),        # M. fascicularis, fn 2
          identical(snap[[3]][30], "248.44 \u00d7 10^9"),  # RoB cells, Callimico:
                                        # exponent misprinted in the paper
          identical(snap[[2]][30], "61.88 \u00d7 10^6"))

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

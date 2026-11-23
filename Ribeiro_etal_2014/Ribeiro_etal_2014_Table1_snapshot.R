## ============================================================================
## Ribeiro_etal_2014_Table1_snapshot.R
##
## Snapshot script for Ribeiro_etal_2014_Table1 -- writes ONLY the snapshot
## (house rule: snapshot scripts are separate from item scripts, one per
## item). Method 2 of __HOWTO_make_a_snapshot.md: capture the publisher's
## own machine-readable table.
##
## Source captured: Table 1 of the PubMed Central full text of Ribeiro,
## Manger, Catania, Kaas & Herculano-Houzel (2014), "Greater addition of
## neurons to the olfactory bulb than to the cerebral cortex of
## eulipotyphlans but not rodents, afrotherians or primates", Frontiers
## in Neuroanatomy 8:23 (doi:10.3389/fnana.2014.00023; PMCID
## PMC3990053), frozen in this folder as fulltext.html. The PMC HTML is
## the publisher's digital rendering of the printed table; every value
## in the snapshot was cross-checked against the publisher PDF
## (Ribeiro-2014-Greater addition of neurons to th.pdf, same folder,
## Table 1 on PDF page 4), whose text layer and rendered page agree
## with the PMC rendering on every cell (see README).
##
## Output: Ribeiro_etal_2014_Table1_snapshot.csv -- the table exactly
## as published: species as rows in printed order under their printed
## clade headings (GLIRES, PRIMATES, SCANDENTIA, EULIPOTYPHLA,
## AFROTHERIA, kept as heading rows), measures as columns in printed
## order (Mass, g; Neurons; % Neurons; Neurons/mg), mean +/- SD
## strings kept whole. The item script Ribeiro_etal_2014_Table1.R
## cleans; it never reads the HTML.
##
## Text renderings (digits and wording untouched in every case):
##  - superscripts are caret-rendered (Gabi_etal_2010 pattern): the
##    printed "10" with superscript "6" appears as "10^6".
##  - the Neurons column's SD term is printed with a plus-minus glyph
##    where a multiplication sign belongs -- "3.89 x 10^6 +/- 1.25
##    +/- 10^6" -- in BOTH the PDF (verified on the rendered page at
##    300 dpi) and the PMC HTML. This is a typesetting error in the
##    published table, not a capture artefact; the snapshot keeps the
##    printed glyph verbatim and the item script interprets the SD
##    term as x 10^6, guarded on the exact printed pattern.
##  - species names are printed as in the paper, including its
##    misspelling "Petrodomus tetradactylus" (for Petrodromus) in the
##    Afrotheria block; the item script maps it to the accepted
##    binomial used by Neves et al. (2014) and Herculano-Houzel et
##    al. (2015).
##  - the table's footnote (printed below the table) is not part of
##    the table grid and is not in the snapshot; it is quoted in the
##    README. It reads: "All values refer to both olfactory bulbs.
##    % Neurons, percentage of cells in the olfactory bulb that are
##    NeuN+. Neurons/mg, density of neurons per miligram of
##    olfactory bulb tissue. Data from Sarko et al. (2009),
##    Herculano-Houzel et al. (2011), Neves et al. (2014) and this
##    study."
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
  me   <- "Ribeiro_etal_2014_Table1_snapshot.R"   # this file's own name
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
## element recursed into transparently, except <sup>, which is
## caret-rendered ("10^6") following the Gabi_etal_2010 snapshot.
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
if (inherits(tab, "xml_missing"))
  stop("Table 1 (cellular composition of the olfactory bulb) not found in fulltext.html.")

groups <- c("GLIRES", "PRIMATES", "SCANDENTIA", "EULIPOTYPHLA", "AFROTHERIA")
rows <- xml_find_all(tab, ".//tr")
out  <- list()
for (r in rows) {
  cells <- xml_find_all(r, "./td|./th")
  vals  <- vapply(cells, cell_text, character(1))
  if (length(vals) == 1L && vals[1] %in% groups) {
    out[[length(out) + 1L]] <- c(vals[1], "", "", "", "")   # printed clade heading
  } else if (length(vals) == 5L) {
    out[[length(out) + 1L]] <- vals
  } else {
    stop("Unexpected cell count in a Table 1 row: ", length(vals))
  }
}
stopifnot(length(out) == 29L)                # header + 5 headings + 23 species
hdr <- out[[1]]
stopifnot(identical(hdr, c("Species", "Mass, g", "Neurons", "% Neurons",
                           "Neurons/mg")))
snap <- as.data.frame(do.call(rbind, out[-1]), stringsAsFactors = FALSE)
names(snap) <- hdr
row.names(snap) <- NULL

expected_species <- c(
  "Mus musculus", "Mesocricetus auratus", "Rattus norvegicus",
  "Proechimys cayennensis", "Cavia porcellus", "Sciurus carolinensis",
  "Oryctolagus cuniculus", "Dasyprocta primnolopha",
  "Hydrochoerus hydrochoeris",
  "Microcebus murinus", "Callithrix jacchus", "Otolemur garnetti",
  "Aotus trivirgatus", "Macaca mulatta",
  "Tupaia glis",
  "Sorex fumeus", "Blarina brevicauda", "Parascalops breweri",
  "Condylura cristata", "Scalopus aquaticus",
  "Petrodomus tetradactylus", "Elephantulus myurus", "Procavia capensis")
is_group <- snap[[1]] %in% groups
stopifnot(identical(snap[[1]][is_group], groups),
          identical(snap[[1]][!is_group], expected_species))
## Positional anchors on values that carry build decisions:
stopifnot(identical(snap[[3]][2], "3.89 \u00d7 10^6 \u00b1 1.25 \u00b1 10^6"),
                                        # Mus musculus Neurons: the printed
                                        # +/- in place of x in the SD term
          identical(snap[[2]][28], "0.286"),   # Procavia capensis mass (no SD)
          identical(snap[[3]][28], "20.91 \u00d7 10^6"),
          identical(snap[[5]][13], "232,309 \u00b1 137,605"))  # Callithrix N/mg

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

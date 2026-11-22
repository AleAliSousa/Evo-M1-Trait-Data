## ============================================================================
## HerculanoHouzel_etal_2006_Table1_snapshot.R
##
## Snapshot script for HerculanoHouzel_etal_2006_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item scripts,
## one per item). Method 2 of __HOWTO_make_a_snapshot.md: capture the
## publisher's own machine-readable table.
##
## Source captured: Table 1 of the PubMed Central full text of
## Herculano-Houzel, Mota & Lent (2006), "Cellular scaling rules for rodent
## brains", PNAS 103(32):12138-12143 (doi:10.1073/pnas.0604911103;
## PMCID PMC1567708), frozen in this folder as fulltext.html. The PMC HTML
## is the publisher's digital rendering of the printed table; every value
## in the snapshot was cross-checked against the publisher PDF
## (Herculano-Houzel-2006-Cellular scaling rul.pdf, same folder, PDF
## page 2), whose text layer agrees with the PMC rendering on every cell,
## including the agouti total-neurons value, which is printed without a
## +/- term in both renderings.
##
## Output: HerculanoHouzel_etal_2006_Table1_snapshot.csv -- the table
## exactly as published (printed column headings, printed species order
## (vernacular names) and verbatim cell strings, e.g. "40.4 ± 11.6",
## "2,843.3 ± 195.5", "856.74"), before any cleaning. The printed
## "Variation" summary row is kept in the snapshot; the item script
## HerculanoHouzel_etal_2006_Table1.R drops it. PMC renders the printed
## "(x10^6)" multiplier as "(×106)"; the heading is kept as rendered.
## The item script reads this file; it never reads the HTML.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and the
## freshly captured table differs from it, this script stops instead of
## overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "HerculanoHouzel_etal_2006_Table1_snapshot.R"   # this file's own name
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

doc    <- read_html(html_path)
tables <- xml_find_all(doc, ".//table")
tab    <- NULL
for (tb in tables) {
  txt <- clean_text(xml_text(tb))
  if (grepl("Capybara", txt) && grepl("Total neurons", txt)) { tab <- tb; break }
}
if (is.null(tab)) stop("Table 1 (cellular composition) not found in fulltext.html.")

rows <- xml_find_all(tab, ".//tr")
out  <- list()
for (r in rows) {
  cells <- clean_text(xml_text(xml_find_all(r, ".//td|.//th")))
  if (length(cells) != 5L) next
  out[[length(out) + 1L]] <- cells
}
stopifnot(length(out) == 8L)                       # header + 6 species + Variation
snap <- as.data.frame(do.call(rbind, out[-1]), stringsAsFactors = FALSE)
names(snap) <- out[[1]]
stopifnot(identical(snap[[1]], c("Mouse", "Hamster", "Rat", "Guinea pig",
                                 "Agouti", "Capybara", "Variation")))

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character",
                         na.strings = "")
  if (!identical(old, snap))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}

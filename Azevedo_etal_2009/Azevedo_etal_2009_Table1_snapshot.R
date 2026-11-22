## ============================================================================
## Azevedo_etal_2009_Table1_snapshot.R
##
## Snapshot script for Azevedo_etal_2009_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item scripts,
## one per item). Method 3 of __HOWTO_make_a_snapshot.md: extract the
## table programmatically from the PDF.
##
## Source captured: Table 1 of Azevedo et al. (2009), "Equal numbers of
## neuronal and nonneuronal cells make the human brain an isometrically
## scaled-up primate brain", J Comp Neurol 513(5):532-541
## (doi:10.1002/cne.21974), from the publisher PDF supplied by the
## curator (Azevedo-2009-Equal numbers of neu.pdf, this folder; the
## table is on PDF page 8, journal page 539). There is no open-access
## HTML full text to scrape instead (the article is not in PubMed
## Central or Europe PMC), so the frozen PDF in this folder is the
## capture source. The extraction reads the PDF's word geometry with
## poppler's pdftotext -bbox (the same poppler text layer the R package
## pdftools wraps; pdftools itself is not required), clusters the words
## of the left-hand page column into the printed rows and columns, and
## types NO value by hand: every cell is anchored by stopifnot checks
## on the printed row labels, in printed order.
##
## Output: Azevedo_etal_2009_Table1_snapshot.csv -- the table exactly as
## published: the printed column headings (Expected / Observed /
## Difference over an unheaded first column), the five printed group
## rows ("For a primate of 75 kg", ...) kept as rows with empty value
## cells, and the twelve data rows, verbatim ("1,362", "170.97",
## "+10.7%"). The table's footnote ("Results are given in billions") is
## asserted present in the source and quoted in the item README; like
## the HH2006 snapshot, the snapshot file holds the table grid only.
##
## Glyph note: the PDF's font encodes the printed "+" of the Difference
## column as U+2D19 and the printed minus as U+2013 in the text layer
## (the HH2011 build notes the same +/- corruption in this publisher's
## text layers). The snapshot maps those two codepoints back to the
## glyphs actually printed, "+" and U+2212; digits and text are taken
## over unchanged.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Azevedo_etal_2009_Table1_snapshot.R"   # this file's own name
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

pdf_path <- file.path(folder, "Azevedo-2009-Equal numbers of neu.pdf")
if (!file.exists(pdf_path))
  stop("Publisher PDF not found in ", folder,
       " -- Azevedo-2009-Equal numbers of neu.pdf must sit next to this script.")
if (!nzchar(Sys.which("pdftotext")))
  stop("pdftotext (poppler) not found on PATH -- it provides the word geometry.")

## ---- word geometry of PDF page 8 (journal page 539) --------------------------
bbox <- paste(system2("pdftotext", c("-f", "8", "-l", "8", "-bbox",
                                     shQuote(pdf_path), "-"),
                      stdout = TRUE),
              collapse = "\n")
hits <- regmatches(bbox, gregexpr(
  '<word xMin="[0-9.]+" yMin="[0-9.]+" xMax="[0-9.]+" yMax="[0-9.]+">[^<]*</word>',
  bbox))[[1]]
grab <- function(pat) as.numeric(sub(pat, "\\1", hits))
words <- data.frame(
  xMin = grab('.*xMin="([0-9.]+)".*'), yMin = grab('.*yMin="([0-9.]+)".*'),
  xMax = grab('.*xMax="([0-9.]+)".*'),
  text = sub('.*>([^<]*)</word>', "\\1", hits), stringsAsFactors = FALSE)
words$xc <- (words$xMin + words$xMax) / 2

## The table sits in the left column of the two-column page (x < 300 pt);
## the right column starts at x = 303.7 and is body text, not table.
w <- words[words$xMin < 300, ]
page_text <- paste(w$text, collapse = " ")
if (!grepl("TABLE 1. Observed and Expected Cellular Composition", page_text, fixed = TRUE))
  stop("Table 1 title not found on PDF page 8.")
if (!grepl("Results are given in billions.", page_text, fixed = TRUE))
  stop("Table 1 footnote ('Results are given in billions.') not found.")

## ---- cluster words into printed lines ---------------------------------------
w <- w[order(w$yMin, w$xMin), ]
row_id <- cumsum(c(TRUE, diff(w$yMin) > 3.5))
lines <- lapply(split(w, row_id), function(d) d[order(d$xMin), ])
line_text <- vapply(lines, function(d) paste(d$text, collapse = " "),
                    character(1))

hdr <- which(grepl("^Expected Observed Difference$", line_text))
if (length(hdr) != 1L) stop("Column header row (Expected/Observed/Difference) not found.")
foot <- which(grepl("^1 Results are given in billions\\.$", line_text))
if (length(foot) != 1L || foot <= hdr) stop("Footnote row not found below the header.")
centers <- vapply(c("Expected", "Observed", "Difference"), function(h) {
  d <- lines[[hdr]]; d$xc[d$text == h]
}, numeric(1))

body <- lines[(hdr + 1L):(foot - 1L)]
if (length(body) != 17L)
  stop("Expected 17 table rows (5 group + 12 data), found ", length(body), ".")

cells_of <- function(d) {
  lab <- d$xMin < 168
  vals <- vapply(centers, function(cx) {
    sel <- !lab & abs(d$xc - cx) < 30
    paste(d$text[sel], collapse = " ")
  }, character(1))
  c(paste(d$text[lab], collapse = " "), vals)
}
snap <- as.data.frame(t(vapply(body, cells_of, character(4))),
                      stringsAsFactors = FALSE)
names(snap) <- c("", "Expected", "Observed", "Difference")
rownames(snap) <- NULL   # drop the page-line indices inherited from the line list

## The Difference column's signs, as printed (see glyph note in the header).
snap$Difference <- gsub("\u2013", "\u2212", gsub("\u2d19", "+", snap$Difference,
                                                 fixed = TRUE))

expected_labels <- c(
  "For a primate of 75 kg",
  "Total brain mass (g)", "Total number of brain cells",
  "Total number of brain neurons", "Total number of brain nonneurons",
  "For a primate brain of 1,508 g",
  "Total number of neurons", "Total number of nonneurons",
  "For a primate cortex of 1,233 g",
  "Total number of neurons", "Total number of nonneurons",
  "For a primate cerebellum of 154 g",
  "Total number of neurons", "Total number of nonneurons",
  "For a primate RoB of 118 g",
  "Total number of neurons", "Total number of nonneurons")
if (!identical(snap[[1]], expected_labels))
  stop("Captured row labels do not match the printed table's rows, in order.")
group_rows <- c(1L, 6L, 9L, 12L, 15L)
if (!all(snap$Expected[group_rows] == "" & snap$Observed[group_rows] == "" &
         snap$Difference[group_rows] == ""))
  stop("A group row carries values -- the capture has slipped a row.")
if (!all(nzchar(snap$Expected[-group_rows]) & nzchar(snap$Observed[-group_rows]) &
         nzchar(snap$Difference[-group_rows])))
  stop("A data row is missing a value -- the capture has slipped a cell.")

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character")
  names(old) <- names(snap)   # the first printed heading is blank; read.csv may rename it
  if (!identical(as.matrix(old), as.matrix(snap)))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}

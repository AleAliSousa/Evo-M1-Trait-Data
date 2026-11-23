## ============================================================================
## Phillips_Sherwood_2005_Table1_snapshot.R
##
## Snapshot script for Phillips_Sherwood_2005_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item scripts,
## one per item). Method 3 of __HOWTO_make_a_snapshot.md: extract the
## table programmatically from the PDF.
##
## Source captured: Table 1 of Phillips & Sherwood (2005), "Primary
## motor cortex asymmetry is correlated with handedness in capuchin
## monkeys (Cebus apella)", Behavioral Neuroscience 119(6):1701-1704
## (doi:10.1037/0735-7044.119.6.1701), from the publisher PDF frozen in
## this folder (Phillips-2005-Primary-motor-cortex-asymmetry-i.pdf;
## the table is on PDF page 3, journal page 1703). The extraction reads
## the PDF's word geometry with poppler's pdftotext -bbox, clusters
## the words into the printed rows and columns, and types NO value by
## hand: every cell is anchored by stopifnot checks on the printed row
## labels, in printed order.
##
## Geometry notes: the printed minus signs (U+2AFA, the APA font's minus glyph) are separate words
## sitting ~2 pt above their digits; the row clustering (gap > 3.5 pt)
## keeps each minus with its row, and cell assembly re-attaches a lone
## minus word to the number that follows it in the same column band.
## The printed heading wraps over two lines ("Simple" / "Central
## sulcus" above the main heading line); both heading clusters are
## asserted word-for-word below and the snapshot uses the combined
## printed headings, documented here, not silently.
##
## Output: Phillips_Sherwood_2005_Table1_snapshot.csv -- the table
## exactly as published: 7 monkey rows in printed order under the
## printed headings. Negative values carry the printed U+2AFA minus;
## the build script converts them to ASCII for analysis.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Phillips_Sherwood_2005_Table1_snapshot.R"
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

pdf_path <- file.path(folder, "Phillips-2005-Primary-motor-cortex-asymmetry-i.pdf")
if (!file.exists(pdf_path))
  stop("Publisher PDF not found in ", folder)
if (!nzchar(Sys.which("pdftotext")))
  stop("pdftotext (poppler) not found on PATH -- it provides the word geometry.")

## ---- word geometry of PDF page 3 (journal page 1703) -------------------------
bbox <- paste(system2("pdftotext", c("-f", "3", "-l", "3", "-bbox",
                                     shQuote(pdf_path), "-"),
                      stdout = TRUE),
              collapse = "\n")
hits <- regmatches(bbox, gregexpr(
  '<word xMin="[0-9.]+" yMin="[0-9.]+" xMax="[0-9.]+" yMax="[0-9.]+">[^<]*</word>',
  bbox))[[1]]
num <- function(h, attr) as.numeric(sub(paste0('.*', attr, '="([0-9.]+)".*'), "\\1", h))
words <- data.frame(
  x = num(hits, "xMin"), y = num(hits, "yMin"),
  text = sub(".*>([^<]*)</word>", "\\1", hits), stringsAsFactors = FALSE)

## Table window and printed column bands (xMin ranges).
win <- words[words$x >= 110 & words$x < 500 & words$y >= 110 & words$y <= 210, ]
bands <- rbind(c(110, 160), c(160, 205), c(205, 260), c(260, 325),
               c(325, 385), c(385, 440), c(440, 500))
MINUS <- "⫺"

## Cluster words into printed rows: sorted y, new row when the gap
## exceeds 3.5 pt (printed row pitch is ~9 pt; a minus sign sits
## ~2 pt above its digits and stays with its row).
win <- win[order(win$y, win$x), ]
grp <- cumsum(c(TRUE, diff(win$y) > 3.5))
assemble <- function(w) {
  cells <- character(7)
  for (b in seq_len(nrow(bands))) {
    tok <- w$text[w$x >= bands[b, 1] & w$x < bands[b, 2]]
    if (!length(tok)) next
    out <- character(0)
    for (t in tok) {
      if (identical(t, MINUS)) out <- c(out, MINUS)
      else if (length(out) && identical(out[length(out)], MINUS))
        out[length(out)] <- paste0(MINUS, t)
      else out <- c(out, t)
    }
    cells[b] <- paste(out, collapse = " ")
  }
  cells
}
row_cells <- lapply(split(win, grp), assemble)
grid <- as.data.frame(do.call(rbind, row_cells), stringsAsFactors = FALSE)
names(grid) <- c("Monkey ID", "Age (in years)", "Simple reaching HI",
                 "Simple reaching z", "Tube task MHI", "Tube task z",
                 "Central sulcus AQ")

## The first two clusters are the printed heading rows (the heading
## wraps: "Simple" and "Central sulcus" sit above the main line).
stopifnot(identical(unname(unlist(grid[1, ])),
                    c("", "", "Simple", "", "", "Central", "sulcus")),
          identical(unname(unlist(grid[2, ])),
                    c("Monkey ID", "Age (in years)", "reaching HI",
                      "Simple reaching z", "Tube task MHI", "Tube task z", "AQ")))
snap <- grid[-(1:2), ]
row.names(snap) <- NULL
stopifnot(nrow(snap) == 7L)
expected_ids <- c("CA003", "H03", "CA9207", "H04", "CG29", "H02", "H06")
if (!identical(snap$`Monkey ID`, expected_ids))
  stop("Captured monkey IDs do not match the printed table's rows, in order.")
## Positional anchors on values that carry build decisions:
stopifnot(identical(unname(unlist(snap[1, ])),
                    c("CA003", "18", paste0(MINUS, "0.84"), "6.52",
                      paste0(MINUS, "1.00"), paste0(MINUS, "14.59"), "10.80")),
          identical(unname(unlist(snap[7, ])),
                    c("H06", "1", paste0(MINUS, "0.12"), "0.83", "0.39",
                      "10.44", paste0(MINUS, "0.20"))))

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

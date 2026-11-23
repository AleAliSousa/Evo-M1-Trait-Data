## ============================================================================
## Semendeferi_etal_2011_Table3_snapshot.R
##
## Snapshot script for Semendeferi_etal_2011_Table3 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). Method 3 of __HOWTO_make_a_snapshot.md:
## extract the table programmatically from the PDF.
##
## Source captured: Table 3 of Semendeferi et al. (2011), "Spatial
## organization of neurons in the frontal pole sets humans apart from
## great apes", Cerebral Cortex 21(7):1485-1497
## (doi:10.1093/cercor/bhq191), from the publisher PDF frozen in this
## folder (Semendeferi-2011-Spatial organization of.pdf; the table is
## on PDF page 5, journal page 1489). The article is not in PubMed
## Central or Europe PMC, so the frozen PDF is the capture source (the
## Azevedo_etal_2009 pattern). The extraction reads the PDF's word
## geometry with poppler's pdftotext -bbox, clusters the words of the
## right-hand page column into the printed rows and columns, and types
## NO value by hand: every cell is anchored by stopifnot checks on the
## printed row labels, in printed order. The capture window ends at
## x = 560 so the rotated publisher download line at x = 570 cannot
## leak into the BA 17 column.
##
## Output: Semendeferi_etal_2011_Table3_snapshot.csv -- the table
## exactly as published: the printed headings ("BA 10 (SD)" etc.) and
## the six species rows, each cell the printed "mean (SD)" string
## (GLR, dimensionless). The table's note (the region key) is not part
## of the table grid and is not in the snapshot; it is quoted in the
## README.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Semendeferi_etal_2011_Table3_snapshot.R"   # this file's own name
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

pdf_path <- file.path(folder, "Semendeferi-2011-Spatial organization of.pdf")
if (!file.exists(pdf_path))
  stop("Publisher PDF not found in ", folder,
       " -- Semendeferi-2011-Spatial organization of.pdf must sit next to this script.")
if (!nzchar(Sys.which("pdftotext")))
  stop("pdftotext (poppler) not found on PATH -- it provides the word geometry.")

## ---- word geometry of PDF page 5 (journal page 1489) -------------------------
bbox <- paste(system2("pdftotext", c("-f", "5", "-l", "5", "-bbox",
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

## Table window (right column) and printed column bands (xMin ranges).
win <- words[words$x >= 308 & words$x < 560 & words$y >= 478 & words$y <= 548, ]
bands <- rbind(c(308, 360), c(360, 415), c(415, 468), c(468, 520), c(520, 560))

win <- win[order(win$y, win$x), ]
grp <- cumsum(c(TRUE, diff(win$y) > 3.5))
row_cells <- lapply(split(win, grp), function(w) {
  cells <- character(5)
  for (i in seq_len(nrow(w))) {
    b <- which(w$x[i] >= bands[, 1] & w$x[i] < bands[, 2])
    if (length(b) == 1L)
      cells[b] <- paste(c(cells[b], w$text[i])[nzchar(c(cells[b], w$text[i]))],
                        collapse = " ")
  }
  cells
})
grid <- as.data.frame(do.call(rbind, row_cells), stringsAsFactors = FALSE)
expected_header <- c("Species", "BA 10 (SD)", "BA 4 (SD)", "BA 3 (SD)", "BA 17 (SD)")
stopifnot(identical(unname(unlist(grid[1, ])), expected_header))
names(grid) <- expected_header
snap <- grid[-1, ]
row.names(snap) <- NULL
stopifnot(nrow(snap) == 6L)
if (!identical(snap$Species, c("Human", "Bonobo", "Chimpanzee", "Gorilla",
                               "Orangutan", "Gibbon")))
  stop("Captured row labels do not match the printed table's rows, in order.")
## Positional anchors:
stopifnot(identical(snap$`BA 10 (SD)`[1], "0.18 (0.04)"),
          identical(snap$`BA 17 (SD)`[6], "0.39 (0.05)"),
          all(grepl("^[0-9]+\\.[0-9]+ \\([0-9]+\\.[0-9]+\\)$", as.matrix(snap[, -1]))))

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

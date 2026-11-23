## ============================================================================
## Semendeferi_etal_2011_Table1_snapshot.R
##
## Snapshot script for Semendeferi_etal_2011_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item scripts,
## one per item). Method 3 of __HOWTO_make_a_snapshot.md: extract the
## table programmatically from the PDF.
##
## Source captured: Table 1 ("Specimens") of Semendeferi et al. (2011),
## "Spatial organization of neurons in the frontal pole sets humans
## apart from great apes", Cerebral Cortex 21(7):1485-1497
## (doi:10.1093/cercor/bhq191), from the publisher PDF frozen in this
## folder (Semendeferi-2011-Spatial organization of.pdf; the table is
## on PDF page 3, journal page 1486). The article is not in PubMed
## Central or Europe PMC, so the frozen PDF is the capture source (the
## Azevedo_etal_2009 pattern). The extraction reads the PDF's word
## geometry with poppler's pdftotext -bbox, clusters the words of the
## left-hand page column into the printed rows and columns, and types
## NO value by hand: every cell is anchored by stopifnot checks on the
## printed row labels, in printed order.
##
## Output: Semendeferi_etal_2011_Table1_snapshot.csv -- the table
## exactly as published: 19 specimen rows in printed order under the
## printed headings. The species (group) label is printed only on the
## first row of each group; continuation rows have an empty Species
## cell, as printed. The printed heading wraps: "Brain weight" carries
## "(g)" on a second line; the snapshot column name is the combined
## "Brain weight (g)" and the "(g)" heading row is asserted, then
## dropped (documented here, not silently).
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Semendeferi_etal_2011_Table1_snapshot.R"   # this file's own name
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

## ---- word geometry of PDF page 3 (journal page 1486) -------------------------
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

## Table window (left column) and printed column bands (xMin ranges).
win <- words[words$x >= 45 & words$x < 300 & words$y >= 250 & words$y <= 435, ]
bands <- rbind(c(45, 105), c(105, 160), c(160, 195), c(195, 250), c(250, 300))

## Cluster words into printed rows: sorted y, new row when the gap
## exceeds 3.5 pt (printed row pitch is ~8 pt; within-row jitter < 1 pt).
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
names(grid) <- c("Species", "Specimen", "Sex", "Age (years)", "Brain weight (g)")

## The first two clusters are the printed heading rows.
stopifnot(identical(unname(unlist(grid[1, ])),
                    c("Species", "Specimen", "Sex", "Age (years)", "Brain weight")),
          identical(unname(unlist(grid[2, ])), c("", "", "", "", "(g)")))
snap <- grid[-(1:2), ]
row.names(snap) <- NULL
stopifnot(nrow(snap) == 19L)

expected_specimens <- c("H988", "SN146", "SN16", "SN189", "SN382", "SN281",
                        "SN56", "SN207", "YN86", "Zahlie", "Chimp 1", "YN89",
                        "Bathsheba", "YN82", "YN85", "Briggs", "Harry",
                        "Disco", "YN81")
if (!identical(snap$Specimen, expected_specimens))
  stop("Captured specimen labels do not match the printed table's rows, in order.")
stopifnot(identical(snap$Species,
                    c("Human", rep("", 7), "Bonobo", "", "Chimpanzee", "", "",
                      "Gorilla", "Orangutan", "", "", "Gibbon", "")))
## Positional anchors on values that carry build decisions:
stopifnot(identical(unname(unlist(snap[18, ])), c("Gibbon", "Disco", "F", "22", "120")),
          identical(unname(unlist(snap[19, ])), c("", "YN81", "F", "Ad", "92")),
          identical(snap$`Brain weight (g)`[1], "1633"))

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

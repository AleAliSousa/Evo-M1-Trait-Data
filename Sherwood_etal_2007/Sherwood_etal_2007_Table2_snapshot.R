## ============================================================================
## Sherwood_etal_2007_Table2_snapshot.R
##
## Snapshot script for Sherwood_etal_2007_Table2 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). The capture source is the PMC author
## manuscript HTML frozen in this folder (fulltext.html, PMC2680156;
## Europe PMC's full-text XML endpoint returns an error for this
## article, so the PMC HTML rendering is the capture source). The
## table is extracted programmatically from the HTML and no value is
## typed by hand.
##
## Source captured: Table 2 of Sherwood, Wahl, Erwin, Hof & Hopkins
## (2007), Journal of Comparative Neurology 503(4):525-537
## (doi:10.1002/cne.21399) -- population-level asymmetries: mean AQ,
## SD, t and P for HI and the 11 neuroanatomical variables of
## Table 1 (n = 18). The printed table's first column (the variable
## names) carries no heading in the PMC rendering; the snapshot
## names it "Variable", documented here.
##
## Output: Sherwood_etal_2007_Table2_snapshot.csv -- the table
## exactly as published: 12 variable rows in printed order. Negative
## values carry the HTML's U+2212 minus; the build converts for
## analysis.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Sherwood_etal_2007_Table2_snapshot.R"
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

html_path <- file.path(folder, "fulltext.html")
if (!file.exists(html_path)) stop("PMC full text not found in ", folder)
doc <- xml2::read_html(html_path)
clean <- function(x) trimws(gsub("\\s+", " ", xml2::xml_text(x)))
tables <- xml2::xml_find_all(doc, "//table")
stopifnot(length(tables) == 2L)
extract <- function(tbl) {
  rows <- xml2::xml_find_all(tbl, ".//tr")
  do.call(rbind, lapply(rows, function(tr) {
    cells <- xml2::xml_find_all(tr, "./td | ./th")
    vapply(cells, clean, character(1))
  }))
}
grid <- extract(tables[[2]])
stopifnot(identical(unname(grid[1, ]), c("", "Mean AQ", "SD", "t", "P")))
snap <- as.data.frame(grid[-1, , drop = FALSE], stringsAsFactors = FALSE)
names(snap) <- c("Variable", "Mean AQ", "SD", "t", "P")
row.names(snap) <- NULL
stopifnot(nrow(snap) == 12L,
          identical(snap$Variable[1], "Coordinated bimanual HI"),
          identical(snap$`Mean AQ`[1], "0.30"))

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

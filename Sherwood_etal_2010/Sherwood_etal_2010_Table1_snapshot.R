## ============================================================================
## Sherwood_etal_2010_Table1_snapshot.R
##
## Snapshot script for Sherwood_etal_2010_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). The capture source is the PMC author
## manuscript HTML frozen in this folder (fulltext.html, PMC4676573;
## Europe PMC's full-text XML endpoint returns an error for this
## article, so the PMC HTML rendering is the capture source). The
## table is extracted programmatically from the HTML and no value is
## typed by hand.
##
## Source captured: Table 1 ("Data used in this study") of Sherwood
## et al. (2010), "Neocortical synaptophysin asymmetry and
## behavioral lateralization in chimpanzees (Pan troglodytes)",
## European Journal of Neuroscience 31(8):1456-1464
## (doi:10.1111/j.1460-9568.2010.07168.x) -- per-individual data for
## 33 chimpanzees. Missing values are captured as printed: the
## protein-expression AQ cell holds an en dash (U+2013) for 12
## animals and PMI holds "N/A" for 4; both are kept verbatim here
## and converted to missing only in the build.
##
## Output: Sherwood_etal_2010_Table1_snapshot.csv -- the table
## exactly as published: 33 subject rows in printed order under the
## printed headings. Negative values carry the HTML's U+2212 minus;
## the build script converts them to ASCII for analysis.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Sherwood_etal_2010_Table1_snapshot.R"
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
extract <- function(tbl) {
  rows <- xml2::xml_find_all(tbl, ".//tr")
  do.call(rbind, lapply(rows, function(tr) {
    cells <- xml2::xml_find_all(tr, "./td | ./th")
    vapply(cells, clean, character(1))
  }))
}
grids <- lapply(tables, extract)
printed_hdr <- c("Subject", "Sex", "Age at death (years)", "PMI (h)",
                 "Rearing history", "SY-immunoreactive puncta density AQ",
                 "SY protein expression level AQ", "Handedness index",
                 "Handedness category")
hit <- which(vapply(grids, function(g)
  ncol(g) == 9L && identical(unname(g[1, ]), printed_hdr), logical(1)))
stopifnot(length(hit) == 1L)
grid <- grids[[hit]]
snap <- as.data.frame(grid[-1, , drop = FALSE], stringsAsFactors = FALSE)
names(snap) <- printed_hdr
row.names(snap) <- NULL
stopifnot(nrow(snap) == 33L)
expected_codes <- c("C0630", "C5625", "C0594", "C4751", "C0368", "C3001",
                    "C0342", "C2108", "C0320", "C0406", "C2105", "C0336",
                    "C0408", "C0200", "C0242", "C0645", "C5960", "C5872",
                    "C5531", "C0507", "C0491", "C0576", "C4630", "C5389",
                    "C0429", "C0423", "C3961", "C0573", "C0369", "C9698",
                    "C0301", "C0273", "C0367")
if (!identical(snap$Subject, expected_codes))
  stop("Captured codes do not match the printed table's rows, in order.")
stopifnot(sum(snap$`SY protein expression level AQ` == "–") == 12L,
          sum(snap$`PMI (h)` == "N/A") == 4L,
          identical(snap$`Handedness index`[1], "0.51"))

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

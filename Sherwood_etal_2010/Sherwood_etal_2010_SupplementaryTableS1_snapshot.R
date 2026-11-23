## ============================================================================
## Sherwood_etal_2010_SupplementaryTableS1_snapshot.R
##
## Snapshot script for Sherwood_etal_2010_SupplementaryTableS1 --
## writes ONLY the snapshot (house rule: snapshot scripts are
## separate from item scripts, one per item).
##
## Source captured: Supplementary Table S1 of Sherwood et al.
## (2010), European Journal of Neuroscience 31(8):1456-1464
## (doi:10.1111/j.1460-9568.2010.07168.x), from the supplementary
## Word document attached to the PMC author manuscript and frozen in
## this folder (NIHMS741073-supplement-Supp_Materials.doc). The
## script converts the .doc to HTML with LibreOffice (headless, into
## a temp directory) and extracts the table programmatically from
## the HTML; no value is typed by hand.
##
## The table gives the per-hemisphere SY-immunoreactive puncta
## densities (number of puncta per 10^8/mm3) from which Table 1's
## density AQs were calculated, for the same 33 chimpanzees. The
## conversion's table has a trailing footnote row ("F = female, M =
## male, Age at death in years"); only rows whose first cell is a
## subject code are captured, and their order is asserted.
##
## Output: Sherwood_etal_2010_SupplementaryTableS1_snapshot.csv --
## the table exactly as published: 33 subject rows in printed order
## under the printed headings (minus signs are the document's ASCII
## hyphens, as printed).
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Sherwood_etal_2010_SupplementaryTableS1_snapshot.R"
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

doc_path <- file.path(folder, "NIHMS741073-supplement-Supp_Materials.doc")
if (!file.exists(doc_path)) stop("Supplementary document not found in ", folder)
soffice <- Sys.which("soffice")
if (!nzchar(soffice)) soffice <- Sys.which("libreoffice")
if (!nzchar(soffice)) stop("LibreOffice (soffice) not found on PATH.")

tmp <- tempfile("supp_"); dir.create(tmp)
on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
## Convert via a shell call: soffice's launcher needs its program
## directory on LD_LIBRARY_PATH when started from an R session
## (a plain system2() call fails to load libreglo.so in this
## environment); the prefix is added only when that directory exists.
lo_prog <- "/usr/lib/libreoffice/program"
prefix <- if (dir.exists(lo_prog))
  sprintf("LD_LIBRARY_PATH=%s ", lo_prog) else ""
cmd <- sprintf("%s%s --headless -env:UserInstallation=file:///tmp/lo_profile_s1 --convert-to html --outdir %s %s",
               prefix, shQuote(soffice), shQuote(tmp), shQuote(doc_path))
if (system(cmd, intern = FALSE) != 0L)
  stop("LibreOffice conversion of the supplementary document failed.")
html_file <- list.files(tmp, pattern = "\\.html$", full.names = TRUE)
stopifnot(length(html_file) == 1L)
doc <- xml2::read_html(html_file)
clean <- function(x) trimws(gsub("\\s+", " ", xml2::xml_text(x)))
tables <- xml2::xml_find_all(doc, "//table")
stopifnot(length(tables) == 1L)
rows <- xml2::xml_find_all(tables[[1]], ".//tr")
grid <- do.call(rbind, lapply(rows, function(tr) {
  cells <- xml2::xml_find_all(tr, "./td | ./th")
  vapply(cells, clean, character(1))
}))
printed_hdr <- c("Subject", "Sex", "Age", "SY-ir puncta density - left",
                 "SY-ir puncta density - right", "SY-ir puncta density AQ")
stopifnot(identical(unname(grid[1, ]), printed_hdr))
body <- grid[-1, , drop = FALSE]
body <- body[grepl("^C[0-9]+$", body[, 1]), , drop = FALSE]
snap <- as.data.frame(body, stringsAsFactors = FALSE)
names(snap) <- printed_hdr
row.names(snap) <- NULL
expected_codes <- c("C0630", "C5625", "C0594", "C4751", "C0368", "C3001",
                    "C0342", "C2108", "C0320", "C0406", "C2105", "C0336",
                    "C0408", "C0200", "C0242", "C0645", "C5960", "C5872",
                    "C5531", "C0507", "C0491", "C0576", "C4630", "C5389",
                    "C0429", "C0423", "C3961", "C0573", "C0369", "C9698",
                    "C0301", "C0273", "C0367")
stopifnot(nrow(snap) == 33L)
if (!identical(snap$Subject, expected_codes))
  stop("Captured codes do not match the printed table's rows, in order.")
stopifnot(identical(snap$`SY-ir puncta density - left`[1], "1.76"),
          identical(snap$`SY-ir puncta density - left`[19], "3.28"),
          identical(snap$`SY-ir puncta density AQ`[19], "-0.91"))

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

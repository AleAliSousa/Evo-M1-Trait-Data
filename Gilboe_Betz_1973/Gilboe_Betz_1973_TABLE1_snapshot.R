# Gilboe_Betz_1973_TABLE1_snapshot.R ------------------------------------------------------
#
# Freezes the snapshot (ONLY Gilboe_Betz_1973_TABLE1_snapshot.csv) of Gilboe, D. D., & Betz, A. L. (1973). Oxygen uptake in the isolated canine brain. American Journal of Physiology, 224(3), 588-595.
# DOI 10.1152/ajplegacy.1973.224.3.588. Source PDF: gilboe_betz_1973.pdf (journal pp. 588-595 (PDF pages 1-8)).
#
# Source: OCR text layer, partly garbled (± as zt/&); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_extract_snapshot.R
# pattern); this script freezes the TABLE1 block to <paper>_<locus>_snapshot.csv and the
# item build script Gilboe_Betz_1973_TABLE1.R READS that frozen file. No cleaning happens here.
#
# Fidelity conventions: one snapshot row per printed row (caption, header tiers,
# section rows, footnotes included); blank padding under spanning headers;
# a cell printed on two lines is one cell holding a newline; superscript footnote
# letters are written ^a; asterisks, daggers and parenthesised numbers as printed;
# subscripts are written inline (CMRO2, Paco2); a printed superscript that is a
# typesetting slip is kept (^2).
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders at
# 300 and 500 dpi, read at 2-5x zoom; verified by re-reading every row across
# against fresh crops after the tables' own arithmetic was run (see README).
# ---------------------------------------------------------------------------

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)
paper  <- basename(folder)


## Parse a printed block: one line per printed row, cells separated by "|";
## "\\n" inside a field is a printed line break within one cell.
as_grid <- function(block, ncol) {
  lines <- strsplit(sub("^\n", "", sub("\n$", "", block)), "\n", fixed = TRUE)[[1]]
  g <- do.call(rbind, lapply(lines, function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    if (length(x) > ncol) stop("row has more than ", ncol, " cells: ", line, call. = FALSE)
    length(x) <- ncol; x[is.na(x)] <- ""; x }))
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  Encoding(g) <- "UTF-8"   # the source file is UTF-8 whatever the session locale
  g
}
read_frozen <- function(file, header) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
## Refuse to silently overwrite a frozen copy that differs: a snapshot is
## evidence, and a changed value must be a deliberate, reviewed edit.
freeze <- function(grid, locus, header = NULL) {
  file <- file.path(folder, paste0(paper, "_", locus, "_snapshot.csv"))
  if (file.exists(file)) {
    old <- read_frozen(file, header = !is.null(header))
    if (!identical(dim(old), dim(grid)) || !identical(unname(old), unname(grid)))
      stop(paper, "_", locus, ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and move ",
           "the superseded file to archive/ before re-running.", call. = FALSE)
    message(paper, "_", locus, ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    ## written byte-for-byte as UTF-8 (every field quoted, quotes doubled), so the
    ## result does not depend on the session locale
    q <- function(x) paste0('"', gsub('"', '""', x, fixed = TRUE), '"')
    rows <- c(if (!is.null(header)) paste(q(header), collapse = ","),
              apply(grid, 1, function(r) paste(q(r), collapse = ",")))
    con <- file(file, open = "wb"); writeLines(enc2utf8(rows), con, useBytes = TRUE); close(con)
    message(paper, "_", locus, ": wrote ", basename(file), " (", nrow(grid), " rows x ", ncol(grid), " cols)")
  }
  invisible(file)
}


## ---- TABLE1 (16 printed rows x 3 columns) --------------------
TABLE1_printed <- "
TABLE 1. Conditions during perfusion of isolated brain||
|Halothane|Sodium Pentobarbital
Arterial pH|7.358 ± 0.003 (100)|7.383 ± 0.007 (100)
Arterial Pco2, mm Hg|36.0 ± 0.4 (100)|40.0 ± 0.6 (100)
Arterial Po2, mm Hg|463 ± 8 (100)|587 ± 14 (99)
Venous Po2, mm Hg|34.6 ± 1.1 (100)|39.7 ± 1.1 (98)
Brain weight, g|85.0 ± 1.1 (25)|87.4 ± 1.5 (25)
Blood flow rate, ml/100 g per min|47.3 ± 0.7 (100)|39.2 ± 1.0 (100)
Perfusion pressure, mm Hg|121 ± 2 (419)|107 ± 1 (469)
Hematocrit, %|22.2 ± 0.4 (100)|23.0 ± 0.6 (100)
Na+, mEq/liter|146 ± 2 (30)\\n[147 ± 1 (147)]|
K+, mEq/liter|4.19 ± 0.08 (31)\\n[4.31 ± 0.05 (146)]|
Mg++, mEq/liter|1.75 ± 0.12 (31)\\n[1.35 ± 0.05 (148)]|
Ca++, mEq/liter|4.88 ± 0.03 (31)\\n[4.74 ± 0.02 (148)]|
Cl-, mEq/liter|118 ± 2 (30)\\n[117 ± 1 (167)]|
Values are means ± SE with the number of determinations shown in parentheses. With the exception of the perfusion pressure and the electrolyte values in brackets, the data were obtained at the moment O2 uptake and CO2 efflux were determined. The perfusion pressure is the average of measurements made at 10-min intervals during the first 150 min of perfusion. The electrolyte values in brackets were obtained during experiments conducted under similar conditions, but not included in this study.||
"
g <- as_grid(TABLE1_printed, 3L)
stopifnot(nrow(g) == 16L, ncol(g) == 3L)
freeze(g, "TABLE1")

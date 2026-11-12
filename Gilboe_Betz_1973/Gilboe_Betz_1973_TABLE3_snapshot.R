# Gilboe_Betz_1973_TABLE3_snapshot.R ------------------------------------------------------
#
# Freezes the snapshot (ONLY Gilboe_Betz_1973_TABLE3_snapshot.csv) of Gilboe, D. D., & Betz, A. L. (1973). Oxygen uptake in the isolated canine brain. American Journal of Physiology, 224(3), 588-595.
# DOI 10.1152/ajplegacy.1973.224.3.588. Source PDF: gilboe_betz_1973.pdf (journal pp. 588-595 (PDF pages 1-8)).
#
# Source: OCR text layer, partly garbled (± as zt/&); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_extract_snapshot.R
# pattern); this script freezes the TABLE3 block to <paper>_<locus>_snapshot.csv and the
# item build script Gilboe_Betz_1973_TABLE3.R READS that frozen file. No cleaning happens here.
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


## ---- TABLE3 (5 printed rows x 8 columns) --------------------
TABLE3_printed <- "
TABLE 3. Oxygen uptake and carbon dioxide efflux before and during pentylenetetrazol and epinephrine administration|||||||
|Flow Rate, ml/100 g per min|Control O2 Uptake, ml/100 g per min|P|Experimental O2 Uptake, ml/100 g per min|Control CO2 Efflux, (ml/100 g per min)|P|Experimental CO2 Efflux, ml/100 g per min
Pentylenetetrazol|52.5\\n± 2.4\\n(5)|4.08\\n± 0.20\\n(19)|NS|3.78\\n± 0.16\\n(20)|3.55\\n± 0.41\\n(19)|NS|4.36\\n± 0.49\\n(20)
Epinephrine|72.9\\n± 8.4\\n(3)|3.66\\n± 0.18\\n(8)|NS|3.90\\n± 0.14\\n(12)|5.64\\n± 0.97\\n(8)|NS|4.66\\n± 0.71\\n(12)
Values are means ± SE, with the number of determinations shown in parentheses. NS means no significant difference exists between the 2 values that are compared (P > 0.05).|||||||
"
g <- as_grid(TABLE3_printed, 8L)
stopifnot(nrow(g) == 5L, ncol(g) == 8L)
freeze(g, "TABLE3")

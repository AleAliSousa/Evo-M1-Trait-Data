# Nilsson_Siesjö_1976_TABLEIII_snapshot.R ---------------------------------------------------
#
# Freezes the snapshot of Nilsson, B., & Siesjö, B. K. (1976). A method for determining blood flow and oxygen consumption in the rat brain. Acta Physiologica Scandinavica, 96(1), 72-82.
# DOI 10.1111/j.1748-1716.1976.tb10172.x. Source PDF: Nilsson-1976-A method for determi.pdf (journal pp. 72-82 (PDF pages 1-11)).
#
# Source: OCR text layer, garbled for the table (± read as k/&/+); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_extract_snapshot.R
# pattern); this script freezes the TABLEIII block to <paper>_TABLEIII_snapshot.csv (only) and the
# item build scripts READ those frozen files. No cleaning happens here.
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

## ---- TABLEIII (5 printed rows x 7 columns) --------------------
TABLEIII_printed <- "
TABLE III. Mean arterial blood pressure (MABP), Paco2, arterial oxygen content ([To2]a), arteriovenous difference in oxygen content (AVDo2), CBF and CMRo2 in normocapnia, hypocapnia and hypercapnia. The values are means ±S.E.||||||
Exp. group|MABP|Paco2|[To2]a|AVDo2|CBF|CMRo2
Normocapnia\\n(n=8)|138\\n±2|34.9\\n±0.6|21.11\\n±0.48|9.59\\n±0.34|79.5\\n±2.4|7.58\\n±0.18
Hypocapnia\\n(n=4)|146\\n±7|16.8\\n±1.6|22.61\\n±0.79|14.44\\n±1.08|52.2\\n±4.7|7.42\\n±0.40
Hypercapnia\\n(n=4)|148\\n±3|72\\n±3|19.88\\n±0.67|2.10\\n±0.29|397\\n±57|7.85\\n±0.19
"
g <- as_grid(TABLEIII_printed, 7L)
stopifnot(nrow(g) == 5L, ncol(g) == 7L)
freeze(g, "TABLEIII")


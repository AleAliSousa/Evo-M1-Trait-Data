# Nemoto_etal_1994_extract_snapshot.R ------------------------------------------------------
#
# Freezes the snapshots of Nemoto, E. M., Yao, L., Yonas, H., & Darby, J. (1994). Compartmentation of whole brain blood flow and oxygen and glucose metabolism in monkeys. Journal of Neurosurgical Anesthesiology, 6(3), 170-174.
# DOI 10.1097/00008506-199407000-00004. Source PDF: Nemoto-1994-Compartmentation of.pdf (journal pp. 170-174 (PDF pages 1-5)).
#
# Source: NO text layer (photographed pages); every value read from 300-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_extract_snapshot.R
# pattern); this script freezes each block to <paper>_<locus>_snapshot.csv and the
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

## ---- TABLE2 (11 printed rows x 4 columns) --------------------
TABLE2_printed <- "
TABLE 2. Cerebral blood flow (CBF), cerebral metabolic rate of oxygen (CMRO2) and of glucose (CMRG) in six monkeys during the unanesthetized and thiopental-anesthetized states (isoelectric EEG) (values are X̄ ± SD)|||
Measurement no.|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)|CMRG (mg/100 g/min)
Unanesthetized|||
1|76 ± 18|5.70 ± 1.10|8.10 ± 2.10
2|75 ± 23|5.40 ± 0.95|8.26 ± 3.37
3|71 ± 19|5.66 ± 1.11|6.75 ± 1.95
Thiopental-anesthetized (flat EEG)|||
4|49 ± 14|3.26 ± 1.03|3.28 ± 1.11
5|47 ± 15|3.16 ± 0.60|2.58 ± 0.95
6|43 ± 8|2.88 ± 0.38|2.88 ± 0.78
EEG, electroencephalogram.|||
"
g <- as_grid(TABLE2_printed, 4L)
stopifnot(nrow(g) == 11L, ncol(g) == 4L)
freeze(g, "TABLE2")

## ---- TABLE3 (11 printed rows x 4 columns) --------------------
TABLE3_printed <- "
TABLE 3. Compartmentation of cerebral blood flow (CBF), cerebral metabolic rate of oxygen (CMRO2), and of glucose (CMRG), and the oxygen-glucose index (OGI) in six normal rhesus monkeys (values are X̄ ± SD)|||
Variable|Total|Basal|Active
CBF (ml/100\\ng/min)|76 ± 21|48 ± 14^a|27 ± 10^a,b
% Total CBF|100 ± 0|60 ± 5|40 ± 5^b
CMRO2 (ml/100\\ng/min)|5.95 ± 0.54|3.10 ± 0.51^a|2.85 ± 0.78^a
% Total CMRO2|100 ± 0|53 ± 11|47 ± 11
CMRG (mg/100\\ng/min)|8.09 ± 2.78|3.13 ± 0.77^a|5.32 ± 3.54^a
% Total CMRG|100 ± 0|41 ± 20|59 ± 20
OGI|0.99 ± 0.10|1.27 ± 0.252|0.87 ± 0.15^b
^a p < 0.05 compared with total.|||
^b p < 0.05 compared with basal.|||
"
g <- as_grid(TABLE3_printed, 4L)
stopifnot(nrow(g) == 11L, ncol(g) == 4L)
freeze(g, "TABLE3")


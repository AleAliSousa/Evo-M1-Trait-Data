# Sahlin_etal_1987_TABLEVI_snapshot.R ------------------------------------------------------
# (Split from the retired Sahlin_etal_1987_extract_snapshot.R: this script writes only Sahlin_etal_1987_TABLEVI_snapshot.csv.)
#
# Freezes the snapshot of Sahlin, C., Brismar, J., Delgado, T., Owman, C., Salford, L. G., & Svendgaard, N.-A. (1987). Cerebrovascular and metabolic changes during the delayed vasospasm following experimental subarachnoid hemorrhage in baboons, and treatment with a calcium antagonist. Brain Research, 403(2), 313-332.
# DOI 10.1016/0006-8993(87)90069-2. Source PDF: Sahlin-1987-Cerebrovascular and metabolic chan.pdf (journal pp. 313-332 (PDF pages 1-20)).
#
# Source: usable OCR text layer (used only to locate passages; values read from 300/500-dpi renders). The printed layout of TABLE VI
# is written out verbatim below (method 5); this script freezes it to
# Sahlin_etal_1987_TABLEVI_snapshot.csv and the item build script READS that
# frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # = Sahlin_etal_1987_TABLEVI


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
  file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
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

## ---- TABLEVI (8 printed rows x 8 columns) --------------------
TABLEVI_printed <- "
TABLE VI|||||||
Ability of CBF to autoregulate (and effects on CMRO2) during angiotensin-induced hypertension at the MABP levels indicated, in comparison with control levels of normotension tested|||||||
Values are means ± S.E.M., n = number of experiments.|||||||
Experimental group|n|Normotension|||Hypertension||
||MABP (mm Hg)|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)|MABP (mm Hg)|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)
Before SAH|7|100–120|57.1 ± 1.9|3.42 ± 0.12|150–160|59.5 ± 2.1|2.86 ± 0.23
After SAH|7|95–115|52.0 ± 2.0|2.92 ± 0.14|140–160|65.6 ± 4.2|2.90 ± 0.27
Paired t-test showed no significant difference between normotensive and hypertensive flow values before experimental SAH, but a significant difference with P = 0.02 after SAH. The difference in CMRO2 (before SAH) did not reach statistical significance.|||||||
"
g <- as_grid(TABLEVI_printed, 8L)
stopifnot(nrow(g) == 8L, ncol(g) == 8L)
freeze(g, "TABLEVI")


# Sahlin_etal_1987_extract_snapshot.R ------------------------------------------------------
#
# Freezes the snapshots of Sahlin, C., Brismar, J., Delgado, T., Owman, C., Salford, L. G., & Svendgaard, N.-A. (1987). Cerebrovascular and metabolic changes during the delayed vasospasm following experimental subarachnoid hemorrhage in baboons, and treatment with a calcium antagonist. Brain Research, 403(2), 313-332.
# DOI 10.1016/0006-8993(87)90069-2. Source PDF: Sahlin-1987-Cerebrovascular and metabolic chan.pdf (journal pp. 313-332 (PDF pages 1-20)).
#
# Source: usable OCR text layer (used only to locate passages; values read from 300/500-dpi renders). The printed layout of each table
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

## ---- TABLEIV (7 printed rows x 6 columns) --------------------
TABLEIV_printed <- "
TABLE IV|||||
Changes in CBF and CMRO2 one week following experimental SAH, expressed both as actual values and following correction to paCO2 = 40 mm Hg|||||
Values are means ± S.E.M. n = number of experiments.|||||
Experimental group|n|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)|CBF corr. (ml/100 g/min)|CMRO2 corr. (ml/100 g/min)
Before SAH|13|63.2 ± 4.4|3.22 ± 0.13|66.1 ± 4.4|3.37 ± 0.12
After SAH|13|51.6 ± 2.8**|2.88 ± 0.08**|51.8 ± 2.8**|2.88 ± 0.11**
Student's t-test: **0.001 < P < 0.01.|||||
"
g <- as_grid(TABLEIV_printed, 6L)
stopifnot(nrow(g) == 7L, ncol(g) == 6L)
freeze(g, "TABLEIV")

## ---- TABLEV (7 printed rows x 6 columns) --------------------
TABLEV_printed <- "
TABLE V|||||
Hypercapnic response of CBF and CMRO2 before and one week after cisternal blood injection|||||
Values are means ± S.E.M., n = number of experiments.|||||
Experimental group|n|Normocapnia||Hypercapnia|
||CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)
Before SAH|8|64.1 ± 5.1|3.67 ± 0.15|126.3 ± 7.5|3.52 ± 0.37
After SAH|7|57.2 ± 3.6|2.99 ± 0.14|86.2 ± 3.6|3.05 ± 0.17
"
g <- as_grid(TABLEV_printed, 6L)
stopifnot(nrow(g) == 7L, ncol(g) == 6L)
freeze(g, "TABLEV")

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

## ---- TABLEVII (8 printed rows x 8 columns) --------------------
TABLEVII_printed <- "
TABLE VII|||||||
Effect of intravenous nimodipine infusion (0.5 µg/kg/min) on CBF autoregulation and CMRO2 during angiotensin-induced hypertension at the MABP levels indicated, before and after experimental SAH|||||||
Values are means ± S.E.M., n = number of experiments.|||||||
Experimental group|n|Nimodipine during normotension|||Nimodipine during hypertension||
||MABP (mm Hg)|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)|MABP (mm Hg)|CBF (ml/100 g/min)|CMRO2 (ml/100 g/min)
Before SAH|5|90–120|58.3 ± 2.7|3.42 ± 0.29|120–145|94.8 ± 11.0*|3.18 ± 0.25
After SAH|5|95–115|54.6 ± 1.6|3.00 ± 0.12|125–140|70.8 ± 2.2**|3.01 ± 0.44
Paired t-test showed significant differences between CBF values at normotension and hypertension: *0.01 < P < 0.05, **0.001 < P < 0.01. There were no statistically significant differences in the CMRO2 values.|||||||
"
g <- as_grid(TABLEVII_printed, 8L)
stopifnot(nrow(g) == 8L, ncol(g) == 8L)
freeze(g, "TABLEVII")


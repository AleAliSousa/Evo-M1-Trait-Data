# Geiger_Magnes_1947_TABLE1_snapshot.R ----------------------------------------------------
#
# Freezes the snapshots of Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537.
# DOI 10.1152/ajplegacy.1947.149.3.517. Source PDF: geiger_magnes_1947.pdf (journal pp. 517-537 (PDF pages 1-21)).
#
# Source: OCR text layer, garbled (Table 1 printed sideways, low-contrast); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Geiger_Magnes_1947_TABLE1_snapshot.csv and the
# item build script Geiger_Magnes_1947_TABLE1.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Geiger_Magnes_1947_TABLE1

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
freeze <- function(grid, header = NULL) {
  file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
  if (file.exists(file)) {
    old <- read_frozen(file, header = !is.null(header))
    if (!identical(dim(old), dim(grid)) || !identical(unname(old), unname(grid)))
      stop(item_name, ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and move ",
           "the superseded file to archive/ before re-running.", call. = FALSE)
    message(item_name, ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    ## written byte-for-byte as UTF-8 (every field quoted, quotes doubled), so the
    ## result does not depend on the session locale
    q <- function(x) paste0('"', gsub('"', '""', x, fixed = TRUE), '"')
    rows <- c(if (!is.null(header)) paste(q(header), collapse = ","),
              apply(grid, 1, function(r) paste(q(r), collapse = ",")))
    con <- file(file, open = "wb"); writeLines(enc2utf8(rows), con, useBytes = TRUE); close(con)
    message(item_name, ": wrote ", basename(file), " (", nrow(grid), " rows x ", ncol(grid), " cols)")
  }
  invisible(file)
}
## ---- TABLE1 (28 printed rows x 15 columns) --------------------
TABLE1_printed <- "
The Oxygen consumption of the perfused brain (ml. O2 consumed per 100 grams brains per min.). Division into 3 groups according to functional state of brain||||||||||||||
EXPERIMENT|DURATION OF PERFUSION, MINUTES|||||||||||||REMARKS
|0-15|15-30|30-45|45-60|60-75|75-90|90-105|105-120|120-135|135-150|150-165|165-180|180-195|
Group A||||||||||||||
23-5|4.65|4.65|4.50|4.80|4.65|4.42|4.35|3.78(1)|3.45|3.15(2)|3.22|3.34|3.34|(1) Added 60 mgm. % chloral hydrate. (2) Changed blood
30-5|4.75|4.23|3.60|3.30|3.08|3.22|3.15|3.00(1)|2.70|2.48|2.85*|||(1) Changed blood—strong vasoconstriction
6-6|4.57|3.98|3.74|3.45(1)|3.08*|2.80||||||||(1) Changed blood—vasoconstriction
13-6|5.45|4.20|4.12|4.42|3.90*|2.70||||||||
8-7|5.55|5.06|5.32|4.95|4.70|3.90(1)|3.00|2.85*||||||(1) Added 20 mgm. % Na-amytal
15-7|4.73|4.50|4.87|4.75|4.65|4.42(1)|4.42|3.75(2)|3.00|2.85*||||(1) Changed blood. (2) Added 20 mgm. % Na-amytal
Average.|4.95|4.44|4.36|4.28|4.01|||||||||
Group B||||||||||||||
30-1|3.68|3.75|3.38*|3.15||||||||||
4-2|4.27|3.45|3.67|3.67*|3.45|||||||||
7-2|4.35|4.10|3.00|2.93*|2.55|2.40||||||||
17-2|3.82|3.30|3.15*|3.15||||||||||
25-3|3.45|3.52|3.00|3.00*|2.65|2.40||||||||
17-6|3.45|3.38|3.45*|3.22(1)|2.92|||||||||(1) Added 20 mgm. % Na-pentothal
Average.|3.83|3.58|3.27|3.18|2.90|||||||||
Group C||||||||||||||
25-2|3.22*|2.93|2.78|2.70|2.70|||||||||
28-2|2.55|2.40|2.10*|2.03|2.10|||||||||
4-3|3.00*|3.15|2.82|3.15||||||||||
11-3|2.32*|2.32|2.22|2.22|2.10|||||||||
21-3|3.75*|3.00|2.92|2.63|2.40|||||||||
3-7|3.75*|2.81|2.64|2.66||||||||||
Average.|3.10|2.77|2.58|2.56|2.32|||||||||
* Loss of reflexes.||||||||||||||
"
g <- as_grid(TABLE1_printed, 15L)
stopifnot(nrow(g) == 28L, ncol(g) == 15L)
freeze(g)

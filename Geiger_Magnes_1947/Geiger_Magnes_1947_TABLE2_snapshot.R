# Geiger_Magnes_1947_TABLE2_snapshot.R ----------------------------------------------------
#
# Freezes the snapshots of Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537.
# DOI 10.1152/ajplegacy.1947.149.3.517. Source PDF: geiger_magnes_1947.pdf (journal pp. 517-537 (PDF pages 1-21)).
#
# Source: OCR text layer, garbled (Table 1 printed sideways, low-contrast); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Geiger_Magnes_1947_TABLE2_snapshot.csv and the
# item build script Geiger_Magnes_1947_TABLE2.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Geiger_Magnes_1947_TABLE2

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
## ---- TABLE2 (17 printed rows x 7 columns) --------------------
TABLE2_printed <- "
TABLE 2||||||
The glucose consumption of the perfused brain||||||
EXPERIMENT|DURATION|GLUCOSE||PER 100 GRAMS BRAIN PER MINUTE||% GLUCOSE ACCOUNTED FOR BY OXIDATION
||Mgm.% in blood at start|Mgm. uptake by brain|Glucose mgm.|Oxygen ml.|
|minutes|||||
1|33|131|41.7|4.85|3.40|95
2|25|154|34.0|4.95|2.88|78
3|33|174|72.2|8.00|3.50|58
4|16|182|17.8|3.90|3.60|123
5|28|192|61.4|7.80|3.10|53
6|18|210|21.1|5.10|3.40|89
7|22|192|28.8|5.70|2.60|61
8|42|206|102.5|8.70|4.65|71
9|86|149|149.0|6.60|3.56|72
10|55|181|85.8|5.70|4.12|96.5
11|38|217|53.2|5.10|3.60|94
12|25|181|28.0|4.08|4.12|34
"
g <- as_grid(TABLE2_printed, 7L)
stopifnot(nrow(g) == 17L, ncol(g) == 7L)
freeze(g)

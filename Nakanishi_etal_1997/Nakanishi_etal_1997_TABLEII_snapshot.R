# Nakanishi_etal_1997_TABLEII_snapshot.R -------------------------------------------------
# (Split from the retired Nakanishi_etal_1997_extract_snapshot.R: this script writes only Nakanishi_etal_1997_TABLEII_snapshot.csv.)
#
# Freezes the snapshot of Nakanishi, O., Ishikawa, T., Imamura, Y., & Hirakawa, T. (1997). Inhibition of cerebral metabolic and circulatory responses to nitrous oxide by 6-hydroxydopamine in dogs. Canadian Journal of Anaesthesia, 44(9), 1008-1013.
# DOI 10.1007/BF03011974. Source PDF: Nakanishi-1997-Inhibition of cerebral metaboli.pdf (journal pp. 1008-1013, PDF pages 1-6).
#
# Source: born-digital typeset PDF with a usable text layer (used only to locate
# passages); every value was read from 300/500-dpi page renders. The printed
# layout of TABLE II is written out verbatim below (method 5); this script
# freezes it to Nakanishi_etal_1997_TABLEII_snapshot.csv and the item build script READS that frozen file.
#
# Fidelity conventions: one snapshot row per printed row (caption, header, data
# rows, footnotes); the Periods and Time labels sit on the printed line where the
# page sets them (vertically centred between two group lines) and are NOT
# propagated here; daggers and asterisks are kept as printed; subscripts inline.
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders at 300
# and 500 dpi, before any compilation value was looked at.
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # = Nakanishi_etal_1997_TABLEII


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


## ---- TABLEII (19 printed rows x 5 columns) --------------------
TABLEII_printed <- "
TABLE II Modification of cerebral circulatory and metabolic Response to N2O by pretreatment with 6-Hydroxydopamine in dogs||||
Periods|Time|Groups|CBF\\n(ml·100 g⁻¹·min⁻¹)|CMRO2\\n(ml·100 g⁻¹·min⁻¹)
Control||sham-op*|63 ± 5|6.11 ± 0.21
||6-OHDA|61 ± 3|5.98 ± 0.07
||sham-op|173 ± 26†|7.10 ± 0.39†
|10 min|6-OHDA|135 ± 19†|6.00 ± 0.20
N2O||sham-op|141 ± 17†|6.92 ± 0.28†
addition|30 min|6-OHDA|92 ± 6†|5.99 ± 0.23
||sham-op|111 ± 8†|7.34 ± 0.43†
|60 min|6-OHDA|84 ± 9|6.32 ± 0.07
||sham-op|65 ± 4|6.44 ± 0.19
|10 min|6-OHDA|65 ± 7|5.95 ± 0.10
N2O||sham-op|60 ± 4|6.16 ± 0.22
withdrawal|30 min|6-OHDA|59 ± 4|5.94 ± 0.16
||sham-op|57 ± 3|6.11 ± 0.28
|60 min|6-OHDA|57 ± 14|5.81 ± 0.14
* Sham-op: Sham operated||||
Mean ± SD of seven dogs.||||
† different from control (P < 0.05).||||
"
g <- as_grid(TABLEII_printed, 5L)
stopifnot(nrow(g) == 19L, ncol(g) == 5L)
freeze(g, "TABLEII")


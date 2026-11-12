# Schmidt_etal_1945_TABLE5_snapshot.R -----------------------------------------------------
#
# Freezes the snapshots of Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52.
# DOI 10.1152/ajplegacy.1945.143.1.33. Source PDF: schmidt_etal_1945.pdf (journal pp. 33-52 (PDF pages 1-20)).
#
# Source: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Schmidt_etal_1945_TABLE5_snapshot.csv and the
# item build script Schmidt_etal_1945_TABLE5.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Schmidt_etal_1945_TABLE5

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
## ---- TABLE5 (8 printed rows x 16 columns) --------------------
TABLE5_printed <- "
TABLE 5|||||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|B-P|O2 CON-TENT||CO2 CON-TENT||CEREBRAL|||O^2 CON-SUMED||BLOOD SUGAR|CONDI-TION|C.R.|WT. OF BRAIN
|||Art.|Vein|Art.|Vein|A-VO2|Blood flow|O2 up-take|Total|% by brain||||
|||vols. %||vols. %||vols. %|ml./100g./min.)||ml./min.||mgm. %|||
31|Control|79|10.6|2.6|45.6|52.3|8.0|51.0|4.08|75|5.9|159|Excel.|++++|108
|10' after insulin-20 u|66|9.9|2.4|46.4|54.2|7.5|47.2|3.54|70|5.0|98|Excel.|++++|
|1 hr. after insulin|66|9.1|1.7|47.2|54.5|7.4|49.3|3.64|75|4.9|41|Excel.|++++|
|After glucose-5 g.|69|6.0|1.2|49.3|52.7|4.8|60.3|2.89|76|3.8|197|Excel.|++++|
"
g <- as_grid(TABLE5_printed, 16L)
stopifnot(nrow(g) == 8L, ncol(g) == 16L)
freeze(g)

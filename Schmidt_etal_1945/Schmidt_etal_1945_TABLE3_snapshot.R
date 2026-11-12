# Schmidt_etal_1945_TABLE3_snapshot.R -----------------------------------------------------
#
# Freezes the snapshots of Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52.
# DOI 10.1152/ajplegacy.1945.143.1.33. Source PDF: schmidt_etal_1945.pdf (journal pp. 33-52 (PDF pages 1-20)).
#
# Source: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Schmidt_etal_1945_TABLE3_snapshot.csv and the
# item build script Schmidt_etal_1945_TABLE3.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Schmidt_etal_1945_TABLE3

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
## ---- TABLE3 (20 printed rows x 15 columns) --------------------
TABLE3_printed <- "
TABLE 3||||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|BLOOD PRES-SURE|O2 CONTENT||CO2 CONTENT||CEREBRAL|||O2 CONSUMED||CONDITION OF ANIMAL|COR-NEAL REFLEX|BRAIN WEIGHT
|||Art.|Vein|Art.|Vein|A-VO2|Blood flow|O2 up-take|Total|% by brain|||
||mm. Hg|vols. %||vols. %||vols. %|ml./100 g./min.||ml./min.||||grams
30|Control (nat. resp.)|110|12.5|4.7|52.1|59.6|7.8|53.0|4.13|35|12.3|Excellent|++++|105
|Epineph. infusion|125|10.7|4.6|51.8|58.0|6.1|62.3|3.80|33|12.2|Excellent|++++|
31|Control (nat. resp.)|96|15.4|6.1|46.6|55.0|9.3|45.9|4.26|53|8.7|Excellent|++++|108
|Epineph. infusion|145|13.0|8.4|49.2|52.8|4.6|76.8|3.53|29|13.1|Excellent|++++|
|After epineph.|79|10.6|2.6|45.6|52.3|8.0|51.0|4.08|75|5.9|Excellent|++++|
32|Control (art. resp.)|36|9.6|0.8|67.8|74.6|8.8|21.0|1.85|||Bad|0|95
|Epineph. infusion|112|8.5|4.9|66.6|69.0|3.6|85.6|3.08|||Fair|+|
8|Control (art. resp.)|32|11.7|2.0|44.3|54.7|9.7|18.9|1.83|||Bad|0|95
|Epineph. infusion|94|11.5|6.5|43.9|48.3|5.0|41.5|1.96|||Bad|0|
|Epineph. continued|88|9.9|5.7|42.1|46.3|4.2|44.0|1.85|||Bad|0|
15|Control (art. resp.)|64|14.2|4.0|81.1|89.3|10.2|17.7|1.80|||Bad|0|109
|Epineph. infusion|154|12.5|7.1|80.3|87.3|5.4|44.7|2.40|||Bad|0|
|After epineph.|46|8.2|1.8|83.7|90.4|6.4|9.6|0.61|||Moribund|0|
12|Control (art. resp.)|77|13.1|8.5|67.7|79.9|4.6|22.7|1.05|||Bad|0|90
|Epineph. infusion|164|11.1|5.7|67.8|72.1|5.4|22.4|1.21|||Bad|0|
|After epineph.|54|6.9|2.8|52.8|61.1|4.1|10.6|0.43|||Moribund|0|
"
g <- as_grid(TABLE3_printed, 15L)
stopifnot(nrow(g) == 20L, ncol(g) == 15L)
freeze(g)

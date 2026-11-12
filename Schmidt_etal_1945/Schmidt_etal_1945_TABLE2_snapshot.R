# Schmidt_etal_1945_TABLE2_snapshot.R -----------------------------------------------------
#
# Freezes the snapshots of Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52.
# DOI 10.1152/ajplegacy.1945.143.1.33. Source PDF: schmidt_etal_1945.pdf (journal pp. 33-52 (PDF pages 1-20)).
#
# Source: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Schmidt_etal_1945_TABLE2_snapshot.csv and the
# item build script Schmidt_etal_1945_TABLE2.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Schmidt_etal_1945_TABLE2

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
## ---- TABLE2 (25 printed rows x 14 columns) --------------------
TABLE2_printed <- "
TABLE 2|||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|BLOOD PRES-SURE|O2 CONTENT||CO2 CONTENT||CEREBRAL|||O2 CONSUMED||CONDITION OF ANIMAL|COR-NEAL REFLEX
|||Art.|Vein|Art.|Vein|AV-O2|Blood flow|O2 up-take|Total|% by brain||
||mm. Hg|vols. %||vols. %||vols. %|ml./100 g./min.||ml./min.|||
26|Control|116|14.4|6.1|45.6|53.2|8.2|40.4|3.30|31|8.7|Excellent|++
|Bleeding 10 ml.|88|14.5|5.3|45.5|55.2|9.3|33.9|3.14|28|9.2|V. good|++
|Bleeding 10 ml.|70|14.9|3.3|43.9|56.3|11.7|27.9|3.26|28|9.6|V. good|++
|Bleeding 10 ml.|58|14.8|0.8|41.2|57.4|14.0|20.2|2.83|25|9.3|Fair|±
|Bleeding 10 ml.|44|14.7|0.6|35.8|55.8|14.1|13.2|1.85|21|7.2|Bad|0
|Blood returned|114|11.6|3.4|46.0|53.7|8.1|46.0|3.72|34|9.0|Good|+
|15 min. later|110|12.9|3.4|47.4|57.3|9.5|41.4|3.94|35|9.2|Good|+
24|Control|124|11.6|5.6|50.9|56.9|6.0|73.6|4.43|31|12.2|Excellent|+++
|Bleeding 10 ml.|80|12.7|3.4|53.5|61.3|9.3|39.6|3.69|28|11.1|Fair|+
|Bleeding 6 ml.|64|12.5|2.2|54.6|64.4|10.3|30.2|3.12|27.5|9.8|Bad|0
|Blood returned|105|12.2|3.2|51.9|60.3|9.0|32.2|2.92|32|7.8|Bad|0
|Gelatin 10 cc.|138|11.4|5.1|51.5|57.5|6.3|56.5|3.55|34|8.8|Good|++
30|Control|110|12.5|4.7|52.1|59.6|7.8|53.0|4.13|35|12.3|Excellent|++++
|Bleeding 75 ml.|56|10.3|1.5|49.7|59.6|8.8|32.9|3.04|27|11.1|Good|++
|Bleeding 35 ml.|40|9.4|0.9|45.7|54.8|8.5|24.6|2.09|12|18.3|Bad|±
|Blood returned|100|10.0|5.3|45.1|49.1|4.7|62.2|2.93|35|8.9|Good|++
25|Control|150|14.6|4.9|45.9|54.1|9.7|46.6|4.52|41|8.8|Excellent|+++
|Bleeding 10 ml.|100|15.2|2.0|46.7|58.3|13.2|29.5|3.90|32|9.7|Fair|+
|3 min. later|96|13.7|1.3|51.6|59.6|12.4|28.0|3.48|30|9.0|Bad|0
|Transfused 25 ml.|114|13.2|3.3|57.5|65.4|9.9|31.2|3.10|art.|resp.|Bad|0
|30 min. later|56|8.1|3.2|79.6|83.0|4.9|11.2|0.56|art.|resp.|Moribund|0
"
g <- as_grid(TABLE2_printed, 14L)
stopifnot(nrow(g) == 25L, ncol(g) == 14L)
freeze(g)

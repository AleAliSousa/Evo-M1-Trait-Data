# Schmidt_etal_1945_TABLE1_snapshot.R -----------------------------------------------------
#
# Freezes the snapshots of Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52.
# DOI 10.1152/ajplegacy.1945.143.1.33. Source PDF: schmidt_etal_1945.pdf (journal pp. 33-52 (PDF pages 1-20)).
#
# Source: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Schmidt_etal_1945_TABLE1_snapshot.csv and the
# item build script Schmidt_etal_1945_TABLE1.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Schmidt_etal_1945_TABLE1

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
## ---- TABLE1 (17 printed rows x 12 columns) --------------------
TABLE1_printed <- "
TABLE 1|||||||||||
EXPT. NO.|GENERAL CONDITION|BLOOD PRES-SURE|CEREBRAL||||O2 CONSUMED||CERE-BRAL R.Q.|WEIGHT|
|||A-V diff.||Blood flow|O2 uptake|Total|% by brain||Ani-mal|Brain
|||O2|CO2|||||||
|||vols. %||ml./100g./min.||ml./min.|||kg.|grams
5|Good—light anesthesia|135|7.0|6.0|53.4|3.7|||0.85|2.8|90
9|Good—deep anesthesia|84|6.6|6.9|38.0|2.5|||1.05|3.2|90
13|Good—light anesthesia|114|8.7|7.3|33.5|2.9|29|9.0|0.84|3.5|88
14|Excellent—active movements|100|10.1|10.2|33.4|3.4|30|11.7|1.01|3.5|114
22|Excellent—active movements|134|7.8|8.0|41.0|3.1|40|6.9|1.02|4.1|89
24|Excellent—reflexes very active|124|6.0|6.0|73.6|4.4|31|12.1|1.00|3.7|85
25|Excellent—reflexes very active|150|9.7|8.2|46.6|4.5|41|8.8|0.85|4.1|80
26|Excellent—reflexes very active|116|8.2|7.6|40.4|3.3|31|8.7|0.92|3.3|82
27|Excellent—reflexes very active|102|8.8|10.7|49.7|4.4|35|9.4|1.22|3.0|75
30|Excellent—reflexes very active|110|7.8|7.5|53.0|4.1|37|12.3|0.96|5.8|105
31|Excellent—reflexes very active|100|8.2|8.1|53.7|4.4|48|10.0|0.99|5.3|108
Average||115|8.0|8.0|46.9|3.7|36|10.0|1.00|3.8|91
"
g <- as_grid(TABLE1_printed, 12L)
stopifnot(nrow(g) == 17L, ncol(g) == 12L)
freeze(g)

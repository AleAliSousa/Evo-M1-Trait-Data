# MacLean_etal_2014_TableS7_snapshot.R ----------------------------------------------------------
# R port of MacLean_etal_2014_TableS7_snapshot.py (python-docx -> xml2). Python is not needed: the
# snapshot is the cell grid of the single table in the original Word file
# pnas.1323533111.st07.docx, and R reads that table straight from word/document.xml.
#
# Freezes the displayed cell grid of MacLean et al. (2014), PNAS, Table S7:
# one snapshot row per Word table row (column `source_row` = its 1-based number),
# one column per grid column (c1..c8), text exactly as the Word cell holds it.
# The original Word file remains authoritative; the snapshot preserves its text and
# row order. No cleaning happens here.
#
# python-docx's `row.cells` convention is kept so the grid is the same as before:
# a cell spanning several grid columns (w:gridSpan) is repeated across them, a cell
# continued from the row above (w:vMerge) repeats the text of the cell above, the
# paragraphs of one cell are joined with a newline, and w:tab is a tab character.
#
# Writes ONLY MacLean_etal_2014_TableS7_snapshot.csv (UTF-8, CRLF line endings, a field is quoted only
# if it holds a comma, a double quote or a line break: the output of Python's
# csv.writer, as before). Re-running is safe: the script refuses to overwrite a
# frozen file whose content differs, unless --force is given.

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
folder    <- dirname(.sp)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # this script is <Item>_snapshot.R
FORCE     <- "--force" %in% commandArgs(trailingOnly = TRUE)
suppressPackageStartupMessages(library(xml2))

number           <- as.integer(sub("^.*TableS", "", item_name))
expected_rows    <- 46L
expected_columns <- 8L
source_docx      <- file.path(folder, paste0("pnas.1323533111.st0", number, ".docx"))
snap_file        <- file.path(folder, paste0(item_name, "_snapshot.csv"))

xml_dir <- tempfile("docx_"); dir.create(xml_dir)
utils::unzip(source_docx, files = "word/document.xml", exdir = xml_dir)
doc <- read_xml(file.path(xml_dir, "word", "document.xml"))
ns  <- xml_ns(doc)
tbls <- xml_find_all(doc, ".//w:tbl", ns)
if (length(tbls) != 1L) stop(basename(source_docx), ": expected one table", call. = FALSE)
trs <- xml_find_all(tbls[[1]], "./w:tr", ns)
if (length(trs) != expected_rows) stop(basename(source_docx), ": unexpected row count", call. = FALSE)

## text of one run: w:t, w:tab, w:br / w:cr, w:noBreakHyphen (as python-docx Run.text)
run_text <- function(r) {
  paste0(vapply(xml_children(r), function(e) {
    switch(xml_name(e),
           t = xml_text(e), tab = "\t", ptab = "\t", cr = "\n", noBreakHyphen = "-",
           br = {ty <- xml_attr(e, "w:type", ns); if (is.na(ty) || ty == "textWrapping") "\n" else ""},
           "")
  }, character(1)), collapse = "")
}
## text of one paragraph: its runs, also those inside a w:hyperlink
par_text <- function(p) {
  kids <- xml_children(p)
  paste0(vapply(kids, function(k) {
    switch(xml_name(k),
           r = run_text(k),
           hyperlink = paste0(vapply(xml_find_all(k, "./w:r", ns), run_text, character(1)), collapse = ""),
           "")
  }, character(1)), collapse = "")
}
cell_text <- function(tc) paste(vapply(xml_find_all(tc, "./w:p", ns), par_text, character(1)), collapse = "\n")

grid <- matrix(NA_character_, nrow = length(trs), ncol = expected_columns)
for (i in seq_along(trs)) {
  col <- 0L
  for (tc in xml_find_all(trs[[i]], "./w:tc", ns)) {
    span <- xml_attr(xml_find_first(tc, "./w:tcPr/w:gridSpan", ns), "w:val", ns)
    span <- if (is.na(span)) 1L else as.integer(span)
    vm   <- xml_find_first(tc, "./w:tcPr/w:vMerge", ns)
    cont <- !inherits(vm, "xml_missing") && !identical(xml_attr(vm, "w:val", ns), "restart")
    idx  <- col + seq_len(span)
    if (idx[length(idx)] > expected_columns)
      stop(basename(source_docx), ": row ", i, " has more than ", expected_columns, " cells", call. = FALSE)
    grid[i, idx] <- if (cont) {
      if (i == 1L) stop("vMerge continuation in the first row", call. = FALSE)
      grid[i - 1L, idx]
    } else cell_text(tc)
    col <- col + span
  }
  if (col != expected_columns)
    stop(basename(source_docx), ": row ", i, " has ", col, " cells", call. = FALSE)
}

snap <- rbind(c("source_row", paste0("c", seq_len(expected_columns))),
              cbind(as.character(seq_len(nrow(grid))), grid))
csv_field <- function(x) {
  q <- grepl("[,\"\r\n]", x)
  x[q] <- paste0("\"", gsub("\"", "\"\"", x[q], fixed = TRUE), "\"")
  x
}
new_txt <- paste0(apply(matrix(csv_field(snap), nrow = nrow(snap)), 1, paste, collapse = ","),
                  "\r\n", collapse = "")
new_raw <- charToRaw(enc2utf8(new_txt))
if (file.exists(snap_file) && identical(readBin(snap_file, "raw", file.size(snap_file)), new_raw)) {
  message(basename(snap_file), ": frozen snapshot already on disk and identical; nothing written.")
} else if (file.exists(snap_file) && !FORCE) {
  stop("REFUSING to overwrite a differing frozen copy: ", basename(snap_file),
       "\nRe-run with --force only after deciding whether the difference is a ",
       "transcription fix (record it) or an error.", call. = FALSE)
} else {
  writeBin(new_raw, snap_file)
  message(basename(snap_file), ": ", expected_rows, " source rows")
}

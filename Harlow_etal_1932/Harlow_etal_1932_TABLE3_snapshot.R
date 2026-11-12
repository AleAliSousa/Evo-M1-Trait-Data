# Harlow_etal_1932_TABLE3_snapshot.R -----------------------------------------------
# R port of Harlow_etal_1932_TABLE3_snapshot.py (csv/openpyxl -> base R/writexl); the Python script is
# kept as Harlow_etal_1932_TABLE3_snapshot.py.retired.  Python was NOT needed: the table is a hand
# transcription held as a printed-layout block below, and R reproduces the frozen
# snapshot exactly (cell-identical when read back with readxl; sheet "TABLE3").
#
# Builds the frozen snapshot Harlow_etal_1932_TABLE3_snapshot.xlsx (TABLE 3, p.331) for
# Harlow, Uehling & Maslow (1932),
# J. Comp. Psychol. 13(3), 313-343, doi:10.1037/h0073864, from the scanned
# PDF in this folder ("Harlow-1932-Comparative behavior.pdf").
#
# The PDF is a 1932 scan.  Its embedded OCR text layer is unusable for tables
# (columns are emitted out of reading order and digits are corrupted), so the
# values below were read off page renders at 200-400 dpi, cell by cell, and
# typed here verbatim as printed -- snapshot HOWTO method 5 ("manual entry"),
# with the printed-layout block living inside this script
# (Jacobs_etal_2018_Table3_snapshot.R pattern).
#
# Transcribed by: AI assistant (Claude), 2026-10-31.
# Checked by: the same session, by re-rendering each table at 400 dpi with the
# column rules visible and reading every row left-to-right against the block
# below.  A human side-by-side check is still outstanding -- see each item
# README and the `Human visual check of snapshot` column of __ReadMe.xlsx.
#
# Rules obeyed (see _skills/build-dataset-item/references/__HOWTO_make_a_snapshot.md):
#   * one snapshot row per printed row, in printed order, blanks and section
#     rows included;
#   * column order as published, with blank padding under spanning headers;
#   * values exactly as printed (fractions as "11 1/2", footnote marks kept,
#     blank cells left blank);
#   * nothing sorted, deduplicated or unpivoted.
#
# Printed page number: TABLE 3 p.331 (PDF page 19).
#
# Writes ONLY Harlow_etal_1932_TABLE3_snapshot.xlsx.  Re-running is safe: the script refuses to
# overwrite a frozen file whose content differs, unless --force is given.

# TABLE 3 (p.331).  Eleven printed label lines for ten value rows: lines 2 and
# 3 ("II. Pat" and "II. Baboon Min") are joined by a printed brace to a single
# set of values, and the numeral "II." is printed twice.  Both facts are kept
# as printed; the brace sits in its own column at the position it occupies on
# the page (between the ANIMAL column and the first value column).  The shared
# values are placed on the FIRST braced line and the brace column says so.
# See Harlow_etal_1932_errata.csv (E001).

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

## The printed table, one line per row, cells separated by "|" (an empty field where
## the page is blank). Typed as printed; nothing is cleaned here.
printed_table <- "
TABLE 3||||
Responses of 10 primates to neutral orientation, favorable orientation, and unfavorable orientation of correct container following 50-second delay periods||||
Percentages of responses correct in 50 trials||||
ANIMAL|[printed brace]|NEUTRAL ORIENTATION|UNFAVORABLE ORIENTATION|FAVORABLE ORIENTATION
I. Mandrill||100|100|100
II. Pat|} joined to next line|98|100|100
II. Baboon Min|} joined to previous line|||
III. Baboon Andy||96|94|98
IV. Baboon Tommy||100|98|100
V. Gibbon Charlotte||90|82|94
VI. Guenon Mona||88|64|100
VII. Macaque No. III||74|32|100
VIII. Guenon Thunder||62|24|96
IX. Mandrill Socrates||54|12|98
X. Macaque No. IV||56|4|100
"

NCOL <- 5L
lines <- strsplit(printed_table, "\n", fixed = TRUE)[[1]]
lines <- lines[nzchar(lines)]
stopifnot(all(lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) == NCOL - 1L))
grid <- do.call(rbind, lapply(lines, function(line) {
  x <- strsplit(line, "|", fixed = TRUE)[[1]]
  length(x) <- NCOL
  x
}))
grid[!is.na(grid) & grid == ""] <- NA_character_
stopifnot(nrow(grid) == 15L, ncol(grid) == NCOL, grid[1, 1] == "TABLE 3")

snap_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
sheet     <- "TABLE3"
## writexl (not openxlsx): a plain, style-free workbook; every cell is text, blanks are empty.
write_snapshot <- function() {
  writexl::write_xlsx(setNames(list(as.data.frame(grid, stringsAsFactors = FALSE)), sheet),
                      snap_file, col_names = FALSE)
  message("wrote ", basename(snap_file), " (", nrow(grid), " rows)")
}
if (file.exists(snap_file)) {
  old <- as.matrix(readxl::read_excel(snap_file, sheet = sheet, col_names = FALSE,
                                      col_types = "text", .name_repair = "minimal"))
  new <- grid
  dimnames(old) <- NULL; dimnames(new) <- NULL
  old[is.na(old)] <- ""; new[is.na(new)] <- ""
  if (identical(dim(old), dim(new)) && identical(old, new)) {
    message(basename(snap_file), ": frozen snapshot already on disk and identical; nothing written.")
  } else if (!FORCE) {
    stop("REFUSING to overwrite a differing frozen copy: ", basename(snap_file),
         "\nRe-run with --force only after deciding whether the difference is a ",
         "transcription fix (record it) or an error.", call. = FALSE)
  } else write_snapshot()
} else write_snapshot()


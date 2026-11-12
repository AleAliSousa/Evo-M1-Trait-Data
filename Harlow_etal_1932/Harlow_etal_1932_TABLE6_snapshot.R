# Harlow_etal_1932_TABLE6_snapshot.R -----------------------------------------------
# R port of Harlow_etal_1932_TABLE6_snapshot.py (csv/openpyxl -> base R/writexl); the Python script is
# kept as Harlow_etal_1932_TABLE6_snapshot.py.retired.  Python was NOT needed: the table is a hand
# transcription held as a printed-layout block below, and R reproduces the frozen
# snapshot exactly (cell-identical when read back with readxl; sheet "TABLE6").
#
# Builds the frozen snapshot Harlow_etal_1932_TABLE6_snapshot.xlsx (TABLE 6, p.337) for
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
# Printed page number: TABLE 6 p.337 (PDF page 25).
#
# Writes ONLY Harlow_etal_1932_TABLE6_snapshot.xlsx.  Re-running is safe: the script refuses to
# overwrite a frozen file whose content differs, unless --force is given.

# TABLE 6 (p.337) -- direct vs indirect method.  Two-tier header -> XLSX.

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
TABLE 6||||||
Comparison of direct and indirect methods||||||
Per cent of correct responses made in 20 trials by 10 primates at delay intervals of fifteen, thirty, and sixty seconds using both methods||||||
ANIMAL|15-SECOND DELAY||30-SECOND DELAY||60-SECOND DELAY|
|DM|IM|DM|IM|DM|IM
I. Mandrill (Pat)|100|100|100|100|100|100
II. Baboon (Min)|100|100|100|90|95|85
III. Macaque (Kewpie)|100|90|100|65|90|NR
IV. Baboon (Tommy)|100|100|100|100|90|95
V. Macaque (No. I)|100|90|100|75|90|70
VI. Macaque (Blackie)|90|60|95|65|75|45
VII. Gibbon (Charlotte)|95|90|85|90|80|80
VIII. Guenon (Thunder)|80|NR|70|NR|NR|NR
IX. Guenon (Mona)|100|NR|90|NR|75|NR
X. Cebus (Bugs)|65|NR|NR|NR|NR|NR
DM, direct method. IM, indirect method. NR, animal would not respond.||||||
"

NCOL <- 7L
lines <- strsplit(printed_table, "\n", fixed = TRUE)[[1]]
lines <- lines[nzchar(lines)]
stopifnot(all(lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) == NCOL - 1L))
grid <- do.call(rbind, lapply(lines, function(line) {
  x <- strsplit(line, "|", fixed = TRUE)[[1]]
  length(x) <- NCOL
  x
}))
grid[!is.na(grid) & grid == ""] <- NA_character_
stopifnot(nrow(grid) == 16L, ncol(grid) == NCOL, grid[1, 1] == "TABLE 6")

snap_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
sheet     <- "TABLE6"
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


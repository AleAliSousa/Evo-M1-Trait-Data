# Harlow_etal_1932_TABLE2_snapshot.R -----------------------------------------------
# R port of Harlow_etal_1932_TABLE2_snapshot.py (csv/openpyxl -> base R/writexl); the Python script is
# kept as Harlow_etal_1932_TABLE2_snapshot.py.retired.  Python was NOT needed: the table is a hand
# transcription held as a printed-layout block below, and R reproduces the frozen
# snapshot exactly (cell-identical when read back with readxl; sheet "TABLE2").
#
# Builds the frozen snapshot Harlow_etal_1932_TABLE2_snapshot.xlsx (TABLE 2, p.323) for
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
# Printed page number: TABLE 2 p.323 (PDF page 11).
#
# Writes ONLY Harlow_etal_1932_TABLE2_snapshot.xlsx.  Re-running is safe: the script refuses to
# overwrite a frozen file whose content differs, unless --force is given.

# TABLE 2 (p.323) -- Summary of correct responses.
# Three-tier header (PERIOD OF DELAY spanning 8 delay blocks x NT/PC/LFC)
# -> XLSX, with blank padding under every spanning header.
# animal, familiar name, then 8 x (NT, PC, LFC) exactly as printed

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
TABLE 2|||||||||||||||||||||||||
Summary of correct responses|||||||||||||||||||||||||
ANIMAL|FAMILIAR NAME|PERIOD OF DELAY|||||||||||||||||||||||
||0 second|||5 seconds|||15 seconds|||30 seconds|||60 seconds|||120 seconds|||180 seconds|||Over 180 seconds||
||NT|PC|LFC|NT|PC|LFC|NT|PC|LFC|NT|PC|LFC|NT|PC|LFC|NT|PC|LFC|NT|PC|LFC|NT|PC|LFC
|||per cent|per cent||per cent|per cent||per cent|per cent||per cent|per cent||per cent|per cent||per cent|per cent||per cent|per cent||per cent|per cent
Orang-outan|Jiggs|60|100||60|98||60|100||40|95|||||20|90|||||16|88|*
Gibbon|Charlotte|200|89|98|200|90|96|200|86|92|200|80|90|65|71||35|66|||||||
Macaque|No. I|200|94|98|200|94|96|200|90|94|200|92|94|100|82|90|60|75|||||||
Macaque|No. II|200|86|94|100|93|92|100|92|94|100|89|90|60|63||40|65|||||||
Macaque|No. III|200|72|88|200|77|84|200|71|74|200|62|70|100|51|53|60|47|||||||
Macaque|No. IV|100|78|92|100|81|86|100|77|82|60|65||60|55||||||||||
Macaque|No. V|200|89|96|200|91|94|200|87|94|200|78|86|100|70|78|100|65|74||||||
Macaque|Sourface|200|90|100|200|96|98|200|86|96|200|85|98|100|89|96|80|80|86||||||
Macaque|Kewpie|200|92|98|200|94|100|200|95|94|200|93|96|100|94|96|100|86|90|20|70||||
Barbary ape|Blackie|200|92|98|200|98|100|200|90|94|200|89|92|100|70|80|60|73|||||||
Guenon|Thunder|200|82|88|100|86|90|80|78||60|68||20|70||||||||||
Guenon|Lightning|100|84|94|100|88|90|100|84|84|60|72||30|73||||||||||
Guenon|Mona|200|80|90|200|77|92|200|81|88|200|76|92|100|74|84|80|64|||||||
Guenon|Skeezix|(Failed to grasp problem)|||||||||||||||||||||||
Mangabey|Sooty|200|91|94|140|84|88|80|78||60|63||40|55||||||||||
Baboon|Tommy|200|99|100|200|100|100|200|99|100|200|93|98|100|90|92|100|84|88||||||
Baboon|Andy|200|96|98|200|95|98|200|90|96|200|91|94|100|84|88|100|78|80||||||
Baboon|Min|200|96|100|200|98|98|200|96|100|200|96|98|100|90|94|100|81|84||||||
Mandrill|Pat|200|96|100|200|99|100|200|96|98|200|90|94|100|92|94|100|84|86|60|80||20|85|\u2020
Mandrill|Socrates|60|73||40|68|||||||||||||||||||
Mandrill|Xanthippe|200|80|96|100|82|92|100|74|84|70|59|||||||||||||
Cebus monkey|Scarface Al|140|74|78|110|77||30|73||||||||||||||||
Cebus monkey|Bugs|90|77||80|76||20|65||||||||||||||||
Lemur|Racket|80|89||40|80||40|78||14|57|||||||||||||
NT, number of trials.  PC, per cent total trials correct.  LFC, per cent last 50 trials correct.|||||||||||||||||||||||||
* Three hundred seconds.|||||||||||||||||||||||||
\u2020 Six hundred seconds.|||||||||||||||||||||||||
"

NCOL <- 26L
lines <- strsplit(printed_table, "\n", fixed = TRUE)[[1]]
lines <- lines[nzchar(lines)]
stopifnot(all(lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) == NCOL - 1L))
grid <- do.call(rbind, lapply(lines, function(line) {
  x <- strsplit(line, "|", fixed = TRUE)[[1]]
  length(x) <- NCOL
  x
}))
grid[!is.na(grid) & grid == ""] <- NA_character_
stopifnot(nrow(grid) == 33L, ncol(grid) == NCOL, grid[1, 1] == "TABLE 2")

snap_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
sheet     <- "TABLE2"
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


# Harlow_etal_1932_TABLE1_snapshot.R -----------------------------------------------
# R port of Harlow_etal_1932_TABLE1_snapshot.py (csv/openpyxl -> base R/writexl); the Python script is
# kept as Harlow_etal_1932_TABLE1_snapshot.py.retired.  Python was NOT needed: the table is a hand
# transcription held as a printed-layout block below, and R reproduces the frozen
# snapshot exactly (byte-identical CSV, CRLF line endings as before).
#
# Builds the frozen snapshot Harlow_etal_1932_TABLE1_snapshot.csv (TABLE 1, p.316) for
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
# Printed page number: TABLE 1 p.316 (PDF page 4).
#
# Writes ONLY Harlow_etal_1932_TABLE1_snapshot.csv.  Re-running is safe: the script refuses to
# overwrite a frozen file whose content differs, unless --force is given.

# TABLE 1 (p.316) -- Classification of the animals.  Flat layout -> CSV.

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
TABLE 1|||||
Classification of the animals|||||
FAMILY|GENUS|SPECIES|FAMILIAR NAME|ESTIMATED AGE|SEX
Suborder Anthropoidea|||||
||||years|
Pongiidae (orang-outan)|Pongo|Pygmaeus|Jiggs|11 1/2|Male
Hylobatidae (white-handed gibbon)|Hylobates|Lar|Charlotte|15|Male
Lasiopygidae (Macacus rhesus)|Pithecus|Rhesus|No. I|7|Male
Lasiopygidae (Macacus rhesus)|Pithecus|Rhesus|No. II|5|Female
Lasiopygidae (Macacus rhesus)|Pithecus|Rhesus|No. III|5|Female
Lasiopygidae (Macacus rhesus)|Pithecus|Rhesus|No. IV|5|Female
Lasiopygidae (Macacus rhesus)|Pithecus|Rhesus|No. V|4|Female
Lasiopygidae (Java monkey)|Pithecus|Mordax|Sourface|5|Male
Lasiopygidae (Java monkey)|Pithecus|Mordax|Kewpie|5|Male
Lasiopygidae (Barbary ape)|Simia*|Sylvanus|Blackie|5|Male
Lasiopygidae (sooty mangaby)|Cercocebus|Aethiops|Sooty|3|Male
Lasiopygidae (Mona guenon)|Lasiopyga|Mona|Mona|3|Female
Lasiopygidae (green guenon)|Lasiopyga|Callitrichus|Thunder|9|Male
Lasiopygidae (green guenon)|Lasiopyga|Callitrichus|Lightning|9|Male
Lasiopygidae (mustached guenon)|Lasiopyga|Cephus|Skeezix|1 1/2|Male
Lasiopygidae (yellow baboon)|Papio|Cynocephalus|Tommy|7|Male
Lasiopygidae (guinea baboon)|Papio|Papio|Andy|7|Male
Lasiopygidae (guinea baboon)|Papio|Papio|Min|7|Female
Lasiopygidae (mandrill)|Papio|Sphinx|Pat|20|Male
Lasiopygidae (mandrill)|Papio|Sphinx|Socrates|1 1/2|Male
Lasiopygidae (mandrill)|Papio|Sphinx|Xanthippe|1 1/2|Female
Cebidae (Capuchin monkey)|Cebus|Capucinus|Scarface Al|4|Male
Cebidae (Capuchin monkey)|Cebus|Capucinus|Bugs|4|Male
Suborder Lemuroidea|||||
Nycticibidae|Lemur|Variegatus|Racket|13|Male
* The Barbary ape is classified by Elliot as a separate genus, Simia; by Sonntag (25) it is classified as belonging to the genus Macacus (Elliot's genus Pithecus). We include it with the macaques in the discussion of results.|||||
"

NCOL <- 6L
lines <- strsplit(printed_table, "\n", fixed = TRUE)[[1]]
lines <- lines[nzchar(lines)]
stopifnot(all(lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) == NCOL - 1L))
grid <- do.call(rbind, lapply(lines, function(line) {
  x <- strsplit(line, "|", fixed = TRUE)[[1]]
  length(x) <- NCOL
  x
}))
grid[!is.na(grid) & grid == ""] <- NA_character_
stopifnot(nrow(grid) == 31L, ncol(grid) == NCOL, grid[1, 1] == "TABLE 1")

## Same output as Python's csv.writer: UTF-8, CRLF, a field is quoted only if it
## contains a comma, a double quote or a line break.
csv_field <- function(x) {
  x[is.na(x)] <- ""
  q <- grepl("[,\"\r\n]", x)
  x[q] <- paste0("\"", gsub("\"", "\"\"", x[q], fixed = TRUE), "\"")
  x
}
snap_file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
new_txt <- paste0(apply(matrix(csv_field(grid), nrow = nrow(grid)), 1, paste, collapse = ","),
                  "\r\n", collapse = "")
if (file.exists(snap_file)) {
  old <- as.matrix(read.csv(snap_file, header = FALSE, colClasses = "character",
                            na.strings = NULL, encoding = "UTF-8"))
  new <- grid; new[is.na(new)] <- ""
  dimnames(old) <- NULL; dimnames(new) <- NULL
  if (identical(dim(old), dim(new)) && identical(old, new)) {
    message(basename(snap_file), ": frozen snapshot already on disk and identical; nothing written.")
  } else if (!FORCE) {
    stop("REFUSING to overwrite a differing frozen copy: ", basename(snap_file),
         "\nRe-run with --force only after deciding whether the difference is a ",
         "transcription fix (record it) or an error.", call. = FALSE)
  } else {
    writeBin(charToRaw(enc2utf8(new_txt)), snap_file)
    message("wrote ", basename(snap_file), " (", nrow(grid), " rows)")
  }
} else {
  writeBin(charToRaw(enc2utf8(new_txt)), snap_file)
  message("wrote ", basename(snap_file), " (", nrow(grid), " rows)")
}


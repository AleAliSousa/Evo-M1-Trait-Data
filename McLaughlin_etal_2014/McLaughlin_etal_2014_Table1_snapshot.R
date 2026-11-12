# McLaughlin_etal_2014_Table1_snapshot.R -------------------------------
#
# Builds the frozen snapshot of McLaughlin, Sheridan, Winter, Fox, Zeanah &
# Nelson (2014) Biol Psychiatry 76: 629-638, Table 1 "Sociodemographic and
# Developmental Characteristics Among Children Reared in Institutions and
# Community Control Subjects in the Bucharest Early Intervention Project
# (n = 80)", p. 630 (PDF page 2).
#
# The source is a printed (born-digital) journal PDF: a picture of the table,
# not the data. Its text layer is legible but loses the column grid, so the
# printed layout is written out verbatim below (HOWTO method 5 /
# Jacobs_etal_2018 / Mink_etal_1981 pattern); this script freezes it to .xlsx
# and the build (McLaughlin_etal_2014_Table1.R) READS that frozen file.
# No cleaning happens here.
#
# Layout conventions (all reversible from the frozen file):
#  * one worksheet row per printed row, in printed order, including the
#    caption, the two header tiers, the "Age (Months)" heading row and the
#    footnote lines;
#  * the spanning group headers sit over their M column with blank padding
#    under the span (SD column), as printed;
#  * printed indentation of sub-rows is kept as two leading spaces (written
#    ".." in the block below and converted to two spaces on freezing);
#  * a superscript footnote mark is written "^a"; the chi-square symbol with
#    superscript 2 and subscript 1 is written "chi^2_1";
#  * parentheses around SDs, thousands commas and leading-zero-less decimals
#    (".25") are kept exactly as printed.
#
# Transcribed by an AI assistant (Claude) on 2026-11-11 from 300- and 450-dpi
# renders of PDF page 2, read row by row across the printed table.
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))

SHEET <- "Table1"; NCOL <- 7L; N_ROWS <- 16L; PDF_PAGE <- 2L
HEADER_ROWS <- 1:3; DATA_ROWS <- 4:14

printed <- "
Table 1. Sociodemographic and Developmental Characteristics Among Children Reared in Institutions and Community Control Subjects in the Bucharest Early Intervention Project (n = 80)||||||
|Ever Institutionalized Group (n = 58)||Never Institutionalized Group (n = 22)||Group Difference|
|M|SD|M|SD|F|p Value
Female, No. (%)|n = 28 (48.3%)||n = 12 (54.5%)||chi^2_1 = .25|.617
Age (Months)||||||
..Age at study entry|17.7|(7.8)|20.0|(7.2)|1.21|.276
..Age at MRI scan|116.3|(9.0)|117.9|(10.6)|.1|.816
..Age at HBQ assessment|103.2|(4.6)|101.4|(4.0)|2.49|.149
Birth Weight (grams)|2780.0|(623.3)|3150.0|(411.8)|4.41^a|.040
Head Circumference at Birth (cm)|46.07|(2.61)|46.5|(2.08)|.04|.843
Full-Scale IQ|72.0|(15.8)|107.9|(14.67)|96.49^a|.001
Intracranial Volume|1,456,490|(132,948)|1,499,091|(109,367)|1.79|.184
Cerebral Gray Matter|790,429|(71,160)|833,849|(62,887)|6.31^a|.014
Cortical Gray Matter|577,432|(57,120)|613,899|(48,391)|7.04^a|.010
HBQ, MacArthur Health and Behavior Questionnaire; MRI, magnetic resonance imaging.||||||
^aSignificant at the p < .05 level, two-sided test.||||||
"

grid <- do.call(rbind, lapply(
  strsplit(trimws(printed, which = "both"), "\n", fixed = TRUE)[[1]],
  function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- NCOL
    x
  }))
grid[!is.na(grid) & grid == ""] <- NA_character_
## leading spaces in column 1 are the printed indentation (hierarchy), kept
grid[, 1] <- sub("^\\.\\.", "  ", grid[, 1])

stopifnot(ncol(grid) == NCOL, nrow(grid) == N_ROWS)

## ---- text-layer cross-check (no values are taken from it) ------------------
## Every numeric lexeme typed in the block must occur, as a token, in the PDF
## text layer of the same page. This catches a mistyped digit; it cannot catch
## a value placed in the wrong cell -- that is what the human row-by-row read
## against the page render is for (README).
pdf_file <- list.files(folder, pattern = "\\.pdf$", full.names = TRUE)
stopifnot(length(pdf_file) == 1L)
if (requireNamespace("pdftools", quietly = TRUE)) {
  layer <- pdftools::pdf_text(pdf_file)[PDF_PAGE]
  layer_tokens <- unique(unlist(regmatches(layer, gregexpr("[0-9][0-9.,]*|\\.[0-9]+", layer))))
  cells <- grid[DATA_ROWS, -1, drop = FALSE]
  typed <- unique(unlist(regmatches(cells, gregexpr("[0-9][0-9.,]*|\\.[0-9]+", cells))))
  typed <- sub("[.,]$", "", typed)
  missing <- setdiff(typed, layer_tokens)
  if (length(missing))
    stop(item_name, ": numeric lexemes not found in the PDF text layer of page ", PDF_PAGE,
         ": ", paste(missing, collapse = ", "), call. = FALSE)
  message(item_name, ": all ", length(typed), " distinct numeric lexemes found in the text layer of PDF page ", PDF_PAGE)
} else message(item_name, ": pdftools not installed; text-layer cross-check skipped")

snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))

suppressPackageStartupMessages(library(openxlsx))
wb <- createWorkbook()
addWorksheet(wb, SHEET)
writeData(wb, SHEET, as.data.frame(grid, stringsAsFactors = FALSE),
          colNames = FALSE, keepNA = FALSE)
addStyle(wb, SHEET, createStyle(textDecoration = "bold", wrapText = TRUE),
         rows = HEADER_ROWS, cols = seq_len(NCOL), gridExpand = TRUE)
setColWidths(wb, SHEET, cols = 1, widths = 36)
setColWidths(wb, SHEET, cols = 2:NCOL, widths = 16)

## Refuse to silently overwrite a frozen copy that differs.
if (file.exists(snapshot_file)) {
  old <- as.matrix(readxl::read_excel(snapshot_file, sheet = SHEET,
                                      col_names = FALSE, col_types = "text",
                                      .name_repair = "minimal", trim_ws = FALSE))
  new <- grid
  dimnames(old) <- NULL; dimnames(new) <- NULL
  old[is.na(old)] <- ""; new[is.na(new)] <- ""
  if (!identical(dim(old), dim(new)) || !identical(unname(old), unname(new))) {
    stop(item_name, ": the frozen snapshot on disk differs from the block in this ",
         "script. Refusing to overwrite. Reconcile the difference against the PDF ",
         "and move the superseded file to archive/ before re-running.", call. = FALSE)
  }
  message(item_name, ": frozen snapshot already on disk and identical; nothing written.")
} else {
  saveWorkbook(wb, snapshot_file, overwrite = FALSE)
  message(item_name, ": wrote ", basename(snapshot_file), " (", nrow(grid), " rows x ", NCOL, " cols)")
}

# McLaughlin_etal_2014_Table4_snapshot.R -------------------------------
#
# Builds the frozen snapshot of McLaughlin, Sheridan, Winter, Fox, Zeanah &
# Nelson (2014) Biol Psychiatry 76: 629-638, Table 4 "Group Differences in the
# Volume of Subcortical Structures and the Cerebellum Among Children Reared in
# Institutions and Community Control Subjects in the Bucharest Early
# Intervention Project (n = 80)^a", p. 634 (PDF page 6).
#
# Printed (born-digital) journal PDF; the printed layout is written out
# verbatim below (HOWTO method 5 / Mink_etal_1981 pattern), frozen to .xlsx,
# and READ by McLaughlin_etal_2014_Table4.R. No cleaning happens here.
#
# Layout conventions (all reversible from the frozen file):
#  * one worksheet row per printed row, in printed order: caption, two header
#    tiers, the "Striatum" heading row, 8 structure rows, the footnote line;
#  * printed indentation is kept as two leading spaces (".." below): Caudate,
#    Putamen, Globus pallidus and Nucleus accumbens are indented under
#    "Striatum"; Amygdala, Hippocampus, Thalamus and Cerebellum are NOT;
#  * SDs in this table are printed WITHOUT parentheses (unlike Table 1);
#  * the Nucleus accumbens F cell prints "3.68S" -- kept verbatim (see the
#    errata file, McLaughlin_etal_2014-E001);
#  * superscript footnote mark written "^a". No unit is printed anywhere in
#    the table or caption.
#
# Transcribed by an AI assistant (Claude) on 2026-11-11 from 300- and 450-dpi
# renders of PDF page 6, read row by row across the printed table.
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

SHEET <- "Table4"; NCOL <- 7L; N_ROWS <- 13L; PDF_PAGE <- 6L
HEADER_ROWS <- 1:3; DATA_ROWS <- 4:12

printed <- "
Table 4. Group Differences in the Volume of Subcortical Structures and the Cerebellum Among Children Reared in Institutions and Community Control Subjects in the Bucharest Early Intervention Project (n = 80)^a||||||
|Ever Institutionalized Group (n = 58)||Never Institutionalized Group (n = 22)||Group Difference^a|
|M|SD|M|SD|F|p Value
Striatum||||||
..Caudate|8338.2|865.1|8693.7|878.1|1.03|.512
..Putamen|11,742.7|1052.2|11,804.0|1058.4|.31|.763
..Globus pallidus|4242.6|485.5|4417.8|484.2|1.00|.512
..Nucleus accumbens|1447.2|216.3|1389.5|187.7|3.68S|.472
Amygdala|3759.2|395.8|3893.8|336.4|1.43|.512
Hippocampus|9254.7|792.5|9382.8|749.7|.00|.992
Thalamus|14,465.7|1459.8|15,046.2|1187.1|1.47|.512
Cerebellum|130,490.5|12,289.3|134,281.3|13,773.0|.19|.763
^aAnalyses control for age, gender, total brain volume, and repetition time and p values corrected for the false discovery rate.||||||
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

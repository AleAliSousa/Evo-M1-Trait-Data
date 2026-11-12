# Latimer_Sawin_1955_TABLE2_snapshot.R: split from Latimer_Sawin_1955_extract_snapshot.R (one script per output); writes only Latimer_Sawin_1955_TABLE2_snapshot.*
# Latimer_Sawin_1955_TABLE2_snapshot.R ---------------------------------------
#
# Builds the six frozen snapshots of Latimer, H. B., & Sawin, P. B. (1955). The
# weight of the brain, of its parts and the weight and length of the spinal cord
# in the rabbit (race X). Journal of Comparative Neurology, 103(3), 513-539.
# https://doi.org/10.1002/cne.901030307
#
#   Latimer_Sawin_1955_TABLE1_snapshot.xlsx   sheet "TABLE1": TABLE 1, p. 517
#                                             (PDF page 5), body weight and length
#   Latimer_Sawin_1955_TABLE2_snapshot.xlsx   sheet "TABLE2": TABLE 2, p. 518
#                                             (PDF page 6), brain and brain parts
#   Latimer_Sawin_1955_TABLE4_snapshot.xlsx   sheet "TABLE4": TABLE 4, p. 524
#                                             (PDF page 12), brain and brain parts,
#                                             35 normal vs 15 dwarf males
#   Latimer_Sawin_1955_TABLE5_snapshot.xlsx   sheet "TABLE5": TABLE 5, p. 525
#                                             (PDF page 13), the same for 30 normal
#                                             vs 20 dwarf females
#   Latimer_Sawin_1955_TABLE6_snapshot.xlsx   sheet "TABLE6": TABLE 6, p. 526
#                                             (PDF page 14), spinal cord, 50 males
#                                             vs 50 females
#   Latimer_Sawin_1955_TABLE7_snapshot.xlsx   sheet "TABLE7": TABLE 7, p. 527
#                                             (PDF page 15), spinal cord, normal vs
#                                             dwarf males and females
#
# TABLE 3 (empirical formulae) and TABLE 8 (correlations) are not registered and
# are not snapshotted here.
#
# The source is a 1955 journal scan: Acrobat Paper Capture OCR laid over 300-ppi
# bitonal page images. The OCR text layer is NOT reliable and nothing was taken
# from it: on these two pages it reads "2.47" where the page prints 4.47 (TABLE 1,
# Panel B, dwarf males, nose-anus length, Coef. var.), "XALES" for MALES, "Cody
# weight" for Body weight, "30 I O R X A L" for 30 NORMAL, "Erdn" for Brain, and
# it garbles the TABLE 2 column headers. On pages 12-15 it reads "9.205" where the
# page prints 9.265 (TABLE 4, NORMAL Brain Average), "O.OG39" for 0.0639 and
# "3.5-1" for 3.54 (TABLE 4), "80 dwarf" for 20 dwarf (TABLE 5 caption), "1.61"
# for 1.64 (TABLE 7, dwarf females, Cord L. % of B.L., Stand. dev.), "Cord r,."
# for Cord L., "5 0 MALES" for 50 MALES and "YAI.UE" for VALUE. The values below
# are a HAND TRANSCRIPTION read from the page images (__HOWTO_make_a_snapshot.md
# method 5; the Mink_etal_1981 printed-layout-block pattern). This script freezes
# each block to .xlsx and refuses to overwrite a frozen copy that differs; the
# build scripts (Latimer_Sawin_1955_TABLE1.R, _TABLE2.R, _TABLE4.R, _TABLE5.R,
# _TABLE6.R, _TABLE7.R) READ the frozen files.
# No cleaning happens here.
#
# Fidelity decisions, all of them reversible from the frozen files:
#
#  * One snapshot row per PRINTED ROW, in printed order: the table number, the
#    caption (its printed line breaks are typesetting and are joined with a
#    space), panel titles and block headings, the header tiers, the data rows and,
#    under TABLE 1, the printed footnote. Neither table prints a blank row.
#  * Columns as printed: row label | first group (Average, Stand. dev., Coef. var.)
#    | second group (the same three) | "t" VALUES. A spanning group header ("50
#    MALES", "35 NORMAL", ...) sits in the first column of its span with blank
#    padding to its right. The "t" VALUES header spans both header tiers and sits
#    in the upper one.
#  * A header printed on two lines ("Stand." over "dev.") is ONE cell holding a
#    real newline (written "\\n" in the blocks below).
#  * Small capitals are written as capitals ("50 MALES", "VALUES"). The printed
#    quotes around t are typographic and are written “t”. The row label prints an
#    en dash in "nose–anus" (the running text prints a hyphen); kept.
#  * TABLE 1 Panels B and C print only the group labels ("35 NORMAL", "15 DWARF");
#    they do not repeat the statistic header row or the "t" header. Reproduced as
#    printed, not repaired.
#  * TABLE 2's first block ("Weights in grams", per the caption) has no block
#    heading of its own; the other two blocks do. Reproduced as printed.
#  * Every numeric cell is kept as printed text, trailing zeros included
#    ("1870.0", "0.060"), and with its printed number of decimals: TABLE 7 prints
#    the Stand. dev. of the 30 normal females' cord weight with two decimals
#    ("0.38") where the rest of that column prints three. Kept.
#  * TABLES 4 and 5 print all three block headings, "Weights in grams" included
#    (TABLE 2 prints none over its grams block), and their third heading reads
#    "Percentages of brain weight" (TABLE 2: "Percentages of total brain weight").
#    Their group headers print no n ("NORMAL", "DWARF"); the n is in the caption.
#    Block headings sit in the first column, as in TABLE 2.
#  * TABLE 4 prints a footnote under its last row ("In tables 4, 5, and 7, ...");
#    TABLES 5, 6 and 7 print none. Reproduced where printed.
#  * TABLE 6 prints the singular "“t”" over "VALUE"; TABLES 4, 5 and 7 print
#    VALUES. Kept.
#  * TABLES 6 and 7 print two row labels on two lines ("Cord, % of" over "net
#    B.W."; "Cord L., % of" over "B.L."), their numbers level with the second
#    line. Such a label is ONE cell holding a real newline, on the row of its
#    numbers. TABLE 7 breaks its female label differently ("Cord, % of net" over
#    "B.W."); kept as printed. The wide space in "Cord,  gm" and "net  B.W." is
#    justification to the column and is written as one space.
#  * TABLE 7 is printed in two blocks headed "35 normal and 15 dwarf males" and
#    "30 normal and 20 dwarf females"; the column headers are printed once, above
#    the first block. Reproduced as printed.
#
# TABLES 1 and 2 transcribed by an AI assistant on 2026-11-06 from the PDF's own
# 300-ppi page images (extracted without resampling), read at 1x, 2x and 4x zoom,
# then cross-read cell by cell against the OCR text layer: 161 numeric cells, one
# disagreement (the 4.47 above), resolved from the image and by arithmetic
# (100 x 19.4 / 433.6 = 4.47).
# TABLES 4, 5, 6 and 7 transcribed by an AI assistant on 2026-11-07 from 300-dpi
# renders of PDF pages 12-15 (pdftoppm -r 300), read at 1x and 2x zoom and at 4x
# for every cell the text layer reads differently, then cross-read cell by cell
# against the OCR text layer: 280 numeric cells, four numeric disagreements (9.205,
# O.OG39, 3.5-1 and 1.61 above), each resolved from the image; the caption's 20
# (text layer "80") also agrees with TABLE 1 Panel C ("20 DWARF").
#
# R NOT RUN — outputs written by a Python mirror; Alexandra to run the R. The six
# frozen .xlsx files were written by a Python mirror of this script that parses
# the blocks below (TABLES 1 and 2 on 2026-11-06, TABLES 4-7 on 2026-11-07); run
# this script once to confirm that it reports all six frozen snapshots as
# identical (nothing is rewritten).
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)

suppressPackageStartupMessages(library(openxlsx))

## The printed sheets, one line per worksheet row, cells separated by "|", an
## empty field where the page (or a header tier) is blank. "\\n" inside a field is
## a printed line break WITHIN one cell.
printed_TABLE2 <- "
TABLE 2|||||||
Weights in grams and percentage weights of the brain and of its parts in 50 male and in 50 female rabbits|||||||
|MALES|||FEMALES|||“t”\\nVALUES
|Average|Stand.\\ndev.|Coef.\\nvar.|Average|Stand.\\ndev.|Coef.\\nvar.|
Brain|9.156|0.537|5.86|9.349|0.717|7.67|1.48
Prosencephalon|6.118|0.424|6.92|6.218|0.528|8.50|1.03
Mesencephalon|0.753|0.060|8.00|0.785|0.064|8.14|2.56
Cerebellum|1.381|0.089|6.48|1.437|0.122|8.49|2.59
Medulla|0.889|0.076|8.60|0.910|0.072|7.94|1.43
Percentages of net body weight|||||||
Brain|0.596|0.077|12.94|0.554|0.082|14.77|2.66
Prosencephalon|0.398|0.053|13.30|0.368|0.055|15.03|2.74
Mesencephalon|0.049|0.008|15.75|0.047|0.008|17.62|1.55
Cerebellum|0.090|0.013|14.25|0.085|0.012|14.46|2.01
Medulla|0.058|0.007|12.42|0.054|0.008|15.10|2.45
Percentages of total brain weight|||||||
Prosencephalon|66.90|1.45|2.17|66.47|1.13|1.71|1.63
Mesencephalon|8.25|0.61|7.37|8.42|0.62|7.38|1.37
Cerebellum|15.13|0.86|5.71|15.37|0.59|3.81|1.61
Medulla|9.72|0.61|6.32|9.74|0.48|4.88|0.18
"

NCOL <- 8L

to_grid <- function(txt) {
  lines <- strsplit(trimws(txt, which = "both"), "\n", fixed = TRUE)[[1]]
  stopifnot(all(lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) == NCOL - 1L))
  g <- do.call(rbind, lapply(lines, function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- NCOL
    x
  }))
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  g[!is.na(g) & g == ""] <- NA_character_
  g
}
grid_T2 <- to_grid(printed_TABLE2)
## Structural guards. A data row prints all seven numeric cells.
is_num_row <- function(g) apply(g[, 2:NCOL, drop = FALSE], 1, function(x)
  all(!is.na(x) & grepl("^[0-9]+\\.[0-9]+$", x)))
## TABLE 2: 20 printed rows; 5 + 5 + 4 = 14 data rows under 3 blocks.
stopifnot(nrow(grid_T2) == 20L, sum(is_num_row(grid_T2)) == 14L,
          sum(grepl("^Percentages of ", grid_T2[, 1])) == 2L,
          grid_T2[1, 1] == "TABLE 2")
freeze_xlsx <- function(grid, file, sheet) {
  if (file.exists(file)) {
    old <- as.matrix(readxl::read_excel(file, sheet = sheet, col_names = FALSE,
                                        .name_repair = "minimal"))
    new <- grid
    dimnames(old) <- NULL; dimnames(new) <- NULL
    old[is.na(old)] <- ""; new[is.na(new)] <- ""
    if (!identical(dim(old), dim(new)) || !identical(unname(old), unname(new)))
      stop(basename(file), ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF page ",
           "image and move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
    return(invisible(FALSE))
  }
  data_rows  <- which(is_num_row(grid))
  hdr_rows   <- which(!is_num_row(grid) & is.na(grid[, 1]))        # header tiers
  label_rows <- setdiff(which(!is_num_row(grid) & !is.na(grid[, 1])),
                        c(2L, grep("^In tables", grid[, 1])))       # titles, headings
  wb <- createWorkbook()
  addWorksheet(wb, sheet)
  writeData(wb, sheet, as.data.frame(grid, stringsAsFactors = FALSE),
            colNames = FALSE, keepNA = FALSE)
  addStyle(wb, sheet, createStyle(textDecoration = "bold", wrapText = TRUE,
                                  valign = "top", halign = "center"),
           rows = hdr_rows, cols = seq_len(NCOL), gridExpand = TRUE)
  addStyle(wb, sheet, createStyle(textDecoration = "bold"), rows = label_rows, cols = 1L)
  addStyle(wb, sheet, createStyle(textDecoration = "italic"), rows = 2L, cols = 1L)
  addStyle(wb, sheet, createStyle(halign = "right"), rows = data_rows,
           cols = 2:NCOL, gridExpand = TRUE)
  wrap_rows <- data_rows[grepl("\n", grid[data_rows, 1], fixed = TRUE)]  # two-line row labels
  if (length(wrap_rows))
    addStyle(wb, sheet, createStyle(wrapText = TRUE), rows = wrap_rows, cols = 1L)
  setColWidths(wb, sheet, cols = 1, widths = 30)
  setColWidths(wb, sheet, cols = 2:NCOL, widths = 12)
  saveWorkbook(wb, file, overwrite = FALSE)
  message(basename(file), ": wrote ", nrow(grid), " rows x ", NCOL, " cols (",
          length(data_rows), " printed data rows)")
  invisible(TRUE)
}

freeze_xlsx(grid_T2, file.path(folder, paste0(item_name, "_snapshot.xlsx")), "TABLE2")

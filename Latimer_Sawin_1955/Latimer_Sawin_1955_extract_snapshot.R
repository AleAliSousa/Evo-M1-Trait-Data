# Latimer_Sawin_1955_extract_snapshot.R ---------------------------------------
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

suppressPackageStartupMessages(library(openxlsx))

## The printed sheets, one line per worksheet row, cells separated by "|", an
## empty field where the page (or a header tier) is blank. "\\n" inside a field is
## a printed line break WITHIN one cell.
printed_TABLE1 <- "
TABLE 1|||||||
Weight and length of the body for the entire group of 50 males and 50 females in panel A. Panels B and C show similar data for the normal and dwarf males and females|||||||
Panel A All rabbits together|||||||
|50 MALES|||50 FEMALES|||“t”\\nVALUES
|Average|Stand.\\ndev.|Coef.\\nvar.|Average|Stand.\\ndev.|Coef.\\nvar.|
Body weight, gross|1870.0|301.8|16.14|2192.9|459.7|20.96|4.11
Body weight, net|1565.4|244.4|15.61|1734.9|337.3|19.44|2.86
Body length, nose–anus|454.6|24.1|5.30|478.3|33.7|7.05|4.00
Panel B Males|||||||
35 normal and 15 dwarf males|||||||
|35 NORMAL|||15 DWARF|||
Body weight, gross|1972.3|274.3|13.91|1630.6|234.1|14.36|4.20
Body weight, net|1650.0|214.6|13.01|1367.9|196.4|14.36|4.32
Body length, nose–anus|463.7|20.8|4.49|433.6|19.4|4.47|4.76
Panel C Females|||||||
30 normal and 20 dwarf females|||||||
|30 NORMAL|||20 DWARF|||
Body weight, gross|2480.0|345.4|13.93|1762.1|219.5|12.46|8.24
Body weight, net|1959.3|230.7|11.78|1398.4|139.5|9.98|9.73
Body length, nose–anus|496.8|16.3|3.27|444.3|20.4|4.59|10.20
In tables 1, 2 and 6, “t” values of 2.63 and above are significant at 1% and “t” values from 1.98 to 2.62 are significant at 5%.|||||||
"

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

printed_TABLE4 <- "
TABLE 4|||||||
Weights of the brain and of its parts in 35 normal and in 15 dwarf male rabbits|||||||
|NORMAL|||DWARF|||“t”\\nVALUES
|Average|Stand.\\ndev.|Coef.\\nvar.|Average|Stand.\\ndev.|Coef.\\nvar.|
Weights in grams|||||||
Brain|9.265|0.459|4.95|8.849|0.610|6.90|2.63
Prosencephalon|6.241|0.342|5.48|5.898|0.442|7.50|2.95
Mesencephalon|0.751|0.060|7.95|0.756|0.067|8.89|0.27
Cerebellum|1.403|0.079|5.64|1.331|0.096|7.23|2.75
Medulla|0.899|0.075|8.30|0.864|0.077|8.96|1.48
Percentages of net body weight|||||||
Brain|0.571|0.071|12.36|0.654|0.060|9.20|3.92
Prosencephalon|0.382|0.050|13.03|0.436|0.041|9.40|3.62
Mesencephalon|0.0462|0.0067|14.40|0.0559|0.0058|10.30|4.85
Cerebellum|0.0864|0.0117|13.53|0.0987|0.0097|9.82|3.54
Medulla|0.0551|0.0060|10.87|0.0639|0.0060|9.41|4.71
Percentages of brain weight|||||||
Prosencephalon|67.02|1.59|2.38|66.63|1.04|1.57|0.86
Mesencephalon|8.12|0.62|7.67|8.55|0.43|5.04|2.40
Cerebellum|15.16|0.86|5.68|15.06|0.89|5.94|0.37
Medulla|9.70|0.68|7.04|9.76|0.52|5.30|0.30
In tables 4, 5, and 7, “t” values of 2.68 and above are significant at 1% and those between 2.01 and 2.67, are significant at 5% level.|||||||
"

printed_TABLE5 <- "
TABLE 5|||||||
Weights of the brain and of its parts in 30 normal and in 20 dwarf female rabbits|||||||
|NORMAL|||DWARF|||“t”\\nVALUES
|Average|Stand.\\ndev.|Coef.\\nvar.|Average|Stand.\\ndev.|Coef.\\nvar.|
Weights in grams|||||||
Brain|9.755|0.493|5.05|8.740|0.577|6.60|6.66
Prosencephalon|6.503|0.393|6.04|5.789|0.411|7.10|6.12
Mesencephalon|0.804|0.057|7.08|0.757|0.065|8.58|2.70
Cerebellum|1.503|0.087|5.79|1.338|0.100|7.45|4.35
Medulla|0.945|0.061|6.44|0.857|0.054|6.30|5.20
Percentages of net body weight|||||||
Brain|0.504|0.057|11.29|0.629|0.052|8.24|7.80
Prosencephalon|0.336|0.043|12.69|0.416|0.034|8.13|6.95
Mesencephalon|0.0414|0.0041|9.94|0.0545|0.0065|11.95|8.67
Cerebellum|0.0775|0.0072|9.32|0.0962|0.0088|9.17|8.14
Medulla|0.0487|0.0050|10.32|0.0617|0.0053|8.66|8.56
Percentages of brain weight|||||||
Prosencephalon|66.64|1.29|1.93|66.22|0.81|1.22|1.28
Mesencephalon|8.25|0.54|6.49|8.67|0.67|7.74|2.43
Cerebellum|15.41|0.63|4.12|15.30|0.48|3.11|0.65
Medulla|9.70|0.56|5.74|9.81|0.31|3.15|0.79
"

printed_TABLE6 <- "
TABLE 6|||||||
Weights, lengths and percentage weights and lengths of the spinal cord in 50 male and 50 female rabbits|||||||
|50 MALES|||50 FEMALES|||“t”\\nVALUE
|Average|Stand.\\ndev.|Coef.\\nvar.|Average|Stand.\\ndev.|Coef.\\nvar.|
Cord, gm|3.925|0.384|9.78|4.292|0.470|10.96|4.23
Cord, mm|276.5|13.8|4.98|288.3|16.0|5.56|3.64
Cord, % of\\nnet B.W.|0.255|0.031|12.15|0.253|0.032|12.85|0.41
Cord L., % of\\nB.L.|60.9|1.69|2.77|60.7|1.75|2.88|0.58
"

printed_TABLE7 <- "
TABLE 7|||||||
Weights, lengths and percentage weights and lengths of the spinal cord in the normal and dwarf rabbits|||||||
|NORMAL|||DWARF|||“t”\\nVALUES
|Average|Stand.\\ndev.|Coef.\\nvar.|Average|Stand.\\ndev.|Coef.\\nvar.|
35 normal and 15 dwarf males|||||||
Cord, gm|3.945|0.365|9.26|3.915|0.438|11.19|0.24
Cord, mm|280.6|12.1|4.32|267.0|13.0|4.89|3.62
Cord, % of\\nnet B.W.|0.241|0.022|9.19|0.288|0.023|8.08|6.70
Cord L., % of\\nB.L.|60.5|1.49|2.47|61.6|1.94|3.16|2.16
30 normal and 20 dwarf females|||||||
Cord, gm|4.537|0.38|8.31|3.926|0.359|9.15|5.72
Cord, mm|298.5|9.6|3.21|273.0|12.3|4.49|8.38
Cord, % of net\\nB.W.|0.233|0.022|9.21|0.282|0.024|8.43|7.40
Cord L., % of\\nB.L.|60.1|1.62|2.70|61.5|1.64|2.68|2.94
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

grid_T1 <- to_grid(printed_TABLE1)
grid_T2 <- to_grid(printed_TABLE2)
grid_T4 <- to_grid(printed_TABLE4)
grid_T5 <- to_grid(printed_TABLE5)
grid_T6 <- to_grid(printed_TABLE6)
grid_T7 <- to_grid(printed_TABLE7)

## Structural guards. A data row prints all seven numeric cells.
is_num_row <- function(g) apply(g[, 2:NCOL, drop = FALSE], 1, function(x)
  all(!is.na(x) & grepl("^[0-9]+\\.[0-9]+$", x)))
## TABLE 1: 21 printed rows; 3 panels x 3 rows = 9 data rows.
stopifnot(nrow(grid_T1) == 21L, sum(is_num_row(grid_T1)) == 9L,
          sum(grepl("^Panel [A-C] ", grid_T1[, 1])) == 3L,
          grid_T1[1, 1] == "TABLE 1")
## TABLE 2: 20 printed rows; 5 + 5 + 4 = 14 data rows under 3 blocks.
stopifnot(nrow(grid_T2) == 20L, sum(is_num_row(grid_T2)) == 14L,
          sum(grepl("^Percentages of ", grid_T2[, 1])) == 2L,
          grid_T2[1, 1] == "TABLE 2")
## TABLE 4: 22 printed rows; 5 + 5 + 4 = 14 data rows under 3 headed blocks; footnote.
stopifnot(nrow(grid_T4) == 22L, sum(is_num_row(grid_T4)) == 14L,
          sum(grid_T4[, 1] %in% "Weights in grams") == 1L,
          sum(grepl("^Percentages of ", grid_T4[, 1])) == 2L,
          sum(grepl("^In tables ", grid_T4[, 1])) == 1L,
          grid_T4[1, 1] == "TABLE 4")
## TABLE 5: 21 printed rows; the same 14 data rows under 3 headed blocks; no footnote.
stopifnot(nrow(grid_T5) == 21L, sum(is_num_row(grid_T5)) == 14L,
          sum(grid_T5[, 1] %in% "Weights in grams") == 1L,
          sum(grepl("^Percentages of ", grid_T5[, 1])) == 2L,
          !any(grepl("^In tables ", grid_T5[, 1])),
          grid_T5[1, 1] == "TABLE 5")
## TABLE 6: 8 printed rows; 4 data rows, no block heading.
stopifnot(nrow(grid_T6) == 8L, sum(is_num_row(grid_T6)) == 4L,
          grid_T6[1, 1] == "TABLE 6")
## TABLE 7: 14 printed rows; 2 blocks (males, females) x 4 data rows.
stopifnot(nrow(grid_T7) == 14L, sum(is_num_row(grid_T7)) == 8L,
          sum(grepl("^[0-9]+ normal and [0-9]+ dwarf (males|females)$", grid_T7[, 1])) == 2L,
          grid_T7[1, 1] == "TABLE 7")

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

freeze_xlsx(grid_T1, file.path(folder, paste0(paper, "_TABLE1_snapshot.xlsx")), "TABLE1")
freeze_xlsx(grid_T2, file.path(folder, paste0(paper, "_TABLE2_snapshot.xlsx")), "TABLE2")
freeze_xlsx(grid_T4, file.path(folder, paste0(paper, "_TABLE4_snapshot.xlsx")), "TABLE4")
freeze_xlsx(grid_T5, file.path(folder, paste0(paper, "_TABLE5_snapshot.xlsx")), "TABLE5")
freeze_xlsx(grid_T6, file.path(folder, paste0(paper, "_TABLE6_snapshot.xlsx")), "TABLE6")
freeze_xlsx(grid_T7, file.path(folder, paste0(paper, "_TABLE7_snapshot.xlsx")), "TABLE7")

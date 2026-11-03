# Heiss_etal_1985_extract_snapshot.R ------------------------------------------
#
# Builds the two frozen snapshots of Heiss, Pawlik, Herholz, Wagner & Wienhard
# (1985) "Regional cerebral glucose metabolism in man during wakefulness,
# sleep, and dreaming", Brain Research 327: 362-366.
#
#   Heiss_etal_1985_TABLEI_snapshot.csv           TABLE I, p. 363 (PDF page 2)
#   Heiss_etal_1985_Text_snapshot.csv   values printed only in the
#                                                 abstract (p. 362) and the
#                                                 RESULTS text (p. 364)
#
# The source is a 1985 scanned journal page. Its OCR text layer is legible for
# this paper but was NOT used as the source: the values below are a HAND
# TRANSCRIPTION read from 300- and 400-dpi renders of PDF pages 1-3
# (__HOWTO_make_a_snapshot.md method 5, the Mink_etal_1981 /
# Jacobs_etal_2018 printed-layout-block pattern). The OCR layer was used only
# afterwards as an independent second reading; it agreed on every value.
# This script writes the frozen files and refuses to overwrite a frozen copy
# that differs. The build scripts READ those files. No cleaning happens here.
#
# Fidelity decisions (all reversible from the frozen file):
#  * One snapshot row per printed row. TABLE I prints 24 region rows in six
#    groups separated by a vertical gap; each gap is kept as an empty row, so
#    snapshot row n matches printed line n. "Whole brain (all regions /
#    weighted according to size)" is one region printed on two lines: one cell
#    holding a real newline.
#  * The two spanning headers ("Non-dreamers (n = 3)" over columns 2-3,
#    "Dreamer" over 4-5) sit in their first column with blank padding.
#  * Signs are kept as printed, including the alignment space between a minus
#    or plus sign and a single-digit value ("- 9.2 ± 9.84", "+ 7.4"). The page
#    prints a typographic minus; it is written as ASCII "-".
#  * The text snapshot is CONSTRUCTED (there is no printed table): one row per
#    printed value, with page, column and the sentence it comes from.
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders.
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

## ---- printed blocks: one line per row, cells separated by "|" ----------------
## "\\n" inside a field is a printed line break WITHIN one cell.

printed_TABLEI <- "
TABLE I||||
Regional cerebral metabolic rate for glucose in normal human subjects during sleep and wakefulness (µmol/100 g/min)||||
Region|Non-dreamers (n = 3)||Dreamer|
|Awake\\n(mean ± S.D.)|% Change asleep\\n(mean ± S.D.)|Awake|% Change asleep
Orbital cortex|42.1 ± 1.85|-20.5 ± 8.65|36.3|+ 7.4
Inf. front. cortex|44.6 ± 2.35|-14.5 ± 3.97|39.4|+ 4.3
Sup. front. cortex|41.4 ± 1.99|-11.7 ± 6.92|30.0|+30.0
Premotor cortex|42.6 ± 1.83|-13.9 ± 4.81|38.4|+11.5
Sensorimot. cortex|44.2 ± 3.07|-14.2 ± 4.21|37.0|+16.2
Insular cortex|39.7 ± 1.39|-12.3 ± 3.36|30.8|+26.0
Inf. temp. cortex|35.4 ± 2.92|-10.6 ± 5.20|31.9|+11.6
Middle temp. cortex|38.8 ± 3.00|-11.8 ± 7.71|34.0|+ 8.8
Sup. temp. cortex|41.3 ± 2.11|-10.9 ± 6.97|36.8|+ 5.7
Inf. par. cortex|38.2 ± 2.68|-11.5 ± 5.40|31.0|+25.2
Sup. par. cortex|38.8 ± 1.75|-11.6 ± 4.57|33.7|+13.9
Vis. assoc. cortex|36.1 ± 3.07|-12.3 ± 4.98|29.1|+22.3
Prim. vis. cortex|40.1 ± 4.09|- 9.2 ± 9.84|35.5|+20.0
||||
Inf. limbic struct.|32.3 ± 2.50|- 9.9 ± 4.76|27.9|+14.0
Hippocampus|38.3 ± 5.17|- 9.4 ± 9.33|31.6|+23.4
Cingulate gyrus|44.6 ± 2.86|-11.9 ± 7.62|41.0|+11.2
||||
Front. bas. white matter|21.6 ± 0.83|-13.4 ± 5.14|18.6|+11.8
Occ. par. white matter|20.8 ± 1.72|-14.8 ± 1.88|17.0|+ 8.2
||||
Caudate nucleus|40.5 ± 3.52|-11.6 ± 6.57|34.0|+ 7.9
Lentiform nucleus|41.6 ± 6.35|- 9.6 ± 8.85|38.3|+ 2.1
Thalamus|38.4 ± 3.21|-17.5 ± 7.22|31.0|+14.5
||||
Brainstem|27.9 ± 4.85|- 6.8 ± 12.10|24.6|+17.1
Cerebellar gray matter|32.9 ± 5.96|- 9.5 ± 4.00|31.1|+ 9.3
||||
Whole brain (all regions\\nweighted according to size)|36.2 ± 2.38|-12.6 ± 4.73|30.3|+16.4
"

printed_text <- "
text_row|page|location|passage_as_printed|value_printed|dispersion_printed|units_printed|subjects_as_printed|state_as_printed|region_as_printed
1|362|Abstract|exhibited a non-selective decrease in metabolic rates averaging 12.6 ± 4.73% (mean ± S.D.) for the entire brain|12.6|4.73|% (decrease)|3 of the subjects [who] did not report dreaming|sleep stages I-IV|the entire brain
2|362|Abstract|a generalized increase in cerebral glucose utilization ranging from 2.1% in lentiform nucleus to 30.0% in the superior frontal cortex|2.1||% (increase)|the fourth volunteer who experienced an extended nightmare|sleep examination|lentiform nucleus
3|362|Abstract|a generalized increase in cerebral glucose utilization ranging from 2.1% in lentiform nucleus to 30.0% in the superior frontal cortex|30.0||% (increase)|the fourth volunteer who experienced an extended nightmare|sleep examination|the superior frontal cortex
4|362|Abstract|with a weighted whole brain average of 16.4%|16.4||% (increase)|the fourth volunteer who experienced an extended nightmare|sleep examination|weighted whole brain
5|364|left column, RESULTS para. 1|the dreaming volunteer's metabolic rates (weighted whole brain average = 30.3 µmol/100 g/min)|30.3||µmol/100 g/min|the dreaming volunteer|during wakefulness|weighted whole brain
6|364|left column, RESULTS para. 1|from the non-dreamers group (36.2 ± 2.38 µmol/100 g/min)|36.2|2.38|µmol/100 g/min|the non-dreamers group|during wakefulness|weighted whole brain
7|364|right column, RESULTS para. 2|a significant ... generalized decrease in brain glucose utilization down to a weighted average of 31.6 ± 1.42 µmol/100 g/min for the whole brain|31.6|1.42|µmol/100 g/min|the non-dreaming volunteers|during sleep|the whole brain
8|364|right column, RESULTS para. 2|increases were so far above the weighted whole brain average of + 16.4%|+ 16.4||% (increase)|the dreaming subject|his sleep study|weighted whole brain
"

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  g
}

grid_T1 <- to_grid(printed_TABLEI, 5L)
grid_tx <- to_grid(printed_text, 10L)

## Structural guards: 4 header rows + 24 region rows + 5 gap rows; 1 header + 8 text rows.
stopifnot(nrow(grid_T1) == 4L + 24L + 5L, sum(nzchar(grid_T1[5:33, 1])) == 24L)
stopifnot(nrow(grid_tx) == 9L)

## ---- freeze, refusing to overwrite a differing frozen copy --------------------
freeze <- function(grid, file) {
  if (file.exists(file)) {
    old <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                              na.strings = character(0), check.names = FALSE,
                              encoding = "UTF-8"))
    dimnames(old) <- NULL
    new <- grid; dimnames(new) <- NULL
    if (!identical(dim(old), dim(new)) || !identical(old, new))
      stop(basename(file), ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and ",
           "move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
  }
}

freeze(grid_T1, file.path(folder, paste0(paper, "_TABLEI_snapshot.csv")))
freeze(grid_tx, file.path(folder, paste0(paper, "_Text_snapshot.csv")))

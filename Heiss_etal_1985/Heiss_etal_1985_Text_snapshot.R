# Heiss_etal_1985_Text_snapshot.R ---------------------------------------------
#
# Builds the frozen snapshot (text values only) of Heiss, Pawlik, Herholz, Wagner & Wienhard
# (1985) "Regional cerebral glucose metabolism in man during wakefulness,
# sleep, and dreaming", Brain Research 327: 362-366.
#
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
# This script writes the frozen file and refuses to overwrite a frozen copy
# that differs. The build script READS that file. No cleaning happens here.
#
# Fidelity decisions (all reversible from the frozen file):
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # Heiss_etal_1985_Text_snapshot

## ---- printed blocks: one line per row, cells separated by "|" ----------------
## "\\n" inside a field is a printed line break WITHIN one cell.

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

grid_tx <- to_grid(printed_text, 10L)

## Structural guard: 1 header + 8 text rows.
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

freeze(grid_tx, file.path(folder, paste0(sub("_snapshot$", "", item_name), "_snapshot.csv")))

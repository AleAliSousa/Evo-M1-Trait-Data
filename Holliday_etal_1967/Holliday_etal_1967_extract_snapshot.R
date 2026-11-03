# Holliday_etal_1967_extract_snapshot.R ----------------------------------------
#
# Builds the frozen snapshots of Holliday, Potter, Jarrah & Bearg (1967), "The relation
# of metabolic rate to body weight and organ size", Pediatric Research 1: 185-195.
#
#   Holliday_etal_1967_TableII_snapshot.csv    Table II, p. 189 (PDF page 5)
#   Holliday_etal_1967_TableIII_snapshot.csv   Table III, p. 191 (PDF page 7)
#
# The PDF is a scanned reprint WITHOUT a text layer (0 characters on all 11 pages), so
# there is no machine-readable second reading. The blocks below are a HAND
# TRANSCRIPTION read from 170-350 dpi renders by an AI assistant (Claude) on
# 2026-11-03 (__HOWTO_make_a_snapshot.md method 5), re-verified cell by cell against
# the page images and against the earlier working transcription
# (__energetics_comparison/classic_energetics_compilations/holliday_1967_table3_transcribed.csv,
# classic_human_brain_partition.csv): no cell differs. This script writes the frozen
# file and refuses to overwrite a differing frozen copy; the build READS it.
#
# Fidelity: values as printed, including leading-point decimals (".92", ".3"), the
# parenthesised estimates "(200)", the lung weight "12" printed without a decimal point
# in the 10 kg infant column (it must be .12 for the weights to sum to the printed 1.46
# kg; kept as printed, see README and errata), "20,340" / "13,700" (thousands commas kept),
# and the printed total "3890" for Hog (the five organs add to 3870; kept as printed).
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

printed_TableII <- "
Table II. Organ metabolic rate, OMR, cal/day compared to whole body BMR for a 10 kg infant and a 70 kg adult||||||||
Organ|10 kg infant||||70 kg adult|||
|OMR/kg\\n(cal/kg/day)|Weight\\n(kg)|OMR\\ncal/organ/day\\ntotal|%|OMR/kg\\n(cal/kg/day)|Weight\\n(kg)|OMR\\ncal/organ/day\\ntotal|%
Brain [21]|260|.92|240|45|260|1.4|365|21
Heart [39]|600|.05|30|6|600|.3|180|10
Kidney [11]|400|.07|28|5|400|.3|120|7
Liver (splanchnic) [6]|350|.30|105|19|350|1.6|560|32
Lung (estimated)|(200)|12|24|4|(200)|.8|160|9
||||||||
Total derived from 5 organs||1.46|427|79||4.4|1385|79
Total BMR|||540||||1780|
"

printed_TableIII <- "
Table III. Relation of organ weight to body weight in 9 species (Data from BRODY [8])||||||||||
Organ|Dog|Guinea\\npig|Hog|Horse|Human|Monkey|Rat|Sheep|Steer
|Organ weight (g)|||||||||
Brain|175|4.7|120|670|1300|42|2.00|105|500
Heart|85|2.3|350|4250|320|23|0.94|280|2300
Kidneys|140|11.2|500|3320|500|42|4.20|320|2000
Liver|420|27.0|1600|6700|1700|110|12.00|960|5000
Lung|120|5.0|1300|5400|980|30|1.30|710|3900
||||||||||
Total|940|50.2|3890|20,340|4800|247|20.44|2375|13,700
|Body weight (kg)|||||||||
|10|0.8|125|600|60|4.5|0.25|52|700
Sum of total organ wt\\n———————\\nbody weight  ×100|||||||||
|9.44|6.25|3.12|3.39|8.0|5.49|8.16|4.56|1.95
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

grid_T2 <- to_grid(printed_TableII, 9L)
grid_T3 <- to_grid(printed_TableIII, 10L)

## Structural guards: Table II = 3 header rows + 5 organ rows + gap + 2 total rows;
## Table III = 3 header rows + 5 organ rows + gap + total + 2 body-weight rows + 2 ratio rows.
stopifnot(nrow(grid_T2) == 3L + 5L + 1L + 2L, sum(nzchar(grid_T2[4:8, 3])) == 5L)
stopifnot(nrow(grid_T3) == 3L + 5L + 1L + 1L + 2L + 2L, sum(nzchar(grid_T3[4:8, 2])) == 5L)

freeze(grid_T2, file.path(folder, paste0(paper, "_TableII_snapshot.csv")))
freeze(grid_T3, file.path(folder, paste0(paper, "_TableIII_snapshot.csv")))

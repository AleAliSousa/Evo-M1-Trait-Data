# Hevner_WongRiley_1990_Table1_snapshot.R ------------------------------------------------
#
# Builds the frozen snapshot of Hevner & Wong-Riley (1990) "Regulation of
# cytochrome oxidase protein levels by functional activity in the macaque monkey
# visual system", Journal of Neuroscience 10(4): 1331-1340
# (doi 10.1523/JNEUROSCI.10-04-01331.1990; verified against CrossRef 2026-11-18).
#
#   Hevner_WongRiley_1990_Table1_snapshot.csv      Table 1, J Neurosci 10: 1337
#                                              (PDF page 7, upper right)
#
# The source is a scanned 1990 journal page. Its OCR text layer is readable for
# words but garbles the ± signs ("*", "f", "k", "+") and interleaves the two value
# columns, so no value was taken from it. The values below are a HAND
# TRANSCRIPTION read from a 200-dpi render of the page (__HOWTO_make_a_snapshot.md
# method 5, the Sokoloff_etal_1977 printed-layout-block pattern), checked cell by
# cell against a zoomed crop of the table. This script writes the frozen file and
# refuses to overwrite a frozen copy that differs; the build script READS it.
# No cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed row: caption, two header tiers (the spanning
#    header "Relative optical density (mean ± SD)" sits over columns 2-3 with a
#    blank under it in column 1; the row-label header "Cortical layer, treatment,
#    and region" is printed on three lines and kept with "\\n"), the two printed
#    section headings, the four region rows in printed order, the footnote last.
#  * "±" is kept; the column header "Immunohisto-\\nchemistry" keeps its printed
#    line-break hyphen.
#  * The footnote is one printed paragraph and is kept as one cell.
#
# Transcribed and checked by an AI assistant (Claude) on 2026-11-18 from a
# 200-dpi page render and a zoomed crop of the table region.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

printed_Table1 <- "
Table 1. Optical densitometry of CO histochemical and immunohistochemical staining in normal and experimental striate cortex||
Cortical layer,\\ntreatment,\\nand region|Relative optical density (mean ± SD)|
|Histochemistry|Immunohisto-\\nchemistry
Normal layer 2 and 3||
Interpuff|1.00 ± 0.05|1.00 ± 0.04
Puff|1.32 ± 0.04|1.19 ± 0.04
TTX-treated (4 week) layer 4C||
Dark column|1.00 ± 0.04|1.00 ± 0.08
Light column|0.80 ± 0.02|0.79 ± 0.08
All sections were cut tangential to the cortical surface. Adjacent histochemically and immunohistochemically stained sections (normal and experimental) were used for densitometry. Densitometric readings were normalized to yield interpuff (normal cortex) or dark column (experimental cortex) densities of 1.00. For each region, 25 readings were taken. All puff/interpuff and dark-column/light-column differences within a section were significant (p < 0.001, Student's t test, 2-tailed). Optical density may not be linearly proportional to CO activity or amount.||
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

grid_T <- to_grid(printed_Table1, 3L)

## Structural guards: 10 printed rows; 4 region rows, each with both value columns filled;
## the two normalisation-reference rows (Interpuff, Dark column) print 1.00 in both columns.
val_rows <- grepl("^[0-9.]+ ± [0-9.]+$", grid_T[, 2])
stopifnot(nrow(grid_T) == 10L, sum(val_rows) == 4L,
          all(grepl("^[0-9.]+ ± [0-9.]+$", grid_T[val_rows, 3])),
          grid_T[4, 1] == "Normal layer 2 and 3", grid_T[7, 1] == "TTX-treated (4 week) layer 4C",
          all(grepl("^1\\.00 ±", grid_T[c(5, 8), 2:3])))

freeze(grid_T, file.path(folder, paste0(item_name, "_snapshot.csv")))

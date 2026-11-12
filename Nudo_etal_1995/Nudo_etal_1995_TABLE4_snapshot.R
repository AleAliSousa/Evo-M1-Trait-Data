# Nudo_etal_1995_TABLE4_snapshot.R ----------------------------------------------------
# R port of the former Nudo_etal_1995_extract_snapshot.py/.R (openpyxl -> openxlsx), now one script per item:
# this script writes only Nudo_etal_1995_TABLE4_snapshot.xlsx (siblings: the other TABLE<n>_snapshot.R).
#
# The transcribed values, the printed header tiers, the printed row order, the
# printed footnotes and the cosmetic layout (bold header rows, wrapped header
# cells, column widths) are all carried over unchanged. Verified cell-by-cell
# against the committed snapshots: every cell value identical.
#
# ---------------------------------------------------------------------------
# Original header, carried over verbatim from the Python script:
#
# Build the Nudo et al. 1995 snapshots (TABLE 1 - TABLE 5).
#
# Source: Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). Variation and
# evolution of mammalian corticospinal somata with special reference to primates.
# J Comp Neurol 358(2):181-205.  DOI 10.1002/cne.903580203.
# PDF in this folder: "Nudo-1995-Variation and evolution of mammalian.pdf".
#
# Printed / scanned source -> a snapshot is REQUIRED (__HOWTO_build_a_dataset_file.md
# invariant 1). The PDF carries an OCR text layer, and that text layer is NOT reliable
# (it renders "Rattus norvegicus" as "Raltus noruegicus", "Macaca" as "Maraca",
# "cells/mm2" as "cells/mm'", "0.3" as "03", "94.0" as "94.1)"). Every cell below was
# therefore read off 300-dpi renders of the printed pages, not off the text layer:
#
#     TABLE 1  p. 183 (PDF p. 3), left column
#     TABLE 2  p. 185 (PDF p. 5), full width
#     TABLE 3  p. 187 (PDF p. 7), right column, above Table 4
#     TABLE 4  p. 187 (PDF p. 7), right column
#     TABLE 5  p. 188 (PDF p. 8), full width
#
# Faithful capture per __HOWTO_make_a_snapshot.md: printed caption, printed header
# tiers, printed row order, printed footnotes, printed thousands separators, printed
# missing-value token "n/a", printed zeros, and printed typos - all verbatim. Nothing
# is corrected here; corrections happen in the .R with a comment (golden rule).
#
# Print typos deliberately carried verbatim (see the READMEs):
#   * TABLE 2, Cat row      -> order printed "Camivora"  (all other tables: "Carnivora")
#   * TABLE 2/4/5, Rabbit   -> order printed "Lagamorpha" (TABLE 3 prints "Lagomorpha")
#   * TABLE 2, Hedgehog/H.a -> ipsilateral total printed in SQUARE brackets "615 [1,415]"
#                              although footnote 2 says "parentheses"
#   * TABLE 5, header       -> "Thickness (um)" but the values are millimetres (the text,
#                              p. 187, calls the same numbers "slow loris (0.71 mm)")
#
# Documented deviations (the only two):
#   1. The printed headers are 2-4 stacked physical lines. They are flattened into two
#      header rows (tier 1 = label, tier 2 = unit / sub-label) so the sheet is machine
#      readable. No printed word is dropped.
#   2. TABLE 1 common names wrap across up to three printed lines
#      ("Nine-banded / armadillo", "Common mar- / moset"). They are joined with a single
#      space, and a line-break hyphen ("mar-") is closed up. The scientific names, which
#      never wrap, are verbatim - including the printed genus abbreviations
#      "E. europaeus" and "M. mulatta".
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
paper_dir <- dirname(.sp)

suppressPackageStartupMessages(library(openxlsx))

## Each block below is the printed sheet exactly as it is written out: one line
## per worksheet row, cells separated by "|", an empty field where the page (or
## the printed header tier) is blank. No value is parsed, converted or cleaned
## here - that happens downstream in the per-table .R.
write_sheet <- function(txt, sheet, filename, dims, bold_rows, wrap_rows, widths) {
  g <- do.call(rbind, lapply(strsplit(strsplit(txt, "\n", fixed = TRUE)[[1]], "|", fixed = TRUE),
                             function(x) { length(x) <- dims[2]; x }))
  g[!is.na(g) & g == ""] <- NA_character_
  stopifnot(nrow(g) == dims[1], ncol(g) == dims[2])
  wb <- createWorkbook()
  addWorksheet(wb, sheet)
  writeData(wb, sheet, as.data.frame(g, stringsAsFactors = FALSE),
            colNames = FALSE, keepNA = FALSE)
  if (length(bold_rows))
    addStyle(wb, sheet, createStyle(textDecoration = "bold"),
             rows = bold_rows, cols = seq_len(dims[2]), gridExpand = TRUE)
  if (length(wrap_rows))
    addStyle(wb, sheet, createStyle(textDecoration = "bold", wrapText = TRUE),
             rows = wrap_rows, cols = seq_len(dims[2]), gridExpand = TRUE)
  ## openxlsx adds 0.71 padding to a stored width; subtract it so the file matches
  ## the widths the openpyxl version wrote.
  if (length(widths)) setColWidths(wb, sheet, cols = seq_along(widths), widths = widths - 0.71)
  saveWorkbook(wb, file.path(paper_dir, filename), overwrite = TRUE)
  message(sprintf("%s [%s]: %d rows x %d cols", filename, sheet, dims[1], dims[2]))
}


## ---- TABLE4 ------------------------------------------------------
txt_TABLE4 <- "TABLE 4. Maximum Surface Density of Corticospinal Somata (cells/mm²)||||
|Region|||
Animal/G.s./Order|A|B|C|C'
Albino rat/R.n./Rodentia|2,250|592|0|1,606
Armadillo/D.n./Edentata|736|201|0|0
Bushbaby/G.s./Primates|4,030|1,323|1,504|0
Cat/F.c./Carnivora|1,677|189|0|0
Gray squirrel/S.c./Rodentia|1,664|574|0|976
Ground squirrel/C.t./Rodentia|3,310|602|0|1,143
Hedgehog/E.a./Insectivora|848|326|0|0
Hedgehog/E.e./Insectivora|771|356|0|0
Hedgehog/H.a./Insectivora|676|184|0|0
Hyrax/P.c./Hyracoidea|1,148|446|0|0
Least shrew/C.p./Insectivora|706|107|0|0
Marmoset/C.j./Primates|1,305|435|638|0
Mole/S.a./Insectivora|3,472|1,335|0|0
Monkey/C.a./Primates|900|228|464|0
Monkey/M.f./Primates|300|128|128|0
Monkey/M.m./Primates|408|99|161|0
Monkey/S.s./Primates|760|253|535|0
Opossum/D.v./Marsupialia|857|429|0|0
Opossum/M.d./Marsupialia|655|393|0|0
Rabbit/O.c./Lagamorpha|540|256|0|170
Raccoon/P.l./Carnivora|786|171|0|0
Slow loris/N.c./Primates|875|282|226|0
Tree shrew/T.g./Scandentia|1,790|429|0|0
Vole/P.p./Rodentia|2,339|759|0|1,075"
write_sheet(txt_TABLE4, "TABLE4", "Nudo_etal_1995_TABLE4_snapshot.xlsx", c(27L, 5L),
            bold_rows = c(1), wrap_rows = c(2, 3), widths = c(34.0, 15.0, 15.0, 15.0, 15.0))

# Nudo_etal_1995_TABLE3_snapshot.R ----------------------------------------------------
# R port of the former Nudo_etal_1995_extract_snapshot.py/.R (openpyxl -> openxlsx), now one script per item:
# this script writes only Nudo_etal_1995_TABLE3_snapshot.xlsx (siblings: the other TABLE<n>_snapshot.R).
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


## ---- TABLE3 ------------------------------------------------------
txt_TABLE3 <- "TABLE 3. Number of Corticospinal Somata by Taxonomic Order||||||||
|#|Mean|Mean|Mean|Mean|Mean|Mean|Mean
Order|Species|# CSN¹|#A|#B|#C|#C'|%A|%B
Carnivora|2|68,736|65,897|2,407|0|0|94.0|4.8
Edentata|1|10,454|10,088|366|0|0|96.5|3.5
Hyracoidea|1|20,638|19,008|1,548|0|0|92.1|7.5
Insectivora|5|4,195|3,246|949|0|0|80.1|19.9
Lagomorpha|1|5,526|4,227|663|0|636|76.5|12.0
Marsupialia|2|4,556|4,302|236|0|0|88.2|11.7
Primates|7|43,575|40,738|1,892|888|0|92.7|5.0
Rodentia|4|15,391|12,962|917|0|1,490|82.0|6.3
Scandentia|1|6,950|6,672|278|0|0|96.0|4.0
¹Numbers of CS somata are stereologically corrected values.||||||||"
write_sheet(txt_TABLE3, "TABLE3", "Nudo_etal_1995_TABLE3_snapshot.xlsx", c(13L, 9L),
            bold_rows = c(1), wrap_rows = c(2, 3), widths = c(34.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0))

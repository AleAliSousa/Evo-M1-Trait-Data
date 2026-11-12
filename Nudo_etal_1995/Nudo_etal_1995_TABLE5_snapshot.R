# Nudo_etal_1995_TABLE5_snapshot.R ----------------------------------------------------
# R port of the former Nudo_etal_1995_extract_snapshot.py/.R (openpyxl -> openxlsx), now one script per item:
# this script writes only Nudo_etal_1995_TABLE5_snapshot.xlsx (siblings: the other TABLE<n>_snapshot.R).
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


## ---- TABLE5 ------------------------------------------------------
txt_TABLE5 <- "TABLE 5. Nine Other Morphological Characteristics of Corticospinal Somata|||||||||
|Avg surface density|Thickness|Maximum volume density|Column height|Concentration|Concentration (large cells; %)|Rostral/caudal|Condensation|% Medial-lateral distribution
Animal/G.s./Order|(cells/mm²)|(µm)|(cells/mm³)|(cells)|(%)||||
Albino rat/R.n./Rodentia|639|0.38|6,475|5.02|26.7|78.7|0.89|93.0|29
Armadillo/D.n./Edentata|140|0.18|4,089|2.51|35.8|n/a|0.80|84.7|29
Bushbaby/G.s./Primates|830|0.38|11,918|7.61|34.4|91.6|3.23|96.9|27
Cat/F.c./Carnivora|173|0.17|11,526|2.37|36.7|69.0|6.67|99.4|65
Gray squirrel/S.c./Rodentia|414|0.36|5,283|3.28|28.3|73.5|2.86|95.0|30
Ground squirrel/C.t./Rodentia|800|0.38|9,751|6.76|36.8|89.8|1.10|93.7|33
Hedgehog/E.a./Insectivora|257|0.17|5,432|2.66|18.8|42.9|0.85|94.1|56
Hedgehog/E.e./Insectivora|195|0.35|2,640|5.02|28.4|55.2|0.93|92.7|32
Hedgehog/H.a./Insectivora|138|0.19|3,965|2.57|15.7|61.0|1.22|96.8|38
Hyrax/P.c./Hyracoidea|258|0.35|3,280|4.00|n/a|n/a|1.39|84.5|64
Least shrew/C.p./Insectivora|245|0.15|5,116|2.68|10.7|n/a|1.00|93.1|50
Marmoset/C.j./Primates|355|0.35|4,248|4.13|21.8|80.5|1.82|98.5|33
Mole/S.a./Insectivora|802|0.21|17,848|7.21|34.1|52.6|1.41|92.2|35
Monkey/C.a./Primates|106|0.37|2,849|2.36|19.6|63.3|5.26|99.0|78
Monkey/M.f./Primates|76|0.26|1,372|2.29|9.1|79.5|10.00|98.9|54
Monkey/M.m./Primates|108|0.41|1,196|2.23|13.2|86.1|1.64|94.3|78
Monkey/S.s./Primates|178|0.38|2,302|2.43|13.9|69.7|2.70|94.6|68
Opossum/D.v./Marsupialia|298|0.20|4,781|2.56|23.1|65.2|1.16|83.7|55
Opossum/M.d./Marsupialia|168|0.10|7,125|2.67|15.9|43.4|1.25|78.7|54
Rabbit/O.c./Lagamorpha|116|0.46|1,348|2.45|20.8|71.4|2.13|94.8|39
Raccoon/P.l./Carnivora|103|0.38|2,368|3.27|27.9|87.5|3.23|98.1|61
Slow loris/N.c./Primates|263|0.71|1,417|4.06|12.6|79.1|3.45|94.0|56
Tree shrew/T.g./Scandentia|474|0.31|6,555|4.97|28.7|76.9|2.86|90.9|64
Vole/P.p./Rodentia|685|0.33|7,821|6.10|26.3|81.8|1.18|91.0|40"
write_sheet(txt_TABLE5, "TABLE5", "Nudo_etal_1995_TABLE5_snapshot.xlsx", c(27L, 10L),
            bold_rows = c(1), wrap_rows = c(2, 3), widths = c(34.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0))

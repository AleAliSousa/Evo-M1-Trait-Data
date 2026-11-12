# Nudo_etal_1995_TABLE2_snapshot.R ----------------------------------------------------
# R port of the former Nudo_etal_1995_extract_snapshot.py/.R (openpyxl -> openxlsx), now one script per item:
# this script writes only Nudo_etal_1995_TABLE2_snapshot.xlsx (siblings: the other TABLE<n>_snapshot.R).
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


## ---- TABLE2 ------------------------------------------------------
txt_TABLE2 <- "TABLE 2. Number and Percentage of Corticospinal Somata in Each Region||||||||||||||
|Maximum|Soma|Correction|Corrected|Region|||||||||
Animal/G.s.¹/Order|profile #²|diameter (µm)|term|#CSN|#A|%A|#B|%B|#C|%C|#C'|%C'|# Other|% Other
Albino rat/R.n./Rodentia|21,825|19.52|0.837|18,268|15,363|84.1|749|4.1|0|0.0|2,119|11.6|37|0.2
Armadillo/D.n./Edentata|12,505|19.57|0.836|10,454|10,088|96.5|366|3.5|0|0.0|0|0.0|0|0.0
Bushbaby/G.s./Primates|45,335|18.33|0.845|38,308|34,516|90.1|3,294|8.6|421|1.1|0|0.0|77|0.2
Cat/F.c./Camivora|41,820|26.61|0.790|33,038|29,866|90.4|2,412|7.3|0|0.0|0|0.0|760|2.3
Gray squirrel/S.c./Rodentia|19,695|21.89|0.820|16,150|13,308|82.4|1,308|8.1|0|0.0|1,486|9.2|48|0.3
Ground squirrel/C.t./Rodentia|24,775|18.30|0.845|20,935|18,695|89.3|1,151|5.5|0|0.0|1,089|5.2|0|0.0
Hedgehog/E.a./Insectivora|765 (2,135)|12.57|0.888|1,896|1,644|86.7|252|13.3|0|0.0|0|0.0|0|0.0
Hedgehog/E.e./Insectivora|4,255 (5,545)|19.42|0.837|4,641|3,550|76.5|1,091|23.5|0|0.0|0|0.0|0|0.0
Hedgehog/H.a./Insectivora|615 [1,415]|16.76|0.856|1,211|957|79.0|254|21.0|0|0.0|0|0.0|0|0.0
Hyrax/P.c./Hyracoidea|5,990 (25,895)|25.42|0.797|20,638|19,008|92.1|1,548|7.5|0|0.0|0|0.0|82|0.4
Least shrew/C.p./Insectivora|474|12.08|0.892|423|348|82.3|75|17.7|0|0.0|0|0.0|0|0.0
Marmoset/C.j./Primates|31,540|21.06|0.826|26,052|23,890|91.7|1,693|6.5|469|1.8|0|0.0|0|0.0
Mole/S.a./Insectivora|5,900 (14,210)|11.01|0.901|12,803|9,730|76.0|3,073|24.0|0|0.0|0|0.0|0|0.0
Monkey/C.a./Primates|75,310|27.14|0.787|59,269|55,179|93.1|2,252|3.8|1,600|2.7|0|0.0|237|0.4
Monkey/M.f./Primates|46,260|31.01|0.763|35,296|32,331|91.6|1,588|4.5|1,377|3.9|0|0.0|0|0.0
Monkey/M.m./Primates|113,230|34.50|0.743|84,130|82,447|98.0|1,094|1.3|589|0.7|0|0.0|0|0.0
Monkey/S.s./Primates|50,080|23.40|0.810|40,565|36,792|90.7|2,272|5.6|1,420|3.5|0|0.0|81|0.2
Opossum/D.v./Marsupialia|10,095|17.03|0.854|8,621|8,207|95.2|379|4.4|0|0.0|0|0.0|35|0.4
Opossum/M.d./Marsupialia|550|12.31|0.890|490|397|81.1|93|18.9|0|0.0|0|0.0|0|0.0
Rabbit/O.c./Lagamorpha|6,780|22.70|0.815|5,526|4,227|76.5|663|12.0|0|0.0|636|11.5|0|0.0
Raccoon/P.l./Carnivora|127,670|22.22|0.818|104,434|101,928|97.6|2,402|2.3|0|0.0|0|0.0|104|0.1
Slow loris/N.c./Primates|26,360|23.14|0.812|21,404|20,013|93.5|1,049|4.9|342|1.6|0|0.0|0|0.0
Tree shrew/T.g./Scandentia|8,394|20.80|0.828|6,950|6,672|96.0|278|4.0|0|0.0|0|0.0|0|0.0
Vole/P.p./Rodentia|7,120|14.74|0.872|6,209|4,483|72.2|459|7.4|0|0.0|1,267|20.4|0|0.0
¹G.s., Genus specie; see Table 1.||||||||||||||
²Numbers in parentheses represent the total number of CS somata in ipsilateral hemisphere in species in which the ipsilateral total exceeded the contralateral total. Numbers to the left represent the total number of CS somata in the contralateral hemisphere.||||||||||||||"
write_sheet(txt_TABLE2, "TABLE2", "Nudo_etal_1995_TABLE2_snapshot.xlsx", c(29L, 15L),
            bold_rows = c(1), wrap_rows = c(2, 3), widths = c(34.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0))

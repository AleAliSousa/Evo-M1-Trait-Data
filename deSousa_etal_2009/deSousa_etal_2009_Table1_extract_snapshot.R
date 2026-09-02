# deSousa_etal_2009_Table1_extract_snapshot.R ----------------------------------------------------
# R port of deSousa_etal_2009_Table1_extract_snapshot.py (openpyxl -> openxlsx).
#
# The transcribed values, the printed header tiers, the printed row order, the
# printed footnotes and the cosmetic layout (bold header rows, wrapped header
# cells, column widths) are all carried over unchanged. Verified cell-by-cell
# against the committed snapshot: every cell value identical.
#
# ---------------------------------------------------------------------------
# Original header, carried over verbatim from the Python script:
#
# Build the de Sousa et al. 2009 Table 1 snapshot (Cereb Cortex 20(4):966-981, Advance Access p. 2).
#
# Faithful capture per __HOWTO_make_a_snapshot.md: the printed caption, the three-tier
# column header, footnote markers kept attached to the strings that carry them
# (``Homo sapiensa,b``, ``EQe``, ``area (mm2)f``), printed blanks left blank, printed
# row order and original units (kg / g / cm3 / mm3 / mm2) unchanged. Values are stored
# as the printed *strings* so trailing zeros ("1.20", "16.0") and the literal "NA"
# survive verbatim; the reformat (deSousa_etal_2009_Table1.R) does the typing.
#
# Nothing is corrected here. Two things that look wrong are carried as printed and
# flagged in the README instead:
#   * ``ppz`` (Zahlia) neocortex 279 cm3 is the value de Sousa et al. 2010 Table 1
#     prints for a *different* bonobo (YN86-137); Zahlia's own is 214.4.
#   * brain mass is rounded relative to 2010 Table 1 (58 vs 57.6; 360 vs 359.5).
#
# Run:  python3 deSousa_etal_2009_Table1_extract_snapshot.py [--verify]
# --verify re-reads the PDF with pdfplumber and asserts every transcribed token is
# actually on the page in the expected row (it is the transcription audit; it needs
# pdfplumber and the PDF, and is skipped silently if either is missing).
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


## ---- Table1 ------------------------------------------------------
txt_Table1 <- "Table 1||||||||||||
Samples used in analyses of V1, V2, and VP||||||||||||
Species|code|archive|sex|age (yrs)|body mass|brain mass|EQe|neocortex|left V1 vol|left LGN|optic nerve|eye half surface
||number|||(kg)|(g)||volume|(mm3)|vol (mm3)|cross sectional|area (mm2)f
||||||||(cm3)|||area (mm2)f|
Gorilla gorilla|ggy|YN82-140|F|20|85|376|1.20|254|4044|150|17.6|1774
Hylobates lar|hld|Disco|F|22|7|120|2.54|77|2292|90|12.7|1299
Homo sapiensa,b|hs5|54491|F|79|63|1350|5.41|974|7587|186|22.8|1855
Homo sapiensa,b|hs6|6895|F|79|63|1110|4.45|974|7013|156|22.8|1855
Macaca fascicularis|mf2|ma22|M|3|3|58|2.31||1357|46|8.4|985
Pongo pygmaeus|ouy|YN85-38|M|16.5|58|369|1.56|269|3504|92|16.1|1282
Pan paniscusc|ppz|Zahlia|F|11|33|324|2.09|279|5687|130||
Pan troglodytes|ptb|Bathsheba|F|24|80|360|1.20|263|4705|168|16.0|1446
Pan troglodytesd|ptd|1548|NA|NA|51|387|1.82|198|2799|86|16.0|1446
||||||||||||
a Used same sex species mean value for body weight (Zilles 1972).||||||||||||
b Used combined sex mean human neocortex value (n = 8) based on unpublished data provided by Carol MacLeod.||||||||||||
c Used same sex species mean value for body weight (Jungers and Susman 1984).||||||||||||
d Used combined sex species mean values for brain and body weight (Herndon et al. 1999.).||||||||||||
e Encephalization quotient (EQ) after Martin (1981) and Ruff et al. (1997).||||||||||||
f Species mean data from Stephan and Frahm 1981.||||||||||||"
write_sheet(txt_Table1, "Table1", "deSousa_etal_2009_Table1_snapshot.xlsx", c(21L, 13L),
            bold_rows = c(1), wrap_rows = c(3, 4, 5), widths = c(22.0, 10.0, 10.0, 10.0, 10.0, 13.0, 13.0, 13.0, 13.0, 13.0, 13.0, 13.0, 13.0))

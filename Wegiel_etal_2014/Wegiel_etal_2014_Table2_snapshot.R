# Wegiel_etal_2014_Table2_snapshot.R ----------------------------------
#
# Wegiel J, Flory M, Kuchna I, et al. (2014) Acta Neuropathol Commun 2:141.
# doi:10.1186/s40478-014-0141-7
# Table 2 "Mean volume (±SE) of 14 brain structures and 24 cytoarchitectonic
# subdivisions in one brain hemisphere of autistic and control subjects*" (p. 9).
#
# FROZEN-SOURCE HELPER (not the item build). Pulls the printed table from the
# PDF text layer (pdftools::pdf_text, born-digital BMC PDF, layout preserved)
# and writes <item_name>_snapshot.xlsx in the PRINTED layout: caption, the two
# spanning headers with blank padding, sub-headers, 38 body rows in printed
# order, and the two footnote lines. No table value is typed in this script:
# only the printed header literals are anchored (and checked against the page
# text). Cells are stored as text exactly as printed ("3,030 ± 116", "ns").
# Superscript "mm3" in the text layer is written "mm³" as printed.
# Refuses to overwrite a frozen copy that differs.

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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # Wegiel_etal_2014_Table2
base <- item_name

suppressPackageStartupMessages({ library(pdftools); library(openxlsx); library(readxl) })

pdf_file <- "Wegiel-2014-Stereological study of the neurona.pdf"
page_no  <- 9L
lines <- strsplit(pdf_text(pdf_file)[page_no], "\n", fixed = TRUE)[[1]]

## ---- locate the printed blocks (anchored on printed literals) ----------------
i_cap  <- grep("^Table 2 Mean volume", lines)
i_head <- grep("^Brain structure or cytoarchitectonic", lines)
i_sub  <- grep("^\\s+Autism\\s+Control\\s+p<\\s+Autism\\s+Control\\s*$", lines)
i_foot <- grep("^\\*Statistical significance controlled", lines)
stopifnot(length(i_cap) == 1L, length(i_head) == 1L, length(i_sub) == 1L, length(i_foot) == 1L)
stopifnot(grepl("Volume \\(mm3\\) \\(Absolute volume calculated using", lines[i_head]),
          grepl("Volume \\(mm3\\) corrected", lines[i_head]),
          grepl("mounted section thickness\\)", lines[i_head + 1L]),
          grepl("for shrinkage", lines[i_head + 1L]))

caption <- paste(trimws(lines[i_cap]), trimws(lines[i_cap + 1L]))
body    <- lines[(i_sub + 1L):(i_foot - 1L)]
body    <- body[nzchar(trimws(body))]
foot    <- trimws(lines[i_foot:(i_foot + 1L)])

## ---- split each printed row into its 6 printed cells -------------------------
## Columns are separated by runs of >= 2 spaces in the layout text; a cell such
## as "3,030 ± 116" contains only single spaces. Leading indentation of the
## printed "- " subdivision rows is presentation and is dropped; the "- " kept.
cells <- lapply(sub("^\\s+", "", body), function(x) strsplit(x, "\\s{2,}")[[1]])
n_cells <- vapply(cells, length, integer(1))
if (any(n_cells != 6L)) stop("Row(s) not split into 6 cells: ", paste(body[n_cells != 6L], collapse = " | "))
dat <- do.call(rbind, cells)
stopifnot(nrow(dat) == 38L)                     # caption: 14 structures + 24 subdivisions
stopifnot(sum(!grepl("^- ", dat[, 1])) == 14L, sum(grepl("^- ", dat[, 1])) == 24L)

sup3 <- function(x) gsub("mm3", "mm\u00b3", x, fixed = TRUE)

## ---- assemble the printed layout --------------------------------------------
snap <- rbind(
  c(sup3(caption), rep(NA, 5)),
  c("Brain structure or cytoarchitectonic subdivision",
    "Volume (mm\u00b3) (Absolute volume calculated using mounted section thickness)", NA, NA,
    "Volume (mm\u00b3) corrected for shrinkage", NA),
  c(NA, "Autism", "Control", "p <", "Autism", "Control"),
  dat,
  cbind(sup3(foot), matrix(NA, 2, 5))
)
dimnames(snap) <- NULL

## ---- freeze (refuse to overwrite a differing frozen copy) --------------------
out <- paste0(base, "_snapshot.xlsx")
if (file.exists(out)) {
  old <- as.matrix(read_excel(out, sheet = "Table2", col_names = FALSE,
                              col_types = "text", .name_repair = "minimal"))
  dimnames(old) <- NULL
  if (identical(dim(old), dim(snap)) && identical(old, snap)) {
    message(out, " unchanged (frozen copy identical to the PDF extraction).")
  } else {
    stop(out, " exists and DIFFERS from the PDF extraction; not overwritten. ",
         "Inspect and delete it by hand only if the frozen copy is wrong.")
  }
} else {
  wb <- createWorkbook()
  addWorksheet(wb, "Table2")
  writeData(wb, "Table2", as.data.frame(snap, stringsAsFactors = FALSE), colNames = FALSE)
  mergeCells(wb, "Table2", cols = 2:4, rows = 2)
  mergeCells(wb, "Table2", cols = 5:6, rows = 2)
  setColWidths(wb, "Table2", cols = 1:6, widths = c(46, 22, 22, 8, 14, 14))
  saveWorkbook(wb, out, overwrite = FALSE)
  message("Frozen ", out, ": ", nrow(snap), " rows x ", ncol(snap), " cols (",
          nrow(dat), " printed body rows).")
}

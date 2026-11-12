# Wegiel_etal_2014_Table3_snapshot.R ----------------------------------
#
# Wegiel J, Flory M, Kuchna I, et al. (2014) Acta Neuropathol Commun 2:141.
# doi:10.1186/s40478-014-0141-7
# Table 3 "Total number of neurons per region and neuronal numerical density in
# 15 structures and 16 cytoarchitectonic subdivisions in examined brain
# hemisphere of individuals with autism and control subjects*" (p. 10).
#
# FROZEN-SOURCE HELPER (not the item build). Pulls the printed table from the
# PDF text layer (pdftools::pdf_text, born-digital BMC PDF, layout preserved)
# and writes <item_name>_snapshot.xlsx in the PRINTED layout: caption, the two
# spanning headers with blank padding, sub-headers, 31 body rows in printed
# order, and the two footnotes (* and †). No table value is typed in this
# script: only the printed header literals are anchored (and checked against
# the page text). Cells are stored as text exactly as printed ("61,675,039",
# "ns† (0.013)"). Superscript "mm3" in the text layer is written "mm³".
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # Wegiel_etal_2014_Table3
base <- item_name

suppressPackageStartupMessages({ library(pdftools); library(openxlsx); library(readxl) })

pdf_file <- "Wegiel-2014-Stereological study of the neurona.pdf"
page_no  <- 10L
lines <- strsplit(pdf_text(pdf_file)[page_no], "\n", fixed = TRUE)[[1]]

## ---- locate the printed blocks (anchored on printed literals) ----------------
i_cap  <- grep("^Table 3 Total number of neurons", lines)
i_head <- grep("^Structure/cytoarchitectonic", lines)
i_sub  <- grep("^\\s+Autism\\s+Control\\s+p<\\s+Autism\\s+Control\\s+p<\\s*$", lines)
i_foot <- grep("^\\*Controlled for log age", lines)
i_dag  <- grep("^\u2020\\s*$", lines)                 # the dagger is its own text line
stopifnot(length(i_cap) == 1L, length(i_head) == 1L, length(i_sub) == 1L,
          length(i_foot) == 1L, length(i_dag) == 1L, i_dag == i_foot + 1L)
stopifnot(grepl("Total number of neurons per region", lines[i_head]),
          grepl("Neuronal numerical density \\(N/mm3\\)", lines[i_head]))

caption <- paste(trimws(lines[i_cap]), trimws(lines[i_cap + 1L]))
body    <- lines[(i_sub + 1L):(i_foot - 1L)]
body    <- body[nzchar(trimws(body))]
foot    <- c(trimws(lines[i_foot]),
             paste0("\u2020", paste(trimws(lines[(i_dag + 1L):(i_dag + 2L)]), collapse = " ")))
stopifnot(grepl("^\u2020The total number of neuronal deficit", foot[2]),
          grepl("were entered as covariates\\.$", foot[2]))

## ---- split each printed row into its 7 printed cells -------------------------
cells <- lapply(sub("^\\s+", "", body), function(x) strsplit(x, "\\s{2,}")[[1]])
n_cells <- vapply(cells, length, integer(1))
if (any(n_cells != 7L)) stop("Row(s) not split into 7 cells: ", paste(body[n_cells != 7L], collapse = " | "))
dat <- do.call(rbind, cells)
stopifnot(nrow(dat) == 31L)                     # caption: 15 structures + 16 subdivisions
stopifnot(sum(!grepl("^- ", dat[, 1])) == 15L, sum(grepl("^- ", dat[, 1])) == 16L)

sup3 <- function(x) gsub("mm3", "mm\u00b3", x, fixed = TRUE)

## ---- assemble the printed layout --------------------------------------------
snap <- rbind(
  c(sup3(caption), rep(NA, 6)),
  c("Structure/cytoarchitectonic subdivision", "Total number of neurons per region", NA, NA,
    "Neuronal numerical density (N/mm\u00b3)", NA, NA),
  c(NA, "Autism", "Control", "p <", "Autism", "Control", "p <"),
  dat,
  cbind(sup3(foot), matrix(NA, 2, 6))
)
dimnames(snap) <- NULL

## ---- freeze (refuse to overwrite a differing frozen copy) --------------------
out <- paste0(base, "_snapshot.xlsx")
if (file.exists(out)) {
  old <- as.matrix(read_excel(out, sheet = "Table3", col_names = FALSE,
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
  addWorksheet(wb, "Table3")
  writeData(wb, "Table3", as.data.frame(snap, stringsAsFactors = FALSE), colNames = FALSE)
  mergeCells(wb, "Table3", cols = 2:4, rows = 2)
  mergeCells(wb, "Table3", cols = 5:7, rows = 2)
  setColWidths(wb, "Table3", cols = 1:7, widths = c(36, 14, 14, 12, 12, 12, 8))
  saveWorkbook(wb, out, overwrite = FALSE)
  message("Frozen ", out, ": ", nrow(snap), " rows x ", ncol(snap), " cols (",
          nrow(dat), " printed body rows).")
}

# Seymour_etal_2017_TableS1_snapshot_extract.R
#
# Source -> snapshot step (R). Builds the frozen, journal-faithful snapshot
# Seymour_etal_2017_TableS1_snapshot.xlsx (sheet "TableS1") from the Word
# supplement rsos170846supp1.docx, BEFORE any cleaning. All later cleaning happens
# in Seymour_etal_2017_TableS1.R, reproducibly from this snapshot.
#
# The table cells and the surrounding caption / footnote / reference paragraphs are
# copied verbatim (footnote superscripts such as body mass "70.0a" and age "0.05A"
# are kept), so the snapshot can be eyeballed against the printed supplement.
#
# Packages: officer (read the .docx: paragraphs + table cells in document order) and
# openxlsx (write the snapshot with no imposed header row). Both are pure-R CRAN
# packages -- no Python, no LibreOffice.

suppressPackageStartupMessages({
  library(officer); library(openxlsx); library(dplyr); library(tidyr); library(stringr)
})

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source.", call. = FALSE)
})
setwd(dirname(.sp))

docx_file     <- "rsos170846supp1.docx"
snapshot_file <- "Seymour_etal_2017_TableS1_snapshot.xlsx"
snapshot_sheet <- "TableS1"

sm <- docx_summary(read_docx(docx_file))

## --- the table: one row per row_id, columns ordered by cell_id ---
tbl <- sm %>%
  filter(content_type == "table cell") %>%
  transmute(row_id, cell_id, text = str_squish(replace_na(text, ""))) %>%
  arrange(row_id, cell_id) %>%
  pivot_wider(names_from = cell_id, values_from = text) %>%
  arrange(row_id) %>%
  select(-row_id)
tbl_mat <- as.matrix(tbl)                      # 31 x 11 (header + 30 specimens)
ncol_tab <- ncol(tbl_mat)

## --- caption + footnote/reference paragraphs, in document order ---
paras <- sm %>%
  filter(content_type == "paragraph") %>%
  transmute(text = str_squish(replace_na(text, ""))) %>%
  filter(text != "") %>%
  pull(text)
caption <- paras[str_starts(paras, "Table S1")][1]
notes   <- paras[!str_starts(paras, "Table S1")]

## --- assemble a ragged character matrix and write it with no header row ---
pad <- function(v, n) { length(v) <- n; v[is.na(v)] <- ""; v }
rows <- c(
  list(pad(caption, ncol_tab)),                          # row 1: caption
  lapply(seq_len(nrow(tbl_mat)), function(i) pad(unname(tbl_mat[i, ]), ncol_tab)),  # header + 30 data
  list(pad("", ncol_tab)),                               # blank separator
  lapply(notes, function(t) pad(t, ncol_tab))            # footnotes + reference list
)
mat <- do.call(rbind, rows)

wb <- createWorkbook()
addWorksheet(wb, snapshot_sheet)
writeData(wb, snapshot_sheet, mat, colNames = FALSE)
saveWorkbook(wb, snapshot_file, overwrite = TRUE)
message("Wrote ", snapshot_file, " (", nrow(mat), " rows x ", ncol(mat), " cols)")

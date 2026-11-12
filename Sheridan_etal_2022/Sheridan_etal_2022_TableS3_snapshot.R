# Sheridan_etal_2022_TableS3_snapshot.R --------------------------------
#
# Builds the frozen snapshot of Sheridan, Mukerji, Wade, Humphreys, Garrisi,
# Goel, Patel, Fox, Zeanah, Nelson & McLaughlin (2022) Sci Adv 8(40): eabn4316,
# Supplementary Materials Table S3 (SM PDF page 10, file sciadv.abn4316_sm.pdf).
#
# The SM is a PDF made from a word-processor manuscript: a picture of the
# table, not the data. The printed layout is written out verbatim below
# (HOWTO method 5 / Mink_etal_1981 pattern) and frozen to CSV (the layout is
# flat: one header row, a structure column, a hemisphere column, three group
# columns); Sheridan_etal_2022_TableS3.R READS that frozen file.
#
# Layout conventions (all reversible from the frozen file):
#  * one CSV row per printed row, in printed order: the "Table S3." heading
#    printed above the table, the column-header row, 14 data rows, then the
#    caption that the SM prints BELOW the table;
#  * the structure label is printed once per structure, on the "Right" row;
#    the "Left" row's structure cell is blank, as printed;
#  * "Total grey matter volume (cubic centimeters)" is printed on two lines in
#    a single cell; joined here with one space;
#  * cells kept exactly as printed, including the missing space in
#    "469.3(48.6)" and the leading-zero-less dispersions "(.2)";
#  * NOT transcribed: the manuscript line numbers "5", "10", "15" printed in the
#    right margin beside the NIG column (rows Total grey matter, Hippocampus
#    Left, Putamen Right/Left). They are separate text objects in the PDF text
#    layer, part of the manuscript's continuous line numbering, not table
#    content (README).
#
# Transcribed by an AI assistant (Claude) on 2026-11-11 from 300- and 500-dpi
# renders of SM PDF page 10, read row by row across the printed table.
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))

NCOL <- 5L; N_ROWS <- 17L; PDF_PAGE <- 10L; DATA_ROWS <- 3:16

printed <- "
Table S3.||||
||CAUG (n = 40)|FCG (n= 41)|NIG (n = 33)
Total grey matter volume (cubic centimeters)||469.3(48.6)|470.4 (43.6)|482.1 (51.5)
Total white matter volume||423.9 (49.1)|438.6 (48.7)|456.6 (56.6)
Amygdala|Right|1.5 (.2)|1.5 (.2)|1.5 (.2)
|Left|1.4 (.2)|1.5 (.2)|1.5 (.2)
Hippocampus|Right|4.0 (.4)|4.0 (.4)|4.1 (.4)
|Left|3.9 (.4)|4.0 (.4)|4.0 (.4)
Thalamus|Right|6.9 (.7)|7.0 (.8)|7.2 (.8)
|Left|7.4 (.7)|7.5 (.9)|7.9 (.8)
Caudate|Right|3.9 (.5)|3.9 (.6)|3.9 (.5)
|Left|3.7 (.4)|3.7 (.5)|3.7 (.5)
Putamen|Right|5.6 (.7)|5.7 (.5)|5.6 (.7)
|Left|5.6 (.8)|5.9 (.6)|5.8 (.9)
Globus Pallidus|Right|1.6 (.2)|1.6 (.2)|1.7 (.2)
|Left|1.7 (.3)|1.7 (.2)|1.7 (.3)
Table S3. Volume of total cortical grey and white matter as well as volume of six subcortical structures in cubic centimeters at the second (age 16 years) time point. Volume was measured using FreeSurfer analysis suite. Only differences between the EIG and NIG were significant for total grey and white matter volume.||||
"

grid <- do.call(rbind, lapply(
  strsplit(trimws(printed, which = "both"), "\n", fixed = TRUE)[[1]],
  function(line) { x <- strsplit(line, "|", fixed = TRUE)[[1]]; length(x) <- NCOL; x }))
grid[is.na(grid)] <- ""
stopifnot(ncol(grid) == NCOL, nrow(grid) == N_ROWS)

## ---- text-layer cross-check (no values are taken from it) ------------------
pdf_file <- file.path(folder, "sciadv.abn4316_sm.pdf")
stopifnot(file.exists(pdf_file))
if (requireNamespace("pdftools", quietly = TRUE)) {
  layer <- pdftools::pdf_text(pdf_file)[PDF_PAGE]
  rx <- "[0-9][0-9.]*|\\.[0-9]+"
  layer_tokens <- unique(unlist(regmatches(layer, gregexpr(rx, layer))))
  cells <- grid[DATA_ROWS, 3:5, drop = FALSE]
  typed <- unique(sub("\\.$", "", unlist(regmatches(cells, gregexpr(rx, cells)))))
  missing <- setdiff(typed, layer_tokens)
  if (length(missing))
    stop(item_name, ": numeric lexemes not found in the text layer of SM page ", PDF_PAGE, ": ",
         paste(missing, collapse = ", "), call. = FALSE)
  ## cell-level: each printed cell string (spaces normalised) occurs in the layer
  norm <- function(z) gsub("\\s+", " ", z)
  cell_missing <- cells[!vapply(cells, function(z) grepl(norm(z), norm(layer), fixed = TRUE), logical(1))]
  if (length(cell_missing))
    stop(item_name, ": printed cells not found verbatim in the text layer: ",
         paste(cell_missing, collapse = "; "), call. = FALSE)
  message(item_name, ": all ", length(cells), " value cells found verbatim in the text layer of SM page ", PDF_PAGE)
} else message(item_name, ": pdftools not installed; text-layer cross-check skipped")

snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(snapshot_file)) {
  old <- as.matrix(read.csv(snapshot_file, header = FALSE, colClasses = "character",
                            na.strings = character(0), encoding = "UTF-8", check.names = FALSE))
  dimnames(old) <- NULL
  if (!identical(dim(old), dim(grid)) || !identical(unname(old), unname(grid)))
    stop(item_name, ": the frozen snapshot on disk differs from the block in this script. ",
         "Refusing to overwrite. Reconcile against the PDF and move the superseded file to ",
         "archive/ before re-running.", call. = FALSE)
  message(item_name, ": frozen snapshot already on disk and identical; nothing written.")
} else {
  write.table(grid, snapshot_file, sep = ",", row.names = FALSE, col.names = FALSE,
              quote = TRUE, fileEncoding = "UTF-8")
  message(item_name, ": wrote ", basename(snapshot_file), " (", nrow(grid), " rows x ", NCOL, " cols)")
}

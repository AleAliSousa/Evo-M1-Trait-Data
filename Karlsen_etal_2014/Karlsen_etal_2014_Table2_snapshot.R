# Karlsen_etal_2014_Table2_snapshot.R: split from Karlsen_etal_2014_extract_snapshot.R (one script per output); writes only Karlsen_etal_2014_Table2_snapshot.*
## Karlsen_etal_2014_Table2_snapshot.R -- PDF text layer -> the two frozen snapshots
##
## Karlsen AS, Korbo S, Uylings HBM, Pakkenberg B (2014). A stereological study of the
## mediodorsal thalamic nucleus in Down syndrome. Neuroscience 279:253-259.
## doi:10.1016/j.neuroscience.2014.08.046
##
## Source -> snapshot step (snapshot HOWTO method 3, the Jacob_etal_2021 pattern):
## every DATA value is EXTRACTED from the born-digital PDF's text layer at run time.
## No value is typed in this script; only structural literals (captions, printed
## headers, footnote lines) live here, and each is anchored against the text layer.
##
## Writes (frozen; the build scripts READ these and never regenerate them):
##   Karlsen_etal_2014_Table1_snapshot.xlsx  (sheet "Table1", 18 rows x 8 cols)
##   Karlsen_etal_2014_Table2_snapshot.xlsx  (sheet "Table2", 10 rows x 9 cols)
##
## Frozen-file guard: if a snapshot exists and the extraction differs, the new
## capture is written to *_snapshot_NEW.xlsx and the run stops.
##
## Text-layer quirks repaired (each verified on the 300-dpi page images, PDF pp. 2, 4):
##   - unit superscripts are flattened ("(mm3)", "(106)"): restored as mm\u00b3 / 10\u2076;
##   - footnote marks print as superscript asterisks ("AMI**"): written "AMI^**";
##   - the Table 2 footnote formula (a square root over a sum of squared CEs) is
##     garbled in the text layer; its words are anchored and the formula is typed
##     as printed (a structural literal, not a value);
##   - ligatures (fi, fl, ffi) expanded.

## 0. PATHS --------------------------------------------------------------------
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
paper  <- "Karlsen_etal_2014"
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)
pdf_file <- "Karlsen-2014-A stereological study of the medi.pdf"
if (!file.exists(pdf_file)) stop("Source PDF not found: ", pdf_file, call. = FALSE)
for (p in c("pdftools", "openxlsx", "readxl"))
  if (!requireNamespace(p, quietly = TRUE)) stop("Install ", p, call. = FALSE)

## 1. TEXT LAYER ---------------------------------------------------------------
pages <- pdftools::pdf_text(pdf_file)
stopifnot(length(pages) == 7L)
unlig  <- function(x) { x <- gsub("\ufb01", "fi", x); x <- gsub("\ufb02", "fl", x); gsub("\ufb03", "ffi", x) }
pages  <- unlig(pages)
squish <- function(x) trimws(gsub("[[:space:]]+", " ", paste(x, collapse = " ")))
lines_of <- function(pg) strsplit(pages[pg], "\n", fixed = TRUE)[[1]]
anchor <- function(x, where) if (!any(grepl(x, where, fixed = TRUE)))
  stop("PDF anchor not found: ", x, call. = FALSE)
X <- "\u00d7"; SUP <- c("3" = "\u00b3", "6" = "\u2076")
times10 <- function(mant, ex) paste0(mant, " ", X, " 10", SUP[ex])

## frozen-file guard ------------------------------------------------------------
freeze_xlsx <- function(m, file, sheet) {
  m[is.na(m)] <- ""
  if (file.exists(file)) {
    old <- as.matrix(readxl::read_excel(file, sheet = sheet, col_names = FALSE,
                                        col_types = "text", .name_repair = "minimal"))
    old[is.na(old)] <- ""; dimnames(old) <- NULL
    new <- m; dimnames(new) <- NULL
    # readxl drops trailing all-blank rows/cols; compare on the stored extent
    same <- nrow(old) <= nrow(new) && ncol(old) <= ncol(new) &&
      identical(old, new[seq_len(nrow(old)), seq_len(ncol(old)), drop = FALSE]) &&
      all(new[-seq_len(nrow(old)), , drop = FALSE] == "")
    if (same) { message(basename(file), ": frozen copy matches the extraction (unchanged)"); return(invisible(FALSE)) }
    alt <- sub("\\.xlsx$", "_NEW.xlsx", file)
    wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet, as.data.frame(m, stringsAsFactors = FALSE), colNames = FALSE)
    openxlsx::saveWorkbook(wb, alt, overwrite = TRUE)
    stop(basename(file), " differs from the new extraction; wrote ", basename(alt),
         ". Compare by hand; the frozen copy was NOT changed.", call. = FALSE)
  }
  wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, sheet)
  openxlsx::writeData(wb, sheet, as.data.frame(m, stringsAsFactors = FALSE), colNames = FALSE)
  openxlsx::setColWidths(wb, sheet, cols = seq_len(ncol(m)), widths = "auto")
  openxlsx::saveWorkbook(wb, file, overwrite = FALSE)
  message(basename(file), ": frozen snapshot written (", nrow(m), " x ", ncol(m), ")")
  invisible(TRUE)
}
freeze_csv <- function(df, file) {
  tmp <- tempfile(fileext = ".csv")
  write.csv(df, tmp, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  if (file.exists(file)) {
    if (identical(readLines(file, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
      message(basename(file), ": frozen copy matches the extraction (unchanged)"); return(invisible(FALSE)) }
    alt <- sub("\\.csv$", "_NEW.csv", file); file.copy(tmp, alt, overwrite = TRUE)
    stop(basename(file), " differs from the new extraction; wrote ", basename(alt),
         ". Compare by hand; the frozen copy was NOT changed.", call. = FALSE)
  }
  file.copy(tmp, file); message(basename(file), ": frozen snapshot written (", nrow(df), " rows)")
  invisible(TRUE)
}

## 2. TABLE 2 (PDF page 4 = journal p. 256) -------------------------------------
L <- lines_of(4)
i0 <- grep("Table 2\\. Estimated quantities of the MDT nucleus \\(unilateral\\)", L)
i1 <- grep("^DS, Down syndrome; CE, coefficient of error", L)
stopifnot(length(i0) == 1L, length(i1) == 1L)
T2 <- L[i0:i1]
cap2 <- "Table 2. Estimated quantities of the MDT nucleus (unilateral)"
h1 <- c("Volume", "Neurons, total", "Neurons, large", "Neurons, small", "Glial cells, total",
        "Oligodendr.", "Astrocytes")
h2 <- c("(mm3)", rep("(106)", 6))
cells <- function(ln) strsplit(trimws(ln), "\\s{2,}")[[1]]
stopifnot(identical(cells(T2[grep("^\\s*Volume", T2)]), h1),
          identical(cells(T2[grep("^\\s*\\(mm3\\)", T2)]), h2))
h2p <- c("(mm\u00b3)", rep("(10\u2076)", 6))
NUM <- "([0-9]+(?:\\.[0-9]+)?)"
ROW2 <- paste0("^\\s*(Controls N = 6|DS N = 4)?\\s*(Mean|CE|CV)",
               paste(rep(paste0("\\s+", NUM), 7), collapse = ""), "\\s*$")
out2 <- list(c(cap2, rep("", 8)), c("", "", paste(h1, h2p, sep = "\n")))
n2 <- 0L
for (ln in T2) {
  m <- regmatches(ln, regexec(ROW2, ln, perl = TRUE))[[1]]
  if (!length(m)) next
  if (m[2] == "DS N = 4") out2[[length(out2) + 1]] <- rep("", 9)   # printed gap between groups
  out2[[length(out2) + 1]] <- c(m[2], m[3], m[4:10]); n2 <- n2 + 1L
}
stopifnot(n2 == 6L)
fn2 <- squish(T2[length(T2)])
stopifnot(grepl("DS, Down syndrome; CE, coefficient of error (mean CE =", fn2, fixed = TRUE),
          grepl("CV, coefficient of variation (CV = std. dev./mean).", fn2, fixed = TRUE))
fn2_printed <- paste0("DS, Down syndrome; CE, coefficient of error (mean CE = \u221a(CE\u2081\u00b2 + ",
                      "CE\u2082\u00b2 + . . . + CE\u2099\u00b2)/n); CV, coefficient of variation ",
                      "(CV = std. dev./mean).")
out2[[length(out2) + 1]] <- c(fn2_printed, rep("", 8))
snap2 <- do.call(rbind, out2)
stopifnot(nrow(snap2) == 10L, ncol(snap2) == 9L)
freeze_xlsx(snap2, paste0(item_name, "_snapshot.xlsx"), "Table2")

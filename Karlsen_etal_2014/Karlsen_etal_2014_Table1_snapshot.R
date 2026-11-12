# Karlsen_etal_2014_Table1_snapshot.R: split from Karlsen_etal_2014_extract_snapshot.R (one script per output); writes only Karlsen_etal_2014_Table1_snapshot.*
## Karlsen_etal_2014_Table1_snapshot.R -- PDF text layer -> the two frozen snapshots
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

cells <- function(ln) strsplit(trimws(ln), "\\s{2,}")[[1]]
## 3. TABLE 1 (PDF page 2 = journal p. 254) -------------------------------------
L <- lines_of(2)
j0 <- grep("Table 1\\. Clinical details of the individual subjects", L)
j1 <- grep("CHF, congestive heart failure; DS, Down syndrome; DK, Denmark; NED, The Netherlands\\.", L)
stopifnot(length(j0) == 1L, length(j1) == 1L)
T1 <- L[j0:j1]
hdr <- cells(T1[grep("^\\s*Age \\(years\\)", T1)])
stopifnot(identical(hdr, c("Age (years)", "Height (cm)", "Hemisphere (g)", "Country",
                           "Cause of death", "PMD (h)*")))
hdr[6] <- "PMD (h)^*"
anchor("PMD, post-mortem delay.", T1); anchor("AMI, acute myocardial infarction.", T1)
anchor("Braak score", T1)
ROW1 <- paste0("^\\s*(Controls|DS|Mean)?\\s+([0-9]+(?:\\.[0-9])?)\\s+(-|[0-9]+(?:\\.[0-9])?)\\s+",
               "([0-9]+(?:\\.[0-9])?)(?:\\s+(DK|NED)\\s+(.+?)\\s+([0-9]{2}:[0-9]{2})(?:\\s+([0-9]))?)?\\s*$")
mark <- function(x) sub("^(AMI|CHF)(\\*+)$", "\\1^\\2", x)
out1 <- list(c("Table 1. Clinical details of the individual subjects", rep("", 7)), c("", hdr, ""))
n1 <- 0L
for (ln in T1[-1]) {
  if (grepl("^\\s*Braak score\\s*$", ln)) { out1[[length(out1) + 1]] <- c(rep("", 7), "Braak score"); next }
  m <- regmatches(ln, regexec(ROW1, ln, perl = TRUE))[[1]]
  if (!length(m)) next
  m[is.na(m)] <- ""
  out1[[length(out1) + 1]] <- c(m[2], m[3], m[4], m[5], m[6], mark(m[7]), m[8], m[9]); n1 <- n1 + 1L
}
stopifnot(n1 == 12L)
out1[[length(out1) + 1]] <- c("^* PMD, post-mortem delay.", rep("", 7))
out1[[length(out1) + 1]] <- c("^** AMI, acute myocardial infarction.", rep("", 7))
out1[[length(out1) + 1]] <- c(paste0("^*** ", squish(T1[length(T1)])), rep("", 7))
snap1 <- do.call(rbind, out1)
stopifnot(nrow(snap1) == 18L, ncol(snap1) == 8L)
freeze_xlsx(snap1, paste0(item_name, "_snapshot.xlsx"), "Table1")

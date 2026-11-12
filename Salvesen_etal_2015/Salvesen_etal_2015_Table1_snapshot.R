# Salvesen_etal_2015_Table1_snapshot.R: split from Salvesen_etal_2015_extract_snapshot.R (one script per output); writes only Salvesen_etal_2015_Table1_snapshot.*
## Salvesen_etal_2015_Table1_snapshot.R -- PDF text layer -> the three frozen snapshots
##
## Salvesen L, Ullerup BH, Sunay FB, Brudek T, Lokkegaard A, Agander TK, Winge K,
## Pakkenberg B (2015). Changes in total cell numbers of the basal ganglia in patients
## with multiple system atrophy - a stereological study. Neurobiol Dis 74:104-113.
## doi:10.1016/j.nbd.2014.11.008
##
## Source -> snapshot step (snapshot HOWTO method 3, the Jacob_etal_2021 pattern):
## every DATA value is EXTRACTED from the born-digital PDF's text layer at run time.
## No value is typed in this script; only structural literals (captions, printed
## headers, footnote lines) live here, and each is anchored against the text layer.
##
## Writes (frozen; the build scripts READ these and never regenerate them):
##   Salvesen_etal_2015_Table4_snapshot.xlsx  (sheet "Table4", 50 rows x 8 cols)
##   Salvesen_etal_2015_Table1_snapshot.xlsx  (sheet "Table1", 13 rows x 7 cols)
##   Salvesen_etal_2015_text_snapshot.csv     (constructed: Results-text volumes)
##
## Frozen-file guard: if a snapshot exists and the extraction differs, the new
## capture is written to *_snapshot_NEW.<ext> and the run stops.
##
## Text-layer quirks repaired (each verified on the 300-dpi page image, PDF p. 5):
##   - the superscript exponent is flattened ("0.9 x 106"): restored as 10^6 / 10^3
##     using Unicode superscripts (10\u2076, 10\u00b3);
##   - the printed "<" before p-values renders as "b" ("b0.001*"): restored to "<";
##   - "Density/mm3": superscript restored ("Density/mm\u00b3");
##   - ligatures (fi, fl, ffi) expanded; superscript footnote letters written "^a".

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
paper  <- "Salvesen_etal_2015"
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)
pdf_file <- "Salvesen-2015-Changes in total cell numbers of.pdf"
if (!file.exists(pdf_file)) stop("Source PDF not found: ", pdf_file, call. = FALSE)
for (p in c("pdftools", "openxlsx", "readxl"))
  if (!requireNamespace(p, quietly = TRUE)) stop("Install ", p, call. = FALSE)

## 1. TEXT LAYER ---------------------------------------------------------------
pages <- pdftools::pdf_text(pdf_file)
stopifnot(length(pages) == 10L)
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

## 3. TABLE 1 (PDF page 2 = journal p. 105) -------------------------------------
L <- lines_of(2)
j0 <- grep("^\\s*Table 1\\s*$", L); j1 <- grep("Some samples were omitted", L)
stopifnot(length(j0) == 1L, length(j1) == 1L)
T1 <- L[j0:j1]
anchor("Demographic and autopsy-related data.a", T1)
anchor("Values are mean and [range].", T1)
cells <- function(ln) strsplit(trimws(ln), "\\s{2,}")[[1]]
sp1 <- cells(T1[grep("Putamen", T1)]); sp2 <- cells(T1[grep("Caudate nucleus", T1)])
sp3 <- cells(T1[grep("Globus pallidus", T1)])
stopifnot(identical(sp1, c("Putamen", "Substantia nigra", "Cell markers")),
          identical(sp2, c("Caudate nucleus", "Subthalamic nucleus", "qRT-PCR")),
          identical(sp3, c("Globus pallidus", "Red nucleus")))
grp <- cells(T1[grep("^\\s*Controls\\s+MSA", T1)])
stopifnot(identical(grp, c("Controls", "MSA", "Controlsa", "MSAa", "Controls", "MSA")))
grp <- sub("a$", "^a", grp)                      # superscript footnote mark
nn  <- cells(T1[grep("^\\s*n = ", T1)]); stopifnot(length(nn) == 6L)
row_labels <- c("Age (years)", "Male/female", "PMI (hours)", "Hemisphere (left/right)",
                "Hemisphere weight (g)")
body1 <- lapply(row_labels, function(lab) {
  ln <- T1[startsWith(trimws(T1), lab)]
  stopifnot(length(ln) == 1L)
  v <- cells(ln); stopifnot(v[1] == lab, length(v) == 7L); v })
fnA <- squish(T1[grep("^MSA = multiple system atrophy", T1)])
fnB <- squish(T1[grep("Some samples were omitted", T1)])
snap1 <- rbind(
  c("Table 1", rep("", 6)),
  c("Demographic and autopsy-related data.^a", rep("", 6)),
  c("", paste(sp1[1], sp2[1], sp3[1], sep = "\n"), "", paste(sp1[2], sp2[2], sp3[2], sep = "\n"), "",
    paste(sp1[3], sp2[3], sep = "\n"), ""),
  c("", grp), c("", nn),
  do.call(rbind, body1),
  c("Values are mean and [range].", rep("", 6)),
  c(fnA, rep("", 6)),
  c(paste0("^a ", fnB), rep("", 6)))
stopifnot(nrow(snap1) == 13L, ncol(snap1) == 7L)
freeze_xlsx(snap1, paste0(item_name, "_snapshot.xlsx"), "Table1")

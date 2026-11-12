# Salvesen_etal_2015_Table4_snapshot.R: split from Salvesen_etal_2015_extract_snapshot.R (one script per output); writes only Salvesen_etal_2015_Table4_snapshot.*
## Salvesen_etal_2015_Table4_snapshot.R -- PDF text layer -> the three frozen snapshots
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

## 2. TABLE 4 (PDF page 5 = journal p. 108) -------------------------------------
L <- lines_of(5)
i0 <- grep("^\\s*Table 4\\s*$", L); i1 <- grep("^p-Values represent", L)
stopifnot(length(i0) == 1L, length(i1) == 1L)
T4 <- L[i0:i1]
cap4 <- "Numerical estimations of the different cell types in the basal ganglia and red nucleus of patients with MSA and control subjects."
anchor(cap4, T4)
hdr4 <- c("", "Area", "Controls", "CV", "MSA", "CV", "p-values", "Percent change")
stopifnot(grepl(paste(hdr4[-1], collapse = "\\s+"), squish(T4[grep("Area", T4)[1]])))

ROW4 <- paste0("^\\s*(Neurons|Oligodendrocytes|Astrocytes|Microglia)?\\s*",
               "(SN|PU|CN|GP|STN|RN)\\s+",
               "([0-9.]+) ", X, " 10([36])\\s+([0-9.]+)\\s+",
               "([0-9.]+) ", X, " 10([36])\\s+([0-9.]+)\\s+",
               "(b?[0-9.]+\\*{0,2})\\s*([0-9]+%[\u2191\u2193])?\\s*$")
out4 <- list(c("Table 4", rep("", 7)), c(cap4, rep("", 7)), hdr4)
n_data <- 0L
for (ln in T4[-(1:2)]) {
  s <- trimws(ln)
  if (s %in% c("Total cell numbers")) { out4[[length(out4) + 1]] <- c(s, rep("", 7)); next }
  if (s == "Density/mm3") {           # the printed blank gap before this section
    out4[[length(out4) + 1]] <- rep("", 8)
    out4[[length(out4) + 1]] <- c("Density/mm\u00b3", rep("", 7)); next }
  m <- regmatches(ln, regexec(ROW4, ln, perl = TRUE))[[1]]
  if (length(m)) {
    m[m == ""] <- NA
    p <- sub("^b", "<", m[10])
    out4[[length(out4) + 1]] <- c(ifelse(is.na(m[2]), "", m[2]), m[3],
                                  times10(m[4], m[5]), m[6], times10(m[7], m[8]), m[9],
                                  p, ifelse(is.na(m[11]), "", m[11]))
    n_data <- n_data + 1L
  }
}
stopifnot(n_data == 42L)
fn1 <- squish(T4[grep("^CN = caudate nucleus", T4) + 0:1])
stopifnot(grepl("^CN = caudate nucleus, CV = coefficient of variation", fn1),
          grepl("STN = subthalamic nucleus\\.$", fn1))
fn2 <- squish(T4[grep("^p-Values represent", T4)])
out4[[length(out4) + 1]] <- c(fn1, rep("", 7))
out4[[length(out4) + 1]] <- c(fn2, rep("", 7))
snap4 <- do.call(rbind, out4)
stopifnot(nrow(snap4) == 50L, ncol(snap4) == 8L)
freeze_xlsx(snap4, paste0(item_name, "_snapshot.xlsx"), "Table4")

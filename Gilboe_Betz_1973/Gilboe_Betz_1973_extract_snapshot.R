# Gilboe_Betz_1973_extract_snapshot.R ------------------------------------------------------
#
# Freezes the snapshots of Gilboe, D. D., & Betz, A. L. (1973). Oxygen uptake in the isolated canine brain. American Journal of Physiology, 224(3), 588-595.
# DOI 10.1152/ajplegacy.1973.224.3.588. Source PDF: gilboe_betz_1973.pdf (journal pp. 588-595 (PDF pages 1-8)).
#
# Source: OCR text layer, partly garbled (± as zt/&); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_extract_snapshot.R
# pattern); this script freezes each block to <paper>_<locus>_snapshot.csv and the
# item build scripts READ those frozen files. No cleaning happens here.
#
# Fidelity conventions: one snapshot row per printed row (caption, header tiers,
# section rows, footnotes included); blank padding under spanning headers;
# a cell printed on two lines is one cell holding a newline; superscript footnote
# letters are written ^a; asterisks, daggers and parenthesised numbers as printed;
# subscripts are written inline (CMRO2, Paco2); a printed superscript that is a
# typesetting slip is kept (^2).
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders at
# 300 and 500 dpi, read at 2-5x zoom; verified by re-reading every row across
# against fresh crops after the tables' own arithmetic was run (see README).
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
paper  <- basename(folder)


## Parse a printed block: one line per printed row, cells separated by "|";
## "\\n" inside a field is a printed line break within one cell.
as_grid <- function(block, ncol) {
  lines <- strsplit(sub("^\n", "", sub("\n$", "", block)), "\n", fixed = TRUE)[[1]]
  g <- do.call(rbind, lapply(lines, function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    if (length(x) > ncol) stop("row has more than ", ncol, " cells: ", line, call. = FALSE)
    length(x) <- ncol; x[is.na(x)] <- ""; x }))
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  Encoding(g) <- "UTF-8"   # the source file is UTF-8 whatever the session locale
  g
}
read_frozen <- function(file, header) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
## Refuse to silently overwrite a frozen copy that differs: a snapshot is
## evidence, and a changed value must be a deliberate, reviewed edit.
freeze <- function(grid, locus, header = NULL) {
  file <- file.path(folder, paste0(paper, "_", locus, "_snapshot.csv"))
  if (file.exists(file)) {
    old <- read_frozen(file, header = !is.null(header))
    if (!identical(dim(old), dim(grid)) || !identical(unname(old), unname(grid)))
      stop(paper, "_", locus, ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and move ",
           "the superseded file to archive/ before re-running.", call. = FALSE)
    message(paper, "_", locus, ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    ## written byte-for-byte as UTF-8 (every field quoted, quotes doubled), so the
    ## result does not depend on the session locale
    q <- function(x) paste0('"', gsub('"', '""', x, fixed = TRUE), '"')
    rows <- c(if (!is.null(header)) paste(q(header), collapse = ","),
              apply(grid, 1, function(r) paste(q(r), collapse = ",")))
    con <- file(file, open = "wb"); writeLines(enc2utf8(rows), con, useBytes = TRUE); close(con)
    message(paper, "_", locus, ": wrote ", basename(file), " (", nrow(grid), " rows x ", ncol(grid), " cols)")
  }
  invisible(file)
}

## ---- TABLE1 (16 printed rows x 3 columns) --------------------
TABLE1_printed <- "
TABLE 1. Conditions during perfusion of isolated brain||
|Halothane|Sodium Pentobarbital
Arterial pH|7.358 ± 0.003 (100)|7.383 ± 0.007 (100)
Arterial Pco2, mm Hg|36.0 ± 0.4 (100)|40.0 ± 0.6 (100)
Arterial Po2, mm Hg|463 ± 8 (100)|587 ± 14 (99)
Venous Po2, mm Hg|34.6 ± 1.1 (100)|39.7 ± 1.1 (98)
Brain weight, g|85.0 ± 1.1 (25)|87.4 ± 1.5 (25)
Blood flow rate, ml/100 g per min|47.3 ± 0.7 (100)|39.2 ± 1.0 (100)
Perfusion pressure, mm Hg|121 ± 2 (419)|107 ± 1 (469)
Hematocrit, %|22.2 ± 0.4 (100)|23.0 ± 0.6 (100)
Na+, mEq/liter|146 ± 2 (30)\\n[147 ± 1 (147)]|
K+, mEq/liter|4.19 ± 0.08 (31)\\n[4.31 ± 0.05 (146)]|
Mg++, mEq/liter|1.75 ± 0.12 (31)\\n[1.35 ± 0.05 (148)]|
Ca++, mEq/liter|4.88 ± 0.03 (31)\\n[4.74 ± 0.02 (148)]|
Cl-, mEq/liter|118 ± 2 (30)\\n[117 ± 1 (167)]|
Values are means ± SE with the number of determinations shown in parentheses. With the exception of the perfusion pressure and the electrolyte values in brackets, the data were obtained at the moment O2 uptake and CO2 efflux were determined. The perfusion pressure is the average of measurements made at 10-min intervals during the first 150 min of perfusion. The electrolyte values in brackets were obtained during experiments conducted under similar conditions, but not included in this study.||
"
g <- as_grid(TABLE1_printed, 3L)
stopifnot(nrow(g) == 16L, ncol(g) == 3L)
freeze(g, "TABLE1")

## ---- TABLE2 (6 printed rows x 4 columns) --------------------
TABLE2_printed <- "
TABLE 2. Oxygen uptake, carbon dioxide efflux and respiratory quotients of isolated canine brain|||
|Halothane|P|Sodium Pentobarbital
O2 uptake, ml/100 g per min|3.39 ± 0.12\\n(100)|<0.001|2.54 ± 0.06\\n(98)
CO2 efflux, ml/100 g per min|3.50 ± 0.17\\n(100)|<0.005|2.52 ± 0.30\\n(100)
RQ|1.03 ± 0.06\\n(100)|NS|0.99 ± 0.13\\n(98)
Values are means ± SE, with the number of determinations shown in parentheses. NS means no significant difference exists between the 2 values that are compared (P > 0.05).|||
"
g <- as_grid(TABLE2_printed, 4L)
stopifnot(nrow(g) == 6L, ncol(g) == 4L)
freeze(g, "TABLE2")

## ---- TABLE3 (5 printed rows x 8 columns) --------------------
TABLE3_printed <- "
TABLE 3. Oxygen uptake and carbon dioxide efflux before and during pentylenetetrazol and epinephrine administration|||||||
|Flow Rate, ml/100 g per min|Control O2 Uptake, ml/100 g per min|P|Experimental O2 Uptake, ml/100 g per min|Control CO2 Efflux, (ml/100 g per min)|P|Experimental CO2 Efflux, ml/100 g per min
Pentylenetetrazol|52.5\\n± 2.4\\n(5)|4.08\\n± 0.20\\n(19)|NS|3.78\\n± 0.16\\n(20)|3.55\\n± 0.41\\n(19)|NS|4.36\\n± 0.49\\n(20)
Epinephrine|72.9\\n± 8.4\\n(3)|3.66\\n± 0.18\\n(8)|NS|3.90\\n± 0.14\\n(12)|5.64\\n± 0.97\\n(8)|NS|4.66\\n± 0.71\\n(12)
Values are means ± SE, with the number of determinations shown in parentheses. NS means no significant difference exists between the 2 values that are compared (P > 0.05).|||||||
"
g <- as_grid(TABLE3_printed, 8L)
stopifnot(nrow(g) == 5L, ncol(g) == 8L)
freeze(g, "TABLE3")

## ---- Text: constructed snapshot, one row per printed number --------
## Columns up to region_as_printed are printed text (quoted, page-located);
## curator_* columns are the curator's classification of each value and are
## the only constructed content (see README).
txt_header <- c("text_row", "page", "location", "passage_as_printed", "value_printed", "dispersion_printed", "n_printed", "units_printed", "subjects_as_printed", "state_as_printed", "region_as_printed", "curator_value_role", "curator_cited_refs", "curator_note")
txt_printed <- "
1|588|Abstract|Average O2 uptake in milliliters/100 g per min was 3.39 ± 0.12 SE for halothane and 2.54 ± 0.06 for sodium pentobarbital.|3.39|0.12||milliliters/100 g per min|isolated canine brains|halothane|isolated brain|restatement||O2 uptake; restates TABLE 2
2|588|Abstract|Average O2 uptake in milliliters/100 g per min was 3.39 ± 0.12 SE for halothane and 2.54 ± 0.06 for sodium pentobarbital.|2.54|0.06||milliliters/100 g per min|isolated canine brains|sodium pentobarbital|isolated brain|restatement||O2 uptake; restates TABLE 2
3|588|Abstract|Average CO2 efflux in milliliters/100 g per min was 3.50 ± 0.17 for halothane and 2.52 ± 0.30 for sodium pentobarbital.|3.50|0.17||milliliters/100 g per min|isolated canine brains|halothane|isolated brain|restatement||CO2 efflux; restates TABLE 2
4|588|Abstract|Average CO2 efflux in milliliters/100 g per min was 3.50 ± 0.17 for halothane and 2.52 ± 0.30 for sodium pentobarbital.|2.52|0.30||milliliters/100 g per min|isolated canine brains|sodium pentobarbital|isolated brain|restatement||CO2 efflux; restates TABLE 2
5|591|Discussion|The average of 159 normal cerebral O2 uptake values reported by various authors (30, 31, 32, 35, 36, 37) for the unanesthetized human is 3.35 ± 0.05 ml/100 g per min.|3.35|0.05|159|ml/100 g per min|unanesthetized human|unanesthetized|brain|cited|30; 31; 32; 35; 36; 37|pooled literature average
6|591|Discussion|In the presence of sodium pentobarbital, O2 uptake by in situ monkey brain (2.83 ± 0.13 ml/100 g per min, n = 192 (44, 57))|2.83|0.13|192|ml/100 g per min|monkey|sodium pentobarbital|in situ brain|cited|44; 57|
7|591|Discussion|isolated monkey brain (<2.25 ml/100 g per min, n = 3 (27))|<2.25||3|ml/100 g per min|monkey|sodium pentobarbital|isolated brain|cited|27|printed as an upper bound
8|591|Discussion|and isolated cat brain (2.24 ± 0.05 ml/100 g per min, n = 4 (65)) is depressed.|2.24|0.05|4|ml/100 g per min|cat|sodium pentobarbital|isolated brain|cited|65|
9|592|Discussion|One study reports a rate of cerebral O2 consumption (3.37 ± 0.58 ml/100 g per min, n = 7) comparable to the halothane group in dogs anesthetized with sodium pentobarbital (12).|3.37|0.58|7|ml/100 g per min|dogs|sodium pentobarbital|brain|cited|12|
10|592|Discussion|When venous blood is taken from the sagittal sinus, estimates of brain oxygen utilization in both unanesthetized (5.59 ± 0.26 ml/100 g per min, n = 12 (63))|5.59|0.26|12|ml/100 g per min|dog|unanesthetized|sagittal sinus drainage|cited|63|
11|592|Discussion|and anesthetized (4.85 ± 0.31 ml/100 g per min, n = 165 (1, 19, 24, 46, 48, 49, 62, 63)) dog brains exceed the value determined for the halothane group (Table 2).|4.85|0.31|165|ml/100 g per min|dog|anesthetized|sagittal sinus drainage|cited|1; 19; 24; 46; 48; 49; 62; 63|
12|593|Footnote 1|A straight line was fitted by linear regression to all O2 uptake data collected during the first 210 min after isolation. The slopes and intercepts were -0.00026 ml/100 g per min² and 3.70 mg/100 g per min (n = 163), respectively, for the halothane group|3.70||163|mg/100 g per min|isolated canine brains|halothane|isolated brain|new||regression intercept of O2 uptake on time; printed unit mg/100 g per min (see errata)
13|593|Footnote 1|and -0.0024 ml/100 g per min² and 2.58 mg/100 g per min (n = 245), respectively, for the sodium pentobarbital group.|2.58||245|mg/100 g per min|isolated canine brains|sodium pentobarbital|isolated brain|new||regression intercept of O2 uptake on time; printed unit mg/100 g per min (see errata)
14|593|Footnote 1|The slopes and intercepts were -0.00026 ml/100 g per min² and 3.70 mg/100 g per min (n = 163), respectively, for the halothane group|-0.00026||163|ml/100 g per min²|isolated canine brains|halothane|isolated brain|new||regression slope (not significantly different from 0)
15|593|Footnote 1|and -0.0024 ml/100 g per min² and 2.58 mg/100 g per min (n = 245), respectively, for the sodium pentobarbital group.|-0.0024||245|ml/100 g per min²|isolated canine brains|sodium pentobarbital|isolated brain|new||regression slope (not significantly different from 0)
"
g <- as_grid(txt_printed, 14L)
stopifnot(nrow(g) == 15L, identical(g[, 1], as.character(seq_len(nrow(g)))))
freeze(g, "Text", header = txt_header)


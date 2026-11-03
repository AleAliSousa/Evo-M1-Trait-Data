# Nilsson_Siesjö_1976_extract_snapshot.R ---------------------------------------------------
#
# Freezes the snapshots of Nilsson, B., & Siesjö, B. K. (1976). A method for determining blood flow and oxygen consumption in the rat brain. Acta Physiologica Scandinavica, 96(1), 72-82.
# DOI 10.1111/j.1748-1716.1976.tb10172.x. Source PDF: Nilsson-1976-A method for determi.pdf (journal pp. 72-82 (PDF pages 1-11)).
#
# Source: OCR text layer, garbled for the table (± read as k/&/+); values read from 300/500-dpi renders. The printed layout of each table
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

## ---- TABLEIII (5 printed rows x 7 columns) --------------------
TABLEIII_printed <- "
TABLE III. Mean arterial blood pressure (MABP), Paco2, arterial oxygen content ([To2]a), arteriovenous difference in oxygen content (AVDo2), CBF and CMRo2 in normocapnia, hypocapnia and hypercapnia. The values are means ±S.E.||||||
Exp. group|MABP|Paco2|[To2]a|AVDo2|CBF|CMRo2
Normocapnia\\n(n=8)|138\\n±2|34.9\\n±0.6|21.11\\n±0.48|9.59\\n±0.34|79.5\\n±2.4|7.58\\n±0.18
Hypocapnia\\n(n=4)|146\\n±7|16.8\\n±1.6|22.61\\n±0.79|14.44\\n±1.08|52.2\\n±4.7|7.42\\n±0.40
Hypercapnia\\n(n=4)|148\\n±3|72\\n±3|19.88\\n±0.67|2.10\\n±0.29|397\\n±57|7.85\\n±0.19
"
g <- as_grid(TABLEIII_printed, 7L)
stopifnot(nrow(g) == 5L, ncol(g) == 7L)
freeze(g, "TABLEIII")

## ---- Text: constructed snapshot, one row per printed number --------
## Columns up to region_as_printed are printed text (quoted, page-located);
## curator_* columns are the curator's classification of each value and are
## the only constructed content (see README).
txt_header <- c("text_row", "page", "location", "passage_as_printed", "value_printed", "dispersion_printed", "n_printed", "units_printed", "subjects_as_printed", "state_as_printed", "region_as_printed", "curator_value_role", "curator_cited_refs", "curator_note")
txt_printed <- "
1|72|Abstract|CBF and CMRo2 of the rat brain were 80±2 and 7.6±0.2 ml·(100 g)⁻¹·min⁻¹, respectively.|80|2||ml·(100 g)⁻¹·min⁻¹|rats|nitrous oxide anaesthesia|rat brain|restatement||CBF; rounded restatement of TABLE III Normocapnia (79.5 ± 2.4, n = 8)
2|72|Abstract|CBF and CMRo2 of the rat brain were 80±2 and 7.6±0.2 ml·(100 g)⁻¹·min⁻¹, respectively.|7.6|0.2||ml·(100 g)⁻¹·min⁻¹|rats|nitrous oxide anaesthesia|rat brain|restatement||CMRO2; rounded restatement of TABLE III Normocapnia (7.58 ± 0.18, n = 8). This is the value Mink et al. 1981 cite (7.6).
3|77|Results|The results (Table III) show that CBF was close to 80 and CMRo2 about 7.5 ml·(100 g)⁻¹·min⁻¹.|80|||ml·(100 g)⁻¹·min⁻¹|rats|normal Pco2||restatement||CBF; approximate restatement of TABLE III
4|77|Results|The results (Table III) show that CBF was close to 80 and CMRo2 about 7.5 ml·(100 g)⁻¹·min⁻¹.|7.5|||ml·(100 g)⁻¹·min⁻¹|rats|normal Pco2||restatement||CMRO2; approximate restatement of TABLE III
5|77|Results|In hypocapnia, CBF was reduced to 66% of normal|66|||%|rats|hypocapnia||derived||percentage of normocapnic CBF; restates TABLE III (52.2/79.5)
6|78|Results|In two experiments mean CBF, as calculated from the uptake of ¹⁴C-ethanol in the whole hemisphere, was 79 and 80 ml·(100 g)⁻¹·min⁻¹.|79|||ml·(100 g)⁻¹·min⁻¹|rats (two experiments)|normocapnia (method check)|whole hemisphere|new||CBF by tissue uptake of 14C-ethanol; first of two experiments; printed only here
7|78|Results|In two experiments mean CBF, as calculated from the uptake of ¹⁴C-ethanol in the whole hemisphere, was 79 and 80 ml·(100 g)⁻¹·min⁻¹.|80|||ml·(100 g)⁻¹·min⁻¹|rats (two experiments)|normocapnia (method check)|whole hemisphere|new||CBF by tissue uptake of 14C-ethanol; second of two experiments; printed only here
8|79|Discussion|the outflow through the catheter may apparently exceed the total brain blood flow (mean flow = 80 ml·(100 g⁻¹·min⁻¹, brain weight = 2 g, total flow = 1.6 ml·min⁻¹)|80|||ml·(100 g⁻¹·min⁻¹|rats||total brain|restatement||mean CBF used in a worked example; the printed unit lacks its closing parenthesis
9|79|Discussion|the outflow through the catheter may apparently exceed the total brain blood flow (mean flow = 80 ml·(100 g⁻¹·min⁻¹, brain weight = 2 g, total flow = 1.6 ml·min⁻¹)|2|||g|rats||total brain|assumed||brain weight assumed in the worked example
10|79|Discussion|the outflow through the catheter may apparently exceed the total brain blood flow (mean flow = 80 ml·(100 g⁻¹·min⁻¹, brain weight = 2 g, total flow = 1.6 ml·min⁻¹)|1.6|||ml·min⁻¹|rats||total brain|derived||total brain blood flow = 80 x 2/100
11|72|Introduction|the values for CBF (about 50 ml·(100 g)⁻¹·min⁻¹) and CMRo2 (about 3.3 ml·(100 g)⁻¹·min⁻¹) are representative for the brain as a whole|50|||ml·(100 g)⁻¹·min⁻¹|man||brain as a whole|cited|Kety 1950; Kety 1957; Lassen 1959; Sokoloff 1959|human CBF, cited from reviews
12|72|Introduction|the values for CBF (about 50 ml·(100 g)⁻¹·min⁻¹) and CMRo2 (about 3.3 ml·(100 g)⁻¹·min⁻¹) are representative for the brain as a whole|3.3|||ml·(100 g)⁻¹·min⁻¹|man||brain as a whole|cited|Kety 1950; Kety 1957; Lassen 1959; Sokoloff 1959|human CMRO2, cited from reviews
13|72-73|Introduction|In the dog under light thiopental or nitrous oxide anaesthesia, the CMRo2 values obtained are about 5-6 ml·(100 g)⁻¹·min⁻¹|5-6|||ml·(100 g)⁻¹·min⁻¹|dog|light thiopental or nitrous oxide anaesthesia|superior sagittal sinus drainage|cited|Homberger et al. 1946; Michenfelder and Theye 1968|dog CMRO2 range, cited
14|73|Introduction|in the rat, a value of 10-11 ml·(100 g)⁻¹·min⁻¹ has recently been reported|10-11|||ml·(100 g)⁻¹·min⁻¹|rat||superior sagittal sinus drainage|cited|Eklöf et al. 1973; Norberg and Siesjö 1974|rat cortical CMRO2 range, cited
15|81|Discussion|CMRo2 of human cerebral cortex should be about 4.5 ml·(100 g)⁻¹·min⁻¹. This value is provisional|4.5|||ml·(100 g)⁻¹·min⁻¹|man||human cerebral cortex|derived||extrapolated from the rat-dog cortical line of Fig. 6; not a measurement
"
g <- as_grid(txt_printed, 14L)
stopifnot(nrow(g) == 15L, identical(g[, 1], as.character(seq_len(nrow(g)))))
freeze(g, "Text", header = txt_header)


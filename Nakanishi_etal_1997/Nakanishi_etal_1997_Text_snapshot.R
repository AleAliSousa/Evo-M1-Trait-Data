# Nakanishi_etal_1997_Text_snapshot.R -------------------------------------------------
# (Split from the retired Nakanishi_etal_1997_extract_snapshot.R: this script writes only Nakanishi_etal_1997_Text_snapshot.csv.)
#
# Freezes the snapshot of Nakanishi, O., Ishikawa, T., Imamura, Y., & Hirakawa, T. (1997). Inhibition of cerebral metabolic and circulatory responses to nitrous oxide by 6-hydroxydopamine in dogs. Canadian Journal of Anaesthesia, 44(9), 1008-1013.
# DOI 10.1007/BF03011974. Source PDF: Nakanishi-1997-Inhibition of cerebral metaboli.pdf (journal pp. 1008-1013, PDF pages 1-6).
#
# Source: born-digital typeset PDF with a usable text layer (used only to locate
# passages); every value was read from 300/500-dpi page renders. The printed
# text numbers (constructed snapshot: one row per printed number) are written out verbatim below (method 5); this script
# freezes them to Nakanishi_etal_1997_Text_snapshot.csv and the item build script READS that frozen file.
#
# Fidelity conventions: one snapshot row per printed row (caption, header, data
# rows, footnotes); the Periods and Time labels sit on the printed line where the
# page sets them (vertically centred between two group lines) and are NOT
# propagated here; daggers and asterisks are kept as printed; subscripts inline.
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders at 300
# and 500 dpi, before any compilation value was looked at.
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # = Nakanishi_etal_1997_Text


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
  file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
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


## ---- Text: constructed snapshot, one row per printed number --------
## Columns up to region_as_printed are printed text (quoted, page-located);
## curator_* columns are the curator's classification of each value.
txt_header <- c("text_row", "page", "location", "passage_as_printed", "value_printed", "dispersion_printed", "n_printed", "units_printed", "subjects_as_printed", "state_as_printed", "region_as_printed", "curator_value_role", "curator_cited_refs", "curator_note")
txt_printed <- "
1|1008|Abstract, Results|In the sham group, N2O (60%) increased CMRO2 from 6.11 ± 0.21 ml·100 g⁻¹·min⁻¹ to 7.10 ± 0.39 ml·100 g⁻¹·min⁻¹ and CBF from 63 ± 5 ml·100 g⁻¹·min⁻¹ to 173 ± 26 ml·100 g⁻¹·min⁻¹.|6.11|0.21||ml·100 g⁻¹·min⁻¹|sham group|control (before N2O)||restatement||CMRO2; = TABLE II Control sham-op
2|1008|Abstract, Results|In the sham group, N2O (60%) increased CMRO2 from 6.11 ± 0.21 ml·100 g⁻¹·min⁻¹ to 7.10 ± 0.39 ml·100 g⁻¹·min⁻¹ and CBF from 63 ± 5 ml·100 g⁻¹·min⁻¹ to 173 ± 26 ml·100 g⁻¹·min⁻¹.|7.10|0.39||ml·100 g⁻¹·min⁻¹|sham group|N2O (60%)||restatement||CMRO2; = TABLE II N2O addition 10 min sham-op
3|1008|Abstract, Results|In the sham group, N2O (60%) increased CMRO2 from 6.11 ± 0.21 ml·100 g⁻¹·min⁻¹ to 7.10 ± 0.39 ml·100 g⁻¹·min⁻¹ and CBF from 63 ± 5 ml·100 g⁻¹·min⁻¹ to 173 ± 26 ml·100 g⁻¹·min⁻¹.|63|5||ml·100 g⁻¹·min⁻¹|sham group|control (before N2O)||restatement||CBF; = TABLE II Control sham-op
4|1008|Abstract, Results|In the sham group, N2O (60%) increased CMRO2 from 6.11 ± 0.21 ml·100 g⁻¹·min⁻¹ to 7.10 ± 0.39 ml·100 g⁻¹·min⁻¹ and CBF from 63 ± 5 ml·100 g⁻¹·min⁻¹ to 173 ± 26 ml·100 g⁻¹·min⁻¹.|173|26||ml·100 g⁻¹·min⁻¹|sham group|N2O (60%)||restatement||CBF; = TABLE II N2O addition 10 min sham-op
5|1008|Abstract, Results|In the 6-OHDA group, CMRO2 did not change during N2O exposure, whereas CBF increased from 61 ± 3 ml·100 g⁻¹·min⁻¹ to 135 ± 19 ml·100 g⁻¹·min⁻¹ but less then in the sham group.|61|3||ml·100 g⁻¹·min⁻¹|6-OHDA group|control (before N2O)||restatement||CBF; = TABLE II Control 6-OHDA
6|1008|Abstract, Results|In the 6-OHDA group, CMRO2 did not change during N2O exposure, whereas CBF increased from 61 ± 3 ml·100 g⁻¹·min⁻¹ to 135 ± 19 ml·100 g⁻¹·min⁻¹ but less then in the sham group.|135|19||ml·100 g⁻¹·min⁻¹|6-OHDA group|N2O||restatement||CBF; = TABLE II N2O addition 10 min 6-OHDA
7|1010|Results|CMRO2 increased from 6.11 ml·100g–1·min⁻¹ to 7.10~7.34 ml·100g⁻¹·min⁻¹ during administration of N2O|6.11|||ml·100g–1·min⁻¹|sham-operated group|control||restatement||CMRO2; printed unit has an en dash and no superscript in '100g–1'
8|1010|Results|CMRO2 increased from 6.11 ml·100g–1·min⁻¹ to 7.10~7.34 ml·100g⁻¹·min⁻¹ during administration of N2O|7.10~7.34|||ml·100g⁻¹·min⁻¹|sham-operated group|N2O 60% + 0.2% halothane, during administration||range||CMRO2 range during N2O
9|1010|Results|while CBF increased and reached its maximam 10 min after the administration of N2O (from 63 ml·100g⁻¹·min⁻¹ to 173 ml·100g⁻¹·min⁻¹), and thereafter progressively declined, but was still 111 ml·100g⁻¹·min⁻¹ at 60 min.|63|||ml·100g⁻¹·min⁻¹|sham-operated group|control||restatement||CBF
10|1010|Results|while CBF increased and reached its maximam 10 min after the administration of N2O (from 63 ml·100g⁻¹·min⁻¹ to 173 ml·100g⁻¹·min⁻¹), and thereafter progressively declined, but was still 111 ml·100g⁻¹·min⁻¹ at 60 min.|173|||ml·100g⁻¹·min⁻¹|sham-operated group|N2O, maximum at 10 min||restatement||CBF
11|1010|Results|while CBF increased and reached its maximam 10 min after the administration of N2O (from 63 ml·100g⁻¹·min⁻¹ to 173 ml·100g⁻¹·min⁻¹), and thereafter progressively declined, but was still 111 ml·100g⁻¹·min⁻¹ at 60 min.|111|||ml·100g⁻¹·min⁻¹|sham-operated group|N2O, 60 min||restatement||CBF
12|1010|Results|In the 6-OHDA group, CMRO2 did not change during N2O exposure, whereas CBF increased to a maximum 135 ml·100g⁻¹·min⁻¹ at 10 min (P<0.05), then gradually declined to 84 ml·100g⁻¹·min⁻¹ from 61 ml·100g⁻¹·min⁻¹ at 60 min.|135|||ml·100g⁻¹·min⁻¹|6-OHDA group|N2O, maximum at 10 min||restatement||CBF
13|1010|Results|In the 6-OHDA group, CMRO2 did not change during N2O exposure, whereas CBF increased to a maximum 135 ml·100g⁻¹·min⁻¹ at 10 min (P<0.05), then gradually declined to 84 ml·100g⁻¹·min⁻¹ from 61 ml·100g⁻¹·min⁻¹ at 60 min.|84|||ml·100g⁻¹·min⁻¹|6-OHDA group|N2O, 60 min||restatement||CBF
14|1010|Results|In the 6-OHDA group, CMRO2 did not change during N2O exposure, whereas CBF increased to a maximum 135 ml·100g⁻¹·min⁻¹ at 10 min (P<0.05), then gradually declined to 84 ml·100g⁻¹·min⁻¹ from 61 ml·100g⁻¹·min⁻¹ at 60 min.|61|||ml·100g⁻¹·min⁻¹|6-OHDA group|control||restatement||CBF
15|1012|Discussion|we found CBF to increase approximately 80~170% above control in the sham-operated group compared with the 35~110% increase in our previous studies.3|80~170|||% above control|sham-operated group|N2O||derived||CBF % increase above control
16|1012|Discussion|we found CBF to increase approximately 80~170% above control in the sham-operated group compared with the 35~110% increase in our previous studies.3|35~110|||% (increase)|dogs (previous studies)|N2O||cited|3|CBF % increase in the authors' previous studies (ref. 3)
17|1012|Discussion|in the 6-OHDA group, CBF increased to a maximum approximately 110% above control at 10 min after N2O without increase in CMRO2 (Table II).|110|||% above control|6-OHDA group|N2O, maximum at 10 min||derived||CBF % increase above control
"
g <- as_grid(txt_printed, 14L)
stopifnot(nrow(g) == 17L, identical(g[, 1], as.character(seq_len(nrow(g)))))
freeze(g, "Text", header = txt_header)

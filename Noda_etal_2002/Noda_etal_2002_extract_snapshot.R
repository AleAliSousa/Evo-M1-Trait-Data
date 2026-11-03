# Noda_etal_2002_extract_snapshot.R -------------------------------------------
#
# Builds the two frozen snapshots of Noda, Ohba, Kakiuchi, Futatsubashi, Tsukada
# & Nishimura (2002) "Age-related changes in cerebral blood flow and glucose
# metabolism in conscious rhesus monkeys", Brain Research 936: 76-81.
#
#   Noda_etal_2002_Table2_snapshot.csv   Table 2, rCBF (ml/100 g/min), p. 79
#   Noda_etal_2002_Table3_snapshot.csv   Table 3, rCMRglc (µmol/100 g/min), p. 79
# Each: young (n = 6) and aged (n = 6) male rhesus, conscious (head-holder,
# chair-habituated), mean ± S.D., as Average / R or A / L or P, plus Y–A (%).
# Table 1 (physiological variables) carries no cerebral value and is not built.
#
# The PDF is typeset, but in its text layer "±" reads "6" and the superscript
# significance letters are detached from their cells, so the values below are a
# HAND TRANSCRIPTION read from 330-dpi renders of PDF page 4 by an AI assistant
# (Claude) on 2026-11-02 (method 5); the text layer, read afterwards, agrees on
# every number. Kept as printed: the aged-column unit "(µml/100 g/min ...)"
# (sic) in Table 3; the blank R/L cells of the Cerebellum row; superscripts "^x".
# One snapshot row per printed row ("Hippocampus / with adj. cortex" is one
# cell printed on two lines). Refuses to overwrite a differing frozen copy.
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
printed <- list()
printed[["Table2"]] <- "
Table 2|||||||||
Regional cerebral blood flow in young and aged monkeys|||||||||
|Young monkeys\\n(ml/100 g/min, mean±S.D.) (Y)|||Aged monkeys\\n(ml/100 g/min, mean±S.D.) (A)|||Y–A (%)||
|Average|R or A|L or P|Average|R or A|L or P|Average|R or A|L or P
Cerebellum|47.8±5.1|||34.3±7.6|||28^b||
Hippocampus\\nwith adj. cortex|53.9±7.6|53.2±7.2|54.6±8.3|43.4±4.6|43.3±4.0|43.5±5.5|20^a|19^a|20^a
Striatum|60.5±11.1|60.2±12.7|60.9±10.4|44.1±3.9|43.8±4.0|44.5±4.1|27^b|27^a|27^b
Occipital cortex|59.2±7.6|59.6±8.2|58.9±7.1|43.9±7.2|44.0±6.9|43.8±7.6|26^c|26^b|26^b
Temporal cortex|53.2±6.5|54.7±3.0|51.6±2.5|45.7±4.6|43.9±1.7|47.6±2.1|14^a|20^a|8
Frontal cortex|45.0±6.4|45.2±3.1|44.8±2.5|37.2±3.6|35.7±1.5|38.7±2.8|17^a|21^a|14
Cingulate|54.5±9.6|54.5±4.4|54.5±3.5|46.5±2.1|46.3±0.7|46.8±1.3|15|15|14
Y–A = (Y–A)/Y × 100. Average, values are averaged for the right and left hemisphere, except the cingulate. For the cingulate, values are averaged for the anterior and posterior cingulate; R or A, right hemisphere except for the cingulate; anterior cingulate. L or P, left hemisphere except for the cingulate; posterior cingulate.|||||||||
^a P<0.05.|||||||||
^b P<0.01.|||||||||
^c P<0.005.|||||||||
"
printed[["Table3"]] <- "
Table 3|||||||||
Regional cerebral glucose metabolism in young and aged monkeys|||||||||
|Young monkeys\\n(µmol/100 g/min, mean±S.D.) (Y)|||Aged monkeys\\n(µml/100 g/min, mean±S.D.) (A)|||Y–A (%)||
|Average|R or A|L or P|Average|R or A|L or P|Average|R or A|L or P
Cerebellum|26.8±5.9|||16.3±6.8|||39^a||
Hippocampus\\nwith adj. cortex|32.2±5.2|32.3±5.0|32.1±5.5|21.2±4.0|21.1±3.6|21.3±4.7|34^c|35^c|34^c
Striatum|40.9±9.1|40.3±8.9|41.5±9.3|26.5±5.6|26.6±5.9|26.5±5.4|35^b|34^a|36^b
Occipital cortex|39.7±9.4|40.1±10.0|39.3±8.9|26.7±7.7|27.0±8.0|26.4±7.5|33^a|33^a|33^a
Temporal cortex|36.0±7.3|36.7±3.0|35.3±3.1|26.6±5.0|26.0±2.0|27.3±2.1|26^a|29^a|23
Frontal cortex|34.1±8.2|34.0±3.4|34.2±3.4|22.4±4.7|21.5±1.8|23.2±2.3|34^a|37^b|32^a
Cingulate|36.6±8.5|36.2±3.6|37.1±3.4|26.7±4.5|26.3±1.4|27.1±2.4|27^a|27^a|27^a
Y–A = (Y–A)/Y × 100. Average, values are averaged for the right and left hemisphere, except the cingulate. For the cingulate, values are averaged for the anterior and posterior cingulate. R or A, right hemisphere except for the cingulate; anterior cingulate. L or P, left hemisphere except for the cingulate; posterior cingulate.|||||||||
^a P<0.05.|||||||||
^b P<0.01.|||||||||
^c P<0.005.|||||||||
"

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  g
}

freeze <- function(grid, file) {
  if (file.exists(file)) {
    old <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                              na.strings = character(0), check.names = FALSE,
                              encoding = "UTF-8"))
    dimnames(old) <- NULL
    new <- grid; dimnames(new) <- NULL
    if (!identical(dim(old), dim(new)) || !identical(old, new))
      stop(basename(file), ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and ",
           "move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
  }
}

for (locus in names(printed)) {
  grid <- to_grid(printed[[locus]], 10L)
  stopifnot(nrow(grid) == 2L + 2L + 7L + 4L, identical(grid[4, 2:4], c("Average", "R or A", "L or P")),
            all(grepl("^[0-9.]+±[0-9.]+$", grid[5:11, c(2, 5)])))
  freeze(grid, file.path(folder, paste0(paper, "_", locus, "_snapshot.csv")))
}

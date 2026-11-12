# Buchsbaum_etal_1989_Text_snapshot.R ----------------------------------------
#
# Builds the frozen snapshot of Buchsbaum, Gillin, Wu, Hazlett, Sicotte,
# Dupont & Bunney (1989) "Regional cerebral glucose metabolic rate in human
# sleep assessed by positron emission tomography", Life Sciences 45: 1349-1356.
#
#   Buchsbaum_etal_1989_Text_snapshot.csv   values printed in the
#       Summary (p. 1349) and RESULTS (p. 1353).
#
# The source is a typewriter-set page scanned with an OCR text layer that reads
# "i" for "l" and "3" for "j"; the values are a HAND TRANSCRIPTION read from
# 200- and 400-dpi renders of PDF pages 1, 5 and 6 by an AI assistant (Claude)
# on 2026-11-02 (method 5). The OCR layer, read afterwards, agrees on every
# number. Words garbled by the typeface in the OCR ("mlcromoles") are written
# as printed ("micromoles"). This script freezes the files and refuses to
# overwrite a differing frozen copy; the builds READ them.
#
# Fidelity decisions: one snapshot row per printed row, the three section
# headings and the printed gaps as rows, the sub-means ("Mean") and the "Grand
# Mean" kept; mean and SD are separate printed columns, as on the page. The
# text snapshot is CONSTRUCTED: one row per printed value, sentence quoted.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

printed_text <- "
text_row|page|location|passage_as_printed|value_printed|dispersion_printed|units_printed|subjects_as_printed|state_as_printed|region_as_printed
1|1349|Summary|In comparison to waking controls, subjects given FDG during non-rapid eye movement (NREM) sleep (primarily stages 2 and 3) showed about a 23% reduction in metabolic rate across the entire brain.|23||% (reduction vs waking)|subjects given FDG during NREM sleep vs waking controls|NREM sleep (primarily stages 2 and 3)|the entire brain
2|1353|RESULTS|NREM sleep (mean 14.0, SD=3.7 micromoles/100g/min) showed a marked decrease in metabolic rate (Figure 2) compared with waking (21.4 ±6.3) and REM (19.2 ±4.3).|14.0|3.7|micromoles/100g/min|NREM subjects|NREM sleep|cortical (frontal, parietal, temporal, occipital lobes; the cortical ANOVA)
3|1353|RESULTS|NREM sleep (mean 14.0, SD=3.7 micromoles/100g/min) showed a marked decrease in metabolic rate (Figure 2) compared with waking (21.4 ±6.3) and REM (19.2 ±4.3).|21.4|6.3|micromoles/100g/min|awake subjects|waking|cortical (frontal, parietal, temporal, occipital lobes; the cortical ANOVA)
4|1353|RESULTS|NREM sleep (mean 14.0, SD=3.7 micromoles/100g/min) showed a marked decrease in metabolic rate (Figure 2) compared with waking (21.4 ±6.3) and REM (19.2 ±4.3).|19.2|4.3|micromoles/100g/min|REM subjects|REM sleep|cortical (frontal, parietal, temporal, occipital lobes; the cortical ANOVA)
5|1353|RESULTS|Examination of table means revealed that the largest decrease with NREM was the medial frontal cortex (10.5 micromoles or 38.2% decrease from waking) and the smallest was the putamen (7.5 micromoles or 28.4%).|10.5||micromoles (decrease from waking)|NREM vs awake|NREM sleep|medial frontal cortex
6|1353|RESULTS|Examination of table means revealed that the largest decrease with NREM was the medial frontal cortex (10.5 micromoles or 38.2% decrease from waking) and the smallest was the putamen (7.5 micromoles or 28.4%).|38.2||% (decrease from waking)|NREM vs awake|NREM sleep|medial frontal cortex
7|1353|RESULTS|Examination of table means revealed that the largest decrease with NREM was the medial frontal cortex (10.5 micromoles or 38.2% decrease from waking) and the smallest was the putamen (7.5 micromoles or 28.4%).|7.5||micromoles (decrease from waking)|NREM vs awake|NREM sleep|putamen
8|1353|RESULTS|Examination of table means revealed that the largest decrease with NREM was the medial frontal cortex (10.5 micromoles or 38.2% decrease from waking) and the smallest was the putamen (7.5 micromoles or 28.4%).|28.4||% (decrease from waking)|NREM vs awake|NREM sleep|putamen
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

grid_tx <- to_grid(printed_text, 10L)
stopifnot(nrow(grid_tx) == 9L)
freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))

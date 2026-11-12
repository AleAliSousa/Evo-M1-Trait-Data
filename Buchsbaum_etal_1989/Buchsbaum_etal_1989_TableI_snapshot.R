# Buchsbaum_etal_1989_TableI_snapshot.R ----------------------------------------
#
# Builds the frozen snapshot of Buchsbaum, Gillin, Wu, Hazlett, Sicotte,
# Dupont & Bunney (1989) "Regional cerebral glucose metabolic rate in human
# sleep assessed by positron emission tomography", Life Sciences 45: 1349-1356.
#
#   Buchsbaum_etal_1989_TableI_snapshot.csv   the table on p. 1354 (PDF page 6),
#       "MEAN GLUCOSE METABOLIC RATE IN HUMAN SLEEP (micromoles/100g/min)". The
#       page prints no table number; the RESULTS text calls it "Table I", hence
#       the locus. Arms: Awake (n=10), NREM (n=12), REM (n=12), mean and SD.
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
printed_TableI <- "
MEAN GLUCOSE METABOLIC RATE IN HUMAN SLEEP||||||
(micromoles/100g/min)||||||
Cortical\\n  area|||Sleep Stage|||
|Awake (n=10)||NREM (n=12)||REM (n=12)|
|mean|SD|mean|SD|mean|SD
Lateral cortex||||||
Frontal|23.5|6.5|15.1|4.2|20.8|4.0
Parietal|23.2|6.5|14.5|4.6|20.6|3.9
Temporal|17.6|4.6|12.2|3.1|16.0|3.8
Occipital|21.1|5.9|14.3|4.0|19.4|3.7
Mean|21.4|6.3|14.0|4.1|19.2|3.9
||||||
Subcortical gray||||||
Caudate|25.4|6.4|18.1|4.0|22.3|4.6
Putamen|26.4|6.8|18.9|4.7|23.4|4.9
Thalamus|24.3|7.2|15.6|4.4|18.2|3.8
Globus pallidus|22.7|6.0|16.2|3.5|20.3|4.8
Mean|24.7|6.6|17.2|4.3|21.1|4.9
||||||
Medial cortex||||||
Medial frontal|27.5|7.1|17.0|5.1|24.0|5.1
Anterior cing.|20.5|5.2|14.5|4.2|20.3|4.3
Mid. cing|19.8|5.0|13.4|3.8|18.9|4.1
Post. cing.|19.7|5.0|13.3|3.2|19.2|3.1
Mean|21.9|6.6|14.6|4.3|20.6|4.6
||||||
Grand Mean|22.6|4.5|15.3|4.4|20.3|4.5
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

grid_T  <- to_grid(printed_TableI, 7L)
stopifnot(nrow(grid_T) == 27L, sum(grepl("^[0-9]+\\.[0-9]$", grid_T[, 2])) == 16L)
freeze(grid_T,  file.path(folder, paste0(item_name, "_snapshot.csv")))

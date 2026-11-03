# Passero_etal_1981_extract_snapshot.R ----------------------------------------
#
# Builds the frozen snapshot of Passero, Carli & Battistini (1981)
# "Depression of cerebral glucose utilization during animal hypnosis in the
# rabbit", Neuroscience Letters 21: 345-349.
#
#   Passero_etal_1981_TABLEII_snapshot.csv   TABLE II "Local cerebral glucose
#                                            utilization (µmol/100 g/min)",
#                                            p. 348 (PDF page 4)
#
# TABLE I (p. 347, durations of the experimental conditions in minutes) carries
# no metabolic value and is not built.
#
# The source is a 1981 scanned page. The values below are a HAND TRANSCRIPTION
# read from 300-dpi renders of PDF page 4 (__HOWTO_make_a_snapshot.md method 5,
# Mink_etal_1981 printed-layout-block pattern). The OCR text layer was used
# afterwards only as a second reading: it agreed on all 66 numbers and garbled
# only the significance stars (read as '"'). This script writes the frozen
# file and refuses to overwrite a frozen copy that differs; the build READS it.
#
# Fidelity decisions:
#  * One snapshot row per printed row: title, caption, legend line, column
#    header, 22 structure rows in printed order (no blank or section rows).
#  * Significance stars are kept attached to the % Decrease cell, as printed.
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders.
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

printed_TABLEII <- "
TABLE II|||
LOCAL CEREBRAL GLUCOSE UTILIZATION (µmol/100 g/min)|||
Values are means ± S.E. * P < 0.05; ** P < 0.01; *** P < 0.005 by Student's t-test.|||
Structure|Control (n = 5)|Hypnosis (n = 5)|% Decrease
Visual cortex|76.4 ± 8.8|50.3 ± 7.1|34.1**
Auditory cortex|102.3 ± 9.6|80.1 ± 9.8|21.7*
Parietal cortex|73.1 ± 7.8|55.7 ± 3.4|23.8*
Sensory cortex|75.4 ± 7.5|45.6 ± 6.8|39.5***
Motor cortex|89.9 ± 6.2|63.2 ± 6.2|29.7***
Thalamus|80.1 ± 5.9|61.6 ± 1.9|23.1***
Medial geniculate body|108.2 ± 1.9|94.7 ± 5.5|12.5*
Lateral geniculate body|80.7 ± 4.9|67.2 ± 4.0|16.7
Hypothalamus|62.0 ± 3.3|52.2 ± 4.8|15.8**
Mammillary body|67.6 ± 2.8|58.1 ± 2.4|14.0**
Hippocampus|58.1 ± 2.5|44.5 ± 4.1|23.4***
Amygdala|39.1 ± 1.4|28.2 ± 2.7|27.9**
Caudate-putamen|85.8 ± 5.2|59.4 ± 7.1|30.5***
Globus pallidus|42.1 ± 2.3|34.5 ± 2.7|18.0*
Septal nucleus|48.3 ± 1.9|35.4 ± 1.8|26.7***
Superior olive|94.6 ± 4.9|85.1 ± 8.3|10.0
Substantia nigra|48.3 ± 3.2|40.0 ± 3.9|17.2
Inferior colliculus|125.5 ± 3.2|113.2 ± 3.6|9.8
Superior colliculus|62.1 ± 1.4|56.8 ± 2.0|8.5
Pontine gray matter|46.9 ± 2.2|35.4 ± 2.9|24.5*
Internal capsule|26.1 ± 2.5|18.8 ± 1.2|27.9
Pontine white|27.0 ± 1.1|19.3 ± 2.9|28.5
"

grid <- do.call(rbind, lapply(strsplit(trimws(printed_TABLEII), "\n", fixed = TRUE)[[1]], function(line) {
  x <- strsplit(line, "|", fixed = TRUE)[[1]]
  length(x) <- 4L
  x
}))
grid[is.na(grid)] <- ""

stopifnot(nrow(grid) == 4L + 22L,
          all(grepl("^[0-9.]+ ± [0-9.]+$", grid[5:26, 2:3])),
          all(grepl("^[0-9.]+\\**$", grid[5:26, 4])))

snapshot_file <- file.path(folder, paste0(paper, "_TABLEII_snapshot.csv"))
if (file.exists(snapshot_file)) {
  old <- as.matrix(read.csv(snapshot_file, header = FALSE, colClasses = "character",
                            na.strings = character(0), check.names = FALSE, encoding = "UTF-8"))
  dimnames(old) <- NULL
  new <- grid; dimnames(new) <- NULL
  if (!identical(dim(old), dim(new)) || !identical(old, new))
    stop(basename(snapshot_file), ": the frozen snapshot on disk differs from the block in this ",
         "script. Refusing to overwrite. Reconcile the difference against the PDF and move ",
         "the superseded file to archive/ before re-running.", call. = FALSE)
  message(basename(snapshot_file), ": frozen snapshot already on disk and identical; nothing written.")
} else {
  write.table(grid, snapshot_file, sep = ",", row.names = FALSE, col.names = FALSE,
              qmethod = "double", fileEncoding = "UTF-8")
  message(basename(snapshot_file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
}

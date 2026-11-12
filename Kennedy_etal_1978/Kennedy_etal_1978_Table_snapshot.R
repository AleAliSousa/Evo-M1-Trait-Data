# Kennedy_etal_1978_Table_snapshot.R ----------------------------------------
#
# Builds the frozen snapshot of Kennedy, Sakurada, Shinohara, Jehle &
# Sokoloff (1978) "Local cerebral glucose utilization in the normal conscious
# macaque monkey", Annals of Neurology 4: 293-301.
#
#   Kennedy_etal_1978_Table_snapshot.csv          the single, UNNUMBERED table
#                                                 "Values for Local Cerebral
#                                                 Glucose Utilization in Normal,
#                                                 Conscious Monkeys", p. 298
#                                                 (PDF page 6)
#
# The source is a 1978 scanned journal page whose OCR text layer is garbled
# (figure labels interleaved, "pmoles" for µmoles, digits split), so nothing
# was taken from it. The values below are a HAND TRANSCRIPTION read from
# 300- and 500-dpi renders of PDF pages 6-8 (__HOWTO_make_a_snapshot.md
# method 5, the Mink_etal_1981 printed-layout-block pattern). This script
# writes the frozen files and refuses to overwrite a frozen copy that differs;
# the build scripts READ them. No cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed row. The table prints two section headings
#    (Gray matter, White matter), 39 structure rows (31 gray + 8 white, the
#    counts the RESULTS text states), and nine vertical gaps between structure
#    groups; each gap is an empty row. The footnote is the last row.
#  * The superscript footnote mark is written "^a" ("Optic chiasm^a").
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

printed_Table <- "
Values for Local Cerebral Glucose Utilization in Normal, Conscious Monkeys|
Structure|Value\\n(µmoles/\\n100 gm/min)
Gray matter|
Visual cortex|59 ± 2
Auditory cortex|79 ± 4
Parietal cortex|47 ± 4
Motor cortex|44 ± 3
Frontal cortex|50 ± 2
|
Thalamus: dorsomedial nucleus|54 ± 2
Thalamus: ventral posterolateral nucleus|43 ± 2
Medial geniculate body|65 ± 3
Lateral geniculate body|39 ± 1
Hypothalamus: ventromedial nucleus|25 ± 1
Mamillary body|57 ± 3
Hippocampal gyrus|39 ± 2
Amygdala: anterior nucleus|25 ± 2
Septal nucleus: medial|26 ± 2
Caudate nucleus|52 ± 3
Nucleus accumbens|36 ± 2
Putamen|53 ± 3
Globus pallidus|26 ± 2
Subthalamic nucleus|51 ± 2
Substantia nigra: zona diffusa|29 ± 2
|
Vestibular nucleus|66 ± 3
Cochlear nucleus|51 ± 3
Superior olivary nucleus|63 ± 4
Inferior colliculus|103 ± 6
Superior colliculus|55 ± 4
Pontine reticular nucleus|28 ± 1
|
Vermis|32 ± 2
Flocculus|50 ± 3
Cerebellar cortex|31 ± 2
Cerebellar nuclei|45 ± 2
|
Spinal gray matter: cervical^a|21 ± 2
|
White matter|
Optic chiasm^a|23 ± 2
Optic tract|18 ± 1
|
Corona radiata|11 ± 1
Corpus callosum|11 ± 0
Internal capsule|13 ± 1
Pyramids|13 ± 1
|
Cerebellar white matter|12 ± 1
|
Spinal white matter^a|7 ± 1
The values are means ± standard errors from measurements in 7 animals except those marked with ^a, which represent values in 6 animals.|
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

grid_T  <- to_grid(printed_Table, 2L)

## Structural guards: 39 structure rows (31 gray + 8 white), as the RESULTS text states.
val_rows <- grepl("±", grid_T[, 2])
stopifnot(sum(val_rows) == 39L,
          sum(val_rows[seq_len(which(grid_T[, 1] == "White matter"))]) == 31L)

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

freeze(grid_T,  file.path(folder, paste0(item_name, "_snapshot.csv")))

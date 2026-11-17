# Sokoloff_etal_1977_Table4_snapshot.R ------------------------------------------------
#
# Builds the frozen snapshot of Sokoloff, Reivich, Kennedy, Des Rosiers,
# Patlak, Pettigrew, Sakurada & Shinohara (1977) "The [14C]deoxyglucose
# method for the measurement of local cerebral glucose utilization: theory,
# procedure, and normal values in the conscious and anesthetized albino rat",
# Journal of Neurochemistry 28: 897-916 (doi 10.1111/j.1471-4159.1977.tb10649.x).
#
#   Sokoloff_etal_1977_Table4_snapshot.csv      TABLE 4, J Neurochem 28: 913
#                                                 (PDF page 17)
#
# The source is a scanned 1977 journal page. Its OCR text layer is usable for
# cross-checking words but garbles the ± signs ("f", "k", "&", "rl:") and drops
# digits, so no value was taken from it. The values below are a HAND
# TRANSCRIPTION read from a 300-dpi render of the page (__HOWTO_make_a_snapshot.md
# method 5, the Kennedy_etal_1978 printed-layout-block pattern), checked cell by
# cell against zoomed crops of the render. This script writes the frozen file and
# refuses to overwrite a frozen copy that differs; the build script READS it.
# No cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed row: caption, header tier(s), section headings
#    (Gray matter / White matter), structure rows in printed order, the printed
#    vertical gaps between structure groups as empty rows, footnotes last.
#  * Footnote glyphs are kept as printed ("*" and "†"); "±" is kept; the % Effect
#    minus sign is written as ASCII "-".
#  * A structure label printed on two lines is written with "\\n" at the line
#    break (Table 3: "Hippocampus:\\nammon's horn").
#
# Transcribed and checked by an AI assistant (Claude) on 2026-11-17 from page
# renders; preliminary transcription by the lead agent agreed in every cell.
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

printed_Table4 <- "
TABLE 4. EFFECTS OF THIOPENTAL ANESTHESIA ON LOCAL CEREBRAL GLUCOSE CONSUMPTION IN THE ALBINO RAT*|||
|Local cerebral glucose utilization\\n(µmol/100 g/min)||
Structure|Control (6)†|Anesthetized (8)†|% Effect
Gray matter|||
Visual cortex|111 ± 5|64 ± 3|-42
Auditory cortex|157 ± 5|81 ± 3|-48
Parietal cortex|107 ± 3|65 ± 2|-39
Sensory-motor cortex|118 ± 3|67 ± 2|-43
|||
Lateral geniculate body|92 ± 2|53 ± 3|-42
Medial geniculate body|126 ± 6|63 ± 3|-50
Thalamus: lateral nucleus|108 ± 3|58 ± 2|-46
Thalamus: ventral nucleus|98 ± 3|55 ± 1|-44
Hypothalamus|63 ± 3|43 ± 2|-32
Caudate-putamen|111 ± 4|72 ± 3|-35
Hippocampus: ammon's horn|79 ± 1|56 ± 1|-29
Amygdala|56 ± 4|41 ± 2|-27
|||
Cochlear nucleus|124 ± 7|79 ± 5|-36
Lateral lemniscus|114 ± 7|75 ± 4|-34
Inferior colliculus|198 ± 7|131 ± 8|-34
Superior olivary nucleus|141 ± 5|104 ± 7|-26
Superior colliculus|99 ± 3|59 ± 3|-40
Vestibular nucleus|133 ± 4|81 ± 4|-39
Pontine gray matter|69 ± 3|46 ± 3|-33
|||
Cerebellar cortex|66 ± 2|44 ± 2|-33
Cerebellar nucleus|106 ± 4|75 ± 4|-29
|||
White matter|||
Corpus callosum|42 ± 2|30 ± 2|-29
Genu of corpus callosum|35 ± 5|30 ± 2|-14
Internal capsule|35 ± 2|29 ± 2|-17
Cerebellar white matter|38 ± 2|29 ± 2|-24
* Determined at 30 min following pulse of [14C]deoxyglucose.|||
† The values are the means ± standard errors obtained in the number of animals indicated in brackets. All the differences are statistically significant at the P < 0.05 level.|||
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

grid_T <- to_grid(printed_Table4, 4L)

## Structural guards: 25 structure rows (21 gray + 4 white), all three value columns
## filled on every structure row.
val_rows <- grepl("±", grid_T[, 2])
stopifnot(sum(val_rows) == 25L,
          sum(val_rows[seq_len(which(grid_T[, 1] == "White matter"))]) == 21L,
          all(grepl("±", grid_T[val_rows, 3])), all(grepl("^-[0-9]+$", grid_T[val_rows, 4])))

freeze(grid_T, file.path(folder, paste0(item_name, "_snapshot.csv")))

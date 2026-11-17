# Sokoloff_etal_1977_Table3_snapshot.R ------------------------------------------------
#
# Builds the frozen snapshot of Sokoloff, Reivich, Kennedy, Des Rosiers,
# Patlak, Pettigrew, Sakurada & Shinohara (1977) "The [14C]deoxyglucose
# method for the measurement of local cerebral glucose utilization: theory,
# procedure, and normal values in the conscious and anesthetized albino rat",
# Journal of Neurochemistry 28: 897-916 (doi 10.1111/j.1471-4159.1977.tb10649.x).
#
#   Sokoloff_etal_1977_Table3_snapshot.csv      TABLE 3, J Neurochem 28: 912
#                                                 (PDF page 16)
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

printed_Table3 <- "
TABLE 3. COMPARISON OF VALUES OF LOCAL CEREBRAL GLUCOSE UTILIZATION DETERMINED AT 30 AND 45 min FOLLOWING PULSE OF [14C]DEOXYGLUCOSE IN THE NORMAL CONSCIOUS RAT||
Structure|30 min (10)*\\n(µmol/\\n100 g/min)|45 min (10)*\\n(µmol/\\n100 g/min)
Gray matter||
Visual cortex|113 ± 4|107 ± 6
Auditory cortex|163 ± 4|162 ± 5
Parietal cortex|110 ± 3|112 ± 5
Sensory-motor cortex|124 ± 3|120 ± 5
Olfactory cortex|104 ± 2|98 ± 5
Frontal cortex|112 ± 4|116 ± 5
||
Thalamus: lateral nucleus|110 ± 2|116 ± 5
Thalamus: ventral nucleus|98 ± 2|109 ± 5
Medial geniculate body|130 ± 4|131 ± 5
Lateral geniculate body|94 ± 2|96 ± 5
||
Hypothalamus|61 ± 2|54 ± 2†
Mamillary body|123 ± 4|121 ± 5
Hippocampus:\\nammon's horn|79 ± 1|79 ± 3
Hippocampus:\\ndentate gyrus|70 ± 2|67 ± 3
Amygdala|54 ± 2|52 ± 2
Septal nucleus|62 ± 1|64 ± 3
||
Caudate-putamen|111 ± 2|110 ± 4
Nucleus accumbens|83 ± 3|82 ± 3
Globus-pallidus|58 ± 3|58 ± 2
Substantia nigra|61 ± 2|58 ± 3
Vestibular nucleus|134 ± 3|128 ± 5
Cochlear nucleus|128 ± 5|113 ± 7
Superior olivary nucleus|147 ± 6|133 ± 7
Lateral lemniscus|114 ± 5|104 ± 5
Inferior colliculus|203 ± 6|197 ± 10
Superior colliculus|100 ± 3|95 ± 5
Pontine gray matter|69 ± 2|62 ± 3
||
Cerebellar cortex|63 ± 2|57 ± 2
Cerebellar nucleus|106 ± 3|100 ± 4
White matter||
Corpus callosum|39 ± 2|40 ± 2
Genu of corpus callosum|35 ± 3|34 ± 1
Internal capsule|33 ± 2|33 ± 2
Cerebellar white matter|37 ± 1|37 ± 2
* The values are the means ± standard errors from measurements made in the number of animals indicated in brackets.||
† Statistically significant difference (P < 0.05).||
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

grid_T <- to_grid(printed_Table3, 3L)

## Structural guards: 33 structure rows (29 gray + 4 white; RESULTS p. 912 "33 cerebral
## structures examined"), both value columns filled on every structure row.
val_rows <- grepl("±", grid_T[, 2])
stopifnot(sum(val_rows) == 33L,
          sum(val_rows[seq_len(which(grid_T[, 1] == "White matter"))]) == 29L,
          all(grepl("±", grid_T[val_rows, 3])))

freeze(grid_T, file.path(folder, paste0(item_name, "_snapshot.csv")))

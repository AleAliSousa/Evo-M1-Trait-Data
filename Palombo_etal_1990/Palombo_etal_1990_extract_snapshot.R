# Palombo_etal_1990_extract_snapshot.R ----------------------------------------
#
# Builds the five frozen snapshots of Palombo, Porrino, Bankiewicz, Crane,
# Sokoloff & Kopin (1990) "Local cerebral glucose utilization in monkeys with
# hemiparkinsonism induced by intracarotid infusion of the neurotoxin MPTP",
# The Journal of Neuroscience 10(3): 860-869.
#
#   Palombo_etal_1990_Table1_snapshot.csv   basal ganglia            p. 863
#   Palombo_etal_1990_Table2_snapshot.csv   thalamus                 p. 863
#   Palombo_etal_1990_Table3_snapshot.csv   cerebral hemispheres     p. 864
#   Palombo_etal_1990_Table4_snapshot.csv   forebrain + hypothalamus p. 864
#   Palombo_etal_1990_Table5_snapshot.csv   brain stem + cerebellum  p. 866
#
# 18 + 15 + 14 + 15 + 20 = 82 structure rows, the "82 brain regions" the
# RESULTS text states. Every table has the same four printed arms: Controls
# (n = 4) Right and Left hemisphere, Hemiparkinsonian (n = 4) Lesioned and
# Unlesioned side.
#
# The source is a 1990 scanned journal page. Its OCR text layer was NOT used
# as the source: it misreads 5/7/1 throughout (e.g. "51" for a printed 57 in
# Table 1 "Body of caudate", "31" for a printed 37 in Table 2 "Lateral
# geniculate"). The values below are a HAND TRANSCRIPTION read from 450-dpi
# renders of PDF pages 4, 5 and 7, row by row across all four columns
# (__HOWTO_make_a_snapshot.md method 5, the Mink_etal_1981 printed-layout-
# block pattern). This script writes the frozen files and refuses to
# overwrite a frozen copy that differs; the build scripts READ them.
#
# Fidelity decisions:
#  * One snapshot row per printed row: title, spanning-header row (spanners in
#    their first column with blank padding), column-header row, the structure
#    rows in printed order, then one row per printed footnote line. The tables
#    print no blank or section rows.
#  * Superscript footnote marks are written "^x"; two marks printed together
#    are "^b,c". Spelling kept as printed ("Dentate nculeus", Table 5).
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

## ---- printed blocks: one line per row, cells separated by "|" ----------------
printed <- list()

printed[["Table1"]] <- "
Table 1. Rates of glucose utilization (µmol/100 gm/min) in basal ganglia of MPTP-induced hemiparkinsonian monkeys (mean ± SEM)||||
|Controls (n = 4)||Hemiparkinsonian (n = 4)|
Structure|Right|Left|Lesioned|Unlesioned
Dorsomedial caudate|53 ± 4|53 ± 3|52 ± 5|53 ± 4
Ventral caudate|45 ± 2|45 ± 2|42 ± 2|44 ± 2
Dorsolateral caudate|49 ± 2|49 ± 2|57 ± 5^a|52 ± 3
Body of caudate|57 ± 3|56 ± 3|57 ± 5|53 ± 5
Tail of caudate|52 ± 4|52 ± 4|47 ± 2|48 ± 3
Anterior dorsal putamen|50 ± 4|50 ± 4|62 ± 6|56 ± 4
Anterior ventral putamen|49 ± 3|50 ± 4|57 ± 4|52 ± 3
Posterior dorsal putamen|51 ± 4|51 ± 5|63 ± 5^b|53 ± 4
Posterior ventral putamen|56 ± 4|55 ± 5|63 ± 6^a|54 ± 4
Globus pallidus internal|29 ± 1|28 ± 2|30 ± 2|28 ± 2
Globus pallidus external|24 ± 2|25 ± 2|38 ± 4^b,c|27 ± 2
Subthalamic nucleus|57 ± 5|58 ± 5|48 ± 2^a|58 ± 5
Claustrum|30 ± 1|32 ± 2|25 ± 2|26 ± 2
Substantia nigra pars compacta|43 ± 1|43 ± 1|30 ± 1^b,d|39 ± 1
Substantia nigra pars reticulata|30 ± 2|31 ± 1|28 ± 3|29 ± 2
Ventral tegmental area|37 ± 1|36 ± 1|31 ± 1^a,c|32 ± 1
Nucleus paranigralis|45 ± 1|45 ± 1|41 ± 1^b|43 ± 2
Nucleus parabrachialis pigmentosus|40 ± 1|41 ± 1|33 ± 2^c|34 ± 1^e
^a p < 0.05 and ^b p < 0.01 side-to-side comparisons (Bonferroni t test following 2-way ANOVA).||||
^c p < 0.05 and ^d p < 0.01 lesioned side vs corresponding side of control (Bonferroni t test following 2-way ANOVA).||||
^e p < 0.05 unlesioned side vs corresponding side of control (Bonferroni t test following 2-way ANOVA).||||
"

printed[["Table2"]] <- "
Table 2. Rates of glucose utilization (µmol/100 gm/min) in thalamus of MPTP-induced hemiparkinsonian monkeys (mean ± SEM)||||
|Controls (n = 4)||Hemiparkinsonian (n = 4)|
Structure|Right|Left|Lesioned|Unlesioned
Ventral anterior|38 ± 2|38 ± 1|40 ± 2^a,b|39 ± 2
Ventral lateral|42 ± 1|41 ± 0|41 ± 2|41 ± 2
Anterior ventral|57 ± 3|57 ± 3|58 ± 3|58 ± 3
Anterior medial|54 ± 2|53 ± 2|50 ± 1|52 ± 1
Centromedian nucleus|38 ± 2|39 ± 2|41 ± 1|41 ± 1
Parafascicular nucleus|51 ± 3|50 ± 3|52 ± 1^a,b|50 ± 1
Mediodorsal magnocellularis|56 ± 4|55 ± 4|55 ± 1|55 ± 1
Mediodorsal parvicellularis|55 ± 2|56 ± 1|54 ± 2|55 ± 1
Mediodorsal paralamellaris|57 ± 2|57 ± 2|56 ± 1|60 ± 2
Lateral geniculate|37 ± 3|38 ± 3|36 ± 2|37 ± 2
Reticular nucleus|24 ± 1|24 ± 1|24 ± 2|25 ± 2
Ventral posterolateral|36 ± 2|36 ± 1|35 ± 2|36 ± 2
Medial habenula|32 ± 3|31 ± 2|30 ± 4|30 ± 3
Lateral habenula|50 ± 5|49 ± 4|54 ± 3|51 ± 4
Optic tract|19 ± 1|20 ± 2|22 ± 2|22 ± 3
^a p < 0.05 side-to-side comparisons (Bonferroni t test following 2-way ANOVA).||||
^b Although statistically significant, the 2 sides differ by less than 5%.||||
"

printed[["Table3"]] <- "
Table 3. Rates of glucose utilization (µmol/100 gm/min) in cerebral hemispheres of MPTP-induced hemiparkinsonian monkeys (mean ± SEM)||||
|Controls (n = 4)||Hemiparkinsonian (n = 4)|
Structure|Right|Left|Lesioned|Unlesioned
Orbitofrontal cortex|52 ± 5|52 ± 4|53 ± 2|55 ± 3
Dorsolateral prefrontal cortex|55 ± 5|54 ± 4|55 ± 4|57 ± 4
Anterior cingulate|39 ± 2|41 ± 2|39 ± 0|40 ± 1
Frontal eye fields|57 ± 2|58 ± 2|52 ± 2|54 ± 2
Motor cortex|46 ± 2|47 ± 2|42 ± 2|43 ± 2
Premotor cortex|45 ± 2|45 ± 1|43 ± 1^a,b|46 ± 1
Striate cortex|73 ± 3|73 ± 2|72 ± 8|74 ± 6
Prestriate cortex|59 ± 1|57 ± 1|59 ± 8|58 ± 5
Entorhinal cortex|39 ± 1|39 ± 1|40 ± 2|39 ± 2
Retrosplenial cortex|45 ± 1|45 ± 3|44 ± 1|43 ± 2
Dentate gyrus|28 ± 1|27 ± 2|29 ± 2|29 ± 2
Hippocampus|32 ± 1|33 ± 1|33 ± 2|33 ± 2
Corpus callosum|11 ± 0|10 ± 1|10 ± 1|10 ± 1
Internal capsule|11 ± 2|11 ± 1|12 ± 1|12 ± 1
^a p < 0.05 side-to-side comparisons (Bonferroni t test following 2-way ANOVA).||||
^b Although statistically significant, the 2 sides differ by less than 5%.||||
"

printed[["Table4"]] <- "
Table 4. Rates of glucose utilization (µmol/100 gm/min) in forebrain and hypothalamus of MPTP-induced hemiparkinsonian monkeys (mean ± SEM)||||
|Controls (n = 4)||Hemiparkinsonian (n = 4)|
Structure|Right|Left|Lesioned|Unlesioned
Nucleus accumbens|36 ± 2|37 ± 2|34 ± 1|35 ± 2
Olfactory tubercle|32 ± 2|33 ± 2|37 ± 1|37 ± 1
Lateral septum|27 ± 1|27 ± 1|25 ± 2|25 ± 2
Bed nucleus stria terminalis|23 ± 0|23 ± 1|22 ± 1|22 ± 1
Basolateral amygdala|40 ± 1|41 ± 2|36 ± 3|37 ± 3
Lateral amygdala|36 ± 2|36 ± 2|33 ± 2|35 ± 2
Paraventricular hypothalamus|32 ± 2|31 ± 1|30 ± 1|31 ± 1
Lateral hypothalamus|28 ± 1|27 ± 2|26 ± 1|26 ± 1
Substantia innominata|21 ± 2|22 ± 1|20 ± 1|21 ± 2
Mammillary body medialis|68 ± 6|68 ± 6|67 ± 4|69 ± 4
Mammillary body intermediate|56 ± 7|56 ± 6|59 ± 2|59 ± 2
Mammillary body lateralis|48 ± 6|47 ± 6|47 ± 3|47 ± 3
Median eminence|46 ± 7|46 ± 7|41 ± 4|41 ± 4
Anterior commissure|11 ± 1|11 ± 1|11 ± 1|10 ± 1
Anterior white matter|12 ± 1|13 ± 2|11 ± 1|11 ± 1
"

printed[["Table5"]] <- "
Table 5. Rates of glucose utilization (µmol/100 gm/min) in brain stem and cerebellum of MPTP-induced hemiparkinsonian monkeys (mean ± SEM)||||
|Controls (n = 4)||Hemiparkinsonian (n = 4)|
Structure|Right|Left|Lesioned|Unlesioned
Superior colliculus external|68 ± 9|69 ± 7|68 ± 8|66 ± 8
Superior colliculus internal|56 ± 4|54 ± 2|48 ± 5|48 ± 6
Inferior colliculus|130 ± 5|131 ± 4|124 ± 3|121 ± 6
Red nucleus|44 ± 3|44 ± 3|45 ± 1|47 ± 2
Interpeduncular nucleus|45 ± 2|45 ± 2|41 ± 1|41 ± 1
Pedunculopontine nucleus|39 ± 1|39 ± 1|46 ± 2^a|40 ± 1
Locus coeruleus|37 ± 2|39 ± 1|37 ± 2|37 ± 2
Dorsal raphe|37 ± 3|37 ± 3|35 ± 1|35 ± 1
Parabrachialis medialis nucleus|24 ± 0|24 ± 1|22 ± 0|21 ± 1
Parabrachialis lateralis nucleus|24 ± 1|24 ± 1|22 ± 1|23 ± 1
Inferior olive dorsal lamella|49 ± 3|50 ± 3|48 ± 1|48 ± 1
Inferior olive ventral lamella|48 ± 3|49 ± 2|47 ± 1|47 ± 1
Motor dorsal nucleus vagus|35 ± 1|34 ± 1|32 ± 1|31 ± 1
Pyramids|10 ± 1|10 ± 1|8 ± 1|7 ± 1
Cerebellar cortex|34 ± 3|35 ± 2|32 ± 1|33 ± 1
Uvula|61 ± 5|59 ± 5|59 ± 1|59 ± 0
Dentate nculeus|57 ± 3|56 ± 3|53 ± 2|54 ± 2
Interpositus nucleus|52 ± 2|50 ± 2|47 ± 1|46 ± 2
Fastigial nucleus|46 ± 2|45 ± 3|41 ± 1|40 ± 1
Cerebellar white matter|14 ± 1|14 ± 1|14 ± 0|14 ± 1
^a p < 0.01 side-to-side comparisons (Bonferroni t test following 2-way ANOVA).||||
"

n_structures <- c(Table1 = 18L, Table2 = 15L, Table3 = 14L, Table4 = 15L, Table5 = 20L)
n_footnotes  <- c(Table1 = 3L,  Table2 = 2L,  Table3 = 2L,  Table4 = 0L,  Table5 = 1L)

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
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
  grid <- to_grid(printed[[locus]], 5L)
  ## guards: 3 header rows + structures + footnotes; every structure row has 4 "±" cells
  stopifnot(nrow(grid) == 3L + n_structures[[locus]] + n_footnotes[[locus]],
            identical(grid[3, ], c("Structure", "Right", "Left", "Lesioned", "Unlesioned")))
  body <- grid[3L + seq_len(n_structures[[locus]]), 2:5, drop = FALSE]
  stopifnot(all(grepl("^[0-9]+ ± [0-9]+(\\^[a-e](,[a-e])?)?$", body)))
  freeze(grid, file.path(folder, paste0(paper, "_", locus, "_snapshot.csv")))
}
stopifnot(sum(n_structures) == 82L)

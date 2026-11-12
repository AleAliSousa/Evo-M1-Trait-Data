# Palombo_etal_1990_Table5_snapshot.R ---------------------------------------
#
# Builds the frozen snapshot (Table5 only) of Palombo, Porrino, Bankiewicz, Crane,
# Sokoloff & Kopin (1990) "Local cerebral glucose utilization in monkeys with
# hemiparkinsonism induced by intracarotid infusion of the neurotoxin MPTP",
# The Journal of Neuroscience 10(3): 860-869.
#
#   Palombo_etal_1990_Table5_snapshot.csv   brain stem + cerebellum  p. 866
#
# (The five tables together hold 18 + 15 + 14 + 15 + 20 = 82 structure rows, the "82 brain regions"
# the RESULTS text states.) Every table has the same four printed arms: Controls
# (n = 4) Right and Left hemisphere, Hemiparkinsonian (n = 4) Lesioned and
# Unlesioned side.
#
# The source is a 1990 scanned journal page. Its OCR text layer was NOT used
# as the source: it misreads 5/7/1 throughout (e.g. "51" for a printed 57 in
# Table 1 "Body of caudate", "31" for a printed 37 in Table 2 "Lateral
# geniculate"). The values below are a HAND TRANSCRIPTION read from 450-dpi
# renders of PDF pages 4, 5 and 7, row by row across all four columns
# (__HOWTO_make_a_snapshot.md method 5, the Mink_etal_1981 printed-layout-
# block pattern). This script writes the frozen file and refuses to
# overwrite a frozen copy that differs; the build script READS it.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Palombo_etal_1990_Table5

## ---- printed blocks: one line per row, cells separated by "|" ----------------
printed <- list()

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
  freeze(grid, file.path(folder, paste0(item_name, "_snapshot.csv")))
}

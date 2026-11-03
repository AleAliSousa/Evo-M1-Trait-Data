# Meguro_etal_1999_extract_snapshot.R -----------------------------------------
#
# Builds the frozen snapshot of Meguro, Blaizot, Kondoh, Le Mestric, Baron &
# Chavoix (1999) "Neocortical and hippocampal glucose hypometabolism following
# neurotoxic lesions of the entorhinal and perirhinal cortices in the non-human
# primate as shown by PET", Brain 122: 1519-1531.
#
#   Meguro_etal_1999_Table2_snapshot.csv   Table 2, p. 1525 (PDF page 7):
#       19 regions x 2 groups (RH rhinal-lesioned, SH sham; n = 3 each,
#       "analysis II") x 4 time points (Baseline = pre-surgery, Day 30, 45, 80),
#       mean (SD), mg/100 g/min, plus the printed ANOVA / post hoc columns.
#
# Table 1 (p. 1524) scores lesion damage and carries no metabolic value; it is
# not built. "Analysis I" (all 8 baboons, baseline and day 30) is shown only in
# figures and is not digitised.
#
# The PDF is typeset with a text layer, but the table interleaves cells line by
# line and its symbol font mis-encodes "=" as "5" and "x" as "3", so the block
# below is a HAND TRANSCRIPTION read from 280-dpi renders of PDF page 7 by an AI
# assistant (Claude) on 2026-11-02 (__HOWTO_make_a_snapshot.md method 5). The
# text layer was read afterwards as a second reading and agrees on all 152
# mean (SD) cells. This script writes the frozen file and refuses to overwrite
# a frozen copy that differs; the build READS it.
#
# Fidelity decisions:
#  * One snapshot row per printed row: each region prints on two lines (RH, then
#    SH); the region name and the ANOVA / post hoc cells sit on the RH line.
#  * Kept as printed: the second post hoc header "Day 4" (sic; Day 45/80 is
#    presumably meant), "11.8 (4.)" (Anterior cingulate, SH, Day 30), the single
#    dagger on 0.003 (Associative occipital, Day 4), dashes "–".
#  * Superscripts written "^x".
#  * 2026-11-02: a first freeze declared 10 columns for this 9-column table (a
#    spurious empty 10th column, no value affected); it was moved to archive/
#    before any comparison and the table re-frozen with 9 columns.
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
printed_Table2 <- "
Table 2 Regional CMRglc values in the 19 brain regions in each group (n = 3 per group; analysis II, see Results) at the four time points, and corresponding statistical findings||||||||
Region|Group|Baseline\\nmean (SD)|Day 30\\nmean (SD)|Day 45\\nmean (SD)|Day 80\\nmean (SD)|ANOVA^*|Post hoc t tests^†|
|||||||Day 30|Day 4
Dorsolateral prefrontal|RH|8.4 (1.2)|7.6 (0.5)|7.0 (0.9)|7.2 (0.9)|n.s.|–|–
|SH|9.2 (2.6)|11.0 (3.1)|10.1 (2.8)|9.8 (1.3)|||
Orbitolateral prefrontal|RH|9.1 (0.8)|7.2 (0.9)|6.9 (1.1)|7.6 (1.1)|n.s.|–|–
|SH|9.6 (2.6)|10.9 (3.1)|9.8 (3.4)|9.3 (1.3)|||
Sensorimotor|RH|8.1 (1.3)|6.7 (1.0)|6.8 (0.8)|7.0 (1.0)|Group (P = 0.04)|0.01^‡|0.04
|SH|8.8 (1.4)|9.9 (1.3)|9.2 (2.0)|9.8 (1.3)|||
Inferior parietal|RH|7.4 (1.1)|6.1 (0.9)|5.6 (0.7)|6.3 (0.2)|Group (P = 0.03)|0.01^‡|n.s.
|SH|8.4 (1.8)|9.4 (2.2)|8.0 (2.2)|8.2 (0.5)|||
Anterior temporal|RH|7.4 (0.7)|5.5 (1.4)|5.3 (0.9)|5.5 (0.8)|n.s.|–|–
|SH|8.3 (2.7)|7.4 (2.1)|7.0 (1.2)|7.5 (2.1)|||
Posterior temporal|RH|6.9 (1.2)|5.1 (1.6)|4.6 (0.9)|5.1 (0.3)|Group (P = 0.03)|0.01^‡|n.s.
|SH|8.7 (2.3)|8.3 (1.6)|7.5 (1.2)|7.9 (1.1)|||
Associative occipital|RH|6.2 (0.9)|5.5 (1.3)|4.6 (1.0)|4.9 (0.5)|Group (P = 0.01)|0.003^‡|0.003^†
|SH|7.1 (1.0)|8.6 (1.6)|7.8 (0.3)|8.4 (1.5)|||
Primary occipital|RH|4.7 (1.1)|3.6 (0.4)|3.5 (0.3)|3.5 (0.4)|n.s.|–|–
|SH|4.7 (0.7)|5.5 (1.8)|5.1 (0.4)|5.4 (0.9)|||
Anterior cingulate|RH|10.2 (0.8)|8.1 (1.2)|8.3 (1.0)|9.1 (0.4)|n.s.|–|–
|SH|10.1 (3.3)|11.8 (4.)|11.1 (3.6)|9.9 (2.1)|||
Posterior cingulate|RH|7.6 (0.5)|7.0 (0.3)|5.8 (0.7)|6.4 (0.4)|Group (P = 0.04)|0.01^‡|0.02
|SH|7.6 (0.9)|10.3 (3.0)|8.7 (1.9)|8.2 (0.6)|||
Insula|RH|10.0 (1.2)|7.5 (1.9)|6.9 (0.8)|7.5 (1.1)|n.s.|–|–
|SH|9.7 (1.5)|10.1 (2.4)|9.4 (3.0)|10.1 (1.7)|||
Anterior hippocampal|RH|5.1 (0.5)|4.1 (0.8)|4.0 (1.4)|3.6 (0.7)|n.s.|–|–
|SH|5.6 (1.2)|6.2 (1.7)|5.6 (0.9)|5.6 (1.1)|||
Posterior hippocampal|RH|5.6 (0.9)|3.9 (0.2)|4.0 (0.3)|4.2 (0.5)|Group (P = 0.04)|0.005^‡|n.s.
|SH|5.9 (1.3)|6.1 (1.3)|5.4 (0.5)|5.2 (0.8)|||
Basal forebrain|RH|6.6 (0.7)|6.3 (0.4)|6.3 (1.5)|6.3 (1.5)|n.s.|–|–
|SH|6.3 (2.2)|7.3 (1.9)|5.7 (0.9)|6.2 (1.0)|||
Anterior caudate (head)|RH|9.6 (1.5)|9.0 (1.1)|8.0 (0.4)|8.4 (0.9)|n.s.|–|–
|SH|7.4 (1.4)|9.5 (2.2)|8.6 (2.3)|8.5 (1.9)|||
Posterior caudate (head)|RH|7.6 (0.4)|6.2 (0.6)|5.9 (1.4)|6.0 (1.4)|Group × Time (P = 0.04)|0.01|0.03
|SH|7.3 (1.3)|8.8 (1.5)|8.2 (1.0)|8.0 (1.2)|||
Putamen|RH|9.8 (1.2)|8.0 (1.9)|7.9 (1.4)|7.9 (1.7)|Group × Time (P = 0.03)|0.02|n.s.
|SH|9.9 (0.6)|12.2 (2.6)|11.0 (3.0)|11.8 (1.9)|||
Thalamus|RH|6.6 (0.4)|5.7 (0.6)|5.0 (1.2)|5.2 (0.8)|Group (P = 0.01)|0.001^§|0.003^‡
|SH|9.2 (2.9)|10.6 (1.9)|9.3 (0.7)|9.7 (1.4)|||
Cerebellar lobe|RH|6.9 (1.5)|6.1 (0.2)|5.8 (0.5)|6.1 (0.3)|n.s.|–|–
|SH|5.8 (0.9)|7.2 (1.4)|6.6 (0.1)|6.9 (0.8)|||
CMR values are given as mean (standard deviation). RH = rhinal group; SH = sham-operated group; n.s. = not significant. ^*Two-way ANOVA with time as repeated measure; ^†performed only if ANOVA was significant; ^‡,^§still significant after Bonferroni correction (P < 0.05 and 0.01, respectively).||||||||
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

grid <- to_grid(printed_Table2, 9L)
stopifnot(nrow(grid) == 3L + 38L + 1L, sum(nzchar(grid[4:41, 1])) == 19L,
          all(grid[4:41, 2] == rep(c("RH", "SH"), 19L)),
          all(grepl("^[0-9.]+ \\([0-9.]+\\)$", grid[4:41, 3:6])))
freeze(grid, file.path(folder, paste0(paper, "_Table2_snapshot.csv")))

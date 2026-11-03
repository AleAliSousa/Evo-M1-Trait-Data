# Holliday__1971_extract_snapshot.R -----------------------------------------------
#
# Builds the frozen snapshot of Holliday, M. A. (1971), "Metabolic rate and organ size
# during growth from infancy to maturity and during late gestation and early infancy",
# Pediatrics 47(1) Suppl. 2 (Symposium on Growth and Development): 169-179.
#
#   Holliday__1971_TABLEI_snapshot.csv     TABLE I, p. 170 (PDF page 2)
#
# Table II (height/weight/sum of organ weight/BMR by age) is not built: it carries no
# organ metabolic rate.
#
# The PDF is a poor scan of a bound volume (garbled OCR layer; footnote marks lost). The
# block below is a HAND TRANSCRIPTION read from 170/330-dpi renders of PDF page 2 by an
# AI assistant (Claude) on 2026-11-03 (__HOWTO_make_a_snapshot.md method 5), checked
# against the earlier working transcription (classic_human_brain_partition.csv): the
# brain row (4.2, 296, 1.40, 414, 23.3) and total BMR 1,780 agree. This script writes
# the frozen file and refuses to overwrite a differing frozen copy; the build READS it.
#
# Fidelity: row numbers "1)" ... "5)", footnote marks as ^n (Brain^6 Liver^7 Heart^8
# Kidney^9 Muscle^4), "*" and the dagger kept, em-dashes kept, thousands commas kept
# ("1,177"), the two footnotes kept as rows. The kidney "% BMR" 7.1 is kept as printed
# although 116/1,780 = 6.5% (see README / errata). The Muscle superscript is small and
# blurred in the scan; "4" is the only reference that fits (Andres et al. 1956, skeletal
# muscle).
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

printed_TABLEI <- "
TABLE I||||||
VO2, ORGAN METABOLIC RATE (OMR/KILOGRAM BODY WEIGHT), METABOLIC RATE AND PERCENT BMR DERIVED FROM EACH ORGAN SYSTEM IN ADULT MAN||||||
||Organ|||
Organ|VO2\\n(ml/minute\\n/100 gm)|Metabolic\\nRate\\n(kcal/kg\\nOW/day)|Weight\\n(kg)|OMR\\n(kcal/day)|% BMR
1) Brain^6|4.2|296|1.40|414|23.3
2) Liver^7|4.1|290|1.60|464|26.1
3) Heart^8|8.6|606|0.30|182|10.2
4) Kidney^9|5.5|388|0.30|116|7.1
Total 1–4|—|327*|3.60†|1,177|66.7
5) Muscle^4|0.26|17.6|28.3|500|28.1
Total 1–5|—|—|—|1,677|94.2
70 kg man|—|25.5|—|1,780|100.0
* OMR/kg OW derived from total kilocalorie/day of 4 organ systems, 1,177 ÷ total weight (ΣOW) for the 4 systems = 3.60 kg.|||||
† Metabolic rate (kilocalorie/kg OW/day) = VO2 (milliliter/minute/100 gm) × 10 × 1,440 minute/day ÷ 1,000 × 4.9 kcal/liter oxygen (assuming an R.Q. of 0.9).^10|||||
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

grid_T1 <- to_grid(printed_TABLEI, 6L)
stopifnot(nrow(grid_T1) == 2L + 2L + 8L + 2L)
freeze(grid_T1, file.path(folder, paste0(paper, "_TABLEI_snapshot.csv")))

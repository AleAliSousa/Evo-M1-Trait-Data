# Aschoff__1971_Tabelle1_snapshot.R -------------------------------------------
#
# Builds the frozen snapshot of Aschoff, J. (1971), "Temperaturregulation" section of
# Aschoff, Guenther & Kramer, "Energiehaushalt und Temperaturregulation", in Gauer,
# Kramer & Jung (eds), Physiologie des Menschen, Band 2, Urban & Schwarzenberg,
# Muenchen-Berlin-Wien (scanned excerpt, 12 PDF pages; book pp. 43-69).
#
#   Aschoff__1971_Tabelle1_snapshot.csv   Tabelle 1, p. 44 (PDF page 2)
#
# The scan has a poor OCR layer (decimal commas and thousands points survive in
# Tabelle 1, but Abb. 1 is a figure). The blocks below are a HAND TRANSCRIPTION read
# from 170/300-dpi renders of PDF page 2 by an AI assistant (Claude) on 2026-11-03
# (__HOWTO_make_a_snapshot.md method 5). The text layer of Tabelle 1 was read
# afterwards as an independent second reading and agrees on all 42 value cells.
# This script writes only the frozen file named above and refuses to overwrite a differing frozen copy;
# the build scripts READ it.
#
# Fidelity: German decimal commas ("3,20") and thousands points ("27.000") kept as
# printed; row label "Splanchnikus-\ngebiet" kept as a two-line cell; header tiers
# kept with blank padding under spanners. Printed arithmetic is NOT corrected here.
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

printed_Tabelle1 <- "
Tabelle 1. Sauerstoffaufnahme bzw. Wärmebildung der Organe im ruhenden Körper. (65 kg Gewicht, 270 cm³/min Sauerstoffaufnahme).|||||
|Gewicht\\nin g|Sauerstoffaufnahme||Wärmebildung|
||ml|ml|cal|cal
||100 g · min|Organ · min|100 g · min|Organ · min
Haut|5.000|0,10|5,0|0,48|24
Muskel|27.000|0,16|43,0|0,75|203
Gehirn|1.350|3,20|43,0|15,40|208
Lunge|600|2,00|12,0|9,50|57
Herz|290|10,00|29,0|48,00|139
Nieren|290|7,00|20,3|34,50|100
Splanchnikus-\\ngebiet|2.500|3,60|90,0|17,40|435
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

grid_T1 <- to_grid(printed_Tabelle1, 6L)

## Structural guards: 4 header rows + 7 data rows.
stopifnot(nrow(grid_T1) == 4L + 7L, sum(nzchar(grid_T1[5:11, 2])) == 7L)

freeze(grid_T1, file.path(folder, paste0(paper, "_Tabelle1_snapshot.csv")))

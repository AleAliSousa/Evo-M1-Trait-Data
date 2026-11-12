# Bouilleret_etal_2000_Text_snapshot.R: split from Bouilleret_etal_2000_extract_snapshot.R (one script per output); writes only Bouilleret_etal_2000_Text_snapshot.*
# Bouilleret_etal_2000_Text_snapshot.R -------------------------------------
#
# Builds the two frozen snapshots of Bouilleret, Boyet, Marescaux & Nehlig
# (2000) "Mapping of the progressive metabolic changes occurring during the
# development of hippocampal sclerosis in a model of mesial temporal lobe
# epilepsy", Brain Research 852: 255-262.
#
#   Bouilleret_etal_2000_Table2_snapshot.csv          Table 2 "Effects of
#                                                     intrahippocampal kainate on
#                                                     LCMRglcs of adult mice",
#                                                     pp. 258-259 (PDF pages 4-5)
#   Bouilleret_etal_2000_Text_snapshot.csv  dentate-gyrus values printed
#                                                     only in RESULTS 3.3, p. 259
#
# Table 1 (p. 257, physiological variables) carries no metabolic value and is
# not built.
#
# METHOD: the PDF is typeset (born-digital) with a usable text layer, so the
# values are pulled from it at run time with pdftools (the
# Jacob_etal_2021_extract_snapshot.R pattern; no table value is typed in this
# script). The publisher's symbol font is mis-encoded in the text layer and is
# decoded with a fixed, documented map:
#     '"'                -> '±'        (plus-minus)
#     trailing 'U' / 'UU' -> '*' / '**' (significance marks)
#     'Ž n s 4.'          -> '(n = 4)'  ('Ž' = '(', ' s ' = ' = ', '.' = ')')
#     'p - 0.05'          -> 'p < 0.05'
#     'mmolr100 grmin'    -> 'µmol/100 g/min'
# Every decoded cell was then checked against 330-dpi renders of PDF pages 4-5
# by an AI assistant (Claude) on 2026-11-02, reading each row across all five
# columns: all 48 rows x 5 cells and every significance mark agree.
#
# Fidelity decisions:
#  * One snapshot row per printed row: caption lines, the two-tier header
#    (Control spanning one column; "KA" spanning the four Day columns, in its
#    first column with blank padding), section headings, a blank row for each
#    printed vertical gap, the structure rows in printed order, the
#    "Table 2 (continued)" header repeated on p. 259, and the two footnote lines.
#  * A structure printed on two lines ("Substantia nigra pars / reticulata,
#    right") is one cell holding a real newline.
#  * "destroyed" cells are kept as printed.
#
# This script refuses to overwrite a frozen copy that differs.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)

suppressPackageStartupMessages(library(pdftools))

pdf_file <- list.files(folder, pattern = "^Bouilleret-2000-.*\\.pdf$", full.names = TRUE)
stopifnot(length(pdf_file) == 1L)
## ---- data from text: RESULTS 3.3, p. 259, left column ------------------------
words <- pdf_data(pdf_file)[[5]]
left  <- words[words$x < 297 & words$y > 180 & words$y < 420, ]
left  <- left[order(left$y, left$x), ]
para  <- paste(left$text, collapse = " ")
## In this layer the parenthesis glyphs are separate, mis-positioned tokens
## ("Ž ." pairs drifting away from the words they enclose), so they cannot be
## put back where printed: they are DROPPED from the quoted passage, and the
## README says so. No digit is affected.
para  <- gsub("\\s*\u017d\\s*\\.", "", para)
para  <- gsub("mmolr100 grmin", "µmol/100 g/min", para, fixed = TRUE)
para  <- gsub("\\s+([.,])", "\\1", para)
s_dg <- regmatches(para, regexpr("Finally, at all times after kainate injection, a normo-.*?in the dentate gyrus Fig\\. 1\\.", para))
s_lh <- regmatches(para, regexpr("The lowest level of glucose utilization recorded was [0-9]+ µmol/100 g/min, the highest one [0-9]+ µmol/100 g/min compared to [0-9]+ µmol/100 g/min in control mice\\.", para))
stopifnot(length(s_dg) == 1L, length(s_lh) == 1L)
v <- regmatches(s_lh, gregexpr("[0-9]+(?= µmol)", s_lh, perl = TRUE))[[1]]
stopifnot(length(v) == 3L)

grid_tx <- rbind(
  c("text_row", "page", "location", "passage_as_printed", "value_printed", "units_printed",
    "subjects_as_printed", "state_as_printed", "region_as_printed", "context_as_printed"),
  c("1", "259", "RESULTS 3.3, left column", s_lh, v[1], "µmol/100 g/min",
    "[kainate-treated mice; lowest single value]", "at all times after kainate injection", "dentate gyrus", s_dg),
  c("2", "259", "RESULTS 3.3, left column", s_lh, v[2], "µmol/100 g/min",
    "[kainate-treated mice; highest single value]", "at all times after kainate injection", "dentate gyrus", s_dg),
  c("3", "259", "RESULTS 3.3, left column", s_lh, v[3], "µmol/100 g/min",
    "control mice", "control", "dentate gyrus", s_dg)
)
dimnames(grid_tx) <- NULL

freeze <- function(grid, file) {
  if (file.exists(file)) {
    old <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                              na.strings = character(0), check.names = FALSE,
                              encoding = "UTF-8"))
    dimnames(old) <- NULL
    new <- grid; dimnames(new) <- NULL
    if (!identical(dim(old), dim(new)) || !identical(old, new))
      stop(basename(file), ": the frozen snapshot on disk differs from what this script ",
           "extracts. Refusing to overwrite. Reconcile the difference against the PDF and ",
           "move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
  }
}

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))

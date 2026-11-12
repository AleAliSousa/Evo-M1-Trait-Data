# Bouilleret_etal_2000_Table2_snapshot.R: split from Bouilleret_etal_2000_extract_snapshot.R (one script per output); writes only Bouilleret_etal_2000_Table2_snapshot.*
# Bouilleret_etal_2000_Table2_snapshot.R -------------------------------------
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
pages <- pdf_text(pdf_file)
stopifnot(length(pages) == 8L)

decode_cell <- function(x) {
  x <- trimws(x)
  x <- sub("^([0-9]+) \" ([0-9]+)UU$", "\\1 ± \\2**", x)
  x <- sub("^([0-9]+) \" ([0-9]+)U$",  "\\1 ± \\2*",  x)
  x <- sub("^([0-9]+) \" ([0-9]+)$",   "\\1 ± \\2",   x)
  x
}
decode_n <- function(x) gsub("\u017d n s ([0-9]+)\\.", "(n = \\1)", x)

cell_re <- "[0-9]+ \" [0-9]+U{0,2}|destroyed"
sections <- c("Cerebral cortex", "Forebrain", "Hypothalamus", "Thalamus",
              "Midbrain\u2013brainstem", "White matter")

## ---- table body lines from one page -----------------------------------------
parse_body <- function(lines) {
  out <- list(); pending <- NULL
  for (ln in lines) {
    s <- sub("\\s+$", "", ln)
    if (!nzchar(trimws(s))) { out[[length(out) + 1L]] <- c("", rep("", 5)); next }
    if (trimws(s) %in% sections) { out[[length(out) + 1L]] <- c(trimws(s), rep("", 5)); next }
    cells <- regmatches(s, gregexpr(cell_re, s))[[1]]
    if (length(cells) == 5L) {
      name <- trimws(sub(paste0("\\s{2,}(", cell_re, ").*$"), "", s))
      out[[length(out) + 1L]] <- c(name, decode_cell(cells))
      pending <- length(out)
    } else if (length(cells) == 0L && !is.null(pending) &&
               grepl("pars$", out[[pending]][1])) {
      out[[pending]][1] <- paste0(out[[pending]][1], "\n", trimws(s))   # 2nd printed line of the name
      pending <- NULL
    } else stop("unparsed table line: ", s, call. = FALSE)
  }
  do.call(rbind, out)
}

p4 <- strsplit(pages[4], "\n", fixed = TRUE)[[1]]
p5 <- strsplit(pages[5], "\n", fixed = TRUE)[[1]]

## anchored printed literals (fail loudly if the layer ever reads differently)
i_cap  <- which(trimws(p4) == "Effects of intrahippocampal kainate on LCMRglcs of adult mice")
i_ctl  <- grep("^\\s*Control \u017d n s 4\\.\\s+KA\\s*$", p4)
i_days <- grep("^\\s*Day 0\\s+Day 15\\s+Day 30\\s+Day 120\\s*$", p4)
i_ns   <- grep("^\\s*(\u017d n s [0-9]\\.\\s*){4}$", p4)
i_cc   <- which(trimws(p4) == "Cerebral cortex")
i_end4 <- grep("^\\s*compacta, left\\s*$", p4) + 2L                 # Superior colliculus, left
stopifnot(length(i_cap) == 1L, length(i_ctl) == 1L, length(i_days) == 1L,
          length(i_ns) == 1L, length(i_cc) == 1L, length(i_end4) == 1L)
body4 <- parse_body(p4[i_cc:i_end4])

ns <- regmatches(p4[i_ns], gregexpr("\u017d n s [0-9]\\.", p4[i_ns]))[[1]]
hdr_days <- paste0(c("Day 0", "Day 15", "Day 30", "Day 120"), "\n", decode_n(ns))
hdr1 <- c("", decode_n("Control \u017d n s 4."), "KA", "", "", "")
hdr2 <- c("", "", hdr_days)

j_cont <- grep("^\\s*Table 2 \u017dcontinued\\.\\s*$", p5)
j_wm   <- which(trimws(p5) == "White matter")
j_last <- grep("^\\s*Genu of the corpus callosum, left", p5)
j_fn1  <- grep("statistically significant differences from control group\\.", p5)
j_fn2  <- grep("^\\s*Rates of cerebral glucose utilization, expressed as", p5)
stopifnot(length(j_cont) == 1L, length(j_wm) == 1L, length(j_last) == 1L,
          length(j_fn1) == 1L, length(j_fn2) == 1L)
body5 <- parse_body(p5[j_wm:j_last])

fn1 <- sub("^\\s*p - 0\\.05, p - 0\\.01,", "* p < 0.05, ** p < 0.01,", p5[j_fn1])
fn2 <- sub("mmolr100 grmin", "µmol/100 g/min", trimws(p5[j_fn2]), fixed = TRUE)
fn2 <- sub("means\" S.D.", "means ± S.D.", fn2, fixed = TRUE)
stopifnot(grepl("^\\* p < 0\\.05, \\*\\* p < 0\\.01, statistically", fn1),
          grepl("µmol/100 g/min, represent means ± S.D.$", fn2))

blank <- rep("", 6)
grid <- rbind(
  c("Table 2", rep("", 5)),
  c(trimws(p4[i_cap]), rep("", 5)),
  hdr1, hdr2,
  body4,
  c("Table 2 (continued)", rep("", 5)),
  hdr1, hdr2,
  body5,
  c(fn1, rep("", 5)),
  c(fn2, rep("", 5))
)
dimnames(grid) <- NULL

## structural guards: 24 structures x 2 sides = 48 data rows; 6 sections
is_data <- grepl("±|destroyed", grid[, 2])
stopifnot(sum(is_data) == 48L, sum(grid[, 1] %in% sections) == 6L,
          sum(grid == "destroyed") == 4L)


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

freeze(grid,    file.path(folder, paste0(item_name, "_snapshot.csv")))

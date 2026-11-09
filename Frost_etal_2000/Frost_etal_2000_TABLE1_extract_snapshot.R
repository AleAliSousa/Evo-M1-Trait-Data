# Frost_etal_2000_TABLE1_extract_snapshot.R ----------------------------------
#
# Builds the frozen snapshot of Frost, Milliken, Plautz, Masterton & Nudo (2000)
# TABLE 1 "Area Measurements (in mm2) and Percentages of Body Part
# Representations Within Somatosensory Cortex", J Comp Neurol 421: 29-51,
# printed on p. 36 (PDF page 8).
#
#   Frost_etal_2000_TABLE1_snapshot.csv     13 rows x 8 cols, one row per printed line
#
# The PDF is born-digital (typeset by XPP/PDFlib in 2000; the only images in it
# are figures), so every printed value is EXTRACTED from the PDF text layer at
# run time with pdftools (__HOWTO_make_a_snapshot.md method 3, the
# Jacob_etal_2021_extract_snapshot.R pattern): no table value is typed in this
# script. Only structural literals live here (caption, column headers,
# footnote), and each is checked against the text layer before anything is
# written. The build (Frost_etal_2000_TABLE1.R) READS the frozen file; nothing
# is cleaned here.
#
# The printed table, line by line (checked against a 300-dpi render of PDF
# page 8):
#   the caption; the column header; for each case (9213, 9321, 9324) an area
#   line -- case no., Tot. SS and the six areas -- and beneath it a percentage
#   line -- "(71%)" under S1, S2, Digits, Vibrissae, Rostrum and HL/trunk,
#   nothing under Case no. or Tot. SS; the Average line -- "mean +/- dispersion"
#   in each of the seven value columns, the dispersion on the same line as the
#   mean -- and its percentage line -- "(68.0 +/- 3.6%)"; the footnote, printed
#   on three lines.
#
# Fidelity decisions:
#  * One snapshot row per printed line, in printed order: caption, header,
#    area line and percentage line for each case, the Average line and its
#    percentage line, and the three footnote lines (13 rows). Caption and
#    footnote lines sit in column 1; the percentage lines leave Case no. and
#    Tot. SS blank, as printed.
#  * Each text-layer cell goes into the column whose header it sits under on
#    the page (the header cell with the nearest centre). The run stops unless
#    every area line fills all eight columns and every percentage line fills
#    exactly S1 ... HL/trunk.
#  * Printed text kept verbatim: parentheses, "%", "mean +/- dispersion" in one
#    cell as printed, the HL/trunk Average percentage "(17.7% +/- 1.0%)" with its
#    second "%", and the footnote broken where the page breaks it (mid-sentence).
#
# Text-layer quirks:
#  * the printed plus-minus sign is encoded as U+2AFE in this font's text
#    layer; it is mapped back to U+00B1 (the only glyph map applied) and set
#    with one space either side, as printed;
#  * superscripts are flattened in the text layer ("mm2", "Cortex1" and a lone
#    "1" before the footnote). The caption is written with "mm" + U+00B2 and
#    the footnote mark as "^1" (the Kennedy_etal_1978 convention).
#
# Frozen-file guard: if the snapshot already exists and the extraction differs,
# the new grid is written to *_snapshot_NEW.csv and the run stops. The frozen
# copy never changes silently.
# Re-taking a snapshot (a deliberate change, e.g. a new layout): review
# *_snapshot_NEW.csv against the PDF, then re-run with the explicit switch
#     Rscript Frost_etal_2000_TABLE1_extract_snapshot.R --retake
# (or set RETAKE <- TRUE below). The superseded frozen file is moved to
# archive/<item>_snapshot_superseded_<date>.csv before the new one is written
# (the repo procedure: reconcile against the PDF, move the superseded file to
# archive/, re-run). Record the re-take in the README.
#
# Written by an AI assistant (Claude) for A. de Sousa on 2026-11-06 (7 rows:
# area and percentage in one two-line cell); rewritten on 2026-11-07 at the
# owner's request so that every printed line is its own row (the 7-row
# snapshot is in archive/).
# R NOT RUN -- the frozen snapshot now on disk was written by a Python mirror of
# this script (Frost_etal_2000_TABLE1_python_mirror.py). Alexandra to run this
# script once, without --retake: it should report "frozen snapshot already on
# disk and identical".
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
folder    <- dirname(.sp)
item_name <- sub("_extract_snapshot\\.R$", "", basename(.sp))
pdf_file  <- file.path(folder, "Frost-2000-Somatosensory and motor representat.pdf")
if (!file.exists(pdf_file)) stop("Source PDF not found: ", pdf_file, call. = FALSE)
if (!requireNamespace("pdftools", quietly = TRUE)) stop("Install pdftools", call. = FALSE)

RETAKE <- FALSE   # TRUE only to replace a frozen snapshot deliberately (or run with --retake)
if ("--retake" %in% commandArgs(trailingOnly = TRUE)) RETAKE <- TRUE

## 1. STRUCTURAL LITERALS (as printed) and their text-layer forms --------------
caption_printed   <- paste0("TABLE 1. Area Measurements (in mm\u00b2) and Percentages of Body ",
                            "Part Representations Within Somatosensory Cortex^1")
caption_textlayer <- paste0("TABLE 1. Area Measurements (in mm2) and Percentages of Body ",
                            "Part Representations Within Somatosensory Cortex1")
header_printed    <- c("Case no.", "Tot. SS", "S1", "S2", "Digits", "Vibrissae", "Rostrum",
                       "HL/trunk")
footnote_body <- paste(
  "The three cases shown had the highest resolution, the most definable boundaries and",
  "were considered fairly complete. Percentages of S1 and S2 areas are relative to Tot. SS.",
  "Area measurements of the digits, vibrissae, rostrum, and hindlimb/trunk are taken from",
  "the S1 area only and percentages reflect the proportion of that representation within",
  "S1. For abbreviations, see list. Table was produced by using Canvas 3.5.5.")
PM_TL <- "\u2afe"     # how this text layer encodes the printed plus-minus sign
PM    <- "\u00b1"     # the printed plus-minus sign

## 2. TEXT LAYER, LINE BY LINE ---------------------------------------------------
pages  <- pdftools::pdf_text(pdf_file)
squish <- function(x) trimws(gsub("[[:space:]]+", " ", x))
nows   <- function(x) gsub("[[:space:]]+", "", x)      # caption anchor ignores spacing
pg <- which(vapply(pages, function(p) grepl(nows(caption_textlayer), nows(p), fixed = TRUE),
                   logical(1)))
if (length(pg) != 1L) stop("TABLE 1 caption not found on exactly one PDF page.", call. = FALSE)
L <- strsplit(pages[pg], "\n", fixed = TRUE)[[1]]     # PDF page 8 (journal p. 36), physical layout
L <- sub("[[:space:]]+$", "", L)
L <- gsub(paste0(" *", PM_TL, " *"), paste0(" ", PM_TL, " "), L)   # " +/- " as printed

i_cap <- which(nows(L) == nows(caption_textlayer))
if (length(i_cap) != 1L) stop("TABLE 1 caption line not found once in the text layer.", call. = FALSE)
nxt <- which(nzchar(squish(L)))
nxt <- nxt[nxt > i_cap]               # the printed lines below the caption, in order

## A line's cells: runs of text separated by two or more spaces, with their
## character positions on the line.
cells_of <- function(line) {
  m <- gregexpr("[^[:space:]]+( [^[:space:]]+)*", line)[[1]]
  if (m[1] == -1L) return(data.frame(text = character(0), start = integer(0), end = integer(0)))
  start <- as.integer(m)
  end   <- start + attr(m, "match.length") - 1L
  data.frame(text = substring(line, start, end), start = start, end = end,
             stringsAsFactors = FALSE)
}
centre <- function(d) (d$start + d$end) / 2

## 3. COLUMN HEADER --------------------------------------------------------------
H <- cells_of(L[nxt[1]])
if (!identical(H$text, header_printed))
  stop("Column header line is not as printed: ", L[nxt[1]], call. = FALSE)

## 4. TABLE BODY: eight printed lines, each cell placed under its header ----------
place <- function(line) {
  d <- cells_of(line)
  col <- vapply(centre(d), function(x) which.min(abs(centre(H) - x)), integer(1))
  if (anyDuplicated(col)) stop("Two text-layer cells fall under one column: ", line, call. = FALSE)
  out <- rep("", length(header_printed)); out[col] <- d$text
  out
}
body_lines <- nxt[2:9]
B <- t(vapply(L[body_lines], place, character(length(header_printed))))
dimnames(B) <- NULL

NUM <- "[0-9]+\\.[0-9]+"
area_ln <- c(1L, 3L, 5L)              # case area lines; 2, 4, 6 = their percentage lines
ok <- c(case_numbers  = all(grepl("^[0-9]{4}$", B[area_ln, 1])) && !anyDuplicated(B[area_ln, 1]),
        case_areas    = all(grepl(paste0("^", NUM, "$"), B[area_ln, 2:8])),
        case_pct      = all(grepl("^\\([0-9]+%\\)$", B[area_ln + 1L, 3:8])),
        average_label = B[7, 1] == "Average",
        average_areas = all(grepl(paste0("^", NUM, " ", PM_TL, " ", NUM, "$"), B[7, 2:8])),
        average_pct   = all(grepl(paste0("^\\(", NUM, "%? ", PM_TL, " ", NUM, "%\\)$"), B[8, 3:8])),
        pct_lines_blank_under_case_and_tot_ss = all(B[c(2L, 4L, 6L, 8L), 1:2] == ""))
if (!all(ok))
  stop("TABLE 1 body lines do not have the printed structure (failed: ",
       paste(names(ok)[!ok], collapse = ", "), "):\n", paste(L[body_lines], collapse = "\n"),
       call. = FALSE)

## 5. FOOTNOTE: the mark "1" (its own text-layer line, or the start of the first
## footnote line), then the three printed lines, which together must read as
## the footnote.
f1 <- squish(L[nxt[10]])
if (f1 == "1") {
  fn <- squish(L[nxt[11:13]])
} else if (grepl("^1 ?The three cases", f1)) {
  fn <- squish(L[nxt[10:12]]); fn[1] <- sub("^1 ?", "", fn[1])
} else stop("Footnote mark '1' not found after the table body: ", f1, call. = FALSE)
if (!identical(paste(fn, collapse = " "), footnote_body))
  stop("TABLE 1 footnote lines do not read as printed:\n", paste(fn, collapse = "\n"), call. = FALSE)

## 6. SNAPSHOT GRID: one row per printed line --------------------------------------
grid <- matrix("", nrow = 13L, ncol = length(header_printed))
grid[1, 1]   <- caption_printed
grid[2, ]    <- H$text
grid[3:10, ] <- gsub(PM_TL, PM, B, fixed = TRUE)
grid[11, 1]  <- paste0("^1", fn[1])
grid[12, 1]  <- fn[2]
grid[13, 1]  <- fn[3]
stopifnot(identical(dim(grid), c(13L, 8L)), !any(grepl(PM_TL, grid, fixed = TRUE)))

## 7. FREEZE ------------------------------------------------------------------------
write_grid <- function(grid, file)
  write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
              qmethod = "double", fileEncoding = "UTF-8")
read_grid <- function(file) {
  g <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                          na.strings = character(0), check.names = FALSE, encoding = "UTF-8"))
  dimnames(g) <- NULL
  g
}

freeze <- function(grid, file) {
  alt <- sub("\\.csv$", "_NEW.csv", file)
  if (!file.exists(file)) {
    write_grid(grid, file)
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
    return(invisible())
  }
  old <- read_grid(file)
  if (identical(dim(old), dim(grid)) && identical(old, grid)) {
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
    return(invisible())
  }
  if (!RETAKE) {
    write_grid(grid, alt)
    stop(basename(file), ": the frozen snapshot on disk differs from the text-layer ",
         "extraction. Refusing to overwrite; the new extraction is in ", basename(alt),
         ". Reconcile it against the PDF; to replace the frozen copy deliberately, re-run ",
         "with --retake (or RETAKE <- TRUE), which first moves the superseded file to archive/.",
         call. = FALSE)
  }
  arch <- file.path(dirname(file), "archive",
                    sub("\\.csv$", paste0("_superseded_", format(Sys.Date()), ".csv"), basename(file)))
  if (file.exists(arch)) stop("Archive copy already exists: ", arch, call. = FALSE)
  dir.create(dirname(arch), showWarnings = FALSE)
  if (!file.rename(file, arch)) stop("Could not move ", basename(file), " to archive/.", call. = FALSE)
  write_grid(grid, file)
  if (file.exists(alt) && identical(read_grid(alt), grid)) invisible(file.remove(alt))
  message(basename(file), ": RE-TAKEN -- the superseded frozen copy is now archive/",
          basename(arch), "; wrote ", nrow(grid), " rows x ", ncol(grid),
          " cols. Record the re-take in the README.")
}

freeze(grid, file.path(folder, paste0(item_name, "_snapshot.csv")))

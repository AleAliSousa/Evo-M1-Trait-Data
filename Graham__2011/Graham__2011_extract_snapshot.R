## Graham__2011_extract_snapshot.R — PDF text layer -> the frozen snapshot
##
## Graham, K. L. (2011). Coevolutionary relationship between striatum size and social play
## in nonhuman primates. American Journal of Primatology, 73(4), 314-322.
## doi:10.1002/ajp.20898
##
## TABLE I (p. 317): "Percentages of Social and Nonsocial Play, Adult Body and Brain Weights
## and Striatum Volumes in Nonhuman Primates" — 14 primate taxa x {% social play,
## % nonsocial play, brain size (g), body size (g), striatum (mm3), Sources}.
##
## Source->snapshot step, made reproducible (HOWTO §2 / snapshot HOWTO method 3): every DATA
## value, every per-row source string AND the six footnote texts are EXTRACTED from the PDF's
## text layer at run time — no value is typed into this script. Only the caption and the
## column-header stubs are literals, and each is anchor-verified against the page.
##
## Writes: Graham__2011_TABLEI_snapshot.csv (read by Graham__2011_TABLEI.R, which never
## regenerates it). Frozen-file guard: a differing extraction goes to *_snapshot_NEW.csv
## and the run stops.
##
## Layout notes (checked against a 200-dpi render of p. 317 - row count, the three en dashes,
## the wrapped binomials, the superscript e/f on every citation and the genus-level
## "Papio spp."/"Pithecia spp." labels - AI assistant, 2026-10-28):
##   - long binomials wrap onto a second line indented by two spaces ("Callithrix" /
##     "  jacchus"); the source cell wraps onto lines indented past column 60. Both are
##     reattached to the row they belong to.
##   - the printed en dash (missing % nonsocial play: Cercocebus albigena, Cercopithecus
##     mitis, Erythrocebus patas) survives as U+2013 in the text layer and is kept as the
##     dash; the build script turns it into NA.
##   - every citation in the Sources cell carries a superscript e (captive study) or
##     f (wild study); the text layer leaves the letter attached to the year ("1997e").
##   - "Papio spp." and "Pithecia spp." are printed at genus level.

## 0. PATHS (no setwd) --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or source from RStudio (save the file first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
pdf_file  <- list.files(paper_dir, pattern = "^Graham-2011-.*\\.pdf$", full.names = TRUE)
if (length(pdf_file) != 1L) stop("Expected exactly one source PDF in ", paper_dir, call. = FALSE)
if (!requireNamespace("pdftools", quietly = TRUE)) stop("Install pdftools", call. = FALSE)
snapshot_csv <- file.path(paper_dir, "Graham__2011_TABLEI_snapshot.csv")

## 1. TEXT LAYER ---------------------------------------------------------------
pages <- enc2utf8(pdftools::pdf_text(pdf_file))
pg <- grep("TABLE I. Percentages of Social and Nonsocial Play", pages, fixed = TRUE)
if (length(pg) != 1L) stop("TABLE I caption not found on exactly one page", call. = FALSE)
anchor <- function(pat)
  if (!grepl(pat, pages[pg], fixed = TRUE))
    stop("anchor not found in the PDF text layer: ", pat, call. = FALSE)
anchor("TABLE I. Percentages of Social and Nonsocial Play, Adult Body and Brain Weights and Striatum Volumes in")
anchor("Nonhuman Primates")
anchor("% social")
anchor("% nonsocial")
anchor("Striatum")
anchor("Sources")

lines <- strsplit(pages[pg], "\n", fixed = TRUE)[[1]]
start <- grep("TABLE I. Percentages", lines, fixed = TRUE)[1]
lines <- lines[start:length(lines)]
foot_start <- which(grepl("^[a-f]$", trimws(lines)) & nchar(lines) - nchar(sub("^ +", "", lines)) == 0L)[1]
if (is.na(foot_start)) stop("footnote block (single-letter markers a-f) not found", call. = FALSE)

## 2. PARSE THE DATA ROWS ------------------------------------------------------
dash   <- "\u2013"
numish <- function(s) grepl(paste0("^([0-9,]+\\.?[0-9]*|", dash, ")$"), s)
fields <- function(ln) {
  p <- trimws(strsplit(trimws(ln), "[ ]{2,}")[[1]])
  p[nzchar(p)]
}
indent <- function(ln) nchar(ln) - nchar(sub("^ +", "", ln))

sp <- character(0); vals <- list(); src <- list()
for (ln in lines[seq_len(foot_start - 1L)]) {
  if (!nzchar(trimws(ln))) next
  p <- fields(ln); if (!length(p)) next
  ind <- indent(ln)
  if (ind == 0L && length(p) >= 6L && all(numish(p[2:6]))) {           # a new data row
    sp   <- c(sp, p[1])
    vals[[length(vals) + 1L]] <- p[2:6]
    src[[length(src) + 1L]]   <- if (length(p) > 6L) paste(p[-(1:6)], collapse = " ") else ""
  } else if (length(sp)) {                                             # a continuation line
    if (ind <= 4L && grepl("^[a-z]+$", p[1])) {                        # wrapped binomial
      sp[length(sp)] <- paste(sp[length(sp)], p[1])
      if (length(p) > 1L) src[[length(src)]] <- paste(src[[length(src)]], paste(p[-1], collapse = " "))
    } else if (ind > 60L) {                                            # wrapped Sources cell
      src[[length(src)]] <- paste(src[[length(src)]], paste(p, collapse = " "))
    }
  }
}
if (length(sp) != 14L)
  stop("Expected 14 species rows (the paper's stated sample), parsed ", length(sp), call. = FALSE)
src <- trimws(gsub("[ ]+", " ", unlist(src)))
if (any(!nzchar(src))) stop("A row has an empty Sources cell: ", paste(sp[!nzchar(src)], collapse = "; "), call. = FALSE)

## 3. PARSE THE FOOTNOTES (marker line, then the indented text line) -------------
fl <- lines[foot_start:length(lines)]
fl <- fl[nzchar(trimws(fl))]
marks <- which(grepl("^[a-f]$", trimws(fl)))
foot <- vapply(marks, function(i) paste0(trimws(fl[i]), trimws(fl[i + 1L])), character(1))
if (length(foot) != 6L || !grepl("^aSocial and nonsocial play measures", foot[1]))
  stop("Expected six footnotes a-f; got ", length(foot), call. = FALSE)

## 4. WRITE THE SNAPSHOT (printed layout: caption, header, 14 rows, footnotes) ----
hdr <- rbind(
  c(paste("TABLE I. Percentages of Social and Nonsocial Play, Adult Body and Brain Weights",
          "and Striatum Volumes in Nonhuman Primates"), "", "", "", "", "", ""),
  c("Species", "% social playa", "% nonsocial playa", "Brain size (g)b", "Body size (g)c",
    "Striatum (mm3)d", "Sources"))
body <- cbind(sp, do.call(rbind, vals), src)
snap <- rbind(hdr, body, cbind(foot, "", "", "", "", "", ""))

tmp <- tempfile(fileext = ".csv")
utils::write.table(snap, tmp, sep = ",", row.names = FALSE, col.names = FALSE,
                   qmethod = "double", fileEncoding = "UTF-8")
if (file.exists(snapshot_csv)) {
  if (identical(readLines(snapshot_csv, warn = FALSE, encoding = "UTF-8"),
                readLines(tmp, warn = FALSE, encoding = "UTF-8"))) {
    message("snapshot unchanged: ", basename(snapshot_csv))
  } else {
    alt <- sub("_snapshot\\.csv$", "_snapshot_NEW.csv", snapshot_csv)
    file.copy(tmp, alt, overwrite = TRUE)
    stop("Extraction differs from the frozen snapshot. Wrote ", basename(alt),
         " — compare, then replace deliberately.", call. = FALSE)
  }
} else {
  file.copy(tmp, snapshot_csv)
  message("wrote ", basename(snapshot_csv), ": ", nrow(body), " species rows")
}

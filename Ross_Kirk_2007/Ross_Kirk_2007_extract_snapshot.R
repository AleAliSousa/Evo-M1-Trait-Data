## Ross_Kirk_2007_extract_snapshot.R — PDF text layer -> the frozen snapshot
##
## Ross, C. F., & Kirk, E. C. (2007). Evolution of eye size and shape in primates.
## Journal of Human Evolution, 52(3), 294-313. doi:10.1016/j.jhevol.2006.09.006
##
## APPENDIX 1 (pp. 308-310): "Data, activity patterns, and taxon and activity codes used for
## analyses" — 260 visually dependent terrestrial mammal species x {Genus, Species, Order,
## ACT, n, HBL, AD, CD}. 260 is the sample size the paper states in Materials and methods.
##
## Source->snapshot step, made reproducible (HOWTO §2 / snapshot HOWTO method 3): every DATA
## value and the appendix's own Notes line are EXTRACTED from the PDF's text layer at run
## time — nothing is typed into this script except the appendix title and the column-header
## stubs, which are anchor-verified against the page.
##
## Writes: Ross_Kirk_2007_Appendix1_snapshot.csv (read by Ross_Kirk_2007_Appendix1.R, which
## never regenerates it). A differing extraction goes to *_snapshot_NEW.csv and the run stops.
##
## Layout notes (checked against 170-dpi renders of pp. 308 and 310 — the two-column reading
## order, the row counts per column, the printed Order spelling "Paramelemorphia" and the
## trailing Notes line — AI assistant, 2026-10-28):
##   - each appendix page prints TWO independent table columns; a text-layer line therefore
##     carries up to two data rows. They are split on the character offset of the match
##     (< 60 = left column) and the snapshot keeps printed reading order: all left-column
##     rows of a page, then all right-column rows.
##   - row counts: p.308 62 + 64, p.309 65 + 64, p.310 5 = 260.
##   - "Perameles nasuta" is printed with Order "Paramelemorphia" (a misprint for
##     Peramelemorphia); kept exactly as printed, flagged in the build script's README.
##   - many Species cells are "sp." (genus-level records); kept as printed.

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
pdf_file  <- file.path(paper_dir, "ross_kirk_2007.pdf")
if (!file.exists(pdf_file)) stop("Source PDF not found: ", pdf_file, call. = FALSE)
if (!requireNamespace("pdftools", quietly = TRUE)) stop("Install pdftools", call. = FALSE)
snapshot_csv <- file.path(paper_dir, "Ross_Kirk_2007_Appendix1_snapshot.csv")

## 1. TEXT LAYER ---------------------------------------------------------------
pages <- enc2utf8(pdftools::pdf_text(pdf_file))
title <- "Appendix 1. Data, activity patterns, and taxon and activity"
pg1 <- grep(title, pages, fixed = TRUE)
if (length(pg1) != 1L) stop("Appendix 1 title not found on exactly one page", call. = FALSE)
anchor <- function(pat, where = pg1)
  if (!any(grepl(pat, pages[where], fixed = TRUE)))
    stop("anchor not found in the PDF text layer: ", pat, call. = FALSE)
anchor(title)
anchor("Genus")
anchor("Species")
anchor("Order")
anchor("ACT n HBL AD CD")

## 2. PARSE THE DATA ROWS (two printed columns per page) ------------------------
row_re <- paste0("([A-Z][a-z]+)[ ]+([a-z][a-z.]*)[ ]+([A-Z][a-z]+)[ ]+([a-z])[ ]+",
                 "([0-9]+)[ ]+([0-9]+(?:\\.[0-9]+)?)[ ]+([0-9]+(?:\\.[0-9]+)?)[ ]+",
                 "([0-9]+(?:\\.[0-9]+)?)")
parse_page <- function(page) {
  left <- list(); right <- list()
  for (ln in strsplit(page, "\n", fixed = TRUE)[[1]]) {
    m <- gregexpr(row_re, ln, perl = TRUE)[[1]]
    if (m[1] == -1L) next
    caps <- regmatches(ln, gregexpr(row_re, ln, perl = TRUE))[[1]]
    for (k in seq_along(caps)) {
      f <- regmatches(caps[k], regexec(row_re, caps[k], perl = TRUE))[[1]][-1]
      if (m[k] < 60L) left[[length(left) + 1L]] <- f else right[[length(right) + 1L]] <- f
    }
  }
  c(left, right)                      # printed reading order: left column, then right
}
rows <- unlist(lapply(pages[pg1:(pg1 + 2L)], parse_page), recursive = FALSE)
if (length(rows) != 260L)
  stop("Expected 260 species rows (the sample size stated in Materials and methods), parsed ",
       length(rows), call. = FALSE)
body <- do.call(rbind, rows)

## 3. THE APPENDIX'S OWN NOTES LINE (the column legend) -------------------------
notes_pg <- pages[pg1 + 2L]
nl <- strsplit(notes_pg, "\n", fixed = TRUE)[[1]]
i0 <- grep("^\\s*Notes: ACT, activity code", nl)
if (length(i0) != 1L) stop("Appendix 1 Notes line not found on p.310", call. = FALSE)
## The note sits in the LEFT print column and wraps over the next lines, while the right
## column of the same lines carries Appendix 2's nexus tree. Take the left slice only
## (the note column is ~78 characters wide) and stop at the first line whose left slice is
## blank. The hyphenation at a line break ("n, sam- / ple size") is rejoined.
LCOL <- 78L
lslice <- function(k) trimws(substr(nl[k], 1, LCOL))
notes <- lslice(i0)
j <- i0 + 1L
while (j <= length(nl) && nzchar(lslice(j)) && !grepl("Appendix 2", lslice(j))) {
  nxt <- lslice(j)
  notes <- if (grepl("-$", notes)) paste0(sub("-$", "", notes), nxt) else paste(notes, nxt)
  j <- j + 1L
}
notes <- trimws(gsub("[ ]+", " ", notes))
## the text layer renders the printed "=" of the code legend as the fraction glyph
notes <- gsub("\u00bc", "=", notes, fixed = TRUE)
if (!grepl("cathemeral", notes, fixed = TRUE) || !grepl("cornea diameter", notes, fixed = TRUE))
  stop("Notes line did not capture the full legend: ", notes, call. = FALSE)

## 4. WRITE THE SNAPSHOT --------------------------------------------------------
hdr <- rbind(
  c("Appendix 1. Data, activity patterns, and taxon and activity codes used for analyses",
    "", "", "", "", "", "", ""),
  c("Genus", "Species", "Order", "ACT", "n", "HBL", "AD", "CD"))
snap <- rbind(hdr, body, c(notes, "", "", "", "", "", "", ""))

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

## Pellis_Iwaniuk_2000_extract_snapshot.R — PDF text layer -> the frozen snapshot
##
## Pellis, S. M., & Iwaniuk, A. N. (2000). Adult–adult play in primates: comparative
## analyses of its origin, distribution and evolution. Ethology, 106(12), 1083–1104.
## doi:10.1046/j.1439-0310.2000.00627.x
##
## TABLE 1 (pp. 1087–1088): "Information on play and social organization for the species
## used" — 71 primate species x {social organization, sexual play, non-sexual play,
## play absent (0) or present (1)}.
##
## Source->snapshot step, made reproducible (HOWTO §2 / snapshot HOWTO method 3): every
## DATA value is EXTRACTED from the PDF's text layer at run time — no score is typed into
## this script. Only structural literals (caption, the two-tier column headers, the two
## footnote lines) are written here, and the caption and header stubs are verified against
## the page before the snapshot is written.
##
## Writes: Pellis_Iwaniuk_2000_Table1_snapshot.csv (read by Pellis_Iwaniuk_2000_Table1.R,
## which never regenerates it).
##
## Frozen-file guard: if the snapshot exists and the extraction differs, the new version
## goes to *_snapshot_NEW.csv and the run stops — the frozen copy never changes silently.
##
## Text-layer glyph map (each verified against a 200-dpi render of pp. 1087–1088,
## AI assistant, 2026-10-28):
##   \x80 -> "ff"  (ligature dropped: "Ateles geo\x80royi" prints as "Ateles geoffroyi")
##   \xb1 -> "–"   (the en dash the table prints for a cell that was not scored renders
##                  as "±" in the text layer; it is NOT a plus-minus sign)
## Printed as-is and NOT corrected here (the species key carries the accepted names):
##   "Perodictus potto" (Perodicticus), "Papio hamadrayas" (hamadryas),
##   "Saguinus fuscicolis" (fuscicollis), "Propithecus verreauxi" (Propithecus/Propithecus
##   as printed), "Cacajao calvus" (Cacajao as printed).
## Printed quirk preserved: the last row, Varecia variegata, prints only three values —
## the "Play absent (0) or present (1)" cell is blank on the page.

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
pdf_file  <- list.files(paper_dir, pattern = "^Pellis-2000-.*\\.pdf$", full.names = TRUE)
if (length(pdf_file) != 1L) stop("Expected exactly one source PDF in ", paper_dir, call. = FALSE)
if (!requireNamespace("pdftools", quietly = TRUE)) stop("Install pdftools", call. = FALSE)
snapshot_csv <- file.path(paper_dir, "Pellis_Iwaniuk_2000_Table1_snapshot.csv")

## 1. TEXT LAYER + GLYPH MAP ---------------------------------------------------
pages <- pdftools::pdf_text(pdf_file)
fix_glyphs <- function(x) {
  x <- enc2utf8(x)
  x <- gsub("\u0080", "ff", x, fixed = TRUE)        # dropped ff ligature
  gsub("\u00b1", "\u2013", x, fixed = TRUE)         # the printed en dash
}
tab_pages <- grep("Table 1: Information on play", pages)          # p.1087 (caption)
tab_pages <- sort(unique(c(tab_pages, grep("Table 1: continued", pages))))
if (length(tab_pages) != 2L)
  stop("Expected the table on two pages (caption + continued), found ", length(tab_pages), call. = FALSE)

## anchor assertions: the structural literals below must be on the page
anchor <- function(pat, where)
  if (!any(grepl(pat, pages[where], fixed = TRUE)))
    stop("anchor not found in the PDF text layer: ", pat, call. = FALSE)
anchor("Table 1: Information on play and social organization for the species used", tab_pages[1])
anchor("Type of play context", tab_pages)
anchor("Play absent (0)", tab_pages)
anchor("or present (1)", tab_pages)
anchor("**For species with two values shown", tab_pages[2])

## 2. PARSE THE DATA ROWS ------------------------------------------------------
## A data row is: binomial, then 2-4 cells, each a single digit, an en dash, or "2/3"
## (the table's dual value). Columns are separated by runs of >= 2 spaces.
parse_rows <- function(page) {
  out <- list()
  for (ln in strsplit(fix_glyphs(page), "\n", fixed = TRUE)[[1]]) {
    parts <- trimws(strsplit(trimws(ln), "[ ]{2,}")[[1]])
    parts <- parts[nzchar(parts)]
    if (length(parts) < 2L) next
    if (!grepl("^[A-Z][a-z]+ [a-z]+$", parts[1])) next
    if (!all(grepl("^([0-9]|\u2013|2/3)$", parts[-1]))) next
    out[[length(out) + 1L]] <- parts
  }
  out
}
rows <- c(parse_rows(pages[tab_pages[1]]), parse_rows(pages[tab_pages[2]]))
if (length(rows) != 71L)
  stop("Expected 71 species rows (the paper's stated sample), parsed ", length(rows), call. = FALSE)

## Pad the one short row (Varecia variegata prints no presence cell) to 4 cells, keeping
## the missing cell EMPTY — a blank is not a zero.
cells <- t(vapply(rows, function(r) {
  v <- c(r[-1], rep("", 4L))[1:4]
  c(r[1], v)
}, character(5)))
short <- which(vapply(rows, length, integer(1)) != 5L)
if (length(short) != 1L || cells[short, 1] != "Varecia variegata")
  stop("Unexpected short row(s): ", paste(cells[short, 1], collapse = "; "),
       " — check the page before trusting this parse.", call. = FALSE)

## 3. WRITE THE SNAPSHOT (printed layout: caption, two-tier header, rows, footnotes) ----
hdr <- rbind(
  c("Table 1: Information on play and social organization for the species used", "", "", "", ""),
  c("", "", "Type of play context", "", ""),
  c("Species*", "Social organization", "sexual", "non-sexual**", "Play absent (0) or present (1)"))
foot <- rbind(
  c(paste("*References used for most species can be found in Fagen (1981), Pellis & Iwaniuk (1999b,",
          "2000), and Power (2000). Additional reference material for other species was derived from",
          "Wharton (1950), Hill et al. (1951), Simonds (1965), Chalmers & Rowell (1971), MacKinnon (1974),",
          "Oates (1977), Box & Morris (1980), MacKinnon & MacKinnon (1980), Oswald & Lockard (1980),",
          "Mellen et al. (1981), Byrne et al. (1983), Clark (1985), Koyama (1985), Eibl-Eibesfelt (1989),",
          "Thierry et al. (1989), Robbins (1996), Perry (1996), (1997), (1998), Kinzey (1997),",
          "Reichard & Sommer (1997), Verbeek & de Waal (1997), and other references cited in the text."),
    "", "", "", ""),
  c(paste("**For species with two values shown, the first was used to test the byproduct hypothesis",
          "and the second to test the social assessment hypothesis (see text)."), "", "", "", ""))
snap <- rbind(hdr, cells, foot)

tmp <- tempfile(fileext = ".csv")
utils::write.table(snap, tmp, sep = ",", row.names = FALSE, col.names = FALSE,
                   qmethod = "double", fileEncoding = "UTF-8")
if (file.exists(snapshot_csv)) {
  old <- readLines(snapshot_csv, warn = FALSE, encoding = "UTF-8")
  new <- readLines(tmp, warn = FALSE, encoding = "UTF-8")
  if (identical(old, new)) {
    message("snapshot unchanged: ", basename(snapshot_csv))
  } else {
    alt <- sub("_snapshot\\.csv$", "_snapshot_NEW.csv", snapshot_csv)
    file.copy(tmp, alt, overwrite = TRUE)
    stop("Extraction differs from the frozen snapshot. Wrote ", basename(alt),
         " — compare, then replace deliberately.", call. = FALSE)
  }
} else {
  file.copy(tmp, snapshot_csv)
  message("wrote ", basename(snapshot_csv), ": ", nrow(cells), " species rows")
}

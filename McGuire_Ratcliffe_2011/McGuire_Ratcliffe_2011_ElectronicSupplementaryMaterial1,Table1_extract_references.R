## McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_extract_references.R
##
## Builds reference_tables/<Item>_references.csv -- the lookup that resolves the numeric
## keys printed in the "References" column of ESM 1 Table 1 to the works they stand for.
##
## The item is SECONDARY: every row of Table 1 is a compilation. The volumetric and body
## mass values are taken from Baron, Stephan & Frahm (1996) (stated in the table caption,
## and in the paper's reference [17]); the numbers printed in the "References" column are
## the sources for that row's migratory/sedentary CATEGORY, numbered 1-30 in ESM 1's own
## reference list (ESM 1 pp. 2-4). Those 1-30 are a list local to ESM 1 -- they are NOT
## the reference numbers of the Biology Letters paper.
##
## No citation is typed here: each entry is read from the PDF text layer. Four known
## text-layer artefacts (a glyph gap that pdftools renders as a space, e.g. "Ma mmalia")
## are repaired against the page render; each repair is declared below and asserted to
## have applied.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R, or source() the saved file.", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- sub("_extract_references$", "", tools::file_path_sans_ext(basename(.sp)))
setwd(folder)
source_pdf   <- file.path(folder, "rsbl20100744supp1.pdf")
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_dir     <- file.path(folder, "reference_tables")
refs_csv     <- file.path(refs_dir, paste0(item_name, "_references.csv"))
if (!dir.exists(refs_dir)) dir.create(refs_dir)
stopifnot(file.exists(source_pdf), file.exists(snapshot_csv))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages(library(pdftools))

## 2. PRINTED LINES OF ESM 1 (pages 2-4; the watermark is the only ArialMT text) --------
pages <- pdf_data(source_pdf, font_info = TRUE)[2:4]
lines <- unlist(lapply(pages, function(p) {
  p <- p[grepl("TimesNewRoman", p$font_name), ]
  p <- p[order(p$y, p$x), ]
  ys <- sort(unique(p$y)); p$line <- cumsum(c(TRUE, diff(ys) > 2))[match(p$y, ys)]
  vapply(split(p, p$line), function(L) paste(L$text[order(L$x)], collapse = " "), character(1))
}), use.names = FALSE)
## ESM 2 begins its own, unnumbered reference list -- stop before it.
end <- grep("^Electronic Supplem ?entary Material 2$", lines)
stopifnot(length(end) == 1L)
lines <- lines[seq_len(end - 1L)]

## 3. ASSEMBLE THE 30 NUMBERED ENTRIES ---------------------------------
## An entry opens with its own number as the first token ("12."); every following line
## until the next expected number is a continuation. Requiring the numbers to arrive in
## sequence keeps table cells such as "1, 11" from being mistaken for an entry opener.
## A page range broken across two lines ("... 27, 409-" / "424.") must close up rather
## than gain a space; nothing else in this list wraps on a hyphen (asserted below).
cit <- character(0); nxt <- 1L; cur <- NULL; closed <- 0L
for (ln in lines) {
  tok1 <- sub(" .*$", "", ln)
  if (nxt <= 30L && identical(tok1, paste0(nxt, "."))) {
    if (!is.null(cur)) cit[length(cit) + 1L] <- cur
    cur <- sub("^[0-9]{1,2}\\. ", "", ln); nxt <- nxt + 1L
  } else if (!is.null(cur)) {
    if (grepl("-$", cur) && grepl("^[0-9]", ln)) { cur <- paste0(cur, ln); closed <- closed + 1L }
    else cur <- paste(cur, ln)
  }
}
stopifnot(closed == 1L)
cit[length(cit) + 1L] <- cur
cit <- trimws(gsub("\\s+", " ", cit))
names(cit) <- as.character(seq_along(cit))
stopifnot(length(cit) == 30L, nxt == 31L)

## 4. REPAIR THE TEXT-LAYER GLYPH GAPS ---------------------------------
## Confirmed against a page render of ESM 1 p. 3 on 2026-10-31: the page prints
## "Mammalia", "Mammals", "helvum" and a superscript "th" with no space. Everything else
## -- including the printed typos -- is left exactly as the ESM prints it.
artefacts <- c("Ma mmalia" = "Mammalia", "Ma mmals" = "Mammals",
               "helvu m"   = "helvum",   "4 th ed." = "4th ed.")
for (a in names(artefacts)) {
  hit <- grepl(a, cit, fixed = TRUE)
  if (!any(hit)) stop("declared text-layer artefact no longer present: ", a, call. = FALSE)
  cit <- gsub(a, artefacts[[a]], cit, fixed = TRUE)
}

## 5. KEYS THE TABLE ACTUALLY CITES -------------------------------------
snap <- utils::read.csv(snapshot_csv, colClasses = "character", check.names = FALSE,
                        encoding = "UTF-8", na.strings = NULL)
tok <- trimws(unlist(strsplit(snap$References[nzchar(snap$References)], ",")))
tok <- tok[nzchar(tok)]
stopifnot(all(grepl("^[0-9]+$", tok)))
used <- sort(unique(as.integer(tok)))
missing <- setdiff(used, seq_along(cit))
if (length(missing))
  stop("key(s) cited by Table 1 with no entry in the ESM list: ", paste(missing, collapse = ", "),
       call. = FALSE)
n_rows_citing <- vapply(used, function(k) sum(vapply(strsplit(snap$References, ","), function(z)
  k %in% as.integer(trimws(z[nzchar(trimws(z))])), logical(1)), na.rm = TRUE), integer(1))

## 6. NOTES -------------------------------------------------------------
## Per-key notes record (a) how many Table 1 rows cite the key and (b) anything the ESM
## prints that a reader would otherwise take for our transcription error. Kept verbatim.
verbatim_note <- c(
  "6"  = paste("ESM 1 prints the first author as 'de V. Pienar, U' (no final 'a', no stop)",
               "and the publisher as 'C. Struick Publishers'; the work is by de V. Pienaar,",
               "U., published by C. Struik. Kept verbatim as printed."),
  "10" = "ESM 1 prints 'Sesaonal' for 'Seasonal'. Kept verbatim as printed.",
  "18" = paste("ESM 1 prints 'John Hopkins University Press'; the publisher is Johns Hopkins",
               "University Press. Kept verbatim as printed."),
  "26" = "ESM 1 prints the page range with a space, '251 -261'. Kept verbatim as printed.")

refs <- data.frame(
  ref_key        = as.character(used),
  cited_in_column = "References",
  citation       = unname(cit[as.character(used)]),
  note           = paste0("cited by ", n_rows_citing, " of the 64 species rows of ESM 1 Table 1.",
                          ifelse(as.character(used) %in% names(verbatim_note),
                                 paste0(" ", verbatim_note[as.character(used)]), "")),
  stringsAsFactors = FALSE)

## 7. THE MEASUREMENT SOURCE (a second key namespace, as BensonAmram_etal_2016 does) ---
## The numbers 1-30 attribute the migratory/sedentary CATEGORY only. Every body mass and
## volume in Table 1 comes from one compilation, named in the table caption ("Baron et
## al., 1996") and listed as reference 17 of the Biology Letters paper; the item's
## measurement_source column carries that key on every row. Read the entry from the
## paper PDF rather than retyping it: it sits in the right-hand column of the last page.
paper_pdf <- file.path(folder, "McGuire_Ratcliffe_2011.pdf")
stopifnot(file.exists(paper_pdf))
pp <- pdf_data(paper_pdf)[[4]]
pp <- pp[order(pp$y, pp$x), ]
ys <- sort(unique(pp$y)); pp$line <- cumsum(c(TRUE, diff(ys) > 2))[match(pp$y, ys)]
start <- pp$line[which(pp$text == "Baron,")[1]]
stopifnot(length(start) == 1L, !is.na(start))
col <- function(L) { q <- pp[pp$line == L & pp$x >= 290, ]; q$text[order(q$x)] }
stopifnot(identical(col(start)[1:2], c("17", "Baron,")))
entry <- col(start); L <- start + 1L
repeat {
  w <- col(L)
  if (!length(w) || grepl("^[0-9]{1,2}$", w[1])) break
  entry <- c(entry, w); L <- L + 1L
}
baron <- trimws(gsub("\\s+", " ", paste(entry[-1], collapse = " ")))
stopifnot(grepl("^Baron, G\\., Stephan, H\\. & Frahm, H\\. D\\. 1996 ", baron), grepl("Verlag\\.$", baron))
refs <- rbind(refs, data.frame(
  ref_key = "Baron_etal_1996", cited_in_column = "measurement_source", citation = baron,
  note = paste("Source of every body mass and volume in ESM 1 Table 1, named in the table",
               "caption ('Baron et al., 1996') and listed as reference 17 of the Biology",
               "Letters paper; the caption also states the conversion applied to it,",
               "brain volume = brain mass / 1.036. Not part of the ESM 1 numbered list,",
               "so its key is the repo folder name rather than a number. Cited by all 64",
               "species rows."),
  stringsAsFactors = FALSE))

## The one entry the ESM lists but Table 1 never cites is recorded in the definitions
## Note and the item ReadMe, not here: this file carries only the keys the item uses.
uncited <- setdiff(seq_along(cit), used)
stopifnot(nrow(refs) == 30L, identical(uncited, 14L), !any(grepl("  ", refs$citation)))
utils::write.csv(refs, refs_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("wrote ", basename(refs_csv), ": ", length(used), " of ", length(cit),
        " ESM 1 numbered entries resolved (uncited by Table 1: ", paste(uncited, collapse = ", "),
        ") + the measurement source = ", nrow(refs), " rows")

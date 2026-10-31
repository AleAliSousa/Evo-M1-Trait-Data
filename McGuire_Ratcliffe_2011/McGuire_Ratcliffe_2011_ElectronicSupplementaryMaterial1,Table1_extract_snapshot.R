## McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_extract_snapshot.R
##
## McGuire, L. P., & Ratcliffe, J. M. (2011). Light enough to travel: Migratory bats have
## smaller brains, but not larger hippocampi, than sedentary species. Biology Letters,
## 7(2), 233-236. doi:10.1098/rsbl.2010.0744
##
## Builds the FROZEN SNAPSHOT of Electronic Supplementary Material 1, Table 1 from the
## text layer of rsbl20100744supp1.pdf (pages 1-2).  No table value is typed in this
## script: every cell is read from the PDF word stream (pdftools::pdf_data) and placed in
## a column by its x position, so the printed blank cells stay blank and the printed row
## order is preserved.  The snapshot is the audit anchor; all cleaning happens later in
## McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1.R.
##
## Refuses to overwrite an existing frozen snapshot that differs -- writes
## *_snapshot_REGENERATED.csv next to it instead, for a human to diff.

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
item_name <- sub("_extract_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))
setwd(folder)
source_pdf   <- file.path(folder, "rsbl20100744supp1.pdf")
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
stopifnot(file.exists(source_pdf))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages(library(pdftools))

## 2. WORDS ---------------------------------------------------------
## Table 1 occupies PDF pages 1-2.  The repository watermark is set in ArialMT; the table
## itself is Times New Roman throughout, so font name alone separates them.
pages <- pdf_data(source_pdf, font_info = TRUE)[1:2]
pages <- lapply(pages, function(p) {
  p <- p[grepl("TimesNewRoman", p$font_name), ]
  p$xc <- p$x + p$width / 2
  p[order(p$y, p$x), ]
})

## Group words into printed lines (same baseline, +/- 2 pt).
lines_of <- function(p) {
  ys <- sort(unique(p$y)); grp <- cumsum(c(TRUE, diff(ys) > 2))
  p$line <- grp[match(p$y, ys)]
  split(p, p$line)
}

is_num   <- function(s) grepl("^[0-9]+(\\.[0-9]+)?$", s)
CATEGORY <- c("Sedentary", "Migratory")

## 3. COLUMN ANCHORS (per page, learned from the complete data rows) ----
## A species row is a line carrying a bare "Sedentary"/"Migratory" token well to the right
## of the species column; the two summary rows carry the same words at the far left,
## followed by "(n".  Rows that print all six numbers define the six numeric anchors.
classify <- function(ln) {
  i <- which(ln$text %in% CATEGORY)
  if (!length(i)) return(NULL)
  i <- i[1]
  if (ln$xc[i] > 300) list(kind = "species", at = i) else list(kind = "summary", at = i)
}

anchors_for <- function(lns) {
  xs <- lapply(lns, function(ln) {
    cl <- classify(ln); if (is.null(cl) || cl$kind != "species") return(NULL)
    before <- ln[seq_len(cl$at - 1L), ]
    n <- before[is_num(before$text), ]
    if (nrow(n) == 6L) n$xc else NULL
  })
  xs <- do.call(rbind, xs[!vapply(xs, is.null, logical(1))])
  stopifnot(!is.null(xs), nrow(xs) >= 10L)
  apply(xs, 2, stats::median)
}

## 4. READ THE TABLE, PAGE BY PAGE, IN PRINTED ORDER --------------------
NUMCOL <- c("Body (g)", "Brain (mm3)", "Neocortex (mm3)", "Hippocampus (mm3)",
            "Medulla Oblongata (mm3)", "Cerebellum (mm3)")
COLS   <- c("Family", "Species", NUMCOL, "Category", "References")

blank_row <- function() stats::setNames(as.list(rep("", length(COLS))), COLS)

rows <- list(); header_line <- NULL
for (pg in seq_along(pages)) {
  lns  <- lines_of(pages[[pg]])
  anch <- anchors_for(lns)
  sp_x <- NULL                      # species-column anchor, for the family/species split
  for (ln in lns) {
    cl <- classify(ln)
    if (is.null(cl)) {
      if (pg == 1L && is.null(header_line) && any(ln$text == "Family")) header_line <- ln
      next
    }
    r <- blank_row()
    if (cl$kind == "species") {
      before <- ln[seq_len(cl$at - 1L), ]
      nums   <- before[is_num(before$text), ]
      words  <- before[!is_num(before$text), ]
      ## the binomial is the last two words; anything before it is the family label
      stopifnot(nrow(words) >= 2L)
      r[["Species"]] <- paste(utils::tail(words$text, 2L), collapse = " ")
      if (nrow(words) > 2L) r[["Family"]] <- paste(utils::head(words$text, nrow(words) - 2L), collapse = " ")
      if (is.null(sp_x)) sp_x <- utils::tail(words$xc, 2L)[1]
      for (k in seq_len(nrow(nums))) {
        j <- which.min(abs(anch - nums$xc[k]))
        if (nzchar(r[[NUMCOL[j]]])) stop("two values claim the same column on: ", r[["Species"]])
        r[[NUMCOL[j]]] <- nums$text[k]
      }
      r[["Category"]]   <- ln$text[cl$at]
      after <- ln[seq_len(nrow(ln)) > cl$at, ]
      r[["References"]] <- paste(after$text, collapse = " ")
    } else {
      ## summary row: left-hand label, then "mean ± se" triples under the numeric columns
      lab  <- ln[ln$xc < anch[1] - 25, ]
      vals <- ln[ln$xc >= anch[1] - 25, ]
      r[["Family"]] <- paste(lab$text, collapse = " ")
      if (nrow(vals)) {
        j <- vapply(vals$xc, function(z) which.min(abs(anch - z)), integer(1))
        for (k in sort(unique(j)))
          r[[NUMCOL[k]]] <- paste(vals$text[j == k], collapse = " ")
      }
    }
    rows[[length(rows) + 1L]] <- r
  }
}
snap <- do.call(rbind.data.frame, c(rows, list(stringsAsFactors = FALSE)))
names(snap) <- COLS

## 5. HEADER, FROM THE PRINTED HEADER WORDS ----------------------------
## The printed heading is set over three lines (the four sub-region labels sit one line
## above "Family ... Category References", their "(mm3)" units one line below).  Rebuild
## each heading from the words that fall in its own column, so the file's header row is
## the published header rather than a retyped one.
stopifnot(!is.null(header_line))
hdr_words <- pages[[1]][pages[[1]]$y >= min(header_line$y) - 5 & pages[[1]]$y <= min(header_line$y) + 8, ]
## read in printed order: by heading line, then left to right -- a superscript sits a
## point or two above its own line, so group baselines within 2 pt before sorting on x
hw_ys <- sort(unique(hdr_words$y))
hdr_words$line <- cumsum(c(TRUE, diff(hw_ys) > 2))[match(hdr_words$y, hw_ys)]
hdr_words <- hdr_words[order(hdr_words$line, hdr_words$x), ]
anch_all  <- c(min(pages[[1]]$xc[pages[[1]]$text == "Family"]),
               sp_x,
               anchors_for(lines_of(pages[[1]])),
               min(pages[[1]]$xc[pages[[1]]$text == "Category"]),
               min(pages[[1]]$xc[pages[[1]]$text == "References"]))
j   <- vapply(hdr_words$xc, function(z) which.min(abs(anch_all - z)), integer(1))
hdr <- vapply(seq_along(COLS), function(k) paste(hdr_words$text[j == k], collapse = " "), character(1))
hdr <- gsub("\\(mm 3 \\)", "(mm3)", hdr)         # superscript 3 is its own word in the PDF
hdr <- trimws(gsub("\\s+", " ", hdr))
stopifnot(identical(hdr, COLS))                   # the printed header is what we assumed
names(snap) <- hdr

## 6. INTEGRITY OF THE CAPTURE ------------------------------------------
n_species <- sum(snap$Category %in% CATEGORY)
stopifnot(nrow(snap) == 66L, n_species == 64L,          # caption: "the 64 species"
          sum(snap$Category == "Migratory") == 31L,     # summary row: n = 31
          sum(snap$Category == "Sedentary") == 33L,     # summary row: n = 33
          !any(duplicated(snap$Species[nzchar(snap$Species)])),
          all(nzchar(snap[["Body (g)"]][seq_len(n_species)])),
          all(nzchar(snap[["Brain (mm3)"]][seq_len(n_species)])),
          all(nzchar(snap$References[seq_len(n_species)])))

## 7. FREEZE -------------------------------------------------------------
out <- snapshot_csv
if (file.exists(snapshot_csv)) {
  old <- utils::read.csv(snapshot_csv, colClasses = "character", check.names = FALSE,
                         encoding = "UTF-8", na.strings = NULL)
  if (isTRUE(all.equal(old, snap, check.attributes = FALSE))) {
    message("Frozen snapshot unchanged: ", basename(snapshot_csv))
    out <- NA_character_
  } else {
    out <- sub("_snapshot\\.csv$", "_snapshot_REGENERATED.csv", snapshot_csv)
    warning("Frozen snapshot differs -- wrote ", basename(out), " for a human to diff.",
            call. = FALSE)
  }
}
if (!is.na(out)) {
  utils::write.csv(snap, out, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("wrote ", basename(out), ": ", nrow(snap), " rows x ", ncol(snap), " columns")
}

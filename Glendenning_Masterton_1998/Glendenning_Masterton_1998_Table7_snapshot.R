## Glendenning_Masterton_1998_Table7_snapshot.R -- frozen source for Table7 only
## (one snapshot script per item; the sibling scripts do Tables 1-7 separately).
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of
## mammalian central auditory systems: Variation in nuclei and form of the
## ascending system. Brain Behav Evol 51:59-89. doi:10.1159/000006530
##
## Table 7 (p. 84): animal rankings by similarity in form of the superior olives (r lists).
## The PDF is born-digital (Karger) with a clean text layer. Every cell is taken
## from the text layer by word COORDINATES (pdftools::pdf_data);
## no value is typed in this script. Header labels are the printed literals; captions and
## footnotes are captured verbatim by anchored regex.
## Structural checks (row counts, every cell filled except the printed blanks) run before
## anything is written, and an existing frozen snapshot that differs is never overwritten.
## reference_tables/<Item>_footnotes.csv (caption, footnote) is written as before.
## Checks that need a sibling table (animal names equal to Table 1's) are not made here:
## see internal_checks/ (build HOWTO 7b).
##
## R port (2026-11-12) of Glendenning_Masterton_1998_Table7_snapshot.py (R-first rule), which is retired as
## Glendenning_Masterton_1998_Table7_snapshot.py.retired. Verified in a temp dir (never in place): the regenerated snapshot
## CSV is byte-identical to the frozen one (sha256 equal).
## Run: Rscript Glendenning_Masterton_1998_Table7_snapshot.R   (needs the pdftools package)

suppressPackageStartupMessages(library(pdftools))

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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # "Glendenning_Masterton_1998_TableN"
base      <- sub("_Table[0-9]+$", "_", item_name)       # file-name prefix "Glendenning_Masterton_1998_"
PDF       <- file.path(folder, "Glendenning-1998-Comparative Morphometry of Ma.pdf")
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))
NUC <- c("AVCN", "PVCN", "DCN", "MTB", "LSO", "MSO", "VLL", "DLL", "IC", "MG")

dat <- pdf_data(PDF, font_info = FALSE)

## words of one PDF page: x0/x1/y0/y1 (pt, as pdftools reports them) + centres
words <- function(page) {
  d <- dat[[page]]
  data.frame(x0 = d$x, y0 = d$y, x1 = d$x + d$width, y1 = d$y + d$height, w = d$text,
             stringsAsFactors = FALSE) |>
    transform(xc = (x0 + x1) / 2, yc = (y0 + y1) / 2)
}
## group words into text lines (same yc within tol of the line's first word)
lines_of <- function(d, tol = 2.0) {
  d <- d[order(d$yc, d$x0), ]
  if (!nrow(d)) return(list())
  g <- integer(nrow(d)); k <- 1L; ref <- d$yc[1]
  for (i in seq_len(nrow(d))) {
    if (abs(d$yc[i] - ref) > tol) { k <- k + 1L; ref <- d$yc[i] }
    g[i] <- k
  }
  split(d, g)
}
page_text <- function(page) gsub("\\s+", " ", paste(dat[[page]]$text, collapse = " "), perl = TRUE)   # words in text-flow order
grab <- function(page, start, end) {
  t <- page_text(page)
  m <- regexpr(paste0(gsub("([.\\\\|()\\[{^$*+?])", "\\\\\\1", start), ".*?", end), t, perl = TRUE)
  if (m < 0) stop("anchor not found p", page, ": ", start, call. = FALSE)
  trimws(regmatches(t, m))
}

## pandas-style minimal-quoting CSV, "\n" line ends, UTF-8, no BOM
csv_cell <- function(x) ifelse(grepl("[\",\r\n]", x), paste0("\"", gsub("\"", "\"\"", x), "\""), x)
csv_string <- function(df, header = names(df)) {
  rows <- apply(as.matrix(df), 1, function(r) paste(csv_cell(r), collapse = ","))
  paste0(paste(c(paste(csv_cell(header), collapse = ","), rows), collapse = "\n"), "\n")
}
## write only if absent; an existing frozen snapshot that differs is never overwritten
write_frozen <- function(df, path, header = names(df)) {
  out <- csv_string(df, header)
  if (file.exists(path)) {
    old <- readChar(path, file.info(path)$size, useBytes = TRUE); Encoding(old) <- "UTF-8"
    if (!identical(old, out)) stop("REFUSING to overwrite differing ", path, call. = FALSE)
    return("unchanged")
  }
  con <- file(path, "wb"); writeBin(charToRaw(enc2utf8(out)), con); close(con); "written"
}

main_write <- function(t, notes, label) {
  dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
  res <- write_frozen(t, file.path(folder, paste0(item_name, "_snapshot.csv")))
  if (!is.null(notes)) res <- c(res, write_frozen(notes, file.path(folder, "reference_tables", paste0(item_name, "_footnotes.csv"))))
  cat(label, dim(t), res, "\n")
}
notes_df <- function(cap, foot) data.frame(element = c("caption", "footnote"), text_as_printed = c(cap, foot), stringsAsFactors = FALSE)

## ------------------------------------------------------------ Tables 5-7 (r lists)
rtable <- function(page, label, anchor_end) {
  d <- words(page)
  stop_y <- min(d$yc[d$w == "Ranks"])
  body <- d[d$yc > 92 & d$yc < stop_y - 2 & d$x0 >= 200, ]   # caption sits in the left margin
  rows <- list()
  for (L in lines_of(body)) {
    g <- function(lo, hi) { s <- L[L$x0 >= lo & L$x0 < hi, ]; paste(s$w[order(s$x0)], collapse = " ") }
    rows[[length(rows) + 1L]] <- c(g(200, 312), g(312, 370), g(370, 470), g(470, 503), g(503, 1e9))
  }
  t <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  names(t) <- c("Alphabetical order", "r", "Descending order", "r2", "")
  stopifnot(nrow(t) == 54L, t[["Alphabetical order"]][54] == "", all(t[["Alphabetical order"]][1:53] != ""))
  num <- "^[\u2013-]?\\d\\.\\d{3}$"
  stopifnot(all(grepl(num, t$r[1:53])), all(grepl(num, t$r2)))
  sq <- function(x) gsub("\\s+", " ", x)
  a <- setNames(t$r[1:53], sq(t[["Alphabetical order"]][1:53]))
  dsc <- setNames(t$r2, sq(t[["Descending order"]]))
  avg <- grep("^Average", names(dsc)); stopifnot(length(avg) == 1L)
  dsc <- dsc[-avg]
  stopifnot(identical(sort(paste(names(a), a)), sort(paste(names(dsc), dsc))))
  notes <- notes_df(grab(page, paste0("Table ", label, ". Animal rankings based on"), anchor_end),
                    grab(page, "Ranks less than", "reliably different\\."))
  list(t = t, notes = notes)
}
r <- rtable(26, 7, "form of superior olives")
write_hdr <- c("Alphabetical order", "r", "Descending order", "r", "")   # headers exactly as printed
dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
cat("Table7", dim(r$t), write_frozen(r$t, file.path(folder, paste0(item_name, "_snapshot.csv")), write_hdr),
    write_frozen(r$notes, file.path(folder, "reference_tables", paste0(item_name, "_footnotes.csv"))), "\n")

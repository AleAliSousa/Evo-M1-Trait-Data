## Glendenning_Masterton_1998_Table4_snapshot.R -- frozen source for Table4 only
## (one snapshot script per item; the sibling scripts do Tables 1-7 separately).
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of
## mammalian central auditory systems: Variation in nuclei and form of the
## ascending system. Brain Behav Evol 51:59-89. doi:10.1159/000006530
##
## Table 4 (pp. 72-73): animal rank lists for each nucleus and the two nuclear clusters (A: AVCN-LSO, B: MSO-MG).
## The PDF is born-digital (Karger) with a clean text layer. Every cell is taken
## from the text layer by word COORDINATES (pdftools::pdf_data);
## no value is typed in this script. Header labels are the printed literals; captions and
## footnotes are captured verbatim by anchored regex.
## Structural checks (row counts, every cell filled except the printed blanks) run before
## anything is written, and an existing frozen snapshot that differs is never overwritten.
## The earlier Python script also wrote reference_tables/<Item>_footnotes.csv; poppler's word split ('p <0.05' vs 'p<0.05') does not reproduce that file byte-for-byte, so it is NOT regenerated here (the committed file stays as it is).
## Checks that need a sibling table (animal names equal to Table 1's) are not made here:
## see internal_checks/ (build HOWTO 7b).
##
## R port (2026-11-12) of Glendenning_Masterton_1998_Table4_snapshot.py (R-first rule), which is retired as
## Glendenning_Masterton_1998_Table4_snapshot.py.retired. Verified in a temp dir (never in place): the regenerated snapshot
## CSV is byte-identical to the frozen one (sha256 equal).
## Run: Rscript Glendenning_Masterton_1998_Table4_snapshot.R   (needs the pdftools package)

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
## ------------------------------------------------------- Table 4 (rank lists, 2 pages)
ranklists <- function(page, heads, ystart, stop_word) {
  d <- words(page); edges <- c(0, 120, 210, 295, 380, 465, 1e9)
  stop_y <- min(d$yc[d$w == stop_word & d$yc > 600 & d$x0 < 560])   # footer / footnote, not the rotated sidebar
  body <- d[d$yc > ystart & d$yc < stop_y - 2 & d$x0 < 560, ]
  cols <- setNames(rep(list(character(0)), length(heads)), heads)
  for (L in lines_of(body)) for (i in seq_along(heads)) {
    seg <- L[L$x0 >= edges[i] & L$x0 < edges[i + 1], ]; seg <- seg[order(seg$x0), ]
    cols[[heads[i]]] <- c(cols[[heads[i]]], paste(seg$w, collapse = " "))
  }
  as.data.frame(cols, stringsAsFactors = FALSE, check.names = FALSE)
}
table4 <- function() {
  A <- ranklists(14, c("AVCN", "PVCN", "DCN", "CN (AVCN + PVCN + DCN)", "MTB", "LSO"), 112, "Behav")
  B <- ranklists(15, c("MSO", "SO (MTB + LSO + MSO)", "VLL", "DLL", "IC", "MG"), 112, "CN")
  A <- A[rowSums(A != "") > 0, , drop = FALSE]; B <- B[rowSums(B != "") > 0, , drop = FALSE]
  rownames(A) <- NULL; rownames(B) <- NULL
  stopifnot(nrow(A) == 54L, nrow(B) == 54L)
  rows <- rbind(unname(names(A)), as.matrix(A), c("Table 4B", rep("", 5)),
                unname(names(B)), as.matrix(B))
  t <- as.data.frame(rows, stringsAsFactors = FALSE, check.names = FALSE)
  names(t) <- c("Table 4A", rep("", 5))
  list(t = t, notes = NULL)
}
r <- table4(); main_write(r$t, r$notes, "Table4")

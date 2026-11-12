## Glendenning_Masterton_1998_Table3_snapshot.R -- frozen source for Table3 only
## (one snapshot script per item; the sibling scripts do Tables 1-7 separately).
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of
## mammalian central auditory systems: Variation in nuclei and form of the
## ascending system. Brain Behav Evol 51:59-89. doi:10.1159/000006530
##
## Table 3 (p. 71): normalized logarithmic percentage sizes (53 animals; 12 columns).
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
## R port (2026-11-12) of Glendenning_Masterton_1998_Table3_snapshot.py (R-first rule), which is retired as
## Glendenning_Masterton_1998_Table3_snapshot.py.retired. Verified in a temp dir (never in place): the regenerated snapshot
## CSV is byte-identical to the frozen one (sha256 equal).
## Run: Rscript Glendenning_Masterton_1998_Table3_snapshot.R   (needs the pdftools package)

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

## ------------------------------------ species rows with numeric columns (Tables 2, 3)
numeric_table <- function(page, hdrs, ymin, ymax, name_xmax) {
  d <- words(page)
  y_hdr <- min(d$yc[d$w == hdrs[1]])
  h <- d[d$w %in% hdrs & abs(d$yc - y_hdr) < 3, ]
  h <- h[!duplicated(h$w), ]
  right <- setNames(h$x1[match(hdrs, h$w)], hdrs)
  rows <- list()
  for (L in lines_of(d[d$yc > ymin & d$yc < ymax, ])) {
    L <- L[order(L$x0), ]; nm <- L$w[L$x1 <= name_xmax]; nums <- L[L$x1 > name_xmax, ]
    no <- ""
    if (length(nm) && grepl("^\\d{1,2}$", nm[1])) { no <- nm[1]; nm <- nm[-1] }
    rec <- c(`No.` = no, Animal = paste(nm, collapse = " "), setNames(rep("", length(hdrs)), hdrs))
    for (i in seq_len(nrow(nums))) {
      k <- hdrs[which.min(abs(right[hdrs] - nums$x1[i]))]
      stopifnot(rec[[k]] == "")
      rec[[k]] <- nums$w[i]
    }
    rows[[length(rows) + 1L]] <- rec
  }
  as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE, check.names = FALSE)
}
table3 <- function() {
  H <- c("AVCN", "PVCN", "DCN", "CN", "MTB", "LSO", "MSO", "SO", "VLL", "DLL", "IC", "MG")
  t <- numeric_table(13, H, 95, 675, 160)
  stopifnot(nrow(t) == 53L, all(t[H] != ""))
  list(t = t, notes = notes_df(grab(13, "Table 3. Normalized logarithmic", "table 2"),
                               grab(13, "In each column, mean is 0", "is 0\\.137\\.")))
}
r <- table3(); main_write(r$t, r$notes, "Table3")

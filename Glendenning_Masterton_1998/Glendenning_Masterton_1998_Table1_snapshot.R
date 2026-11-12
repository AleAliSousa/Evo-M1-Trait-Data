## Glendenning_Masterton_1998_Table1_snapshot.R -- frozen source for Table1 only
## (one snapshot script per item; the sibling scripts do Tables 1-7 separately).
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of
## mammalian central auditory systems: Variation in nuclei and form of the
## ascending system. Brain Behav Evol 51:59-89. doi:10.1159/000006530
##
## Table 1 (p. 62, printed rotated 90 deg): in vitro volumes of the 10 ascending nuclei in 53 mammals, with body/brain weights and the printed total.
## The PDF is born-digital (Karger) with a clean text layer. Every cell is taken
## from the text layer by word COORDINATES (pdftools::pdf_data); Table 1 is printed rotated 90 deg, so rows are page-x positions and columns page-y bands;
## no value is typed in this script. Header labels are the printed literals; captions and
## footnotes are captured verbatim by anchored regex.
## Structural checks (row counts, every cell filled except the printed blanks) run before
## anything is written, and an existing frozen snapshot that differs is never overwritten.
## reference_tables/<Item>_footnotes.csv (caption, footnote, abbreviations) is written as before.
## Checks that need a sibling table (animal names equal to Table 1's) are not made here:
## see internal_checks/ (build HOWTO 7b).
##
## R port (2026-11-12) of Glendenning_Masterton_1998_Table1_snapshot.py (R-first rule), which is retired as
## Glendenning_Masterton_1998_Table1_snapshot.py.retired. Verified in a temp dir (never in place): the regenerated snapshot
## CSV is byte-identical to the frozen one (sha256 equal).
## Run: Rscript Glendenning_Masterton_1998_Table1_snapshot.R   (needs the pdftools package)

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
## Table 1 is printed rotated: the footnote text is read from the layout text of the page
page_text <- function(page) gsub("\\s+", " ", paste(pdf_text(PDF)[page], collapse = " "), perl = TRUE)
table1 <- function() {
  d <- words(4); body <- d[d$x0 > 95 & d$x1 < 520, ]
  body$row <- as.integer(round((body$xc - 103.45) / 7.798)) + 1L
  bands <- list(c("Animal No.", 680, 800), c("Common name", 600, 680), c("Genus and species", 500, 600),
                c("Source", 460, 500), c("Body gm", 425, 460), c("Brain gm", 390, 425),
                c("AVCN", 362, 390), c("PVCN", 332, 362), c("DCN", 303, 332), c("MTB", 275, 303),
                c("LSO", 245, 275), c("MSO", 215, 245), c("VLL", 186, 215), c("DLL", 155, 186),
                c("IC", 125, 155), c("MG", 92, 125), c("Total", 0, 92))
  bn <- vapply(bands, `[`, "", 1)
  recs <- vector("list", 53)
  for (r in 1:53) {
    s <- body[body$row == r, ]; s <- s[order(-s$y1), ]
    rec <- setNames(vector("list", length(bn)), bn)
    for (i in seq_len(nrow(s))) for (b in bands) {
      if (as.numeric(b[2]) <= s$yc[i] && s$yc[i] < as.numeric(b[3])) { rec[[b[1]]] <- c(rec[[b[1]]], s$w[i]); break }
    }
    rec <- vapply(rec, function(v) paste(v, collapse = " "), "")
    rec["Animal No."] <- sub("^.*?(\\d+)$", "\\1", rec["Animal No."], perl = TRUE)   # drop running-head words
    recs[[r]] <- rec
  }
  t <- as.data.frame(do.call(rbind, recs), stringsAsFactors = FALSE, check.names = FALSE)
  ## poppler (pdftools) expands the printed U+FB01 ligature in "A<fi>p." to "fi"; the frozen snapshot keeps the
  ## ligature code exactly as the text layer carries it (checked: the only ligature cell in Table 1)
  t[["Source"]] <- sub("^Afip\\.$", "A\uFB01p.", t[["Source"]])
  stopifnot(identical(t[["Animal No."]], as.character(1:53)))
  blanks <- NULL
  for (cn in names(t)) for (i in seq_len(nrow(t))) if (t[[cn]][i] == "") blanks <- rbind(blanks, c(t[["Common name"]][i], cn))
  stopifnot(identical(unname(blanks), rbind(c("Chinchilla", "Brain gm"), c("Mink", "Brain gm"))))   # printed blanks
  notes <- data.frame(element = c("caption", "footnote", "abbreviations"),
    text_as_printed = c(grab(4, "Table 1. In vitro volumes", "\\(.total.\\)"),
                        grab(4, "Body weights in parentheses", "Indiana University\\."),
                        grab(4, "AVCN = Anteroventral", "MG = medial geniculate\\.")), stringsAsFactors = FALSE)
  list(t = t, notes = notes)
}
r <- table1()
dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
cat("Table1", dim(r$t), write_frozen(r$t, file.path(folder, paste0(item_name, "_snapshot.csv"))),
    write_frozen(r$notes, file.path(folder, "reference_tables", paste0(item_name, "_footnotes.csv"))), "\n")

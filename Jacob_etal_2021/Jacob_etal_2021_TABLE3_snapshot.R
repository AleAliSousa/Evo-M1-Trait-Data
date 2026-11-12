## Jacob_etal_2021_TABLE3_snapshot.R — PDF text layer -> the frozen snapshot of TABLE3
##
## Source→snapshot step, made reproducible (HOWTO §2 / snapshot HOWTO method 3):
## every DATA value (means, SEMs, group Ns, F, df, p, ηp²) is EXTRACTED from the
## PDF's text layer at run time — no value is typed into this script. Only
## structural literals live here (captions, printed headers, table-note lines),
## and each is verified against the PDF via an anchor assertion before writing.
##
## Writes ONLY: Jacob_etal_2021_TABLE3_snapshot.csv
## The item build script (Jacob_etal_2021_TABLE3.R) READS this frozen
## file; it never regenerates it.
##
## Frozen-file guard: if a snapshot already exists and the extraction differs,
## the new version is written to *_snapshot_NEW.csv and the run stops — the
## frozen copy never changes silently.
##
## Text-layer quirks handled (documented in the per-item ReadMes):
##   - two-column pages: layout text interleaves the columns line-by-line, so
##     the gutter is detected per page and columns are read left-then-right;
##   - footnote superscripts sometimes float away from their number
##     ("18.52 ± 0.82   a") — reattached ("18.52 ± 0.82a") to match the page;
##   - the printed multiplication sign in "200 × 300 μm" is unmapped in the
##     text layer (renders as a space) — restored in the note literal;
##   - the printed x̄c renders as "xc", and two panel-B means carry a stray
##     space ("43,959, 439") — kept verbatim (FIGURE4 cleaning strips non-digits).

## 0. PATHS (no setwd) --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or source from RStudio (save the file first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
pdf_file  <- file.path(paper_dir, "Jacob-2021-Cytoarchitectural characteristics a.pdf")
if (!file.exists(pdf_file)) stop("Source PDF not found: ", pdf_file, call. = FALSE)
if (!requireNamespace("pdftools", quietly = TRUE)) stop("Install pdftools", call. = FALSE)

## 1. TEXT LAYER ---------------------------------------------------------------
pages  <- pdftools::pdf_text(pdf_file)
squish <- function(x) trimws(gsub("[[:space:]]+", " ", paste(x, collapse = " ")))
S <- squish(pages)                      # layout order (columns interleave)

## reconstruct two-column reading order: detect the blank gutter per page,
## then read all left halves, then all right halves
split_columns <- function(page) {
  lines <- strsplit(page, "\n", fixed = TRUE)[[1]]
  best_pos <- NA_integer_; best_frac <- 0
  for (pos in 50:110) {
    cand <- lines[nchar(lines) > pos + 5]
    if (length(cand) < 10) next
    frac <- mean(substr(cand, pos + 1, pos + 1) == " ")
    if (frac > best_frac) { best_pos <- pos; best_frac <- frac }
  }
  if (is.na(best_pos) || best_frac < 0.85) return(paste(lines, collapse = " "))
  paste(paste(substr(lines, 1, best_pos), collapse = " "),
        paste(substring(lines, best_pos + 1), collapse = " "))
}
SC <- squish(vapply(pages, split_columns, character(1)))   # reading order

anchor <- function(x, where = S)
  if (!grepl(x, where, fixed = TRUE)) stop("PDF anchor not found: ", x, call. = FALSE)
cap <- function(pattern, where = SC) {
  m <- regmatches(where, regexec(pattern, where, perl = TRUE))[[1]]
  if (!length(m)) stop("PDF pattern not found: ", pattern, call. = FALSE)
  m[-1]
}

## 2. TABLE ROWS ----------------------------------------------------------------
## one printed cell: "mean ± sem" + optional footnote marker (reattached)
VAL <- "(\\d+(?:\\.\\d+)?) ± (\\d+(?:\\.\\d+)?)\\s*([ab*])?(?![A-Za-z0-9])"
ROW <- "(Nonsolver|Intermediate|Solver) \\(N = (\\d+)\\)"

extract_rows <- function(n_values, expected_labels) {
  rm <- gregexpr(ROW, S, perl = TRUE)[[1]]
  starts <- as.integer(rm); lens <- attr(rm, "match.length")
  labs <- character(0); ns <- character(0); cell_list <- list()
  for (i in seq_along(starts)) {
    lab_full <- substr(S, starts[i], starts[i] + lens[i] - 1L)
    pos <- starts[i] + lens[i]
    cells <- character(0); ok <- TRUE
    for (k in seq_len(n_values)) {
      rest <- substring(S, pos)
      m <- regexpr(paste0("^ ?", VAL), rest, perl = TRUE)
      if (m == -1L) { ok <- FALSE; break }
      frag <- regmatches(rest, m)
      g <- regmatches(frag, regexec(VAL, frag, perl = TRUE))[[1]]
      cells <- c(cells, paste0(g[2], " ± ", g[3], g[4]))
      pos <- pos + attr(m, "match.length")
    }
    if (ok) {
      labs <- c(labs, sub(" \\(N = \\d+\\)$", "", lab_full))
      ns <- c(ns, sub("^.*N = (\\d+).*$", "\\1", lab_full))
      cell_list[[length(labs)]] <- cells
    }
  }
  for (i in seq_len(length(labs) - length(expected_labels) + 1L))
    if (identical(labs[i:(i + length(expected_labels) - 1L)], expected_labels))
      return(list(labels = labs[i:(i + length(expected_labels) - 1L)],
                  n = ns[i:(i + length(expected_labels) - 1L)],
                  cells = cell_list[i:(i + length(expected_labels) - 1L)]))
  stop("Row sequence not found: ", paste(expected_labels, collapse = ", "), call. = FALSE)
}

## frozen-file guard + writer (UTF-8, LF)
write_snapshot <- function(lines, filename) {
  path <- file.path(paper_dir, filename)
  txt <- paste0(paste(lines, collapse = "\n"), "\n")
  if (file.exists(path)) {
    old <- readChar(path, file.info(path)$size, useBytes = TRUE)
    if (identical(old, txt)) { message(filename, ": unchanged (frozen)"); return(invisible()) }
    alt <- sub("\\.csv$", "_NEW.csv", path)
    con <- file(alt, open = "wb"); writeLines(enc2utf8(txt), con, sep = "", useBytes = TRUE); close(con)
    stop(filename, " differs from the frozen copy — review ", basename(alt),
         " against the PDF before replacing it.", call. = FALSE)
  }
  con <- file(path, open = "wb"); writeLines(enc2utf8(txt), con, sep = "", useBytes = TRUE); close(con)
  message(filename, ": written")
}

## ---- TABLE 3 (5 value columns) ------------------------------------------------
anchor("TABLE 3")
anchor("Cytoarchitecture analysis of the hilus of the dentate gyrus region in raccoons")
anchor("Fusiform neurons")
t3 <- extract_rows(5, c("Nonsolver", "Intermediate", "Solver"))
write_snapshot(c(
  "TABLE 3 Cytoarchitecture analysis of the hilus of the dentate gyrus region in raccoons,,,,,",
  "Solver type,Nonneurons,Neuron total,Fusiform neurons,% Fusiform neuronsa,% All neuronsb",
  vapply(seq_along(t3$labels), function(i)
    paste0(t3$labels[i], " (N = ", t3$n[i], "),", paste(t3$cells[[i]], collapse = ",")), character(1)),
  "\"Note: Values (mean ± SEM) represent averages from the field of vision (200 × 300 μm), and are not cumulative counts.\",,,,,",
  "a % Fusiform neurons represent the proportion of neurons characterized as fusiform cells.,,,,,",
  "b % Neurons represents the proportion of total cells that were characterized as either fusiform cells or other neurons.,,,,,"
), "Jacob_etal_2021_TABLE3_snapshot.csv")


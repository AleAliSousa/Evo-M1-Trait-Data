## Heffner_etal_2014_Figure3_snapshot.R -- frozen-source builder for Figure 3.
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna
## pacos): Audiogram, localization acuity, and use of binaural locus cues.
## J. Acoust. Soc. Am. 135, 778-788. doi:10.1121/1.4861344
##
## R port of the former Heffner_etal_2014_Figure3_snapshot.py (renamed
## Heffner_etal_2014_Figure3_snapshot.py.retired). Writes ONLY
## Heffner_etal_2014_Figure3_snapshot.csv and refuses to overwrite a differing frozen copy.
##
## FIG. 3 (PDF p. 6, journal p. 782) plots the auditory detection thresholds of
## three alpacas.  The plotted symbols ARE the letters A, B and C (one per
## individual); the solid grey line is the mean.  The figure is a RASTER image
## (embedded bitmap 682 x 1015 px, 8-bit grey; no vector paths), so values are
## pixel-digitised from the embedded bitmap at its native resolution (poppler
## `pdfimages`, which writes the image stream itself) -- never from a re-render:
##
##  1. axis lines  = the longest fully dark column / row.  Ticks = dark runs just
##     outside them.  y ticks carry the printed labels 80..0 dB SPL (step 10);
##     x ticks are the 14 printed test frequencies.
##  2. calibration: y linear in dB (least squares on the nine detected ticks);
##     x linear in log10(frequency).  NOTE the tick printed "20" sits at the
##     log position of 22.5 kHz (residual 0.07% against 22.5 vs 10.4% against 20),
##     and the Results text names 22.5 kHz as a test frequency -- the snapshot
##     freezes BOTH the printed label and the position-implied value and the
##     discrepancy is recorded as erratum Heffner_etal_2014-E001.
##  3. letters: connected components of the dark mask inside the plot frame,
##     excluding the title band; components taller than 24 px are two stacked
##     letters and wider than 22 px are two side-by-side letters, split at the
##     glyph height/width (17 / 15 px).  Each box is then identified as A, B or C
##     by normalised cross-correlation against exemplars cut from the uncrowded
##     1 kHz cluster.  Exactly 42 letters are required (14 frequencies x 3 animals).
##  4. writes Heffner_etal_2014_Figure3_snapshot.csv and refuses to overwrite a
##     differing frozen copy.
##
## Run (conda env "evom1-r": magick; poppler `pdfimages` on PATH):
##     Rscript Heffner_etal_2014_Figure3_snapshot.R

## 0. PATHS --------------------------------------------------------
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))
pdf_file     <- file.path(folder, paste0(basename(folder), ".pdf"))
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
## 1. HELPERS (pixel work on the bitmap embedded in the PDF) --------
## Rows/columns are kept 0-based in the arithmetic, exactly as in the original Python
## builder; `px()` converts a 0-based half-open slice (python a[r0:r1, c0:c1]) into an R sub-matrix.
suppressPackageStartupMessages(library(png))

## the embedded bitmap, at native resolution, as an integer matrix [row, col] (never a re-render):
## poppler's pdfimages writes the image stream itself; the image is chosen by page + expected shape.
load_bitmap <- function(pdf, page_no, shape) {
  tmp <- tempfile("pdfimg"); dir.create(tmp)
  st <- system2("pdfimages", c("-png", "-f", page_no, "-l", page_no, shQuote(pdf), file.path(tmp, "im")),
                stdout = FALSE, stderr = FALSE)
  if (st != 0) stop("pdfimages (poppler) failed on ", pdf, call. = FALSE)
  for (f in list.files(tmp, full.names = TRUE)) {
    d <- png::readPNG(f)
    if (length(dim(d)) != 2L) stop("expected a greyscale embedded PNG: ", f, call. = FALSE)
    a <- matrix(as.integer(round(d * 255)), nrow = nrow(d), ncol = ncol(d))
    if (identical(dim(a), as.integer(shape))) return(a)
  }
  stop("no embedded bitmap of shape ", paste(shape, collapse = " x "), " on PDF page ", page_no, call. = FALSE)
}
px <- function(a, r0, r1, c0, c1) a[(r0 + 1):r1, (c0 + 1):c1, drop = FALSE]

## runs of TRUE in a logical vector -> list of c(start, end), 0-based inclusive
runs <- function(mask) {
  idx <- which(mask) - 1L
  if (!length(idx)) return(list())
  br <- c(0L, which(diff(idx) != 1L), length(idx))
  lapply(seq_len(length(br) - 1L), function(k) c(idx[br[k] + 1L], idx[br[k + 1L]]))
}
run_mid <- function(r) vapply(r, function(z) (z[1] + z[2]) / 2, numeric(1))

## 8-connected component labels, numbered in raster (row-major) order of the first pixel,
## as scipy.ndimage.label(m, ones((3, 3))) does
label_cc <- function(m) {
  nr <- nrow(m); nc <- ncol(m)
  f <- as.vector(t(m)); lab <- integer(nr * nc); n <- 0L
  for (p in which(f)) {
    if (lab[p] != 0L) next
    n <- n + 1L; lab[p] <- n; stack <- p
    while (length(stack)) {
      q <- stack[length(stack)]; stack <- stack[-length(stack)]
      r <- (q - 1L) %/% nc; cc <- (q - 1L) %% nc
      for (dr in -1:1) for (dc in -1:1) {
        r2 <- r + dr; c2 <- cc + dc
        if (r2 < 0L || r2 >= nr || c2 < 0L || c2 >= nc) next
        q2 <- r2 * nc + c2 + 1L
        if (f[q2] && lab[q2] == 0L) { lab[q2] <- n; stack <- c(stack, q2) }
      }
    }
  }
  list(lab = matrix(lab, nr, nc, byrow = TRUE), n = n)
}
polyfit1 <- function(x, y) unname(lm.fit(cbind(x, 1), y)$coefficients)   # c(slope, intercept)
polyval1 <- function(k, x) k[1] * x + k[2]

## text forms of the frozen CSV (repr of floats; csv with minimal quoting; "\n" line ends)
pyfloat <- function(x) vapply(x, function(v) {
  if (is.na(v)) return("")
  if (v == 0) return(if (1 / v < 0) "-0.0" else "0.0")
  for (d in 1:17) { s <- sprintf(paste0("%.", d - 1L, "e"), v); if (as.numeric(s) == v) break }
  e10 <- as.integer(sub(".*e", "", s)); k <- max(0L, d - 1L - e10)
  if (e10 < -4L || e10 >= 16L) stop("exponent-style repr not implemented for ", v)
  out <- sprintf(paste0("%.", k, "f"), v)
  if (k == 0L) paste0(out, ".0") else out
}, character(1))
pylist <- function(x, int = FALSE) paste0("[", paste(if (int) as.character(as.integer(x)) else pyfloat(x), collapse = ", "), "]")
pyfield <- function(s) ifelse(grepl("[,\"\n\r]", s), paste0("\"", gsub("\"", "\"\"", s), "\""), s)
pycsv <- function(cols) {   # named list of character vectors, already formatted
  paste0(paste(names(cols), collapse = ","), "\n",
         paste0(do.call(paste, c(lapply(cols, pyfield), sep = ",")), "\n", collapse = ""))
}
## never overwrite a differing frozen copy
write_frozen <- function(out, path) {
  if (file.exists(path)) {
    old <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    if (!identical(paste0(old, "\n"), out)) stop("REFUSING to overwrite differing frozen snapshot ", path, call. = FALSE)
    cat("snapshot unchanged\n"); return(invisible(FALSE))
  }
  writeBin(charToRaw(enc2utf8(out)), path)
  cat("wrote", path, "\n"); invisible(TRUE)
}

## 2. FIGURE-SPECIFIC CONSTANTS --------------------------------------
PAGE_NO <- 6L                      # PDF page 6, journal p. 782
SHAPE   <- c(682L, 1015L)
FREQ_PRINTED  <- c(.025, .032, .063, .125, .250, .500, 1, 2, 4, 8, 16, 20, 32, 40)
FREQ_POSITION <- c(.025, .032, .063, .125, .250, .500, 1, 2, 4, 8, 16, 22.5, 32, 40)
Y_TICKS <- c(80, 70, 60, 50, 40, 30, 20, 10, 0)

## normalised cross-correlation of a template over an image, scipy fftconvolve(mode = "same") alignment:
## the template is zero-centred with its background set to -0.35 first; returns the maximum score
ncc_max <- function(img, t) {
  t0 <- t; t0[t0 == 0] <- -0.35; t0 <- t0 - mean(t0)
  H <- nrow(img); W <- ncol(img); kh <- nrow(t0); kw <- ncol(t0)
  oh <- (kh - 1L) %/% 2L; ow <- (kw - 1L) %/% 2L          # 'same' = centred crop of the full result
  best <- -Inf
  for (m in oh:(oh + H - 1L)) for (n in ow:(ow + W - 1L)) {   # full-result index (0-based)
    s <- m - (kh - 1L); u <- n - (kw - 1L)                     # template offset on the image
    r0 <- max(0L, s); r1 <- min(H, s + kh); c0 <- max(0L, u); c1 <- min(W, u + kw)
    if (r0 >= r1 || c0 >= c1) { v <- 0 } else
      v <- sum(img[(r0 + 1L):r1, (c0 + 1L):c1] * t0[(r0 - s + 1L):(r1 - s), (c0 - u + 1L):(c1 - u)])
    if (v > best) best <- v
  }
  best / sqrt(sum(t0^2))
}

## 3. DIGITISE ------------------------------------------------------
a <- load_bitmap(pdf_file, PAGE_NO, SHAPE); dark <- a < 100
yaxis <- which.max(colSums(dark)) - 1L          # 95
xaxis <- which.max(rowSums(dark)) - 1L          # 596
yt <- run_mid(runs(apply(px(dark, 0, nrow(dark), yaxis - 10L, yaxis - 2L), 1, all)))
xt <- run_mid(runs(apply(px(dark, xaxis + 1L, xaxis + 9L, 0, ncol(dark)), 2, all)))
stopifnot(length(yt) == 9L, length(xt) == 14L)
cfy     <- polyfit1(yt, Y_TICKS)
cfx_pos <- polyfit1(xt, log10(FREQ_POSITION))
cfx_lab <- polyfit1(xt, log10(FREQ_PRINTED))

## letter exemplars from the uncrowded 1 kHz cluster
tA <- px(dark, 480, 497, 531, 547) * 1.0
tB <- px(dark, 485, 502, 547, 561) * 1.0
tC <- px(dark, 480, 498, 560, 575) * 1.0

mask <- matrix(FALSE, nrow(dark), ncol(dark)); mask[13:594, 99:1014] <- dark[13:594, 99:1014]
mask[11:30, 381:690] <- FALSE                                    # figure title
CC <- label_cc(mask)
boxes <- list()
for (i in seq_len(CC$n)) {
  w <- which(CC$lab == i, arr.ind = TRUE)
  rs <- min(w[, 1]) - 1L; re <- max(w[, 1]); cs <- min(w[, 2]) - 1L; ce <- max(w[, 2])   # python slice start/stop
  h <- re - rs; wd <- ce - cs
  if (nrow(w) < 50L || !(h >= 13L && h <= 40L && wd >= 8L && wd <= 45L)) next
  nrow_ <- if (h > 24L) 2L else 1L; ncol_ <- if (wd > 22L) 2L else 1L
  for (ri in 0:(nrow_ - 1L)) for (ci in 0:(ncol_ - 1L)) {
    r0 <- if (nrow_ == 2L) rs + ri * (h - 17L) else rs
    r1 <- if (nrow_ == 2L) r0 + 17L else re
    c0 <- if (ncol_ == 2L) cs + ci * (wd - 15L) else cs
    c1 <- if (ncol_ == 2L) c0 + 15L else ce
    boxes[[length(boxes) + 1L]] <- list(r0 = r0, r1 = r1, c0 = c0, c1 = c1, merged = nrow_ * ncol_ > 1L)
  }
}
rows <- list()
for (b in boxes) {
  sub <- px(dark, max(0L, b$r0 - 4L), min(nrow(dark), b$r1 + 4L), max(0L, b$c0 - 4L), min(ncol(dark), b$c1 + 4L)) * 1.0
  sc <- c(A = ncc_max(sub, tA), B = ncc_max(sub, tB), C = ncc_max(sub, tC))
  letter <- names(sc)[which.max(sc)]
  xc <- (b$c0 + b$c1) / 2; yc <- (b$r0 + b$r1) / 2
  j <- which.min(abs(xt - xc))                     # 1-based; frequency_index = j - 1
  rows[[length(rows) + 1L]] <- data.frame(
    frequency_index = j - 1L,
    frequency_kHz_printed_label = FREQ_PRINTED[j],
    animal_letter = letter,
    px_x = round(xc, 1), px_y = round(yc, 1),
    threshold_dB_SPL = round(polyval1(cfy, yc), 2),
    frequency_kHz_from_tick_position = round(10^polyval1(cfx_pos, xt[j]), 3),
    frequency_kHz_from_printed_labels = round(10^polyval1(cfx_lab, xt[j]), 3),
    glyph_was_merged = if (b$merged) "yes" else "no",
    ncc_A = round(sc[["A"]], 2), ncc_B = round(sc[["B"]], 2), ncc_C = round(sc[["C"]], 2),
    stringsAsFactors = FALSE)
}
M <- do.call(rbind, rows)
M <- M[order(M$frequency_index, M$animal_letter), ]
stopifnot("expected 42 letters (14 frequencies x 3 animals)" = nrow(M) == 42L,
          all(table(M$frequency_index) == 3L))
## 60-dB arrows: the two long dark columns inside the plot frame
cols <- colSums(px(dark, 0, nrow(dark), 100, 1010))
arrow_px <- sort(order(cols, decreasing = FALSE)[length(cols) - 1:0] - 1L + 100L)
hdr <- paste0("# Heffner_etal_2014_Figure3 constructed snapshot -- digitised letter markers.\n",
              "# y ticks (px): ", pylist(round(yt, 1)), " -> ", pylist(Y_TICKS, int = TRUE),
              " dB SPL; x ticks (px): ", pylist(round(xt, 1)), "\n",
              "# 60-dB arrows at px columns ", pylist(arrow_px, int = TRUE), " -> ",
              pylist(round(10^polyval1(cfx_pos, arrow_px), 3)), " kHz (text: 0.040 and 32.8 kHz)\n")
out <- paste0(hdr, pycsv(list(
  frequency_index = as.character(M$frequency_index),
  frequency_kHz_printed_label = pyfloat(M$frequency_kHz_printed_label),
  animal_letter = M$animal_letter,
  px_x = pyfloat(M$px_x), px_y = pyfloat(M$px_y),
  threshold_dB_SPL = pyfloat(M$threshold_dB_SPL),
  frequency_kHz_from_tick_position = pyfloat(M$frequency_kHz_from_tick_position),
  frequency_kHz_from_printed_labels = pyfloat(M$frequency_kHz_from_printed_labels),
  glyph_was_merged = M$glyph_was_merged,
  ncc_A = pyfloat(M$ncc_A), ncc_B = pyfloat(M$ncc_B), ncc_C = pyfloat(M$ncc_C))))

## 4. WRITE (only ever the snapshot itself) -------------------------------
write_frozen(out, snapshot_csv)

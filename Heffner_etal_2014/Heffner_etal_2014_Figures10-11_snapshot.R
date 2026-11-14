## Heffner_etal_2014_Figures10-11_snapshot.R -- frozen-source builder for Figures 10 and 11.
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna
## pacos): Audiogram, localization acuity, and use of binaural locus cues.
## J. Acoust. Soc. Am. 135, 778-788. doi:10.1121/1.4861344
##
## R port of the former Heffner_etal_2014_Figures10-11_snapshot.py (renamed
## Heffner_etal_2014_Figures10-11_snapshot.py.retired). Writes ONLY
## Heffner_etal_2014_Figures10-11_snapshot.csv and refuses to overwrite a differing frozen copy.
##
## The registry treats Figures 10 and 11 as ONE item ("Sound-localization acuity
## and functional interaural distance among species using one vs both binaural
## locus cues"): the two figures carry the same species roster and the same
## left/right cue-use grouping, Fig. 10 on a LINEAR sound-localization-threshold
## scale (0-35 deg) and Fig. 11 on a LOGARITHMIC functional-interaural-distance
## scale (40-4000 us).
##
## FIG. 10 is PDF p. 10 (journal p. 786), bitmap 1273 x 754 px;
## FIG. 11 is PDF p. 11 (journal p. 787), bitmap 1280 x 754 px -- both raster,
## so values are pixel-digitised from the embedded bitmaps at native resolution
## (poppler `pdfimages`, which writes the image stream itself; never a re-render).
##
## Method (identical for both panels):
##  1. the grey value bar is located by its two black border columns;
##  2. the numeric scale labels printed inside the bar give the calibration rows;
##     Fig. 10 is calibrated linearly (residuals < 0.04 deg), Fig. 11 as
##     log10(us) linear in row (residuals < 0.35%);
##  3. a species leader line is a connected component touching a bar border from
##     outside and wider than 40 px (narrower components are caption text);
##     the row where it meets the bar is the datum, the row of its far end
##     identifies which printed label it serves;
##  4. where two labels share one tick the leader lines merge into a single
##     component ending at one row -- those species are given the SAME value and
##     flagged shares_tick_with.
##
## The printed label texts (top-to-bottom order, verified against the rendered
## page) are the only hand-entered content.
##
## Run (conda env "evom1-r": magick; poppler `pdfimages` on PATH):
##     Rscript Heffner_etal_2014_Figures10-11_snapshot.R

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
F10 <- list(page = 10L, shape = c(1273L, 754L), tick_values = c(35, 30, 25, 20, 15, 10, 5, 0),
            left  = list("prairie dog", "kangaroo rat, gerbil", "chinchilla", "least weasel",
                         "Egyptian fruit bat", "Jamaican fruit bat", "Japanese macaque",
                         "cat", "human"),
            right = list("domestic mouse", "cattle", "horse", "alpaca", "hedgehog",
                         "spiny mouse", "*goat", "short-tailed fruit bat", "big brown bat",
                         "Norway rat", "straw-colored fruit bat", "dog-faced fruit bat",
                         "greater spear-nosed bat", "pig", "*elephant"))
F11 <- list(page = 11L, shape = c(1280L, 754L), tick_values = c(4000, 2000, 1000, 800, 400, 200, 100, 80, 40),
            left  = list("human", "Japanese macaque", "cat", "chinchilla",
                         c("Egyptian fruit bat", "prairie dog"), c("kangaroo rat", "Jamaican fruit bat"),
                         "gerbil", "least weasel"),
            right = list("*elephant", "cattle", "*goat, horse", "alpaca", "pig",
                         "hedgehog", "Norway rat", "straw-colored fruit bat",
                         "greater spear-nosed bat", "dog-faced fruit bat", "spiny mouse",
                         "domestic mouse", "big brown bat", "short-tailed fruit bat"))
## each element is one leader line; a line serving two printed labels carries both (Fig. 11),
## while comma-joined printed labels ("kangaroo rat, gerbil", "*goat, horse") stay one string (split downstream)

bar_borders <- function(a) {   # columns (0-based) of the two black borders of the grey value bar
  grey <- (a > 150) & (a < 235)
  cc <- which(colSums(grey) > 0.5 * max(colSums(grey))) - 1L
  cd <- colSums(a < 128)
  lo <- Filter(function(c) cd[c + 1L] > 0.5 * nrow(a), (min(cc) - 6L):(min(cc) + 2L))
  hi <- Filter(function(c) cd[c + 1L] > 0.5 * nrow(a), (max(cc) - 4L):(max(cc) + 4L))
  list(c(min(lo), max(lo)), c(min(hi), max(hi)))
}

leader_lines <- function(a, bl, br, min_width = 40) {
  ## per side: the rows at which species leader lines meet the bar, with the row of their
  ## far (text) end -- the far row identifies the printed label, the attach row carries the value
  d <- a < 128
  out <- list()
  for (side in c("L", "R")) {
    if (side == "L") { sub <- d[, seq_len(bl[1]), drop = FALSE]; ac <- bl[1] - 1L
    } else { sub <- d[, (br[2] + 2L):ncol(d), drop = FALSE]; ac <- 0L }
    L <- label_cc(sub)$lab
    ids <- sort(unique(L[, ac + 1L])); ids <- ids[ids > 0L]
    rows <- list()
    for (i in ids) {
      w <- which(L == i, arr.ind = TRUE); ys <- w[, 1] - 1L; xs <- w[, 2] - 1L
      if (max(xs) - min(xs) < min_width) next      # figure titles / axis captions, not leaders
      far <- if (side == "L") min(xs) else max(xs)
      rows[[length(rows) + 1L]] <- c(attach_row = round(mean(ys[xs == ac]), 1),
                                     far_row = round(mean(ys[xs == far]), 1), n_px = length(ys))
    }
    M <- do.call(rbind, rows)
    out[[side]] <- M[order(M[, "far_row"]), , drop = FALSE]
  }
  out
}

numeral_rows <- function(a, bl, br) {   # row centres of the numeric scale labels printed inside the grey bar
  d <- a < 128
  inside <- px(d, 0, nrow(d), bl[2] + 10L, br[1] - 8L)
  L <- label_cc(inside)
  cen <- sort(vapply(seq_len(L$n), function(i) {
    r <- which(rowSums(L$lab == i) > 0) - 1L; (min(r) + max(r) + 1L) / 2 }, numeric(1)))
  groups <- list()
  for (cc in cen) {
    if (length(groups) && abs(cc - groups[[length(groups)]][length(groups[[length(groups)]])]) < 12)
      groups[[length(groups)]] <- c(groups[[length(groups)]], cc)
    else groups[[length(groups) + 1L]] <- cc
  }
  round(vapply(groups, mean, numeric(1)), 1)
}

## 3. DIGITISE ------------------------------------------------------
digitise <- function(spec, figure, quantity, log_scale) {
  a <- load_bitmap(pdf_file, spec$page, spec$shape)
  bb <- bar_borders(a); bl <- bb[[1]]; br <- bb[[2]]
  nrows <- numeral_rows(a, bl, br)
  tv <- spec$tick_values
  ## the numeric labels inside the bar, top to bottom, are the printed scale values;
  ## trailing groups below the bar are the figure's axis caption -- drop them.
  cal_rows <- if (length(nrows) >= length(tv)) nrows[seq_along(tv)] else nrows
  y <- if (log_scale) log10(tv) else as.numeric(tv)
  if (length(nrows) > length(tv)) {
    ## the first group may be an unlabelled top tick: pick the run of len(tv)
    best <- NULL; bestres <- NULL
    for (i in 0:(length(nrows) - length(tv))) {
      cand <- nrows[i + seq_along(tv)]
      res <- max(abs(polyval1(polyfit1(cand, y), cand) - y))
      if (is.null(bestres) || res < bestres) { best <- cand; bestres <- res }
    }
    cal_rows <- best
  }
  cf <- polyfit1(cal_rows, y)
  resid <- polyval1(cf, cal_rows) - y
  o <- order(cal_rows); pxs <- cal_rows[o]; ys <- y[o]
  piece <- function(p) {
    n <- length(pxs)
    v <- if (p < pxs[1]) polyval1(polyfit1(pxs[1:2], ys[1:2]), p)
         else if (p > pxs[n]) polyval1(polyfit1(pxs[n - 1:0], ys[n - 1:0]), p)
         else approx(pxs, ys, xout = p)$y
    if (log_scale) 10^v else v
  }
  LL <- leader_lines(a, bl, br)
  rows <- list()
  for (side in c("L", "R")) {
    sidename <- if (side == "L") "both cues (left of scale)" else "only one cue (right of scale)"
    grp <- if (side == "L") spec$left else spec$right
    comps <- LL[[side]]
    stopifnot(nrow(comps) == length(grp))
    for (k in seq_len(nrow(comps))) {
      r <- comps[k, "attach_row"]
      for (lb in grp[[k]])
        rows[[length(rows) + 1L]] <- data.frame(
          figure = figure, label_as_printed = lb, cue_group = sidename,
          px_attach_row = r, px_label_row = comps[k, "far_row"],
          value = round(piece(r), 3),
          value_globalfit = round(if (log_scale) 10^polyval1(cf, r) else polyval1(cf, r), 3),
          quantity = quantity,
          shares_tick_with = paste(setdiff(grp[[k]], lb), collapse = "; "), stringsAsFactors = FALSE)
    }
  }
  list(rows = do.call(rbind, rows), cal_rows = cal_rows, resid = resid)
}

d10 <- digitise(F10, "Figure 10", "sound_localization_threshold_deg", FALSE)
d11 <- digitise(F11, "Figure 11", "functional_interaural_distance_us", TRUE)
M <- rbind(d10$rows, d11$rows)
stopifnot(nrow(d10$rows) == 24L, nrow(d11$rows) == 24L)
hdr <- paste0("# Heffner_etal_2014_Figures10-11 constructed snapshot -- digitised leader-line scale positions.\n",
              "# Fig.10 linear scale ", pylist(F10$tick_values, int = TRUE), " deg at px rows ",
              pylist(round(d10$cal_rows, 1)), "; fit residuals (deg): ", pylist(round(d10$resid, 3)), "\n",
              "# Fig.11 log scale ", pylist(F11$tick_values, int = TRUE), " us at px rows ",
              pylist(round(d11$cal_rows, 1)), "; fit residuals (%): ", pylist(round(100 * (10^d11$resid - 1), 2)), "\n")
out <- paste0(hdr, pycsv(list(
  figure = M$figure, label_as_printed = M$label_as_printed, cue_group = M$cue_group,
  px_attach_row = pyfloat(M$px_attach_row), px_label_row = pyfloat(M$px_label_row),
  value = pyfloat(M$value), value_globalfit = pyfloat(M$value_globalfit),
  quantity = M$quantity, shares_tick_with = M$shares_tick_with)))

## 4. WRITE (only ever the snapshot itself) -------------------------------
write_frozen(out, snapshot_csv)

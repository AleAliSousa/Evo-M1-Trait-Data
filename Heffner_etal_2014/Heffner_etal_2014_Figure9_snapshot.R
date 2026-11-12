## Heffner_etal_2014_Figure9_snapshot.R -- frozen-source builder for Figure 9.
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna
## pacos): Audiogram, localization acuity, and use of binaural locus cues.
## J. Acoust. Soc. Am. 135, 778-788. doi:10.1121/1.4861344
##
## R port of the former Heffner_etal_2014_Figure9_snapshot.py (renamed
## Heffner_etal_2014_Figure9_snapshot.py.retired). Writes ONLY
## Heffner_etal_2014_Figure9_snapshot.csv and refuses to overwrite a differing frozen copy.
##
## FIG. 9 (PDF p. 9, journal p. 785) is a one-dimensional logarithmic scale of
## behaviourally determined sound-localization thresholds, 1 deg to 180 deg.  Each
## common name printed beside the scale is joined to the bar by a leader line; the
## row at which that line meets the bar IS the datum.  The figure is a RASTER
## image (embedded bitmap 1535 x 754 px, 8-bit grey), so values are pixel-digitised
## from the embedded bitmap at its native resolution (poppler `pdfimages`, which
## writes the image stream itself) -- never from a re-render:
##
##  1. the grey value bar is located by its two black border columns.
##  2. scale ticks are the dark runs projecting inward from each border; the seven
##     printed labels (180, 100, 50, 20, 10, 5, 1 deg) are matched to them.
##  3. calibration: log10(threshold) linear in pixel row, least squares on those
##     seven ticks (residuals < 0.5%); a piecewise-linear interpolation between
##     adjacent printed ticks is carried as the primary value and the single-fit
##     value as *_globalfit, their difference being the calibration spread.
##  4. leader lines are the connected components that touch the bar border from
##     outside and are wider than 30 px (narrower ones are title text).  The row
##     of the far end of each line identifies which printed label it serves; the
##     label texts themselves are listed here in printed top-to-bottom order
##     (the only hand-entered content, verified against the rendered page).
##  5. writes Heffner_etal_2014_Figure9_snapshot.csv.
##
## Run (conda env "evom1-r": magick; poppler `pdfimages` on PATH):
##     Rscript Heffner_etal_2014_Figure9_snapshot.R
## Not run in place on the frozen copy: the guard in write_frozen() only compares.

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
suppressPackageStartupMessages(library(magick))

## the embedded bitmap, at native resolution, as an integer matrix [row, col] (never a re-render):
## poppler's pdfimages writes the image stream itself; the image is chosen by page + expected shape.
load_bitmap <- function(pdf, page_no, shape) {
  tmp <- tempfile("pdfimg"); dir.create(tmp)
  st <- system2("pdfimages", c("-png", "-f", page_no, "-l", page_no, shQuote(pdf), file.path(tmp, "im")),
                stdout = FALSE, stderr = FALSE)
  if (st != 0) stop("pdfimages (poppler) failed on ", pdf, call. = FALSE)
  for (f in list.files(tmp, full.names = TRUE)) {
    d <- image_data(image_read(f), channels = "gray")
    a <- t(matrix(as.integer(d[1, , ]), nrow = dim(d)[2], ncol = dim(d)[3]))
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
PAGE_NO <- 9L                      # PDF page 9 (journal p. 785)
SHAPE   <- c(1535L, 754L)
TICK_VALUES <- c(180, 100, 50, 20, 10, 5, 1)
TICK_ROWS   <- c(171.5, 321.5, 501.0, 735.0, 914.5, 1093.5, 1506.5)
LABELS_LEFT <- c("blind mole rat, gopher", "naked mole rat", "domestic mouse", "marmot",
                 "kangaroo rat, gerbil", "cottontail rabbit", "grasshopper mouse",
                 "hedgehog, hamster", "chinchilla", "short-tailed fruit bat",
                 "big brown bat, fox squirrel", "Norway rat", "straw-colored fruit bat",
                 "Egyptian fruit bat", "dog-faced fruit bat", "Jamaican fruit bat",
                 "greater spear-nose bat", "opossum", "porpoise")
LABELS_RIGHT <- c("cow", "horse", "alpaca", "goat", "least weasel", "ferret", "sea lion",
                  "dog", "Japanese macaque", "harbor seal", "squirrel monkey", "cat",
                  "pig", "human", "elephant")

bar_borders <- function(a) {   # columns (0-based) of the two black borders of the grey value bar
  grey <- (a > 150) & (a < 235)
  cc <- which(colSums(grey) > 0.5 * max(colSums(grey))) - 1L
  cd <- colSums(a < 128)
  lo <- Filter(function(c) cd[c + 1L] > 0.5 * nrow(a), (min(cc) - 6L):(min(cc) + 2L))
  hi <- Filter(function(c) cd[c + 1L] > 0.5 * nrow(a), (max(cc) - 4L):(max(cc) + 4L))
  list(c(min(lo), max(lo)), c(min(hi), max(hi)))
}

leader_lines <- function(a, bl, br, min_width = 30) {
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

scale_ticks <- function(a, bl, br) {
  d <- a < 128
  inL <- round(run_mid(runs(apply(px(d, 0, nrow(d), bl[2] + 1L, bl[2] + 7L), 1, all))), 1)
  inR <- round(run_mid(runs(apply(px(d, 0, nrow(d), br[1] - 6L, br[1]), 1, all))), 1)
  list(inL, inR)
}

## 3. DIGITISE ------------------------------------------------------
a <- load_bitmap(pdf_file, PAGE_NO, SHAPE)
bb <- bar_borders(a); bl <- bb[[1]]; br <- bb[[2]]
tk <- scale_ticks(a, bl, br); inL <- tk[[1]]; inR <- tk[[2]]
stopifnot(all(abs(TICK_ROWS - inL[vapply(inL, function(x) min(abs(TICK_ROWS - x)) < 2, logical(1))]) < 2))
cf <- polyfit1(TICK_ROWS, log10(TICK_VALUES))
o <- order(TICK_ROWS); pxs <- TICK_ROWS[o]; lv <- log10(TICK_VALUES)[o]
piece <- function(p) {
  if (p < pxs[1]) 10^polyval1(polyfit1(pxs[1:2], lv[1:2]), p)
  else if (p > pxs[length(pxs)]) 10^polyval1(polyfit1(pxs[length(pxs) - 1:0], lv[length(lv) - 1:0]), p)
  else 10^approx(pxs, lv, xout = p)$y
}
LL <- leader_lines(a, bl, br)
stopifnot(nrow(LL$L) == length(LABELS_LEFT), nrow(LL$R) == length(LABELS_RIGHT))
M <- NULL
for (side in c("left (rodents, bats, other)", "right (hoofed mammals, carnivores, primates)")) {
  comps <- if (startsWith(side, "left")) LL$L else LL$R
  labs  <- if (startsWith(side, "left")) LABELS_LEFT else LABELS_RIGHT
  for (k in seq_len(nrow(comps))) {
    r <- comps[k, "attach_row"]
    M <- rbind(M, data.frame(label_as_printed = labs[k], scale_side = side,
                             px_attach_row = r, px_label_row = comps[k, "far_row"],
                             localization_threshold_deg = round(piece(r), 3),
                             localization_threshold_deg_globalfit = round(10^polyval1(cf, r), 3),
                             n_species_in_label = lengths(regmatches(labs[k], gregexpr(",", labs[k]))) + 1L,
                             stringsAsFactors = FALSE))
  }
}
stopifnot(nrow(M) == 34L)
resid <- 100 * (10^polyval1(cf, TICK_ROWS) / TICK_VALUES - 1)
hdr <- paste0("# Heffner_etal_2014_Figure9 constructed snapshot -- digitised leader-line scale positions.\n",
              "# printed ticks ", pylist(TICK_VALUES, int = TRUE), " deg at px rows ", pylist(TICK_ROWS),
              "; global log fit residuals (%): ", pylist(round(resid, 2)), "\n",
              "# detected scale ticks (left/right inner): ", pylist(inL), " / ", pylist(inR), "\n")
out <- paste0(hdr, pycsv(list(
  label_as_printed = M$label_as_printed, scale_side = M$scale_side,
  px_attach_row = pyfloat(M$px_attach_row), px_label_row = pyfloat(M$px_label_row),
  localization_threshold_deg = pyfloat(M$localization_threshold_deg),
  localization_threshold_deg_globalfit = pyfloat(M$localization_threshold_deg_globalfit),
  n_species_in_label = as.character(M$n_species_in_label))))

## 4. WRITE (only ever the snapshot itself) -------------------------------
write_frozen(out, snapshot_csv)

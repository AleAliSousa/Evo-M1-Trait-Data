## Huttenlocher__1979_Figure6_snapshot.R -- frozen-source builder for Figure6 (writes ONLY Huttenlocher__1979_Figure6_snapshot.csv)
##
## (Split from the retired Huttenlocher__1979_Figures3-6_extract.py, one script per output: this script
## digitises ONLY Figure6. R port of Huttenlocher__1979_Figure6_snapshot.py, retired as Huttenlocher__1979_Figure6_snapshot.py.retired.)
##
## Huttenlocher, P. R. (1979). Synaptic density in human frontal cortex: developmental
## changes and effects of aging. Brain Res. 163, 195-205. doi:10.1016/0006-8993(79)90349-4
##
## The paper publishes NO data table: every value lives in a figure. Four figures are digitised in this
## paper, each into its own frozen snapshot by its own script:
##   Fig. 3 (p. 199) synapse counts in layer 3 of middle frontal gyrus vs age, filled circles
##   Fig. 4 (p. 200) neuronal density in the same layer vs age; OPEN circles = this study,
##                   FILLED circles = Schade & Van Groenigen (ref. 18)
##   Fig. 5 (p. 203) mean synapses per neuron vs age, open triangles (DERIVED: Fig3 / Fig4)
##   Fig. 6 (p. 203) total brain weights vs age, open circles
##
## The PDF pages are grey SCANS (1950 x 3000 px, one embedded 1-bit CCITT bitmap per page); values are
## pixel-digitised from that embedded bitmap at native resolution (extracted losslessly with pdfimages,
## poppler-utils), never from a re-render. The image processing (hole filling, disk erosion,
## 8-connected labelling, centroids, least-squares lines) is implemented in base R below.
##
##   1. AXES.  Per figure the ordinate is the longest dark column and the abscissa the longest dark row
##      (their positions are fixed in FIGS). Ordinate ticks are located as the short marks protruding to
##      the left of the ordinate and fitted by least squares against their printed labels.
##   2. THE ABSCISSA IS BROKEN AND PIECEWISE LINEAR. Fig. 3 prints NB 0.5 1 // 5 10 15 20 // 40 60 80 100
##      and Figs. 4-6 print NB 0.5 1 2 // 5 10 // Adult Aged(74-90). Each printed tick is located below the
##      abscissa and matched to its printed label (the label text centroids are found independently and
##      used to disambiguate the break glyphs "//" from real ticks). Age is then interpolated WITHIN the
##      segment the point falls in; a point lying in an axis-break gap is flagged (age_in_axis_break) and
##      its age is extrapolated from the nearer segment -- it is not an exact reading. "Adult" and
##      "Aged (74-90)" are CATEGORICAL columns and get no numeric age.
##   3. MARKERS. Open markers (circles, triangles) are found as the white region they enclose: fill the
##      holes of the dark mask, subtract, and keep hole blobs of marker size and roughly square aspect.
##      This survives the fitted curve and the error bars passing through a marker. Filled circles are
##      found by eroding the dark mask with a disk, which removes the curve and the error bars and leaves
##      one blob per marker.
##   4. Writes the one snapshot and refuses to overwrite a differing frozen copy.
##
## Why this was ported (2026-11-12): R-first rule. Verified in a temp dir (never in place): the regenerated
## snapshot is byte-identical to the frozen one (sha256 equal). Needs R packages png; system tool pdfimages.
## Run: Rscript Huttenlocher__1979_Figure6_snapshot.R

suppressPackageStartupMessages(library(png))

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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # "Huttenlocher__1979_FigureN"
fig       <- sub("^.*_(Figure[0-9]+)$", "\\1", item_name)
PDF       <- file.path(folder, "Huttenlocher-1979-Synaptic density in human fr.pdf")

## figure -> page index (0-based), ordinate column, abscissa row, plot box, ordinate labels,
##           abscissa label sequence, marker kinds
FIGS <- list(
  Figure6 = list(page = 8L, yax = 351L, xrow = 2446L, box = c(1570L, 2443L, 356L, 1400L),
                 ylab = c(1400, 1200, 1000, 800, 600, 400, 200), n_ytick = 7L,
                 xlab = list(list("NB", 0.0), list("0.5", 0.5), list("1", 1.0), list("2", 2.0), list("5", 5.0),
                             list("10", 10.0), list("Adult", NULL), list("Aged (74-90)", NULL)),
                 segs = list(c(0L, 3L), c(4L, 5L)),
                 series = list(open_circle = "Total brain weight"),
                 unit = "grams")
)
C <- FIGS[[fig]]

## ---------------------------------------------------------------- image helpers
## The page is one embedded 1-bit (CCITT) bitmap; pdfimages (poppler-utils) writes it losslessly.
page_bitmap <- function(i) {
  if (!nzchar(Sys.which("pdfimages")))
    stop("pdfimages (poppler-utils) is needed to extract the embedded page bitmap", call. = FALSE)
  d <- tempfile("hut"); dir.create(d)
  st <- system2("pdfimages", c("-png", "-f", i + 1, "-l", i + 1, shQuote(PDF), file.path(d, "pg")))
  f <- list.files(d, pattern = "^pg-000\\.png$", full.names = TRUE)
  if (st != 0 || length(f) != 1L) stop("pdfimages failed on page ", i + 1, call. = FALSE)
  m <- readPNG(f); if (length(dim(m)) == 3) m <- m[, , 1]
  m * 255
}

## runs of TRUE in a logical vector: 0-based (start, end) pairs
runs <- function(mask) {
  idx <- which(mask) - 1L
  if (!length(idx)) return(matrix(integer(0), 0, 2))
  brk <- c(TRUE, diff(idx) != 1L)
  s <- idx[brk]; e <- idx[c(brk[-1], TRUE)]
  cbind(s, e)
}

## connected-component labelling (labels numbered in raster order of the first pixel, as scipy.ndimage.label)
cc_label <- function(mask, conn8 = TRUE) {
  nr <- nrow(mask); nc <- ncol(mask)
  rs <- list(); k <- 0L; rr <- integer(0); rs0 <- integer(0); re0 <- integer(0)
  for (r in seq_len(nr)) {
    x <- runs(mask[r, ])
    if (nrow(x)) { rr <- c(rr, rep(r, nrow(x))); rs0 <- c(rs0, x[, 1]); re0 <- c(re0, x[, 2]) }
  }
  n <- length(rr); parent <- seq_len(n)
  find <- function(i) { while (parent[i] != i) { parent[i] <<- parent[parent[i]]; i <- parent[i] }; i }
  pad <- if (conn8) 1L else 0L
  first_of_row <- match(seq_len(nr), rr)
  for (r in seq_len(nr)[-1]) {
    a <- which(rr == r); b <- which(rr == r - 1L)
    if (!length(a) || !length(b)) next
    j <- 1L
    for (i in a) {
      while (j <= length(b) && re0[b[j]] + pad < rs0[i]) j <- j + 1L
      jj <- j
      while (jj <= length(b) && rs0[b[jj]] - pad <= re0[i]) {
        ra <- find(i); rb <- find(b[jj]); if (ra != rb) parent[max(ra, rb)] <- min(ra, rb)
        jj <- jj + 1L
      }
    }
  }
  root <- vapply(seq_len(n), find, 1L)
  ids <- match(root, unique(root))
  lab <- matrix(0L, nr, nc)
  for (i in seq_len(n)) lab[rr[i], (rs0[i] + 1L):(re0[i] + 1L)] <- ids[i]
  list(lab = lab, n = if (n) max(ids) else 0L)
}
## per-component statistics: size, bbox (0-based, python-style stop), centre of mass (0-based row, col)
cc_stats <- function(L) {
  w <- which(L$lab > 0L, arr.ind = TRUE); id <- L$lab[w]
  data.frame(id = seq_len(L$n),
             size = as.vector(tapply(id, id, length)),
             h = as.vector(tapply(w[, 1], id, function(v) max(v) - min(v) + 1L)),
             w = as.vector(tapply(w[, 2], id, function(v) max(v) - min(v) + 1L)),
             cr = as.vector(tapply(w[, 1] - 1, id, mean)), cc = as.vector(tapply(w[, 2] - 1, id, mean)))
}
fill_holes <- function(reg) {
  bg <- !reg; L <- cc_label(bg, conn8 = FALSE)
  edge <- unique(c(L$lab[1, ], L$lab[nrow(L$lab), ], L$lab[, 1], L$lab[, ncol(L$lab)]))
  bg & !(L$lab %in% edge[edge > 0L])
}
erode_disk <- function(reg, rad) {
  er <- reg; nr <- nrow(reg); nc <- ncol(reg)
  for (dy in -rad:rad) for (dx in -rad:rad) if (dy * dy + dx * dx <= rad * rad) {
    sh <- matrix(FALSE, nr, nc)
    ri <- max(1, 1 - dy):min(nr, nr - dy); ci <- max(1, 1 - dx):min(nc, nc - dx)
    sh[ri, ci] <- reg[ri + dy, ci + dx]
    er <- er & sh
  }
  er
}

## ---------------------------------------------------------------- axes
ytick_rows <- function(dd, yax, r0, r1, nexp) {
  best <- NULL
  for (lo in 2:9) for (hi in (lo + 3):(lo + 9)) {
    m <- rowSums(dd[(r0 + 1):r1, (yax - hi + 1):(yax - lo), drop = FALSE])
    x <- runs(m >= (hi - lo) - 1)
    t <- if (nrow(x)) (x[, 1] + x[, 2]) / 2 + r0 else numeric(0)
    mg <- list()
    for (v in t) {
      if (length(mg) && v - tail(mg[[length(mg)]], 1) <= 8) mg[[length(mg)]] <- c(mg[[length(mg)]], v) else mg[[length(mg) + 1L]] <- v
    }
    cen <- vapply(mg, mean, 1)
    if (is.null(best) || abs(length(cen) - nexp) < abs(length(best) - nexp)) best <- cen
  }
  best
}
xlabel_centres <- function(dd, xrow, yax) {
  r0 <- xrow + 12
  sub <- dd[(r0 + 1):(xrow + 95), (yax + 1):ncol(dd), drop = FALSE]
  L <- cc_label(sub, conn8 = TRUE)
  chars <- NULL
  w <- which(L$lab > 0L, arr.ind = TRUE); id <- L$lab[w]
  for (i in seq_len(L$n)) {
    rw <- w[id == i, 1]; cl <- w[id == i, 2]
    if (length(rw) < 25 || (max(rw) - min(rw) + 1) < 10) next   # one printed character: >= 10 px tall
    chars <- rbind(chars, c(min(rw) - 1 + r0, min(cl) - 1 + yax, max(cl) - 1 + yax))
  }
  if (is.null(chars)) stop("no tick-label characters found below the abscissa", call. = FALSE)
  top <- min(chars[, 1])
  chars <- chars[chars[, 1] - top <= 12, , drop = FALSE]
  chars <- chars[order(chars[, 2], chars[, 3]), , drop = FALSE]
  groups <- list()
  for (i in seq_len(nrow(chars))) {
    a <- chars[i, 2]; b <- chars[i, 3]
    if (length(groups) && a - groups[[length(groups)]][2] <= 14) groups[[length(groups)]][2] <- max(groups[[length(groups)]][2], b)
    else groups[[length(groups) + 1L]] <- c(a, b)
  }
  vapply(groups, function(g) (g[1] + g[2]) / 2, 1)
}
xtick_positions <- function(dd, xrow, yax, labels) {
  cand <- integer(0)
  for (lo in 2:8) for (hi in (lo + 3):(lo + 8)) {
    m <- colSums(dd[(xrow + lo + 1):(xrow + hi), , drop = FALSE])
    x <- runs(m >= max(2, (hi - lo) - 2))
    for (i in seq_len(nrow(x))) { v <- (x[i, 1] + x[i, 2]) / 2; if (v > yax) cand <- c(cand, round(v)) }
  }
  tb <- table(cand); pos <- sort(as.integer(names(tb)[tb >= 3]))
  cen <- xlabel_centres(dd, xrow, yax)
  if (length(cen) != length(labels))
    stop(sprintf("found %d tick labels, expected %d", length(cen), length(labels)), call. = FALSE)
  out <- list(); used <- integer(0)
  for (i in seq_along(labels)) {
    free <- pos[!(pos %in% used) & abs(pos - cen[i]) <= 25]
    if (!length(free)) stop(sprintf("no tick matched printed label %s at %.1f px", labels[[i]][[1]], cen[i]), call. = FALSE)
    p <- free[which.min(abs(free - cen[i]))]
    used <- c(used, p); out[[i]] <- list(nm = labels[[i]][[1]], val = labels[[i]][[2]], px = as.numeric(p))
  }
  out
}
polyfit1 <- function(x, y) { X <- cbind(x, 1); solve(crossprod(X), crossprod(X, y))[, 1] }   # linear least squares: c(slope, intercept)
age_from_px <- function(ticks, segs, x) {
  for (t in ticks) if (is.null(t$val) && abs(x - t$px) <= 22) return(list(t$nm, NA_real_, "categorical", "no"))
  fit <- function(a, b) { ii <- (a + 1):(b + 1); polyfit1(vapply(ticks[ii], `[[`, 1, "px"), vapply(ticks[ii], function(t) t$val, 1)) }
  for (s in segs) {
    lo <- ticks[[s[1] + 1]]$px; hi <- ticks[[s[2] + 1]]$px
    if (lo - 14 <= x && x <= hi + 14) {
      c <- fit(s[1], s[2])
      return(list("years", c[1] * x + c[2], sprintf("segment %s-%s", ticks[[s[1] + 1]]$nm, ticks[[s[2] + 1]]$nm), "no"))
    }
  }
  # in an axis-break gap: extrapolate from the nearer segment and flag it
  best <- NULL; bd <- 1e9
  for (s in segs) for (e in list(c(ticks[[s[1] + 1]]$px, s[1]), c(ticks[[s[2] + 1]]$px, s[2]))) {
    if (abs(x - e[1]) < bd) { bd <- abs(x - e[1]); best <- s }
  }
  c <- fit(best[1], best[2])
  list("years", c[1] * x + c[2], sprintf("segment %s-%s (extrapolated)", ticks[[best[1] + 1]]$nm, ticks[[best[2] + 1]]$nm), "yes")
}

## ---------------------------------------------------------------- markers
## box = c(row0, row1, col0, col1) as python slices (0-based, stop exclusive)
box_region <- function(dd, box) dd[(box[1] + 1):box[2], (box[3] + 1):box[4], drop = FALSE]
open_markers <- function(dd, box, amin = 40, amax = 200) {
  reg <- box_region(dd, box); holes <- fill_holes(reg) & !reg
  L <- cc_label(holes, conn8 = TRUE); S <- cc_stats(L)
  S <- S[S$size >= amin & S$size <= amax & S$h >= 4 & S$w >= 3 & S$w / S$h >= 0.45 & S$w / S$h <= 2.0, , drop = FALSE]
  S <- S[order(S$cc + box[3], seq_len(nrow(S))), , drop = FALSE]
  cbind(y = S$cr + box[1], x = S$cc + box[3])
}
filled_markers <- function(dd, box, rad = 3, smin = 6) {
  reg <- box_region(dd, box); er <- erode_disk(reg, rad)
  L <- cc_label(er, conn8 = TRUE); S <- cc_stats(L)
  S <- S[S$size >= smin, , drop = FALSE]
  S <- S[order(S$cc + box[3], seq_len(nrow(S))), , drop = FALSE]
  cbind(y = S$cr + box[1], x = S$cc + box[3])
}

## python-style float text (repr): shortest decimal, ".0" kept on whole numbers
pyrepr <- function(x) { s <- sprintf("%.15g", x); ifelse(grepl("[.eEn]", s), s, paste0(s, ".0")) }
py_round <- function(x, d) round(x, d)
csv_cell <- function(x) ifelse(grepl("[\",\r\n]", x), paste0("\"", gsub("\"", "\"\"", x), "\""), x)

## ---------------------------------------------------------------- main
dd <- page_bitmap(C$page) < 128
yt <- ytick_rows(dd, C$yax, C$box[1], C$box[2], C$n_ytick)
if (length(yt) != C$n_ytick) stop(sprintf("%s: found %d ordinate ticks, expected %d", fig, length(yt), C$n_ytick), call. = FALSE)
cy <- polyfit1(yt, C$ylab)
yres <- max(abs(cy[1] * yt + cy[2] - C$ylab))
ticks <- xtick_positions(dd, C$xrow, C$yax, C$xlab)
rows <- list()
for (kind in names(C$series)) {
  pts <- if (startsWith(kind, "open")) open_markers(dd, C$box, amin = (if (fig == "Figure4") 5 else 15)) else filled_markers(dd, C$box)
  if (kind == "filled_circle" && fig == "Figure3") pts <- filled_markers(dd, C$box, rad = 3, smin = 8)
  for (i in seq_len(nrow(pts))) {
    y <- pts[i, "y"]; x <- pts[i, "x"]
    a <- age_from_px(ticks, C$segs, x)
    rows[[length(rows) + 1L]] <- data.frame(
      figure = fig, series_as_printed = C$series[[kind]], plot_symbol = kind,
      px_x = py_round(x, 1), px_y = py_round(y, 1), age_column = a[[1]],
      age_years_from_abscissa = if (is.na(a[[2]])) "" else pyrepr(py_round(a[[2]], 3)),
      abscissa_segment = a[[3]], age_in_axis_break = a[[4]],
      value_in_figure_units = py_round(cy[1] * y + cy[2], 3), figure_units = C$unit, stringsAsFactors = FALSE)
  }
}
M <- do.call(rbind, rows)
M <- M[order(M$figure, M$plot_symbol, M$px_x), ]
vc <- table(factor(M$plot_symbol, levels = unique(M$plot_symbol)))
vc <- vc[order(-as.integer(vc))]
hdr <- sprintf(paste0("# Huttenlocher__1979 %s constructed snapshot -- pixel digitisation of the ",
                      "embedded page bitmap (1950 x 3000 px, 8-bit grey), PDF p. %d.\n",
                      "# ordinate: ticks at rows [%s] -> [%s] %s (linear fit, max residual %.3f).\n",
                      "# abscissa (BROKEN, piecewise linear): %s\n",
                      "# %d markers resolved: {%s}\n"),
               fig, C$page + 1L, paste(pyrepr(py_round(yt, 1)), collapse = ", "), paste(C$ylab, collapse = ", "),
               C$unit, yres, paste(vapply(ticks, function(t) sprintf("%s=%.1f px", t$nm, t$px), ""), collapse = "; "),
               nrow(M), paste(sprintf("'%s': np.int64(%d)", names(vc), as.integer(vc)), collapse = ", "))
M$px_x <- pyrepr(M$px_x); M$px_y <- pyrepr(M$px_y); M$value_in_figure_units <- pyrepr(M$value_in_figure_units)
body <- paste(apply(as.matrix(M), 1, function(r) paste(csv_cell(r), collapse = ",")), collapse = "\n")
out <- paste0(hdr, paste(csv_cell(names(M)), collapse = ","), "\n", body, "\n")
path <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(path)) {
  old <- readChar(path, file.info(path)$size, useBytes = TRUE); Encoding(old) <- "UTF-8"
  if (!identical(old, out)) stop("REFUSING to overwrite differing frozen snapshot ", path, call. = FALSE)
  cat("snapshot unchanged:", basename(path), "\n")
} else {
  con <- file(path, "wb"); writeBin(charToRaw(enc2utf8(out)), con); close(con)
  cat("wrote", basename(path), nrow(M), "markers\n")
}

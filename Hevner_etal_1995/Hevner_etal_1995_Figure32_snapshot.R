# Hevner_etal_1995_Figure32_snapshot.R ---------------------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of Fig. 32 (p. 338) of Hevner R. F.,
# Liu S. & Wong-Riley M. T. T. (1995) Neuroscience 65(2): 313-342.
#
#   Hevner_etal_1995_Figure32_snapshot.csv   one row per printed bar (11 neuron types)
#
# The paper prints NO table of these values: Fig. 32 shows the optical density of
# CO histochemical staining in the perikarya of 11 neuron types (2 um aperture,
# n = 5 rats) as horizontal bars with S.E.M. error bars. This script renders PDF
# page 26 (journal p. 338) at 600 dpi with pdftools (poppler), finds the plot
# frame, the inner tick marks of the x axis (bottom and top), each bar's right
# edge and its error-bar cap, and converts pixel columns to values by a linear
# fit to the tick marks (bottom/top ticks interpolated across the bar's y
# position to absorb scan skew). The only values typed below are PRINTED
# LITERALS: the axis tick labels, the y-axis cell-type labels (top to bottom),
# n from the legend, and the two values the RESULTS text prints for bars of this
# figure (CA3 0.495 +/- 0.017, CA1 0.357 +/- 0.005; p. 337), kept in their own
# columns as anchors. No digitised value is typed here; the build script READS
# the frozen CSV. The script refuses to overwrite a frozen copy that differs.
#
# Resolution: 1 px = 0.00043 OD units; the tick-fit residual is written per row.
#
# Written by an AI assistant (Claude) on 2026-11-18; cross-checked against an
# independent pypdfium2/numpy digitisation (see README). Run with:
#   LC_ALL=en_US.UTF-8 Rscript Hevner_etal_1995_Figure32_snapshot.R
# -----------------------------------------------------------------------------

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
paper     <- basename(folder)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

pdf_file <- list.files(folder, pattern = "\\.pdf$", full.names = TRUE)
stopifnot(length(pdf_file) == 1L)
PAGE <- 26L   # PDF page carrying journal p. 338 (Fig. 32)
DPI  <- 600L

## ---- printed literals ---------------------------------------------------------------
cell_types <- c("mesencephalic nucleus of V", "reticular nucleus of thalamus", "interpeduncular nucleus",
                "oculomotor nucleus of III", "medial mammillary nucleus", "CA3 hippocampal pyramid",
                "Purkinje cell", "motor nucleus of V", "cerebellar granule cell",
                "CA1 hippocampal pyramid", "dentate granule cell")        # y-axis labels, top -> bottom
ticks_left_to_right <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6)   # interior ticks; labels printed 0.0 0.2 0.4 0.6, minor at odd tenths
n_legend <- 5L                                             # "n = 5 rats" (legend)
printed_in_text <- data.frame(
  cell = c("CA3 hippocampal pyramid", "CA1 hippocampal pyramid"),
  mean_printed_in_text = c("0.495", "0.357"), dispersion_printed_in_text = c("0.017", "0.005"),
  dispersion_type_in_text = c("S.E.M.", "S.E.M."), page_in_text = c("337", "337"), stringsAsFactors = FALSE)

## ---- render and binarise ------------------------------------------------------------
bm <- pdftools::pdf_render_page(pdf_file, page = PAGE, dpi = DPI, numeric = TRUE)
g  <- (bm[, , 1] + bm[, , 2] + bm[, , 3]) / 3
dark <- g < 0.5
message(item_name, ": rendered page ", PAGE, " at ", DPI, " dpi: ", nrow(dark), " x ", ncol(dark), " px")

runs <- function(idx, gap = 2L) {
  if (!length(idx)) return(list())
  br <- c(0L, which(diff(idx) > gap), length(idx))
  lapply(seq_len(length(br) - 1L), function(i) idx[(br[i] + 1L):br[i + 1L]])
}

## frame (search window = the figure's position on the page at 600 dpi)
sub <- dark[580:1740, 2000:3700]
cg <- runs(which(colSums(sub) > 0.8 * nrow(sub))); rg <- runs(which(rowSums(sub) > 0.8 * ncol(sub)))
f <- list(xl = 1999L + round(mean(cg[[1]])), xr = 1999L + round(mean(cg[[length(cg)]])),
          yt = 579L + round(mean(rg[[1]])), yb = 579L + round(mean(rg[[length(rg)]])))

xticks <- function(y0, y1) {                 # inner tick marks along the bottom or top x axis
  s <- dark[y0:y1, (f$xl + 4L):(f$xr - 4L)]
  cols <- which(colSums(s) >= 6)
  out <- do.call(rbind, lapply(runs(cols), function(gr)
    data.frame(x = f$xl + 3L + mean(gr), len = max(colSums(s[, gr, drop = FALSE])))))
  out[out$len < 34, ]                        # drop the frame lines
}
tb <- xticks(f$yb - 40L, f$yb - 4L); tt <- xticks(f$yt + 4L, f$yt + 40L)
if (nrow(tb) != 6L || nrow(tt) != 6L) stop("expected 6 interior x ticks, found ", nrow(tb), " / ", nrow(tt))

## horizontal bars: rows whose dark run from the left axis is long
ys <- (f$yt + 5L):(f$yb - 5L)
w <- vapply(ys, function(y) { x <- f$xl + 4L; n <- 0L
  while (x < f$xr && dark[y, x]) { x <- x + 1L; n <- n + 1L }; n }, integer(1))
gs <- runs(which(w > 100L)); gs <- gs[vapply(gs, length, 1L) >= 20L]
if (length(gs) != 11L) stop("expected 11 bars, found ", length(gs))
message(sprintf("frame x %d-%d y %d-%d; %d ticks; %d bars", f$xl, f$xr, f$yt, f$yb, nrow(tb), length(gs)))

rows <- list()
for (i in seq_along(gs)) {
  y0 <- ys[gs[[i]][1]]; y1 <- ys[gs[[i]][length(gs[[i]])]]; cy <- (y0 + y1) %/% 2L
  x <- f$xl + 4L
  while (x < f$xr && mean(dark[y0:y1, x]) >= 0.8) x <- x + 1L
  bar_end <- x - 1L                                        # right edge of the filled bar
  x <- bar_end + 1L; gap <- 0L; last <- bar_end            # follow the stem rightward
  while (x < f$xr - 2L) {
    if (any(dark[(cy - 12L):(cy + 12L), x])) { last <- x; gap <- 0L } else { gap <- gap + 1L; if (gap > 8L) break }
    x <- x + 1L
  }
  stem_end <- last
  cap_cols <- Filter(function(xx) sum(dark[(cy - 30L):(cy + 30L), xx]) >= 15,
                     (max(stem_end - 40L, bar_end) + 1L):stem_end)
  cr <- if (length(cap_cols)) { r <- runs(unlist(cap_cols)); r[[length(r)]] } else integer(0)
  cap_center <- if (length(cr)) mean(range(cr)) else NA_real_
  t <- (cy - f$yt) / (f$yb - f$yt)
  x_at_y <- tt$x + t * (tb$x - tt$x)
  fit <- lm(v ~ x, data.frame(v = ticks_left_to_right, x = x_at_y))
  val <- function(x) unname(predict(fit, data.frame(x = x)))
  mean_d <- val(bar_end); sem_d <- if (is.na(cap_center)) NA_real_ else val(cap_center) - mean_d
  rows[[i]] <- data.frame(
    cell_type_as_printed = cell_types[i], measure_as_printed = "Optical density", units_as_printed = "arbitrary units",
    n_from_legend = n_legend, mean_digitised = round(mean_d, 4), sem_digitised = round(sem_d, 4),
    bar_y0_px = y0, bar_y1_px = y1, bar_end_px = bar_end, cap_center_px = as.character(cap_center),
    cap_thickness_px = length(cr), units_per_px = signif(abs(unname(coef(fit)[2])), 4),
    tick_fit_resid_max = signif(max(abs(residuals(fit))), 3),
    legibility_note = "bar and S.E.M. cap sharp at 600 dpi; bar end = last column with >= 80 % dark coverage; cap = centre of the cap line",
    stringsAsFactors = FALSE)
}
snap <- do.call(rbind, rows)
snap <- merge(snap, printed_in_text, by.x = "cell_type_as_printed", by.y = "cell", all.x = TRUE, sort = FALSE)
snap <- snap[order(match(snap$cell_type_as_printed, cell_types)), ]
for (k in c("mean_printed_in_text", "dispersion_printed_in_text", "dispersion_type_in_text", "page_in_text"))
  snap[[k]][is.na(snap[[k]])] <- ""
snap$value_source <- ifelse(snap$mean_printed_in_text == "", "digitised", "digitised; also printed in text (see *_in_text)")
rownames(snap) <- NULL
stopifnot(nrow(snap) == 11L)

out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) {
  old <- read.csv(out, colClasses = "character", na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
  new <- read.csv(text = capture.output(write.csv(snap, row.names = FALSE, na = "")), colClasses = "character",
                  na.strings = character(0), check.names = FALSE)
  if (!identical(dim(old), dim(new)) || !isTRUE(all.equal(old, new, check.attributes = FALSE)))
    stop(basename(out), ": the frozen snapshot on disk differs from this run (different renderer/version?). ",
         "Refusing to overwrite. Compare the two, and move the superseded file to archive/ before re-running.", call. = FALSE)
  message(basename(out), ": frozen snapshot already on disk and identical; nothing written.")
} else {
  write.csv(snap, out, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message(basename(out), ": wrote ", nrow(snap), " rows x ", ncol(snap), " cols")
}

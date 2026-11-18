# Hevner_etal_1995_Figure31_snapshot.R ---------------------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of Fig. 31 (p. 336) of Hevner R. F.,
# Liu S. & Wong-Riley M. T. T. (1995) "A metabolic map of cytochrome oxidase
# in the rat brain: histochemical, densitometric and biochemical studies",
# Neuroscience 65(2): 313-342.
#
#   Hevner_etal_1995_Figure31_snapshot.csv   one row per printed bar position
#                                            (12 regions x panels A, B, C = 36 rows,
#                                            incl. the "N.D." position of whole
#                                            brain in panel C)
#
# The paper prints NO table of these values: Fig. 31A-C shows them as bars
# (mean + S.E.M. error bar). This script renders PDF page 24 (journal p. 336) at
# 600 dpi with pdftools (poppler), finds the three plot frames, the inner tick
# marks of the y axes, each bar's top edge and each error-bar cap, and converts
# pixel rows to values by a linear fit to the tick marks (left/right ticks are
# interpolated across the bar's x position to absorb the ~7 px scan skew).
# The only values typed below are PRINTED LITERALS read off the page: the axis
# tick labels, the x-axis category labels, the n per region from the legend,
# and the four values the RESULTS text prints for bars of this figure
# (used as anchors, kept in their own columns and marked `printed_in_text`).
# No digitised value is typed in this script; the build script READS the
# frozen CSV. The script refuses to overwrite a frozen copy that differs.
#
# Resolution: 1 px = 0.23 mU/mg tissue (A), 2.5 mU/mg protein (B),
# 0.00007 OD units (C); the tick-fit residual is written per row.
#
# Written by an AI assistant (Claude) on 2026-11-18; algorithm cross-checked
# against an independent pypdfium2/numpy digitisation of the same page (see
# README). Run with:  LC_ALL=en_US.UTF-8 Rscript Hevner_etal_1995_Figure31_snapshot.R
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
PAGE <- 24L   # PDF page carrying journal p. 336 (Fig. 31)
DPI  <- 600L

## ---- printed literals (read off the page, not measured) -----------------------
## x-axis category labels, left to right, as printed under panel C
regions <- c("whole brain", "cerebellar cortex", "visual cortex", "caudate nucleus",
             "inferior colliculus", "thalamus", "superior colliculus", "hippocampus",
             "olfactory bulb", "corpus callosum", "cranial nerve II", "cranial nerve V")
tissue_class <- c("", rep("gray matter", 8), rep("white matter", 3))   # printed brackets under the labels
## legend p. 336: n for biochemistry (A, B) and for densitometry (C)
n_biochem <- c(6, 5, 4, 5, 5, 5, 5, 5, 5, 3, 4, 4)
n_densito <- c(NA, 6, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6)
## y-axis tick labels as printed (major) and the unlabelled minor ticks between them;
## the interior ticks (frame lines excluded) run top -> bottom:
panels <- list(
  A = list(measure = "CO activity content", units = "mU/mg tissue",
           ticks_top_to_bottom = c(175, 150, 125, 100, 75, 50, 25), ysearch = c(560, 1420)),
  B = list(measure = "CO specific activity", units = "mU/mg protein",
           ticks_top_to_bottom = c(1750, 1500, 1250, 1000, 750, 500, 250), ysearch = c(1440, 2290)),
  C = list(measure = "Optical density", units = "arbitrary units",
           ticks_top_to_bottom = c(0.05, 0.045, 0.04, 0.035, 0.03, 0.025, 0.02, 0.015, 0.01, 0.005),
           ysearch = c(2330, 3190)))
## values the RESULTS text prints for bars of this figure (anchors):
##   p. 335 whole brain: "158 +/- 12 mU/mg tissue" and "1760 +/- 100 mU/mg protein"
##          (the paragraph states mean +/- S.D.; the figure plots S.E.M.)
##   p. 336 "cerebellar cortex (157 +/- 17 mU/mg tissue, mean +/- S.E.M.)",
##          "visual cortex (1760 +/- 150 mU/mg protein)"
printed_in_text <- data.frame(
  panel  = c("A", "B", "A", "B"),
  region = c("whole brain", "whole brain", "cerebellar cortex", "visual cortex"),
  mean_printed_in_text       = c("158", "1760", "157", "1760"),
  dispersion_printed_in_text = c("12", "100", "17", "150"),
  dispersion_type_in_text    = c("S.D.", "S.D.", "S.E.M.", "S.E.M."),
  page_in_text = c("335", "335", "336", "336"), stringsAsFactors = FALSE)

## ---- render and binarise --------------------------------------------------------
bm <- pdftools::pdf_render_page(pdf_file, page = PAGE, dpi = DPI, numeric = TRUE)
g  <- (bm[, , 1] + bm[, , 2] + bm[, , 3]) / 3            # rows = y, cols = x
dark <- g < 0.5
message(item_name, ": rendered page ", PAGE, " at ", DPI, " dpi: ", nrow(dark), " x ", ncol(dark), " px")

runs <- function(idx, gap = 2L) {           # group consecutive indices (gap allowed)
  if (!length(idx)) return(list())
  br <- c(0L, which(diff(idx) > gap), length(idx))
  lapply(seq_len(length(br) - 1L), function(i) idx[(br[i] + 1L):br[i + 1L]])
}

find_frame <- function(y0, y1, x0 = 1100L, x1 = 2500L) {
  sub <- dark[y0:y1, x0:x1]
  cg <- runs(which(colSums(sub) > 0.8 * nrow(sub)))
  rg <- runs(which(rowSums(sub) > 0.8 * ncol(sub)))
  list(xl = x0 - 1L + round(mean(cg[[1]])), xr = x0 - 1L + round(mean(cg[[length(cg)]])),
       yt = y0 - 1L + round(mean(rg[[1]])), yb = y0 - 1L + round(mean(rg[[length(rg)]])))
}

ticks_inner <- function(f, side) {           # inner tick marks of the left or right y axis
  xr <- if (side == "left") (f$xl + 4L):(f$xl + 40L) else (f$xr - 40L):(f$xr - 4L)
  sub <- dark[(f$yt - 5L):(f$yb + 5L), xr]
  rows <- which(rowSums(sub) >= 6)
  out <- do.call(rbind, lapply(runs(rows), function(gr)
    data.frame(y = f$yt - 6L + mean(gr), len = max(rowSums(sub[gr, , drop = FALSE])))))
  out[out$len < 34, ]                          # drop the frame lines (full-width runs)
}

find_bars <- function(f, minh = 20L) {
  xs <- (f$xl + 45L):(f$xr - 5L)
  h <- vapply(xs, function(x) { y <- f$yb - 4L; n <- 0L
    while (y > f$yt && dark[y, x]) { y <- y - 1L; n <- n + 1L }; n }, integer(1))
  gs <- runs(which(h > minh)); gs <- gs[vapply(gs, length, 1L) >= 25L]
  lapply(gs, function(gr) c(x0 = xs[gr[1]], x1 = xs[gr[length(gr)]]))
}

measure_bar <- function(f, x0, x1) {
  cx <- (x0 + x1) %/% 2L
  y <- f$yb - 4L
  while (y > f$yt && mean(dark[y, x0:x1]) >= 0.8) y <- y - 1L
  bar_top <- y + 1L                                      # top edge of the filled bar
  y <- bar_top - 1L; gap <- 0L; last <- bar_top            # follow the error-bar stem upward
  while (y > f$yt + 2L) {
    if (any(dark[y, (cx - 12L):(cx + 12L)])) { last <- y; gap <- 0L } else { gap <- gap + 1L; if (gap > 8L) break }
    y <- y - 1L
  }
  stem_top <- last
  cap_rows <- Filter(function(yy) sum(dark[yy, (cx - 30L):(cx + 30L)]) >= 15,
                     stem_top:(min(stem_top + 40L, bar_top) - 1L))
  cr <- if (length(cap_rows)) runs(unlist(cap_rows))[[1]] else integer(0)
  list(cx = cx, bar_top = bar_top,
       cap_center = if (length(cr)) mean(range(cr)) else NA_real_, cap_thick = length(cr))
}

## ---- digitise ----------------------------------------------------------------------
rows <- list()
for (pn in names(panels)) {
  P <- panels[[pn]]
  f <- find_frame(P$ysearch[1], P$ysearch[2])
  tl <- ticks_inner(f, "left"); tr <- ticks_inner(f, "right")
  if (nrow(tl) != length(P$ticks_top_to_bottom) || nrow(tr) != length(P$ticks_top_to_bottom))
    stop(pn, ": expected ", length(P$ticks_top_to_bottom), " interior ticks, found ",
         nrow(tl), " (left) / ", nrow(tr), " (right)")
  bars <- find_bars(f)
  expected <- if (pn == "C") 11L else 12L
  if (length(bars) != expected) stop(pn, ": expected ", expected, " bars, found ", length(bars))
  labs <- if (pn == "C") regions[-1] else regions
  message(sprintf("%s: frame x %d-%d y %d-%d; %d ticks; %d bars", pn, f$xl, f$xr, f$yt, f$yb, nrow(tl), length(bars)))
  for (i in seq_along(bars)) {
    b <- bars[[i]]; m <- measure_bar(f, b[["x0"]], b[["x1"]])
    t <- (m$cx - f$xl) / (f$xr - f$xl)
    yt_at_x <- tl$y + t * (tr$y - tl$y)
    fit <- lm(v ~ y, data.frame(v = P$ticks_top_to_bottom, y = yt_at_x))
    val <- function(y) unname(predict(fit, data.frame(y = y)))
    mean_d <- val(m$bar_top); sem_d <- if (is.na(m$cap_center)) NA_real_ else val(m$cap_center) - mean_d
    rows[[length(rows) + 1L]] <- data.frame(
      panel = pn, measure_as_printed = P$measure, units_as_printed = P$units,
      region_as_printed = labs[i], tissue_class_as_printed = tissue_class[match(labs[i], regions)],
      n_from_legend = if (pn == "C") n_densito[match(labs[i], regions)] else n_biochem[match(labs[i], regions)],
      mean_digitised = mean_d, sem_digitised = sem_d,
      bar_x0_px = b[["x0"]], bar_x1_px = b[["x1"]], bar_top_px = m$bar_top,
      cap_center_px = m$cap_center, cap_thickness_px = m$cap_thick,
      units_per_px = abs(unname(coef(fit)[2])),
      tick_fit_resid_max = max(abs(residuals(fit))),
      legibility_note = "bar and S.E.M. cap sharp at 600 dpi; bar top = first row with >= 80 % dark coverage; cap = centre of the cap line",
      stringsAsFactors = FALSE)
  }
  if (pn == "C") {   # the printed "N.D." position of whole brain in panel C
    rows[[length(rows) + 1L]] <- data.frame(
      panel = "C", measure_as_printed = P$measure, units_as_printed = P$units,
      region_as_printed = "whole brain", tissue_class_as_printed = "", n_from_legend = NA,
      mean_digitised = NA_real_, sem_digitised = NA_real_, bar_x0_px = NA, bar_x1_px = NA,
      bar_top_px = NA, cap_center_px = NA_real_, cap_thickness_px = NA, units_per_px = NA_real_,
      tick_fit_resid_max = NA_real_, legibility_note = "printed 'N.D.' (not determined) in place of a bar",
      stringsAsFactors = FALSE)
  }
}
snap <- do.call(rbind, rows)
## panel C printed order: whole brain (N.D.) first, as on the page
snap <- snap[order(match(snap$panel, c("A", "B", "C")), match(snap$region_as_printed, regions)), ]
snap <- merge(snap, printed_in_text, by.x = c("panel", "region_as_printed"), by.y = c("panel", "region"),
              all.x = TRUE, sort = FALSE)
snap <- snap[order(match(snap$panel, c("A", "B", "C")), match(snap$region_as_printed, regions)), ]
snap$value_source <- ifelse(is.na(snap$mean_printed_in_text), "digitised", "digitised; also printed in text (see *_in_text)")
for (k in c("mean_printed_in_text", "dispersion_printed_in_text", "dispersion_type_in_text", "page_in_text"))
  snap[[k]][is.na(snap[[k]])] <- ""
## resolution-aware rounding (about one pixel)
snap$mean_digitised <- ifelse(snap$panel == "A", round(snap$mean_digitised, 1),
                       ifelse(snap$panel == "B", round(snap$mean_digitised, 0), round(snap$mean_digitised, 5)))
snap$sem_digitised  <- ifelse(snap$panel == "A", round(snap$sem_digitised, 1),
                       ifelse(snap$panel == "B", round(snap$sem_digitised, 0), round(snap$sem_digitised, 5)))
snap$units_per_px <- signif(snap$units_per_px, 4); snap$tick_fit_resid_max <- signif(snap$tick_fit_resid_max, 3)
snap$cap_center_px <- as.character(snap$cap_center_px)
rownames(snap) <- NULL
stopifnot(nrow(snap) == 36L)

## ---- freeze -------------------------------------------------------------------------
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

## Replot exact deposited individual counts plus separately digitized posterior summaries.
me <- "Baldoni_etal_2025_Figure2_replot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a) || basename(sub("^--file=", "", a[1])) != me) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
base <- sub("_replot\\.R$", "", me)
d <- utils::read.csv(file.path(folder, paste0(base, ".csv")), check.names = FALSE)
p <- utils::read.csv(file.path(folder, "reference_tables", paste0(base, "_posterior_digitized.csv")), check.names = FALSE)
stopifnot(nrow(d) == 98L, nrow(p) == 28L)
d <- d[d$figure2_plotted, , drop = FALSE]
regions <- unique(d$Structure_as_published)
cols <- c("#fa8072", "#c99a00", "#4cae2d", "#16b992", "#00b6df", "#a08bf0", "#ed57cf")
png(file.path(folder, paste0(base, "_replot.png")), width = 2800, height = 950)
par(mfrow = c(2, 7), mar = c(4, 4, 3, 1), cex = 0.85)
for (panel in c("A", "B")) {
  field <- if (panel == "A") "AllCells.n" else "Neurons.n"
  for (j in seq_along(regions)) {
    region <- regions[j]
    z <- d[d$Structure_as_published == region, , drop = FALSE]
    q <- p[p$source_panel == panel & p$Structure_as_published == region, , drop = FALSE]
    stopifnot(nrow(z) == 10L, nrow(q) == 2L)
    ymin <- min(z[[field]], q$CredibleInterval95_Lower_Cells.n, q$AxisLowTick_Cells.n)
    ymax <- max(z[[field]], q$CredibleInterval95_Upper_Cells.n, q$AxisHighTick_Cells.n)
    pad <- 0.03 * (ymax - ymin)
    plot(NA, xlim = c(0.5, 2.5), ylim = c(ymin - pad, ymax + pad), xaxt = "n",
         xlab = "", ylab = "Cell count", main = paste(panel, region), las = 1)
    axis(1, at = 1:2, labels = c("Summer", "Winter"))
    for (k in 1:2) {
      season <- c("Summer", "Winter")[k]
      v <- z[[field]][z$season == season]
      stopifnot(length(v) == 5L)
      points(k + seq(-0.16, 0.16, length.out = length(v)), v, pch = 15, cex = 0.75, col = cols[j])
      s <- q[q$season == season, , drop = FALSE]
      segments(k, s$CredibleInterval95_Lower_Cells.n, k, s$CredibleInterval95_Upper_Cells.n,
               col = cols[j], lwd = 2)
      segments(k - 0.16, s$CredibleInterval95_Lower_Cells.n, k + 0.16, s$CredibleInterval95_Lower_Cells.n,
               col = cols[j], lwd = 2)
      segments(k - 0.16, s$CredibleInterval95_Upper_Cells.n, k + 0.16, s$CredibleInterval95_Upper_Cells.n,
               col = cols[j], lwd = 2)
      points(k, s$PosteriorMean_Cells.n, pch = 16, cex = 1.2, col = cols[j])
    }
  }
}
dev.off()

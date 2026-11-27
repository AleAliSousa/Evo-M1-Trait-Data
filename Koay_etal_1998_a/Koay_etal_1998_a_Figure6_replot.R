# Replot the extracted Figure 6 points without rerunning digitisation or fits.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(args) != 1L) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", args[[1]])))
item <- "Koay_etal_1998_a_Figure6"
d <- read.csv(file.path(folder, paste0(item, ".csv")), check.names = FALSE,
              stringsAsFactors = FALSE)
x <- as.numeric(d$functional_interaural_distance_us)
y <- as.numeric(d$high_freq_hearing_limit_60dB_kHz)
keep <- is.finite(x) & is.finite(y) & x > 0 & y > 0
symbol <- c(filled_circle = 16, open_circle_bat = 1,
            filled_triangle_subterranean = 17, open_triangle_marine = 2)
png(file.path(folder, paste0(item, "_replot.png")), width = 1200, height = 900,
    res = 150)
par(mar = c(5, 5, 3, 2))
plot(x[keep], y[keep], type = "n", log = "xy", xlim = c(35, 4000),
     ylim = c(5, 160), xaxt = "n", yaxt = "n",
     xlab = "Functional interaural distance (µs)",
     ylab = "High-frequency hearing limit at 60 dB SPL (kHz)",
     main = "Koay et al. 1998a — Figure 6 extracted points")
axis(1, at = c(40, 50, 80, 100, 200, 300, 500, 1000, 2000, 4000))
axis(2, at = c(5, 8, 10, 20, 40, 60, 80, 100, 160), las = 1)
for (i in which(keep)) {
  points(x[i], y[i], pch = symbol[[d$marker[i]]], cex = 0.8)
  text(x[i], y[i], labels = d$figure_id[i], pos = 3, offset = 0.25, cex = 0.43)
}
legend("topright", legend = c("other mammals", "bats", "subterranean", "marine"),
       pch = symbol[c("filled_circle", "open_circle_bat",
                      "filled_triangle_subterranean", "open_triangle_marine")],
       bty = "n", cex = 0.8)
dev.off()
cat(item, ": ", sum(keep), " plotted points\n", sep = "")

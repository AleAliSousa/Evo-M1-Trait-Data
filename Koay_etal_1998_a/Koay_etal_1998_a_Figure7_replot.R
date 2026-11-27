# Replot the extracted Figure 7 points without rerunning digitisation or fits.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(args) != 1L) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", args[[1]])))
item <- "Koay_etal_1998_a_Figure7"
d <- read.csv(file.path(folder, paste0(item, ".csv")), check.names = FALSE,
              stringsAsFactors = FALSE)
x <- as.numeric(d$high_freq_hearing_limit_60dB_kHz)
y <- as.numeric(d$low_freq_hearing_limit_60dB_kHz)
keep <- is.finite(x) & is.finite(y) & x > 0 & y > 0
symbol <- c(filled_circle = 16, open_circle_bat = 1,
            filled_triangle_subterranean = 17, open_triangle_marine = 2)
png(file.path(folder, paste0(item, "_replot.png")), width = 1200, height = 900,
    res = 150)
par(mar = c(5, 5, 3, 2))
plot(x[keep], y[keep], type = "n", log = "xy", xlim = c(5, 150),
     ylim = c(0.01, 12), xaxt = "n", yaxt = "n",
     xlab = "High-frequency hearing limit at 60 dB SPL (kHz)",
     ylab = "Low-frequency hearing limit at 60 dB SPL (kHz)",
     main = "Koay et al. 1998a — Figure 7 extracted points")
axis(1, at = c(5, 8, 10, 20, 40, 80, 100, 120, 150))
axis(2, at = c(0.01, 0.05, 0.1, 0.5, 1, 5, 10), las = 1)
for (i in which(keep)) {
  points(x[i], y[i], pch = symbol[[d$marker[i]]], cex = 0.8)
  text(x[i], y[i], labels = d$figure_id[i], pos = 3, offset = 0.25, cex = 0.43)
}
legend("topleft", legend = c("other mammals", "bats", "subterranean", "marine"),
       pch = symbol[c("filled_circle", "open_circle_bat",
                      "filled_triangle_subterranean", "open_triangle_marine")],
       bty = "n", cex = 0.8)
dev.off()
cat(item, ": ", sum(keep), " plotted points\n", sep = "")

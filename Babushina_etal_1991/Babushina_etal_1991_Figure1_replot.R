# Visual check of the extracted CSV; base R only.
# Run: Rscript Babushina_etal_1991/Babushina_etal_1991_Figure1_replot.R
local({
  script <- local({
    for (i in rev(seq_len(sys.nframe()))) {
      p <- sys.frame(i)$ofile
      if (!is.null(p)) return(normalizePath(p))
    }
    a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
    stop("Run the saved script with Rscript or source().")
  })
  folder <- dirname(script)
  item_name <- sub("_replot[.]R$", "", basename(script))
  d <- read.csv(file.path(folder, paste0(item_name, ".csv")))

  png(file.path(folder, paste0(item_name, "_replot.png")),
      width = 1300, height = 850, res = 140)
  on.exit(dev.off())
  par(mar = c(5, 5, 5, 1))
  # The table already holds log10(kHz): do not log-transform it again.
  plot(d$lg_f_kHz_as_plotted, d$threshold_as_plotted, pch = 16,
       xlim = c(-0.6, 2.1), ylim = c(-50, 50), xaxt = "n", yaxt = "n",
       xlab = "lg f [kHz] (log10 frequency in kHz)",
       ylab = "P, dB (relative to 1 microbar)",
       main = "Babushina et al. (1991), Figure 1 - extracted points")
  axis(1, at = 0:2)
  axis(2, at = seq(-40, 40, 20), las = 1)
  legend("topright", legend = unique(d$curve_legend_as_printed), pch = 16, bty = "n")
  mtext("Curve 1 only; other species and the published smooth curve were not digitized.",
        side = 3, line = 0.5, cex = 0.8)
})

# Visual check of the extracted CSV; base R only.
# Run: Rscript Barks_etal_2014/Barks_etal_2014_Fig4A_replot.R
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
  d <- d[match(c("Gorilla beringei", "Gorilla gorilla"), d$Species), ]
  # Raw cm3 columns are in source order; exclude derived mm3 aggregates.
  columns <- grep("_cm3$", names(d), value = TRUE)
  heights <- as.matrix(d[, columns])
  labels <- gsub("_", " ", sub("_cm3$", "", columns))
  labels <- sub("Claustrum", "Claustrum area", labels)

  png(file.path(folder, paste0(item_name, "_replot.png")),
      width = 2000, height = 1100, res = 140)
  on.exit(dev.off())
  par(mar = c(12, 5, 5, 1))
  colours <- c("grey65", "black")
  barplot(heights, beside = TRUE, space = c(0, 0.6), col = colours,
          border = "black", names.arg = labels, las = 2, cex.names = 0.75,
          ylim = c(0, 45), yaxs = "i", yaxt = "n",
          ylab = expression("Mean volume (" * cm^3 * ")"),
          main = "Barks et al. (2014), Figure 4A - absolute volumes, all subjects")
  axis(2, at = seq(0, 45, 5), las = 1)
  legend("topright", legend = d$Species, fill = colours, bty = "n")
  mtext("Approximate eye-digitized means; source +1 SD bars were not extracted. Panel A only.",
        side = 3, line = 0.5, cex = 0.8)
})

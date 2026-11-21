# Visual check of the extracted CSV; base R only.
# Run: Rscript Bartlett__2003/Bartlett__2003_Figure5_replot.R
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
  d <- d[order(as.integer(d$source_month_order)), ]
  # Groom is the lower segment; Play is its own segment, not the bar total.
  heights <- rbind(Groom = d$Groom_time.pct, Play = d$Play_time.pct)

  png(file.path(folder, paste0(item_name, "_replot.png")),
      width = 1300, height = 850, res = 140)
  on.exit(dev.off())
  par(mar = c(5, 5, 5, 1))
  colours <- c("grey75", "grey55")
  barplot(heights, beside = FALSE, space = 0, col = colours,
          border = "black", names.arg = d$month, ylim = c(0, 20),
          yaxs = "i", yaxt = "n", ylab = "% of Activity", xlab = "Month",
          main = "Bartlett (2003), Figure 5 - replot from extracted CSV")
  axis(2, at = seq(0, 20, 5), las = 1)
  legend("topright", legend = c("Play", "Groom"), fill = rev(colours), bty = "n")
  mtext("Digitized monthly activity budgets; February to January, as published.",
        side = 3, line = 0.5, cex = 0.8)
})

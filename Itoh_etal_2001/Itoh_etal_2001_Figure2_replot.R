# Visual check of the extracted CSV; base R only. No extraction or data writes.
# Run from the repository root: Rscript Itoh_etal_2001/Itoh_etal_2001_Figure2_replot.R
# Also supports source(".../Itoh_etal_2001_Figure2_replot.R").
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

  # Match physical bar order in the source (different from its legend order).
  groups <- c("WT", "TRalphaPV/+", "TRbetaPV/PV")
  regions <- unique(d$region_as_published[order(d$source_structure_order)])
  rows <- lapply(groups, function(g)
    match(regions, d$region_as_published[d$genotype == g]))
  means <- t(sapply(seq_along(groups), function(j)
    d$mean_umol_g_min[d$genotype == groups[j]][rows[[j]]]))
  upper <- t(sapply(seq_along(groups), function(j)
    d$upper_error_endpoint_umol_g_min[d$genotype == groups[j]][rows[[j]]]))

  png(file.path(folder, paste0(item_name, "_replot.png")),
      width = 2000, height = 1100, res = 140)
  on.exit(dev.off())
  par(mar = c(14, 5, 4, 1))
  colours <- c("grey40", "white", "grey75")
  x <- barplot(means, beside = TRUE, col = colours, border = "black",
               ylim = c(0, 1.2), names.arg = rep("", length(regions)),
               ylab = "Local cerebral glucose utilization (umol/g/min)",
               main = "Itoh et al. (2001), Figure 2 - replot from extracted CSV")
  arrows(x, means, x, upper, angle = 90, code = 2, length = 0.025)
  text(colMeans(x), -0.025, regions, srt = 55, adj = 1, xpd = NA, cex = 0.85)
  legend("topright", legend = groups, fill = colours, horiz = TRUE, bty = "n")
  mtext("Approximate digitized means; upper error endpoints retained, error type unspecified.",
        side = 3, line = 0.35, cex = 0.8)
})

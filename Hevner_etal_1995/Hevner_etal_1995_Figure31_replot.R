# Visual check of the extracted Fig. 31 A-C bars. D and E are scatter
# displays of the same regional values and were not separately extracted.
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(a) != 1L) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a)))
item_name <- sub("_replot\\.R$", "", basename(sub("^--file=", "", a)))
d <- read.csv(file.path(folder, paste0(item_name, ".csv")),
              check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(identical(unique(d$panel), c("A", "B", "C")))
regions <- d$region_as_printed[d$panel == "A"]
stopifnot(length(regions) == 12L, identical(d$region_as_printed[d$panel == "B"], regions))

png(file.path(folder, paste0(item_name, "_replot.png")),
    width = 1450, height = 1500, res = 170)
op <- par(mfrow = c(3, 1), mar = c(2.3, 6.5, 2.5, 1.5), oma = c(10, 0, 1, 0))
on.exit({par(op); dev.off()}, add = TRUE)
units <- c(A = "CO activity content (mU/mg tissue)",
           B = "CO specific activity (mU/mg protein)",
           C = "Optical density (arbitrary units)")
limits <- c(A = 180, B = 2000, C = 0.055)
for (panel in c("A", "B", "C")) {
  p <- d[d$panel == panel, ]
  k <- match(regions, p$region_as_printed)
  y <- p$mean[k]
  se <- p$sem[k]
  missing <- is.na(k)
  y[missing] <- 0
  names_arg <- if (panel == "C") regions else rep("", length(regions))
  mids <- barplot(y, names.arg = names_arg, las = 2,
                  col = "black", border = "black", space = 0.25,
                  ylim = c(0, limits[panel]), ylab = units[panel],
                  main = paste("Figure 31", panel), cex.names = 0.68,
                  cex.lab = 0.8)
  good <- !missing & !is.na(se)
  arrows(mids[good], y[good] - se[good], mids[good], y[good] + se[good],
         angle = 90, code = 3, length = 0.025, lwd = 1)
  if (any(missing)) text(mids[missing], 0.02 * limits[panel], "N.D.", cex = 0.7)
}
mtext("Regions in published order; error bars are S.E.M.",
      side = 1, outer = TRUE, line = 8, cex = 0.85)

# Visual check of the extracted Fig. 32 horizontal bars. Read item CSV only.
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(a) != 1L) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a)))
item_name <- sub("_replot\\.R$", "", basename(sub("^--file=", "", a)))
d <- read.csv(file.path(folder, paste0(item_name, ".csv")),
              check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(nrow(d) == 11L, identical(d$rank_as_printed, seq_len(11L)))
p <- rev(seq_len(nrow(d)))
png(file.path(folder, paste0(item_name, "_replot.png")),
    width = 1500, height = 850, res = 170)
op <- par(mar = c(5, 20, 3, 1))
on.exit({par(op); dev.off()}, add = TRUE)
mids <- barplot(d$mean[p], horiz = TRUE, names.arg = d$cell_type_as_printed[p],
                las = 1, col = "black", border = "black", xlim = c(0, 0.67),
                xlab = "Optical density (arbitrary units)",
                main = "Figure 32: neuronal cell types (S.E.M. bars)",
                cex.names = 0.7)
arrows(d$mean[p] - d$sem[p], mids, d$mean[p] + d$sem[p], mids,
       angle = 90, code = 3, length = 0.025, lwd = 1)

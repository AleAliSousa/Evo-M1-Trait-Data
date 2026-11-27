args <- grep('^--file=', commandArgs(FALSE), value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=', '', args[1])))
d <- read.csv(file.path(folder,'Westergaard_Hyatt_1994_Figure1.csv'),stringsAsFactors=FALSE)
stopifnot(identical(d$source_order,1:6))
png(file.path(folder,'Westergaard_Hyatt_1994_Figure1_replot.png'),width=900,height=650,res=120)
par(mar=c(10,6,3,1))
bp <- barplot(d$adjusted_frequency_difference_score,names.arg=d$behavior_as_published,
              las=2,ylim=c(-5,20),ylab='Adjusted frequency score difference',
              main='Bonobo mirror-on minus mirror-off: Figure 1',col='grey75',border='black')
abline(h=0,lwd=1.2)
text(bp[d$significant_p_lt_0.05],d$adjusted_frequency_difference_score[d$significant_p_lt_0.05]+0.6,'*')
dev.off()

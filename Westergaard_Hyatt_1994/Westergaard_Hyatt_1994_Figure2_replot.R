args <- grep('^--file=', commandArgs(FALSE), value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=', '', args[1])))
d <- read.csv(file.path(folder,'Westergaard_Hyatt_1994_Figure2.csv'),stringsAsFactors=FALSE)
stopifnot(identical(d$source_order,1:6))
png(file.path(folder,'Westergaard_Hyatt_1994_Figure2_replot.png'),width=900,height=650,res=120)
par(mar=c(10,6,3,1))
v <- d$relative_duration_difference_score
bp <- barplot(replace(v,is.na(v),0),names.arg=d$behavior_as_published,
              las=2,ylim=c(-40,40),ylab='Relative duration difference (percentage points)',
              main='Bonobo mirror-on minus mirror-off: Figure 2',col='grey75',border='black')
abline(h=0,lwd=1.2)
text(bp[!is.na(v)&d$significant_p_lt_0.05],v[!is.na(v)&d$significant_p_lt_0.05]+sign(v[!is.na(v)&d$significant_p_lt_0.05])*2,'*')
text(bp[is.na(v)],2,'NA',cex=.75)
dev.off()

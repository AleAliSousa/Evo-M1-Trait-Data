## Replot the extracted source bars with their panel-specific axis scales and SEM.
me <- "ClippertonAllen_etal_2019_Figure1_replot.R"
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a) || basename(sub("^--file=", "", a[1])) != me) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
base <- sub("_replot\\.R$", "", me)
d <- read.csv(file.path(folder, paste0(base,".csv")), check.names=FALSE)
key <- paste(d$source_panel,d$age,d$Structure_as_published,sep="|")
groups <- unique(key)
png(file.path(folder,paste0(base,"_replot.png")),width=1800,height=560)
par(mfrow=c(1,length(groups)),mar=c(5,4,4,1))
for (g in groups) {
 z <- d[key==g,]
 stopifnot(nrow(z)==2L)
 ymin <- z$Axis_min.mm3[1]; ymax <- z$Axis_max.mm3[1]
 plot(NA,xlim=c(0.5,2.5),ylim=c(ymin,ymax),xlab="",ylab="Volume (mm3)",xaxt="n",main=paste(z$source_panel[1],z$age[1],z$Structure_as_published[1]))
 axis(1,at=1:2,labels=z$genotype,las=2)
 rect(1:2-0.3,ymin,1:2+0.3,z$Volume.mm3,col=c("white","black"),border="black")
 arrows(1:2,z$Volume.mm3-z$SEM_approx.mm3,1:2,z$Volume.mm3+z$SEM_approx.mm3,angle=90,code=3,length=0.05)
}
dev.off()

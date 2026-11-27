## Directly replot the extracted Fig. 2 item; no extraction is rerun here.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp)
item <- sub("_replot\\.R$", "", basename(sp))
d <- read.csv(file.path(folder,paste0(item,".csv")),stringsAsFactors=FALSE)
stopifnot(identical(d$group_as_printed,c("CAU","FCG","NIG")))
png(file.path(folder,paste0(item,"_replot.png")),width=900,height=700,res=120)
par(mar=c(5,6,3,1))
plot(1:3,d$volume_cc,type="n",xlim=c(0.45,3.55),ylim=c(350,450),
     xaxt="n",yaxt="n",xlab="",ylab="Total cortical white matter volume (cc)",
     main="Total Cortical White Matter",las=1)
axis(1,at=1:3,labels=d$group_as_printed)
axis(2,at=c(350,375,400,425,450),las=1)
rect((1:3)-0.35,350,(1:3)+0.35,d$volume_cc,col="#dddddd",border="#444444")
arrows(1:3,d$lower_SEM_cap_cc,1:3,d$upper_SEM_cap_cc,
       angle=90,code=3,length=0.08,lwd=2)
dev.off()

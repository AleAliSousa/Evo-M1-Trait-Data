args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
d <- read.csv(file.path(folder,'Frost_Masterton_1994_Figure3.csv'),stringsAsFactors=FALSE)
png(file.path(folder,'Frost_Masterton_1994_Figure3_replot.png'),width=900,height=650,res=120)
par(mar=c(5,6,3,2))
plot(NA,xlim=c(1,128),ylim=c(0,100),log='x',xaxt='n',
     xlab='Frequency (kHz)',ylab='Detection threshold (dB SPL)',
     main='Frost & Masterton 1994 Figure 3: new opossum curves')
axis(1,at=c(1,2,4,8,16,32,64,128),labels=c(1,2,4,8,16,32,64,128))
abline(h=60,lty=3,col='grey50')
for (i in seq_along(unique(d$series_code))) {
  code <- unique(d$series_code)[i]
  x <- d[d$series_code==code,,drop=FALSE]
  lines(x$frequency_kHz,x$detection_threshold_dB_SPL,type='b',pch=if(i==1) 16 else 1,
        lty=i,col=if(i==1) 'black' else 'grey40')
}
legend('bottomleft',legend=unique(d$Species),pch=c(16,1),lty=c(1,2),
       col=c('black','grey40'),bty='n')
dev.off()

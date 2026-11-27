args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
item <- 'Norlén_etal_2019_Figure1'
d <- read.csv(file.path(folder,paste0(item,'.csv')),stringsAsFactors=FALSE)
png(file.path(folder,paste0(item,'_replot.png')),width=1100,height=1500,res=150)
par(mfrow=c(3,2),mar=c(4,4,3,1))
for (sugar in c('Sucrose','Fructose','Glucose','Maltose','Lactose')) {
  x <- d[d$sugar==sugar,]
  plot(NA,NA,xlim=c(10,1000),ylim=c(40,100),log='x',
       xlab='Concentration (mM)',ylab=paste('Preference for',tolower(sugar),'(%)'),main=sugar)
  abline(h=c(50,66.7),lty=3,col='gray50')
  for (symbol in c('circle','square','triangle')) {
    z <- x[x$series_symbol==symbol,]
    z <- z[order(z$point_order),]
    lines(z$concentration_mM,z$preference_percent,type='b',pch=c(circle=1,square=0,triangle=2)[symbol])
  }
}
plot.new()
legend('center',legend=c('circle','square','triangle'),pch=c(1,0,2),title='Printed series symbols',bty='n')
dev.off()

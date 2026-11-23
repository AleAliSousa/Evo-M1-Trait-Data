## Visual shape check; reads only the built item CSV, never hardcodes measurements.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(!length(a))stop('Run with Rscript.')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('_replot[.]R$','.R',sub('^--file=','',a[1]))))
d <- utils::read.csv(file.path(folder,paste0(item_name,'.csv')),check.names=FALSE)
stopifnot(nrow(d)==20L,identical(d$source_order,seq_len(20L)))
areas <- unique(d$area_as_published)
colors <- c('gray55','gray75','gray30','white','gray90')
png(file.path(folder,paste0(item_name,'_replot.png')),width=1400,height=780,res=140)
op <- par(mar=c(6,5,3,1))
plot(NA,xlim=c(.5,length(areas)+.5),ylim=c(0,330),xlab='',ylab='Average threshold (µA)',
     xaxt='n',yaxt='n',main='Wu et al. 2000, Figure 21 — extracted shape')
axis(2,at=seq(0,300,50));axis(1,at=seq_along(areas),labels=areas,las=2)
for(i in seq_len(nrow(d))){
  x <- d$group_order[i] + if(d$group_order[i]<=5)(d$series_order[i]-2)*.17 else 0
  rect(x-.075,0,x+.075,d$mean_threshold_uA_approx[i],col=colors[d$series_order[i]],border='black')
  if(!is.na(d$upper_sem_endpoint_uA_approx[i])){
    segments(x,d$mean_threshold_uA_approx[i],x,d$upper_sem_endpoint_uA_approx[i])
    segments(x-.035,d$upper_sem_endpoint_uA_approx[i],x+.035,d$upper_sem_endpoint_uA_approx[i])
  }
}
legend('topright',legend=c('forelimb','trunk','hindlimb','eye movement','combined movements'),
       fill=colors,border='black',cex=.8,bty='n')
par(op);dev.off()
cat('Replot:',file.path(folder,paste0(item_name,'_replot.png')),'\n')

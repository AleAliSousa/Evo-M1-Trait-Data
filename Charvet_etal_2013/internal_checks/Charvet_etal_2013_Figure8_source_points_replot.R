## Visual check of table-based Figure 8 source coordinates; not figure digitization.
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
d <- utils::read.csv(file.path(folder,'Charvet_etal_2013_Figure8_source_points.csv'),
                     stringsAsFactors=FALSE)
stopifnot(nrow(d)==27L)
out <- file.path(folder,'Charvet_etal_2013_Figure8_source_points_replot.png')
grDevices::png(out,width=1000,height=720,res=130)
graphics::plot(NA,xlim=c(-2.6,4.15),ylim=c(0.95,7.5),
  xlab=expression(ln('Cortex volume (cm'^3*')')),
  ylab=expression(ln('Neuron numbers ('*10^6*')')),
  main='Charvet Figure 8: coordinates reconstructed from source tables')
prim <- d$series=='Primates — isotropic fractionator' & is.finite(d$ln_volume_cm3)
rod <- d$series=='Rodents — isotropic fractionator' & is.finite(d$ln_volume_cm3)
graphics::points(d$ln_volume_cm3[prim],d$ln_neurons_million[prim],pch=16,cex=1.1)
graphics::points(d$ln_volume_cm3[rod],d$ln_neurons_million[rod],pch=7,cex=1.2)
graphics::legend('bottomright',c('Primates: table-based','Rodents: table-based'),
                 pch=c(16,7),bty='n')
graphics::mtext('Six Charvet Table 2 points omit x: isocortex volumes not printed',
                side=3,line=0.25,cex=0.75)
grDevices::dev.off()
cat(out,'\n')

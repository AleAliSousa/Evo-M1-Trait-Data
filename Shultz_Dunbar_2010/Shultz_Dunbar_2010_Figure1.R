# Shultz & Dunbar 2010, Figure 1 (p. 258), doi:10.1037/a0018894.
# Frozen raster marker centres -> plotted values, identity audit, CSV/TSV and PNG.
# This recovers 63 separately visible markers, not the underlying study dataset.
# Genus candidates are inferred; do not assign genus-averaged scores to species.
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if(length(a)!=1L) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a)))
item <- 'Shultz_Dunbar_2010_Figure1'
read <- function(s) read.csv(file.path(folder,paste0(item,s)),stringsAsFactors=FALSE,na.strings='')
s <- read('_snapshot.csv');cal <- read('_calibration.csv');audit <- read('_identity_audit.csv')
stopifnot(nrow(s)==63L,!anyDuplicated(s$point_id),identical(s$point_id,audit$point_id))
cx <- lm(value~pixel,cal[cal$axis=='x',]);cy <- lm(value~I(1927.5-pixel)+0,cal[cal$axis=='y',])
x <- predict(cx,data.frame(pixel=s$x_pixel));y <- predict(cy,data.frame(pixel=s$y_pixel))
stopifnot(max(abs(x-audit$log10_hippocampus_digitized))<1e-10,max(abs(y-audit$ability_digitized))<1e-10)
d <- audit
d$log10_hippocampus_digitized <- x
d$ability_digitized <- y
d$hippocampus_mm3_reverse_log <- 10^x
# Preserve source and plotted values separately: do not replace x with source volumes.
d$hippocampus_value_origin <- 'reverse_log10_of_digitized_x'
d$ability_scale <- 'arcsin-transformed proportion as described by authors; exact formula not specified'
d$species <- NA_character_
write.csv(d,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='')
tsv <- file.path(dirname(folder),'__Public','comparative-data')
if(dir.exists(tsv)) write.table(d,file.path(tsv,'10.1037%2Fa0018894_Figure1.tsv'),sep='\t',row.names=FALSE,quote=FALSE,na='')
png(file.path(folder,paste0(item,'_reconstructed.png')),width=1800,height=1500,res=180)
par(mar=c(5.5,5,4.5,10),xpd=FALSE)
plot(x,y,type='n',xlim=c(2.17,3.84),ylim=c(-.08,1.58),xaxs='i',yaxs='i',xlab=expression(log[10]*' hippocampus volume (mm'^3*')'),ylab='Ability (published transformed scale)',main='Shultz & Dunbar (2010), Figure 1',axes=FALSE)
axis(1,at=seq(2.4,3.6,.3));axis(2,at=seq(0,1.4,.2),las=1);box()
keys <- c('Delay','Detour','Displace','LS','Oddity','Reversal','Reverse','String')
shapes <- c(23,3,2,8,1,4,25,21)
for(k in seq_along(keys)){
 keep <- d$task_legend==keys[k]
 points(x[keep],y[keep],pch=shapes[k],cex=1.15,lwd=1.7,col=if(k==1)'grey55' else 'black',bg=if(k==1)'grey60' else 'black')
}
# Reconstructed OLS of visible markers, distinguished from the paper's regression.
fit <- lm(y~x);abline(fit,col='grey45',lty=2,lwd=1.5)
par(xpd=NA)
legend(3.90,1.56,c(keys,'Visible-marker OLS'),pch=c(shapes,NA),pt.bg=c('grey60',rep('black',7),NA),col=c('grey55',rep('black',7),'grey45'),lty=c(rep(NA,8),2),lwd=c(rep(NA,8),1.5),bty='n',cex=.86,pt.cex=1.1)
mtext('63 visible markers digitized; overlapping or hidden points may remain unresolved',side=3,line=.4,cex=.8)
mtext(sprintf('Visible-marker R-squared = %.3f; original figure reports 0.323',summary(fit)$r.squared),side=1,line=3.8,cex=.82)
dev.off()
cat('Built',item,':',nrow(d),'visible markers; identity status is explicit in every row.\n')

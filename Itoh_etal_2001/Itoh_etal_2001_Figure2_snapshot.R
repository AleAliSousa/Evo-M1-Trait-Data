## Constructed figure snapshot: independent bar-edge readings, not values inferred
## from the printed percentages. Coordinates are zero-based native bitmap pixels.
## Codex AI assistant, 2026-11-20. The native stencil is preserved unchanged.
args <- commandArgs(FALSE)
p <- sub('^--file=', '', args[grepl('^--file=', args)][1])
if (is.na(p)) stop('Run with Rscript item_snapshot.R')
folder <- dirname(normalizePath(p)); item_name <- sub('_snapshot$', '', tools::file_path_sans_ext(basename(p)))
setwd(folder)
points <- read.csv(file.path('reference_tables', paste0(item_name, '_digitization_points.csv')), check.names=FALSE)
cal <- read.csv(file.path('reference_tables', paste0(item_name, '_axis_calibration.csv')))
a <- cal[cal$axis=='rate', ]; zero <- a$y_pixel[a$value==0]
height <- zero-a$y_pixel
rate_per_pixel <- sum(height*a$value)/sum(height^2)
drift <- lm(y_pixel ~ x_pixel, data=cal[cal$axis=='baseline_drift', ])
## Zero is the independently observed baseline, not a free regression intercept.
rate_at <- function(y,x) as.numeric((predict(drift,data.frame(x_pixel=x))-y)*rate_per_pixel)
stopifnot(nrow(points)==57L, length(unique(points$region_order))==19L,
          all(points$upper_error_edge_y_pixel < points$mean_edge_y_pixel))
fields <- c('Row type','Anatomical group','Brain region as printed',
            'Young Wild Mice (n=3) mean (digitized)', 'WT upper error endpoint (digitized)',
            'Young TRbetaPV/PV Mice (n=3) mean (digitized)', 'TRbeta upper error endpoint (digitized)',
            'Young TRalphaPV/+ Mice (n=4) mean (digitized)', 'TRalpha upper error endpoint (digitized)',
            'TRalpha percent change as printed','Significance as printed',
            'Digitization halfwidth (umol/g/min)')
blank <- function(type, group='', region='') {z<-as.list(rep('',length(fields)));names(z)<-fields;z[[1]]<-type;z[[2]]<-group;z[[3]]<-region;z}
rows <- list(blank('caption',region='Figure 2. Local cerebral glucose utilization in 19 brain regions of young wild-type mice, young TRbetaPV/PV mice, and young TRalphaPV/+ mice. Percent decrease in TRalpha relative to wild-type siblings is shown.'),
             blank('units',region='Local Cerebral Glucose Utilization (umol/g/min); linear axis 0.0 to 1.2'),
             blank('method',region='Constructed snapshot from native 300 dpi bitmap. Plotted bar order is WT, TRalpha, TRbeta; columns follow legend order. All rate values are digitized estimates.'),
             blank('error_bars',region='Upper error endpoints digitized; Figure 2 caption does not specify error-bar type. Do not assume SEM from Table 1.'))
last <- ''
for (i in sort(unique(points$region_order))) {
 z <- points[points$region_order==i, ]; stopifnot(nrow(z)==3)
 if(z$anatomical_group_as_printed[1]!=last){last<-z$anatomical_group_as_printed[1];rows[[length(rows)+1]]<-blank('section',last)}
 r <- blank('data',last,z$region_as_printed[1])
 for(j in seq_along(c('WT','TRbeta','TRalpha'))){v<-z[z$series_key==c('WT','TRbeta','TRalpha')[j], ];r[[2*j+2]]<-sprintf('%.4f',rate_at(v$mean_edge_y_pixel,v$x_pixel));r[[2*j+3]]<-sprintf('%.4f',rate_at(v$upper_error_edge_y_pixel,v$x_pixel))}
 r[[10]]<-z$printed_alpha_percent[1];r[[11]]<-z$printed_significance[1]
 r[[12]]<-sprintf('%.6f',rate_per_pixel*z$pixel_reading_halfwidth[1])
 rows[[length(rows)+1]]<-r
}
snapshot <- do.call(rbind,lapply(rows,as.data.frame,stringsAsFactors=FALSE,check.names=FALSE))
out <- paste0(item_name,'_snapshot.csv');tmp<-tempfile(fileext='.csv')
write.csv(snapshot,tmp,row.names=FALSE,na='',fileEncoding='UTF-8')
if(file.exists(out)){
 if(!identical(readLines(out,warn=FALSE),readLines(tmp,warn=FALSE)))stop('Frozen snapshot differs; review before replacing.')
 cat('Frozen snapshot reproduced identically.\n')
}else{file.copy(tmp,out);cat('Froze constructed snapshot:',out,'\n')}
unlink(tmp)

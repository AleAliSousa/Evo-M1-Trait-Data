## Constructed figure snapshot from frozen 300-dpi page image and pixel readings.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(!length(a))stop('Run this snapshot script with Rscript.')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- sub('_snapshot$','',tools::file_path_sans_ext(basename(sub('^--file=','',a[1]))))
ref <- file.path(folder,'reference_tables')
p <- utils::read.csv(file.path(ref,paste0(item_name,'_pixel_readings.csv')),stringsAsFactors=FALSE,na.strings='')
axis <- utils::read.csv(file.path(ref,paste0(item_name,'_axis.csv')))
stopifnot(nrow(p)==20L,nrow(axis)==2L,identical(p$source_order,seq_len(20L)),all(diff(axis$tick_uA)>0),all(diff(axis$y_px)<0))
uA_from_y <- function(y) axis$tick_uA[1] + (axis$y_px[1]-y)*(diff(axis$tick_uA)/(axis$y_px[1]-axis$y_px[2]))
mean_uA <- round(uA_from_y(p$bar_top_y_px))
upper_uA <- ifelse(is.na(p$upper_sem_y_px),NA_integer_,round(uA_from_y(p$upper_sem_y_px)))
snap <- rbind(c('Figure 21','Stimulation thresholds by cortical area and evoked movement category; mean and SEM digitized from 300-dpi source image',rep('',8)),
              c('source_order','area','series','group_order','series_order','mean_threshold_uA_approx','upper_sem_endpoint_uA_approx','bar_top_y_px','upper_sem_y_px','x_px'),
              cbind(as.character(p$source_order),p$area,p$series,as.character(p$group_order),as.character(p$series_order),
                    as.character(mean_uA),as.character(upper_uA),as.character(p$bar_top_y_px),as.character(p$upper_sem_y_px),as.character(p$x_px)),
              c('Note','SEM is identified by the figure caption. M1 whisker endpoints were not legible in the frozen image; no SEM values inferred. Axis calibration: 0 µA at y=610 px and 300 µA at y=140 px in cropped image.',rep('',8)))
out <- file.path(folder,paste0(item_name,'_snapshot.csv'));tmp <- tempfile(tmpdir=folder,fileext='.csv')
utils::write.table(snap,tmp,sep=',',quote=TRUE,row.names=FALSE,col.names=FALSE,na='',fileEncoding='UTF-8')
if(file.exists(out) && !identical(readBin(out,'raw',file.info(out)$size),readBin(tmp,'raw',file.info(tmp)$size))){unlink(tmp);stop('Frozen snapshot differs; inspect source before replacement.')}
if(!file.exists(out))file.copy(tmp,out)
unlink(tmp);cat('Snapshot:',out,'; bars:',nrow(p),'\n')

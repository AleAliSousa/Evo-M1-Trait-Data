## Printed-layout transcription from the source PDF, 2026-11-20; AI check, human signoff pending.
.sp<-local({f<-tryCatch(sys.frame(1)$ofile,error=function(e)NULL);if(!is.null(f))f else sub('^--file=','',grep('^--file=',commandArgs(FALSE),value=TRUE)[1])})
folder<-dirname(normalizePath(.sp,mustWork=TRUE));item_name<-sub('_snapshot$','',tools::file_path_sans_ext(basename(.sp)))
source_text <- "Table 1. Mean estimated volume (mm³) of the selected ROI by MRI volumetry of the experimental groups\t\t\t\t\n\tPrefrontal cortex\tDorsal striatum\tDorsal hippocampus\tVentral hippocampus\nSA\t7.67 ± 0.30\t47.39 ± 1.90\t28.51 ± 0.19\t15.16 ± 0.54\nMS\t8.30 ± 0.32\t47.56 ± 2.67\t28.85 ± 0.65\t15.21 ± 0.54\nSA-EE\t8.54 ± 0.15*\t47.03 ± 0.98\t30.72 ± 0.92*\t13.64 ± 0.28+\nMS-EE\t8.53 ± 0.54\t47.83 ± 1.78\t32.61 ± 1.90\t17.36 ± 0.46#\nNote: Mean ± S.E.M. *significantly higher vs. SA group (FDR-p < 0.05), +significantly lower vs. MS and SA groups (FDR-p<0.01), #significantly higher vs. MS and SA groups (FDR-p < 0.001)\t\t\t\t"
d<-read.delim(text=source_text,header=FALSE,sep='\t',quote='',fill=TRUE,colClasses='character',check.names=FALSE,blank.lines.skip=FALSE)
p<-file.path(folder,paste0(item_name,'_snapshot.csv'));tmp<-tempfile(fileext='.csv');write.table(d,tmp,sep=',',row.names=FALSE,col.names=FALSE,na='',fileEncoding='UTF-8',qmethod='double')
if(file.exists(p)){if(!identical(readBin(p,'raw',n=file.info(p)$size),readBin(tmp,'raw',n=file.info(tmp)$size)))stop('Frozen snapshot differs; refusing overwrite.')}else file.copy(tmp,p)
unlink(tmp)

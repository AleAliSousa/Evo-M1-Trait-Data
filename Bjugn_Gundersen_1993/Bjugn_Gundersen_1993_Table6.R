## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
stopifnot(nrow(snap)==6L,ncol(snap)==4L)
parts<-lapply(c('Ventral horns','Middle portion','Dorsal horns'),function(region){
 x<-snap[[region]];data.frame(region_as_published=region,volume_mm3=as.numeric(x[1]),glial_cells_million=as.numeric(x[2]),
 endothelial_cells_million=as.numeric(x[3]),neurons_million=as.numeric(x[4]),category1_neurons_pct=as.numeric(sub('%','',x[5],fixed=TRUE)),
 category2_neurons_pct=as.numeric(sub('%','',x[6],fixed=TRUE)),Species='Rattus norvegicus',animal_id='1',
 coverage='spinal cord down to mid-lumbar segments',observation_level='one rat x gray-matter compartment',data_role='primary',stringsAsFactors=FALSE)
})
final.dataframe<-do.call(rbind,parts)
stopifnot(nrow(final.dataframe)==3L,all(final.dataframe$category1_neurons_pct+final.dataframe$category2_neurons_pct==100))

utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
stopifnot(nrow(snap)==4L,ncol(snap)==5L)
classes<-c('Glial','Endothelial','Neurons')
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(classes,function(cl)
 data.frame(source_row=i,region_as_published=snap$Region[i],matter='gray matter',region_volume_mm3=as.numeric(snap[['Mean volume (mm3)']][i]),
 cell_class=cl,mean_cell_count_million=as.numeric(snap[[if(cl=='Neurons')'Mean neurons (10^6)' else paste0('Mean ',tolower(cl),' cells (10^6)')]][i]),
 Species='Rattus norvegicus',observation_level='regional mean across five rats',data_role='primary group mean',stringsAsFactors=FALSE)
))))
stopifnot(nrow(final.dataframe)==12L,all(final.dataframe$mean_cell_count_million>0),all(final.dataframe$region_volume_mm3>0))

utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

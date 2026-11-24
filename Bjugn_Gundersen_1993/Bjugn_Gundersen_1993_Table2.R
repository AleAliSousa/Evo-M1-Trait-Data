## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
stopifnot(nrow(snap)==8L,ncol(snap)==10L)
parts<-lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(c('White','Gray'),function(matter)do.call(rbind,lapply(c('Σ','G','E','N'),function(cell){
 value<-as.numeric(snap[[paste0(matter,' matter ',cell,' (10^6)')]][i])
 data.frame(source_row=i,animal_as_published=snap[['Animal number']][i],matter=paste0(tolower(matter),' matter'),cell_class=cell,
 count_million=value,gray_neuron_CE=if(matter=='Gray'&&cell=='N')suppressWarnings(as.numeric(snap[['Gray matter neuron CE']][i])) else NA_real_,stringsAsFactors=FALSE)
})))))
final.dataframe<-do.call(rbind,parts)
final.dataframe$animal_id<-ifelse(grepl('^[1-5]$',final.dataframe$animal_as_published),final.dataframe$animal_as_published,'')
final.dataframe$summary_statistic<-ifelse(nzchar(final.dataframe$animal_id),'',final.dataframe$animal_as_published)
final.dataframe$Species<-'Rattus norvegicus';final.dataframe$observation_level<-ifelse(nzchar(final.dataframe$animal_id),'individual spinal cord','across-rat source summary')
final.dataframe$data_role<-ifelse(nzchar(final.dataframe$animal_id),'primary','source summary')
stopifnot(nrow(final.dataframe)==64L,all(final.dataframe$count_million>0),
 abs(final.dataframe$count_million[final.dataframe$animal_as_published=='Mean'&final.dataframe$matter=='gray matter'&final.dataframe$cell_class=='N']-6.42)<1e-8)

utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

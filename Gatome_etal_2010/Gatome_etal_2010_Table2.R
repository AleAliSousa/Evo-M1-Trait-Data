## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
parse_mean<-function(x){x<-gsub(',','',x,fixed=TRUE);as.numeric(sub('^([0-9.]+).*','\\1',x))}
parse_sd<-function(x){ifelse(grepl('\\(',x),as.numeric(sub('.*\\(([0-9.]+)\\).*','\\1',x)),NA_real_)}
stopifnot(nrow(snap)==16L,ncol(snap)==11L)
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(c('Rat','Mouse'),function(sp){
 number<-snap[[paste0(sp,' number (SD)')]][i];prop<-snap[[paste0(sp,' proportion (SD) %')]][i]
 data.frame(source_row=i,field=snap$Field[i],phenotype_as_published=snap[['Cell type']][i],species_as_published=sp,
 Species=if(sp=='Rat')'Rattus norvegicus' else 'Mus musculus',neuron_number_mean=parse_mean(number),neuron_number_SD=parse_sd(number),
 number_CE=suppressWarnings(as.numeric(snap[[paste0(sp,' CE')]][i])),proportion_pct=parse_mean(prop),proportion_SD_pct=parse_sd(prop),
 p_prop_CE_vs_ME_as_published=snap[[paste0(sp,' PProp CE,ME')]][i],p_prop_species_as_published=snap[['PProp species']][i],
 observation_level='species x field x morphology group mean',data_role='primary group mean',stringsAsFactors=FALSE)
}))))
stopifnot(nrow(final.dataframe)==32L,all(final.dataframe$neuron_number_mean>0),all(final.dataframe$proportion_pct>=0))

utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
raw_snapshot<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),header=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
stopifnot(ncol(raw_snapshot)==10L)
snap<-raw_snapshot[c(5:12,14:21),,drop=FALSE]
field_blocks<-rep(c('CE','ME'),c(8,8))
parse_mean<-function(x){x<-gsub(',','',x,fixed=TRUE);as.numeric(sub('^([0-9.]+).*','\\1',x))}
parse_sd<-function(x){ifelse(grepl('\\(',x),as.numeric(sub('.*\\(([0-9.]+)\\).*','\\1',x)),NA_real_)}
stopifnot(nrow(snap)==16L)
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(c('Rat','Mouse'),function(sp){
 number<-snap[[if(sp=='Rat')2L else 3L]][i];prop<-snap[[if(sp=='Rat')6L else 7L]][i]
 data.frame(source_row=i,field=field_blocks[i],phenotype_as_published=snap[[1]][i],species_as_published=sp,
 Species=if(sp=='Rat')'Rattus norvegicus' else 'Mus musculus',neuron_number_mean=parse_mean(number),neuron_number_SD=parse_sd(number),
 number_CE=suppressWarnings(as.numeric(snap[[if(sp=='Rat')4L else 5L]][i])),proportion_pct=parse_mean(prop),proportion_SD_pct=parse_sd(prop),
 p_prop_CE_vs_ME_as_published=snap[[if(sp=='Rat')8L else 9L]][i],p_prop_species_as_published=snap[[10]][i],
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

## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
raw_snapshot<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),header=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
stopifnot(ncol(raw_snapshot)==7L)
snap<-raw_snapshot[c(5:10,12:18),,drop=FALSE]
field_blocks<-rep(c('Rat','Mouse'),c(6,7))
parse_mean<-function(x){x<-gsub(',','',x,fixed=TRUE);as.numeric(sub('^([0-9.]+).*','\\1',x))}
parse_sd<-function(x){ifelse(grepl('\\(',x),as.numeric(sub('.*\\(([0-9.]+)\\).*','\\1',x)),NA_real_)}
stopifnot(nrow(snap)==13L)
fields<-c('CE','ME','MEA')
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(fields,function(field){
 raw<-snap[[match(field,fields)*2L]][i]
 data.frame(source_row=i,species_as_published=field_blocks[i],Species=if(field_blocks[i]=='Rat')'Rattus norvegicus' else 'Mus musculus',
 animal_as_published=snap[[1]][i],field=field,number_as_published=raw,neuron_number=parse_mean(raw),group_sd=if(snap[[1]][i]=='Mean')parse_sd(raw) else NA_real_,
 number_CE=as.numeric(snap[[match(field,fields)*2L+1L]][i]),observation_level=if(snap[[1]][i]=='Mean')'species x field source mean' else 'individual x field',
 data_role=if(snap[[1]][i]=='Mean')'source summary' else 'primary',stringsAsFactors=FALSE)
}))))
stopifnot(nrow(final.dataframe)==39L,all(final.dataframe$neuron_number>0),sum(final.dataframe$animal_as_published=='Mean')==6L)

utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

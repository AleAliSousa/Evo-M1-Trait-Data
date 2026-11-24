## Frozen printed table -> analysis CSV -> registry-coded public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run the saved item script with Rscript or source().')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
parse_mean<-function(x){x<-gsub(',','',x,fixed=TRUE);as.numeric(sub('^([0-9.]+).*','\\1',x))}
parse_sd<-function(x){ifelse(grepl('\\(',x),as.numeric(sub('.*\\(([0-9.]+)\\).*','\\1',x)),NA_real_)}
stopifnot(nrow(snap)==6L,ncol(snap)==14L)
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(c('Rat','Mouse'),function(sp)do.call(rbind,lapply(c('Density','Area'),function(measure)do.call(rbind,lapply(c('D','V'),function(side){
 prefix<-if(measure=='Area')'Area' else 'Density';suffix<-if(measure=='Area')' (um2)' else ''
 raw<-snap[[paste0(prefix,' ',sp,' ',side,suffix)]][i]
 data.frame(source_row=i,field=snap$Field[i],phenotype_as_published=snap[['Cell type']][i],species_as_published=sp,
 Species=if(sp=='Rat')'Rattus norvegicus' else 'Mus musculus',dorsoventral=if(side=='D')'dorsal' else 'ventral',
 measure=if(measure=='Area')'soma sectional area' else 'cells per disector',mean_value=parse_mean(raw),SD=parse_sd(raw),
 unit=if(measure=='Area')'um2' else 'count per disector',p_dorsal_ventral_as_published=snap[[paste0(prefix,' ',sp,' P_D,V')]][i],
 observation_level='species x field x phenotype x dorsoventral group mean',data_role='primary group mean',stringsAsFactors=FALSE)
}))))))))
stopifnot(nrow(final.dataframe)==48L,all(final.dataframe$mean_value>0))

utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

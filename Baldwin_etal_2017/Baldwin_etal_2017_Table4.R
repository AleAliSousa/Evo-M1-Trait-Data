## Printed case-by-area LT-ICMS threshold table -> analysis CSV and public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run saved item script.')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),header=FALSE,check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,na.strings=NULL,fileEncoding='UTF-8')
stopifnot(nrow(snap)==25L,ncol(snap)==7L,snap[2,1]=='Case No.',snap[25,1]!='')
areas<-c('M','3a','3b','Sc','PP','S2/Pv')
case_rows<-which(seq_len(nrow(snap))>=4L & seq_len(nrow(snap))<25L & nzchar(snap[[1]]))
stopifnot(length(case_rows)==11L,identical(snap[[1]][case_rows[11]],'Average'))
parts<-lapply(seq_along(areas),function(j){
 n_printed<-vapply(case_rows,function(i){if(i+1L<25L && !nzchar(snap[[1]][i+1L]))snap[[j+1L]][i+1L] else ''},character(1))
 data.frame(source_row=case_rows,case_as_published=snap[[1]][case_rows],cortical_area=areas[j],
  threshold_as_published=snap[[j+1L]][case_rows],n_as_published=sub('^[nN]\\s*=\\s*','',n_printed),stringsAsFactors=FALSE)
})
final.dataframe<-do.call(rbind,lapply(seq_along(case_rows),function(i)do.call(rbind,lapply(parts,function(p)p[i,,drop=FALSE]))))
final.dataframe$case_id<-gsub('–','-',final.dataframe$case_as_published,fixed=TRUE)
final.dataframe$mean_threshold_uA<-suppressWarnings(as.numeric(final.dataframe$threshold_as_published))
final.dataframe$sites_n<-suppressWarnings(as.integer(final.dataframe$n_as_published))
final.dataframe$threshold_status<-ifelse(final.dataframe$threshold_as_published=='nm','not measured',ifelse(final.dataframe$threshold_as_published=='n/a','n/a as printed','measured'))
final.dataframe$species_as_published<-'Tupaia belangeri'
final.dataframe$observation_level<-ifelse(final.dataframe$case_as_published=='Average','across-case summary','case x cortical area')
final.dataframe$data_role<-ifelse(final.dataframe$case_as_published=='Average','source summary','primary')
stopifnot(sum(final.dataframe$threshold_status=='measured')==sum(!is.na(final.dataframe$mean_threshold_uA)),
 all(is.na(final.dataframe$sites_n)|final.dataframe$sites_n>=1L),nrow(final.dataframe)==66L)
for(a in areas){x<-final.dataframe[final.dataframe$cortical_area==a,];stopifnot(sum(x$sites_n[x$case_as_published!='Average'],na.rm=TRUE)==x$sites_n[x$case_as_published=='Average'])}
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

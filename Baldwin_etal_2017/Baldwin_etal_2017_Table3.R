## Printed case-level LT-ICMS movement table -> analysis CSV and public TSV.
.sp <- local({a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))};stop('Run saved item script.')})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-dirname(folder)
snap<-utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),skip=2,check.names=FALSE,colClasses='character',stringsAsFactors=FALSE,fileEncoding='UTF-8')
names(snap)<-c('Case No.','Total sites Tested','Sites with Movements using LT-ICMS','Complex movements: Multijoint','Complex movements: Multibody-part','Complex movements: Multibody-part + multijoint','Total Complex movements')
stopifnot(nrow(snap)==10L,ncol(snap)==7L)
num<-function(x)as.integer(sub('^([0-9]+).*','\\1',x))
final.dataframe<-data.frame(source_row=seq_len(nrow(snap))+3L,case_as_published=snap[['Case No.']],case_id=gsub('–','-',gsub('ᵃ','',snap[['Case No.']],fixed=TRUE),fixed=TRUE),
 species_as_published='Tupaia belangeri',sites_tested=num(snap[['Total sites Tested']]),sites_with_movements_LT_ICMS=num(snap[['Sites with Movements using LT-ICMS']]),
 multijoint_as_published=snap[['Complex movements: Multijoint']],multibody_part_as_published=snap[['Complex movements: Multibody-part']],
 multibody_part_multijoint_as_published=snap[['Complex movements: Multibody-part + multijoint']],total_complex_as_published=snap[['Total Complex movements']],
 total_complex_numeric=num(snap[['Total Complex movements']]),recording_incomplete=grepl('ᵃ',snap[['Case No.']],fixed=TRUE),
 observation_level='case',data_role='primary',check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(sum(final.dataframe$sites_tested)==471L,sum(final.dataframe$sites_with_movements_LT_ICMS)==323L,
 all(final.dataframe$sites_with_movements_LT_ICMS<=final.dataframe$sites_tested),all(final.dataframe$total_complex_numeric<=final.dataframe$sites_with_movements_LT_ICMS))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'}
rr<-which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

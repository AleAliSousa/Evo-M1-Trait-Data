## Source-layout snapshot reader; scientific cells are read only from this item's snapshot.
.sp <- local({f <- tryCatch(sys.frame(1)$ofile,error=function(e)NULL); if(!is.null(f)) f else sub('^--file=','',grep('^--file=',commandArgs(FALSE),value=TRUE)[1])})
folder <- dirname(normalizePath(.sp,mustWork=TRUE));item_name <- tools::file_path_sans_ext(basename(.sp));base <- dirname(folder)
snap <- read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),header=FALSE,check.names=FALSE,colClasses='character',na.strings=character())
parse_cell <- function(x) {x<-gsub(' ','',x,fixed=TRUE);z<-regmatches(x,gregexpr('[0-9]+(?:\\.[0-9]+)?',gsub('(?<=\\d) (?=\\d{3})','',x,perl=TRUE),perl=TRUE))[[1]];if(length(z)!=2L)stop('Expected mean and SEM: ',x);as.numeric(z)}
rows <- list()
add <- function(i,j,region,arm,endpoint,hemi='',stats='',pct='') {
 cell<-snap[i,j];if(cell %in% c('...','…',''))return(invisible(NULL));z<-parse_cell(cell)
 area<-region %in% c('CC','CBV');basis<-if(endpoint=='normalized') if(area)'normalized_linear_size' else 'normalized_volume' else if(area)'area' else 'volume'
 unit<-if(endpoint=='normalized')'dimensionless x1000' else if(area)'mm2' else 'mm3'
 rows[[length(rows)+1L]]<<-data.frame(source_row=i,source_column=j,region_as_published=region,hemisphere=hemi,arm_id=arm,endpoint=endpoint,cell_as_printed=cell,mean=z[1],sem=z[2],dispersion_type='SEM',physical_basis=basis,unit=unit,statistics_as_printed=stats,pct_difference_as_printed=pct,stringsAsFactors=FALSE)
}
for(i in 3:6)for(j in 2:5)add(i,j,snap[2,j],snap[i,1],'reported')
final.dataframe<-do.call(rbind,rows)
final.dataframe$Species<-"Rattus norvegicus";final.dataframe$species_as_published<-"Wistar rats";final.dataframe$source<-item_name
final.dataframe$n_nominal<-5
final.dataframe$age_as_published<-"P90";final.dataframe$source_note<-"Daily maternal separation 4 h on P2–21. Enrichment P21–60; all groups then standard same-treatment housing until P90. MRI n=5 male rats per group, not cohort n=10. Table labels PFC; methods say medial PFC. Methods mention VOIs corrected for total brain volume; retain reported mm3 without assuming raw unadjusted bilateral volume. Tables 1 and 2 disagree in several means; preserve both and analyze separately."
table_checks<-data.frame(check='no_independent_printed_total_or_percent_relation',passed=NA,notes='Row counts are structural checks, not independent validation of values.')
write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
if(file.exists(file.path(base,'__ReadMe.xlsx'))){filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');r<-filecodes[which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name),];if(nrow(r)==1L){item_encoded<-r[['Item encoded']];stopifnot(!is.na(item_encoded),!grepl('_$',item_encoded));dir.create(file.path(base,'__Public','comparative-data'),recursive=TRUE,showWarnings=FALSE);write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,quote=FALSE,na='',fileEncoding='UTF-8')}else message('Main-registry registration pending; public TSV not written.')}else message('Staging build; public TSV awaits main-registry registration.')
cat(item_name,':',nrow(final.dataframe),'source cells parsed.\n')

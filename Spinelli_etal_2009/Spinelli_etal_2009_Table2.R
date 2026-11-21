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
for(i in 5:17)for(j in 2:5)add(i,j,snap[i,1],c('MR','PR','MR','PR')[j-1],if(j<4)'normalized' else 'absolute',hemi=if(grepl('^Right',snap[i,1]))'RH' else if(grepl('^Left',snap[i,1]))'LH' else '',stats=snap[i,7],pct=snap[i,6])
final.dataframe<-do.call(rbind,rows)
final.dataframe$Species<-"Macaca mulatta";final.dataframe$species_as_published<-"rhesus monkeys (Macaca mulatta)";final.dataframe$source<-item_name
final.dataframe$n_nominal<-ifelse(final.dataframe$arm_id=="MR",15L,13L)
final.dataframe$age_as_published<-"MR 27.40 ± 0.90 months; PR 26.39 ± 0.33 months (SEM)";final.dataframe$source_note<-"Random assignment at birth; MR n=15, PR n=13. PR animals nursery/peer reared without mothers for first 6 months, then groups housed together. One mPFC trace unavailable; group of missing animal not specified, so subgroup effective n is unknown. PFL includes gray and white matter; mPFC and dmPFC nested within PFL, dmPFC nested within mPFC. CC and CBV are midsagittal areas, not volumes, despite the spanning mm3 header. Preserve printed percentage differences and test independently."
# Published percent differences are checked without changing either the means or the printed percentages.
a<-final.dataframe[final.dataframe$endpoint=='absolute',];reg<-unique(a$region_as_published)
checks<-lapply(reg,function(rr){z<-a[a$region_as_published==rr,];c<-z$mean[z$arm_id=='MR'];t<-z$mean[z$arm_id=='PR'];p<-as.numeric(gsub('−','-',z$pct_difference_as_printed[1],fixed=TRUE));obs<-100*(t/c-1);tol<-.005+100*(.005/c+t*.005/c^2);data.frame(check=rr,observed=obs,printed=p,residual_pp=obs-p,tolerance_pp=tol,passed=abs(obs-p)<=tol)})
table_checks<-do.call(rbind,checks)
if(any(!table_checks$passed))warning('Printed percent discrepancies retained: ',paste(table_checks$check[!table_checks$passed],collapse=', '))
write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
if(file.exists(file.path(base,'__ReadMe.xlsx'))){filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');r<-filecodes[which(!is.na(filecodes[['Item name']])&filecodes[['Item name']]==item_name),];if(nrow(r)==1L){item_encoded<-r[['Item encoded']];stopifnot(!is.na(item_encoded),!grepl('_$',item_encoded));dir.create(file.path(base,'__Public','comparative-data'),recursive=TRUE,showWarnings=FALSE);write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,quote=FALSE,na='',fileEncoding='UTF-8')}else message('Main-registry registration pending; public TSV not written.')}else message('Staging build; public TSV awaits main-registry registration.')
cat(item_name,':',nrow(final.dataframe),'source cells parsed.\n')

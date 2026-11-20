## Figure 2 reader. Reads only its own frozen snapshot for scientific values.
## All three genotypes are retained; only WT is used downstream for reference costs.
invisible(Sys.setlocale('LC_ALL','en_US.UTF-8'))
.sp <- local({
 a<-grep('^--file=',commandArgs(FALSE),value=TRUE)
 if(exists('sys.frame')){for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p)&&grepl('Figure2[.]R$',p))return(normalizePath(p))}}
 if(length(a))return(normalizePath(sub('^--file=','',a[1])))
 stop('Run with Rscript or source the saved item script.')
})
folder <- dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp))
base <- local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,'__ReadMe.xlsx')))d<-dirname(d);if(file.exists(file.path(d,'__ReadMe.xlsx')))d else Sys.getenv('EVOM1_ROOT',unset=NA_character_)})
setwd(folder)
snap<-read.csv(paste0(item_name,'_snapshot.csv'),check.names=FALSE,colClasses='character',na.strings='')
d<-snap[snap[[1]]=='data', ];stopifnot(nrow(d)==19L)
num<-function(x)as.numeric(gsub('[^0-9.eE+-]','',x))
wt<-num(d[[4]]);alpha<-num(d[[8]]);eps<-num(d[[12]]);printed<-num(d[[10]])
observed<-100*(alpha/wt-1)
## Percent labels are whole integers: +/-0.5 pp rounding. Independently read
## mean edges have +/-3 native-pixel uncertainty retained in the snapshot.
low<-100*((alpha-eps)/(wt+eps)-1);high<-100*((alpha+eps)/(wt-eps)-1)
tolerance<-.5+pmax(observed-low,high-observed)
table_checks<-data.frame(check_id=paste0('TRalpha_percent_',seq_len(nrow(d))),
 basis=paste('Fig 2',d[[3]],'TRalpha versus WT; means read independently'),
 observed=observed,printed=printed,difference=observed-printed,tolerance=tolerance,
 status=ifelse(abs(observed-printed)<=tolerance,'pass','mismatch'),
 note='Whole-percent rounding plus propagated +/-3-pixel mean-edge reading bounds; not biological confidence intervals.')
if(any(table_checks$status!='pass'))warning(sum(table_checks$status!='pass'),' printed-percentage checks differ beyond digitization and rounding bounds; values retained.')
series<-c('Young Wild Mice','Young TRbetaPV/PV Mice','Young TRalphaPV/+ Mice')
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(d)),function(i)do.call(rbind,lapply(1:3,function(j){
 mean<-num(d[[2*j+2]][i]);upper<-num(d[[2*j+3]][i]);e<-eps[i]
 data.frame(source_structure_order=i,anatomical_group_as_published=d[[2]][i],region_as_published=d[[3]][i],
 species_as_published='mice',group_as_published=series[j],genotype=c('WT','TRbetaPV/PV','TRalphaPV/+')[j],n=c(3L,3L,4L)[j],
 mean_umol_g_min=mean,upper_error_endpoint_umol_g_min=upper,
 errorbar_type='not specified in Figure 2 caption',
 CMRgl_umol_100g_min=round(mean*100,2),upper_error_length_umol_100g_min=round((upper-mean)*100,2),
 digitization_halfwidth_umol_100g_min=e*100,
 digitization_low_umol_100g_min=(mean-e)*100,digitization_high_umol_100g_min=(mean+e)*100,
 alpha_pct_as_printed=d[[10]][i],significance_as_printed=d[[11]][i],
 extraction='digitized from native PDF bitmap; approximate',source=item_name,stringsAsFactors=FALSE)
}))))
stopifnot(nrow(final.dataframe)==57L,all(final.dataframe$CMRgl_umol_100g_min>0),all(final.dataframe$upper_error_length_umol_100g_min>0))
write.csv(final.dataframe,paste0(item_name,'.csv'),row.names=FALSE,na='',fileEncoding='UTF-8')
## Prefer live registry. The owner's temporary entry supplies the pending item.
filecodes<-readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1')
registry_source<-'__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){
 filecodes<-readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source<-'__ReadMeAddON.xlsx'
}
rr<-which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded<-filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
tsv_dir<-Sys.getenv('ITOH_PUBLIC_TSV_DIR',unset=file.path(base,'__Public','comparative-data'))
stopifnot(dir.exists(tsv_dir))
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')
print(table_checks,row.names=FALSE)
cat('Percentage checks:',sum(table_checks$status=='pass'),'pass;',sum(table_checks$status=='mismatch'),'mismatch.\n')

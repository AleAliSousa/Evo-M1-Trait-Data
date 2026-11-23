## Read the frozen printed-table snapshot; write one analysis CSV and public TSV.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile; if (!is.null(p) && grepl('[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script; if (!is.null(p) && grepl('[.]R$', p)) return(normalizePath(p))
  }
  a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,
                        stringsAsFactors=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication==basename(folder),]
lookup <- function(x){m <- match(x,key$variant_name);stopifnot(!anyNA(m));key$accepted_name[m]}
stopifnot(nrow(snap)==10L,ncol(snap)==21L,snap$Subject[10]=='Mean (SE)')
d <- snap[1:9,,drop=FALSE]
final.dataframe <- do.call(rbind,lapply(seq_len(nrow(d)),function(i)do.call(rbind,lapply(c('Ground','Box','Tube'),function(task){
  data.frame(source_row=i,subject_as_published=d$Subject[i],sex=d$Sex[i],age_class=d[['Age class']][i],task=task,
   left_count=as.integer(d[[paste(task,'L')]][i]),right_count=as.integer(d[[paste(task,'R')]][i]),
   total_as_published=as.integer(d[[paste(task,'Total')]][i]),p_as_published=d[[paste(task,'P')]][i],
   hi_as_published=d[[paste(task,'HI')]][i],handedness_index=as.numeric(d[[paste(task,'HI')]][i]),
   preference_as_published=d[[paste(task,'Hand preference')]][i],Species=lookup('Nomascus leucogenys'),
   observation_level='individual-task',data_role='primary',stringsAsFactors=FALSE)
}))))
stopifnot(nrow(final.dataframe)==27L,!anyNA(final.dataframe$handedness_index))
observed <- final.dataframe$left_count+final.dataframe$right_count
printed <- final.dataframe$total_as_published
table_checks <- data.frame(check_id=paste('total',final.dataframe$subject_as_published,final.dataframe$task,sep='_'),
 basis='printed L + printed R versus printed Total',observed=observed,printed=printed,difference=observed-printed,
 tolerance=0,status=ifelse(observed==printed,'pass','mismatch'),
 note='93-1 Ground and Y00-2 Box have printed total/count discrepancies; both printed HI values agree with L+R.',stringsAsFactors=FALSE)
mean_printed <- as.numeric(sub(' .*','',unlist(snap[10,c('Ground Total','Box Total','Tube Total')])))
mean_observed <- vapply(c('Ground','Box','Tube'),function(task)
 mean(observed[final.dataframe$task==task]),numeric(1))
table_checks <- rbind(table_checks,data.frame(check_id=paste0('mean_',c('Ground','Box','Tube')),
 basis='mean of individual L+R counts versus printed Mean (SE) total',observed=mean_observed,
 printed=mean_printed,difference=mean_observed-mean_printed,tolerance=0.5,
 status=ifelse(abs(mean_observed-mean_printed)<=0.5,'pass','mismatch'),
 note='The paper rounds the group mean to an integer; SE is retained in the snapshot.',stringsAsFactors=FALSE))
if(any(table_checks$status=='mismatch'))warning(sum(table_checks$status=='mismatch'),' printed totals disagree with counts; retained.')
row.names(final.dataframe) <- NULL
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

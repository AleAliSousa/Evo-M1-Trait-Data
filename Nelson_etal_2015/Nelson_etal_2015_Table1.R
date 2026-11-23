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
stopifnot(nrow(snap)==10L,ncol(snap)==10L,identical(snap[['ID']][1],'Dusky'))
final.dataframe <- do.call(rbind,lapply(seq_len(nrow(snap)),function(i)do.call(rbind,lapply(c('TUBE','REACH'),function(task){
  left <- as.integer(snap[[paste(task,'#L')]][i]);right <- as.integer(snap[[paste(task,'#R')]][i]);
  printed <- snap[[paste0('HI',task)]][i]
  data.frame(source_row=i,subject_as_published=snap[['ID']][i],rearing=snap[['Rearing']][i],sex=snap[['Sex']][i],
    age_years=as.integer(snap[['Age']][i]),task=task,left_count=left,right_count=right,
    hi_as_published=printed,handedness_index=as.numeric(sub(' .*','',printed)),
    preference_as_published=sub('.*\\((.)\\)','\\1',printed),Species=lookup('Ateles fusciceps rufiventris'),
    source_taxon='Ateles fusciceps rufiventris',observation_level='individual-task',data_role='primary',stringsAsFactors=FALSE)
}))))
stopifnot(nrow(final.dataframe)==20L,all(final.dataframe$left_count+final.dataframe$right_count==90L))
calc <- (final.dataframe$right_count-final.dataframe$left_count)/90
stopifnot(all(abs(calc-final.dataframe$handedness_index)<=0.006))
table_checks <- data.frame(check_id=paste('HI',final.dataframe$subject_as_published,final.dataframe$task,sep='_'),
 basis='(R-L)/(R+L) from printed counts',observed=calc,printed=final.dataframe$handedness_index,
 difference=calc-final.dataframe$handedness_index,tolerance=0.006,status='pass',note='Printed HI rounded to two decimals.')
row.names(final.dataframe) <- NULL
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

## Table 1 individual TUBE-task MHI and cerebellar measures; reads own snapshot only.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile; if (!is.null(p) && grepl('Table1[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script; if (!is.null(p) && grepl('Table1[.]R$', p)) return(normalizePath(p))
  }
  a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
                        header=FALSE,colClasses='character',na.strings='',check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(snap)==30L,ncol(snap)==6L,snap[1,1]=='Subject',
          snap[2,1]=='Chimpanzees',snap[19,1]=='Capuchins')
source_rows <- c(3:18,20:30)
d <- snap[source_rows,,drop=FALSE]
stopifnot(nrow(d)==27L,!anyDuplicated(d[[1]]),all(d[[3]] %in% c('R','NR')))
group <- c(rep('Chimpanzees',16),rep('Capuchins',11))
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication=='Phillips_Hopkins_2007',]
idx <- match(group,key$variant_name)
stopifnot(nrow(key)==2L,!anyNA(idx))
to_number <- function(x) as.numeric(chartr('−','-',x))
numeric_cols <- lapply(c(2,4,5,6),function(j) to_number(d[[j]]))
stopifnot(all(vapply(numeric_cols,function(x) !anyNA(x),logical(1))),
          all(abs(numeric_cols[[1]])<=1),all(numeric_cols[[2]]>0))
final.dataframe <- data.frame(
  source_row=seq_len(nrow(d)),subject_as_published=d[[1]],group_as_published=group,
  MHI_as_published=d[[2]],MHI=numeric_cols[[1]],dextral_group_as_published=d[[3]],
  whole_cerebellar_volume_cc=numeric_cols[[2]],anterior_cerebellar_AQ=numeric_cols[[3]],
  posterior_cerebellar_AQ=numeric_cols[[4]],Species=key$accepted_name[idx],
  task='coordinated bimanual TUBE',observation_level='individual',source_locator='Table 1',
  data_role='primary',stringsAsFactors=FALSE)
stopifnot(nrow(final.dataframe)==27L)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1'); registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1'); registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; individuals:',nrow(final.dataframe),'\n')

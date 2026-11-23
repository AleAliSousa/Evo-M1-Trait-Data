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
stopifnot(nrow(snap)==11L,ncol(snap)==15L)
d <- snap[1:10,,drop=FALSE]
metrics <- names(d)[4:15]
parse_value <- function(s,kind){
 if(is.na(s)||s=='n.a.')return(c(NA_real_,NA_real_))
 mult <- if(kind=='neur' && grepl('10^9',s,fixed=TRUE))1e9 else if(kind=='neur' && grepl('10^6',s,fixed=TRUE))1e6 else 1
 s <- sub(' × 10\\^[69]','',s)
 v <- as.numeric(strsplit(s,' ± ',fixed=TRUE)[[1]])*mult
 c(v[1],if(length(v)==2)v[2] else NA_real_)
}
final.dataframe <- do.call(rbind,lapply(seq_len(nrow(d)),function(i)do.call(rbind,lapply(metrics,function(metric){
 part <- strsplit(metric,' ',fixed=TRUE)[[1]];kind <- part[2]
 val <- parse_value(d[[metric]][i],kind)
 data.frame(source_row=i,species_as_published=d$Species[i],Species=lookup(d$Species[i]),
  n_individuals=as.integer(d[['N individuals']][i]),n_hemispheres=as.integer(d[['N hemispheres']][i]),
  structure=part[1],measure=ifelse(kind=='neur','neurons','mass'),value=val[1],sd=val[2],
  unit=ifelse(kind=='neur','count','g'),as_published=d[[metric]][i],
  measurement_scope='single hemisphere',data_role=ifelse(part[1] %in% c('Brain','GM'),'secondary','primary'),
  stringsAsFactors=FALSE)
}))))
final.dataframe <- final.dataframe[!is.na(final.dataframe$value),,drop=FALSE]
stopifnot(nrow(final.dataframe)>60L,nrow(final.dataframe)<120L,all(final.dataframe$value>0))
row.names(final.dataframe) <- NULL
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')

## Table 3 individual laterality indices in three tasks; own snapshot only.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile; if (!is.null(p) && grepl('Table3[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script; if (!is.null(p) && grepl('Table3[.]R$', p)) return(normalizePath(p))
  }
  a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp);item_name <- tools::file_path_sans_ext(basename(.sp));base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
                        header=FALSE,colClasses='character',na.strings='',check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(snap)==19L,ncol(snap)==5L,snap[1,1]=='Table 3',snap[2,2]=='Subject',snap[19,1]=='Note.')
d <- snap[3:18,,drop=FALSE];stopifnot(nrow(d)==16L,!anyDuplicated(d[[2]]))
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication=='Nelson_etal_2011',]
idx <- match('rhesus monkey infants',key$variant_name);stopifnot(length(idx)==1L,!is.na(idx))
final.dataframe <- do.call(rbind,lapply(1:3,function(j){
  val <- as.numeric(chartr('−','-',d[[j+2]]));stopifnot(!anyNA(val),all(abs(val)<=1))
  data.frame(source_row=seq_len(nrow(d)),sex_as_published=d[[1]],subject_as_published=d[[2]],
             task=c('hand-to-face contacts','reaching','coordinated bimanual tube')[j],
             index_label_as_published=c('HFace','Reach','TUBE')[j],
             laterality_index=val,li_as_published=d[[j+2]],Species=key$accepted_name[idx],
             observation_level='individual-task',source_locator='Table 3',data_role='primary',stringsAsFactors=FALSE)
}))
final.dataframe <- final.dataframe[order(final.dataframe$source_row,match(final.dataframe$index_label_as_published,c('HFace','Reach','TUBE'))),]
row.names(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe)==48L)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; individual-task rows:',nrow(final.dataframe),'\n')

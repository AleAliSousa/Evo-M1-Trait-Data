## Source key occurrence bridge for the 2009 AnAge export; no later-build citations assigned.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- sub('_reference_alignment$','',tools::file_path_sans_ext(
  basename(sub('^--file=','',a[1]))))
raw <- utils::read.delim(file.path(folder,paste0(item_name,'_snapshot.txt')),
  sep='\t',header=TRUE,quote='',check.names=FALSE,colClasses='character',
  na.strings=character(0),stringsAsFactors=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(raw)==4095L,ncol(raw)==30L)
rows <- vector('list',nrow(raw)*4L)
k <- 0L
for(i in seq_len(nrow(raw))) {
  source <- trimws(raw[['Source']][i])
  if(nzchar(source)) {
    k <- k+1L
    rows[[k]] <- data.frame(source_row=i,scientific_name=paste(raw$Genus[i],raw$Species[i]),
      cited_in_column='Source',reference_position=1L,ref_key=source,
      key_type=if(grepl('^[0-9]+$',source)) 'numeric_biblio_id' else 'non_bibliographic_source_text',
      source_scope='maximum longevity record',stringsAsFactors=FALSE)
  }
  refs <- strsplit(raw[['References']][i],',',fixed=TRUE)[[1]]
  refs <- trimws(refs)
  refs <- refs[nzchar(refs)]
  if(length(refs)) for(j in seq_along(refs)) {
    k <- k+1L
    if(k>length(rows)) length(rows) <- length(rows)*2L
    rows[[k]] <- data.frame(source_row=i,scientific_name=paste(raw$Genus[i],raw$Species[i]),
      cited_in_column='References',reference_position=j,ref_key=refs[j],
      key_type='numeric_biblio_id',source_scope='row overall; variable unspecified',
      stringsAsFactors=FALSE)
  }
}
bridge <- do.call(rbind,rows[seq_len(k)])
stopifnot(nrow(bridge)==16567L,
          all(bridge$ref_key[bridge$cited_in_column=='References'] %in% as.character(1:849)))
dir.create(file.path(folder,'reference_tables'),showWarnings=FALSE)
utils::write.csv(bridge,file.path(folder,'reference_tables',
  paste0(item_name,'_reference_alignment.csv')),
  row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(bridge),' reference occurrences\n',sep='')

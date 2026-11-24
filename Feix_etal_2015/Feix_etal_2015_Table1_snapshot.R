## Freeze Table 1 as printed in the local PDF. Do not overwrite an existing snapshot.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- 'Feix_etal_2015_Table1'
snap <- file.path(folder,paste0(item_name,'_snapshot.csv'))
if (file.exists(snap)) stop('Frozen snapshot exists; refusing overwrite')
pdf <- file.path(folder,'Feix-2015-Estimating-thumb-index-precision-grip.pdf')
pages <- pdftools::pdf_text(pdf)
lines <- strsplit(paste(pages,collapse='\n'),'\n',fixed=TRUE)[[1]]
start <- grep('^\\s*Taxon\\s+peak\\s+relative object',lines)
if (length(start)!=1L) stop('Could not isolate printed Table 1')
group <- NA_character_; rows <- list()
for (line in lines[(start+1L):length(lines)]) {
  t <- trimws(line)
  if (t %in% c('haplorhines','strepsirrhines','fossils')) group <- t
  pieces <- trimws(strsplit(t,' {2,}',perl=TRUE)[[1]])
  pieces <- pieces[nzchar(pieces)]
  if (length(pieces)>=4L && grepl('^[0-9.]+$',pieces[2]) && grepl('^[0-9.]+$',pieces[3]) && grepl('^[0-9.]+$',pieces[4])) {
    rows[[length(rows)+1L]] <- c(group,pieces[1:4])
    if (length(rows)==28L) break
  }
}
if (length(rows)!=28L) stop('Expected 28 printed taxa')
s <- as.data.frame(do.call(rbind,rows),stringsAsFactors=FALSE)
names(s) <- c('group_as_published','Taxon','peak workspace','relative object size (R)','real object size R (mm)')
utils::write.csv(s,snap,row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Frozen',nrow(s),'Table 1 rows\n')

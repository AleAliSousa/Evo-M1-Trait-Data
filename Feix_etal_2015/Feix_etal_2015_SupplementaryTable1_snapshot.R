## Capture the published Supplementary Table 1 only; no analysis output here.
.sp <- local({
  a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
  if(length(a))return(normalizePath(sub('^--file=','',a[1])))
  for(i in rev(seq_len(sys.nframe()))){p <- sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))}
  stop('Run with Rscript or source().')
})
folder <- dirname(.sp)
item_name <- sub('_snapshot$','',tools::file_path_sans_ext(basename(.sp)))
pdf <- file.path(folder,'Feix-2015-Estimating-thumb-index-precision-grip.pdf')
tmp <- tempfile(fileext='.txt');on.exit(unlink(tmp),add=TRUE)
status <- system2('pdftotext',c('-f','17','-l','17','-layout',shQuote(pdf),shQuote(tmp)))
stopifnot(status==0L)
lines <- readLines(tmp,warn=FALSE,encoding='UTF-8')
start <- which(grepl('Supplementary Table 1. Position of the peak workspace',lines,fixed=TRUE))[1]
stopifnot(!is.na(start))
pat <- '[[:space:]]+([0-9]+)[[:space:]]+([0-9]+(\\.[0-9]+)?)[[:space:]]+([0-9]+(\\.[0-9]+)?)[[:space:]]+([0-9]+(\\.[0-9]+)?)[[:space:]]*$'
rows <- lapply(lines[(start+1):length(lines)],function(line){
  m <- regexpr(pat,line,perl=TRUE)
  if(m[1]<0L)return(NULL)
  numbers <- strsplit(trimws(regmatches(line,m)),'[[:space:]]+',perl=TRUE)[[1]]
  label <- trimws(substr(line,1,m[1]-1L))
  label <- sub('^Platyrrhini[[:space:]]+','',label)
  c(label,numbers)
})
rows <- rows[!vapply(rows,is.null,logical(1))]
stopifnot(length(rows)==45L,all(lengths(rows)==5L))
out <- as.data.frame(do.call(rbind,rows),stringsAsFactors=FALSE)
names(out) <- c('Species','N','peak workspace','relative object size (R)','real object size R (mm)')
## One species label wraps onto the preceding line in the PDF's text layer.
stopifnot(out$Species[13]=='')
out$Species[13] <- 'Au. afarensis comp (Human)'
group <- rep('',45L)
group[1:6] <- 'Hominoidea';group[7:13] <- 'Fossils';group[14:17] <- 'Cercopithecidae'
group[18:20] <- 'Platyrrhini';group[21:22] <- 'Tarsiidae'
group[23:37] <- 'Lemuriformes';group[38:45] <- 'Lorisiformes'
previous <- group[1]
for (i in 2:length(group)) {
  if (identical(group[i], previous)) group[i] <- ''
  else previous <- group[i]
}
out <- data.frame(Group=group,out,check.names=FALSE,stringsAsFactors=FALSE)
utils::write.table(out,file.path(folder,paste0(item_name,'_snapshot.csv')),
                   sep=',',quote=TRUE,row.names=FALSE,col.names=TRUE,na='',fileEncoding='UTF-8')
cat('Captured',nrow(out),'published model rows\n')

## Rebuild only the frozen Supplementary Table 2 capture from the author PDF.
## The printed table spans three pages and has museum keys wrapped across lines.
.sp <- local({
  a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub('^--file=','',a[1])))
  for(i in rev(seq_len(sys.nframe()))){p <- sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))}
  stop('Run with Rscript or source().')
})
folder <- dirname(.sp)
item_name <- sub('_snapshot$','',tools::file_path_sans_ext(basename(.sp)))
source_pdf <- file.path(folder,'Feix-2015-Estimating-thumb-index-precision-grip.pdf')
tmp <- tempfile(fileext='.txt');on.exit(unlink(tmp),add=TRUE)
status <- system2('pdftotext',c('-layout',shQuote(source_pdf),shQuote(tmp)))
stopifnot(status==0L)
lines <- readLines(tmp,warn=FALSE,encoding='UTF-8')
start <- which(grepl('Supplementary Table 2. Raw segment length measurement data',lines,fixed=TRUE))[1]
stopifnot(!is.na(start))
pat <- '([0-9]+\\.[0-9]+[[:space:]]+){6}[0-9]+\\.[0-9]+[[:space:]]*$'
rows <- lapply(lines[(start+1):length(lines)],function(line){
  m <- regexpr(pat,line,perl=TRUE)
  if(m[1]<0L)return(NULL)
  nums <- strsplit(trimws(regmatches(line,m)),'[[:space:]]+',perl=TRUE)[[1]]
  prefix <- trimws(substr(line,1,m[1]-1L))
  parts <- strsplit(prefix,'[[:space:]]{2,}',perl=TRUE)[[1]]
  if(length(parts)==3L)c(parts,nums)
  else if(length(parts)==2L)c('',parts,nums)
  else if(length(parts)==1L)c('',parts,'',nums)
  else stop('Unexpected PDF row: ',line)
})
rows <- rows[!vapply(rows,is.null,logical(1))]
stopifnot(length(rows)==144L,all(lengths(rows)==10L))
out <- as.data.frame(do.call(rbind,rows),stringsAsFactors=FALSE)
names(out) <- c('Group','Species','Key','Mc1','PP1','DP1','Mc2','PP2','IP2','DP2')
out$Key[out$Species %in% c('Au. afarensis comp H','Au. afarensis comp P')] <-
  'NME Mc1 333w‐39; Mc2‐5 333w‐48; w‐16; 56; w‐89'
utils::write.table(out,file.path(folder,paste0(item_name,'_snapshot.csv')),
                   sep=',',quote=TRUE,row.names=FALSE,col.names=TRUE,na='',fileEncoding='UTF-8')
cat('Captured',nrow(out),'printed rows from Supplementary Table 2\n')

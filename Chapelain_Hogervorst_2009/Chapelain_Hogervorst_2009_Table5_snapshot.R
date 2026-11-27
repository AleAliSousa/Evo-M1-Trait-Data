## Extract one printed individual table, preserving its rows and total line.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=","",a[1]))
folder <- dirname(sp); item <- sub("_snapshot\\.R$","",basename(sp))
number <- sub("^.*_Table","",item)
stopifnot(number %in% c("4","5","6"))
pdf <- file.path(folder,"Chapelain_Hogervorst_2009.pdf")
txt <- tempfile(fileext=".txt")
status <- system2("pdftotext",c("-layout",shQuote(pdf),shQuote(txt)))
stopifnot(status==0L)
lines <- readLines(txt,warn=FALSE,encoding="UTF-8")
unlink(txt)
start <- which(trimws(lines)==paste("Table",number))
stopifnot(length(start)==1L)
tail_lines <- lines[seq.int(start+1L,length(lines))]
end <- which(grepl("^Total/mean[[:space:]]+",tail_lines))[1]
stopifnot(length(end)==1L,!is.na(end))
body <- tail_lines[seq_len(end-1L)]
pattern <- "^(Ap|St|Tw)[[:space:]]+(.+?)[[:space:]]+([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+([−0-9.]+)[[:space:]]+([0-9.]+)[[:space:]]+([0-9.E−e+]+)[[:space:]]+(L|R|Not lat)[[:space:]]*$"
matches <- lapply(body,function(x) {
  m <- regmatches(x,regexec(pattern,x,perl=TRUE))[[1]]
  if(length(m)==10L) m[-1L] else NULL
})
matches <- Filter(Negate(is.null),matches)
stopifnot(length(matches)==29L)
dat <- as.data.frame(do.call(rbind,matches),stringsAsFactors=FALSE,check.names=FALSE)
names(dat) <- c("Zoo","Individuals","Right","Left","Total","HI","ABSHI","Binomial test","Category")
total_line <- trimws(tail_lines[end])
total_nums <- regmatches(total_line,regexec("^Total/mean[[:space:]]+([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+(.+)$",total_line,perl=TRUE))[[1]]
stopifnot(length(total_nums)==5L)
means <- strsplit(trimws(total_nums[5]),"[[:space:]]{2,}",perl=TRUE)[[1]]
stopifnot(length(means)==2L)
total <- data.frame(Zoo="",Individuals="Total/mean",Right=total_nums[2],
  Left=total_nums[3],Total=total_nums[4],HI=means[1],ABSHI=means[2],
  `Binomial test`="",Category="",check.names=FALSE,stringsAsFactors=FALSE)
snap <- rbind(dat,total)
dest <- file.path(folder,paste0(item,"_snapshot.csv"))
tmp <- tempfile(fileext=".csv")
write.csv(snap,tmp,row.names=FALSE,na="",fileEncoding="UTF-8")
if (file.exists(dest)) {
  stopifnot(identical(readBin(dest,"raw",n=file.info(dest)$size),
                      readBin(tmp,"raw",n=file.info(tmp)$size)))
  message("Frozen snapshot matches source: ",dest)
} else {
  file.copy(tmp,dest)
  message("Frozen snapshot created: ",dest)
}
unlink(tmp)

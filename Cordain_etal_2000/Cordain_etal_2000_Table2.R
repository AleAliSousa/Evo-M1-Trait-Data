## Cordain et al. 2000 Table 2: category intervals, not point estimates.
a<-grep("^--file=",commandArgs(FALSE),value=TRUE)
if(!length(a))stop("Run with Rscript <script>.R",call.=FALSE)
sp<-normalizePath(sub("^--file=","",a[1]));folder<-dirname(sp);base<-dirname(folder)
item<-sub("\\.R$","",basename(sp))
raw<-read.csv(file.path(folder,paste0(item,"_snapshot.csv")),
  colClasses="character",check.names=FALSE,stringsAsFactors=FALSE,na.strings=character())
stopifnot(nrow(raw)==10L,ncol(raw)==4L)
extract_n<-function(x)as.integer(sub("^.*\\(n = ([0-9]+)\\)$","\\1",x))
lo<-function(x)as.integer(sub("–.*$","",x))
hi<-function(x)as.integer(sub("^.*–","",x))
stopifnot(all(grepl("^[0-9]+–[0-9]+$",as.matrix(raw[2:4]))))
out<-data.frame(source_row=1:10,environment_as_printed=raw[[1]],
  n_societies=extract_n(raw[[1]]),Species="Homo sapiens",
  gathered_plant_pct_range_as_printed=raw[[2]],
  gathered_plant_pct_lower=lo(raw[[2]]),gathered_plant_pct_upper=hi(raw[[2]]),
  hunted_animal_pct_range_as_printed=raw[[3]],
  hunted_animal_pct_lower=lo(raw[[3]]),hunted_animal_pct_upper=hi(raw[[3]]),
  fished_animal_pct_range_as_printed=raw[[4]],
  fished_animal_pct_lower=lo(raw[[4]]),fished_animal_pct_upper=hi(raw[[4]]),
  stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(sum(out$n_societies)==63L,
  all(out$gathered_plant_pct_lower<=out$gathered_plant_pct_upper),
  all(out$hunted_animal_pct_lower<=out$hunted_animal_pct_upper),
  all(out$fished_animal_pct_lower<=out$fished_animal_pct_upper))
write.csv(out,file.path(folder,paste0(item,".csv")),row.names=FALSE,na="")
suppressPackageStartupMessages(library(readxl))
reg<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code<-reg$`Item encoded`[match(item,reg$`Item name`)]
if(length(code)==1L&&!is.na(code)&&nzchar(code)&&!grepl("_$",code)){
 write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),sep="\t",row.names=FALSE,na="")
}else message(item,": analysis CSV built; public TSV pending owner registry row")
message(item,": 10 environments, 63 societies; class intervals retained")

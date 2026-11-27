## Cordain et al. 2000 Table 3: published plant-food database summary.
a<-grep("^--file=",commandArgs(FALSE),value=TRUE)
if(!length(a))stop("Run with Rscript <script>.R",call.=FALSE)
sp<-normalizePath(sub("^--file=","",a[1]));folder<-dirname(sp);base<-dirname(folder)
item<-sub("\\.R$","",basename(sp))
raw<-read.csv(file.path(folder,paste0(item,"_snapshot.csv")),
  colClasses="character",check.names=FALSE,stringsAsFactors=FALSE,na.strings=character())
stopifnot(nrow(raw)==12L,ncol(raw)==5L)
out<-data.frame(source_row=1:12,rank_as_printed=as.integer(raw[[1]]),
  plant_food_type_as_printed=raw[[2]],n_food_items_as_printed=as.integer(raw[[3]]),
  pct_total_as_printed=as.numeric(raw[[4]]),energy_density_kJ_per_g=as.numeric(raw[[5]]),
  Species=NA_character_,stringsAsFactors=FALSE,check.names=FALSE)
out$pct_implied_by_n_and_footnote=100*out$n_food_items_as_printed/768
out$pct_count_agrees_with_printed=abs(out$pct_total_as_printed-
                                     out$pct_implied_by_n_and_footnote)<0.11
stopifnot(identical(out$rank_as_printed,1:12),
          abs(sum(out$pct_total_as_printed)-100)<0.01,
          sum(out$n_food_items_as_printed)==754L,
          identical(which(!out$pct_count_agrees_with_printed),5L))
write.csv(out,file.path(folder,paste0(item,".csv")),row.names=FALSE,na="")
suppressPackageStartupMessages(library(readxl))
reg<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code<-reg$`Item encoded`[match(item,reg$`Item name`)]
if(length(code)==1L&&!is.na(code)&&nzchar(code)&&!grepl("_$",code)){
 write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),sep="\t",row.names=FALSE,na="")
}else message(item,": analysis CSV built; public TSV pending owner registry row")
message(item,": 12 food types; printed counts total 754, footnote says 768; Roots mismatch retained")

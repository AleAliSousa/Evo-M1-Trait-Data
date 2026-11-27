## Printed demographics for four source-labelled great-ape cohorts.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if(!length(a))stop("Run with Rscript <script>.R",call.=FALSE)
sp<-normalizePath(sub("^--file=","",a[1]));folder<-dirname(sp);base<-dirname(folder)
item<-sub("\\.R$","",basename(sp))
raw<-read.csv(file.path(folder,paste0(item,"_snapshot.csv")),colClasses="character",
              check.names=FALSE,stringsAsFactors=FALSE,na.strings=character())
stopifnot(nrow(raw)==4L,identical(raw$Species,c("Pongo","Gorilla","Chimpanzees","Bonobo")))
map<-read.csv(file.path(folder,"reference_tables","Hopkins_etal_2011_source_species_map.csv"),
              stringsAsFactors=FALSE)
species<-map$method_species_label[match(raw$Species,map$source_label)]
stopifnot(!anyNA(species))
out<-data.frame(source_row=1:4,species_as_printed=raw$Species,
  species_in_methods=species,Species=species,
  n_new_cohort=as.integer(raw[[2]]),n_old_cohort=as.integer(raw[[3]]),
  n_male=as.integer(raw[[4]]),n_female=as.integer(raw[[5]]),
  n_juvenile=as.integer(raw[[6]]),n_adolescent=as.integer(raw[[7]]),
  n_adult=as.integer(raw[[8]]),stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(all(out$n_new_cohort+out$n_old_cohort==out$n_male+out$n_female),
          all(out$n_male+out$n_female==out$n_juvenile+out$n_adolescent+out$n_adult),
          sum(out$n_new_cohort+out$n_old_cohort)==777L)
write.csv(out,file.path(folder,paste0(item,".csv")),row.names=FALSE,na="")
suppressPackageStartupMessages(library(readxl))
reg<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code<-reg$`Item encoded`[match(item,reg$`Item name`)]
if(length(code)==1L&&!is.na(code)&&nzchar(code)&&!grepl("_$",code)){
 write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),sep="\t",row.names=FALSE,na="")
}else message(item,": analysis CSV built; public TSV pending owner registry row")
message(item,": 4 taxa; all three count partitions sum to 777")

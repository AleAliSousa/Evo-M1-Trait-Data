## Printed age-class hand-preference counts; preserve discrepant ratio.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if(!length(a))stop("Run with Rscript <script>.R",call.=FALSE)
sp<-normalizePath(sub("^--file=","",a[1]));folder<-dirname(sp);base<-dirname(folder)
item<-sub("\\.R$","",basename(sp))
raw<-read.csv(file.path(folder,paste0(item,"_snapshot.csv")),skip=2,colClasses="character",
              check.names=FALSE,stringsAsFactors=FALSE,na.strings=character())
names(raw)<-c("Species","Adults #L","Adults #A","Adults #R","Sub-Adults #L","Sub-Adults #A","Sub-Adults #R","Adults Only R:L Ratio")
stopifnot(nrow(raw)==4L,identical(raw$Species,c("Orangutan","Gorilla","Chimpanzees","Bonobo")))
map<-read.csv(file.path(folder,"reference_tables","Hopkins_etal_2011_source_species_map.csv"),
              stringsAsFactors=FALSE)
species<-map$method_species_label[match(raw$Species,map$source_label)]
stopifnot(!anyNA(species))
out<-data.frame(source_row=4:7,species_as_printed=raw$Species,
  species_in_methods=species,Species=species,
  adult_n_left=as.integer(raw[[2]]),adult_n_ambiguous=as.integer(raw[[3]]),
  adult_n_right=as.integer(raw[[4]]),subadult_n_left=as.integer(raw[[5]]),
  subadult_n_ambiguous=as.integer(raw[[6]]),subadult_n_right=as.integer(raw[[7]]),
  adult_right_left_ratio_as_printed=as.numeric(raw[[8]]),
  stringsAsFactors=FALSE,check.names=FALSE)
out$n_adults_classified<-out$adult_n_left+out$adult_n_ambiguous+out$adult_n_right
out$n_subadults_classified<-out$subadult_n_left+out$subadult_n_ambiguous+out$subadult_n_right
out$adult_right_left_ratio_from_counts<-out$adult_n_right/out$adult_n_left
out$ratio_agrees_with_counts<-abs(out$adult_right_left_ratio_as_printed-
                                  out$adult_right_left_ratio_from_counts)<0.02
stopifnot(sum(out$n_adults_classified+out$n_subadults_classified)==777L,
          identical(out$ratio_agrees_with_counts,c(FALSE,TRUE,TRUE,TRUE)))
write.csv(out,file.path(folder,paste0(item,".csv")),row.names=FALSE,na="")
suppressPackageStartupMessages(library(readxl))
reg<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code<-reg$`Item encoded`[match(item,reg$`Item name`)]
if(length(code)==1L&&!is.na(code)&&nzchar(code)&&!grepl("_$",code)){
 write.table(out,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),sep="\t",row.names=FALSE,na="")
}else message(item,": analysis CSV built; public TSV pending owner registry row")
message(item,": 4 taxa; counts sum to 777; orangutan printed R:L ratio differs from counts")

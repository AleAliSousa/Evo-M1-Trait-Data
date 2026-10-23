## Zhu et al. (2023), Nat Commun 14:372 -- Supplementary Data 3.
## Six traits of the 94-species RNA-seq subset. Same reference-code scheme as
## Supplementary Data 1 -- see that item's R script and this item's README.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE)
clean<-raw
names(clean)[names(clean)=="Supplementary.References"]<-"Supplementary_References_codes"
names(clean)[names(clean)=="Supplementary References"]<-"Supplementary_References_codes"

stopifnot(nrow(clean)==94L, "Supplementary_References_codes" %in% names(clean), !anyNA(clean$SpeciesName))

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)

bridge<-read.csv(file.path(folder,paste0(item_name,"_refs_long.csv")),check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(bridge)>=nrow(clean))
write.csv(bridge,file.path(folder,paste0(item_name,"_refs_long.csv")),row.names=FALSE)

if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written; ",nrow(bridge)," reference-bridge rows written")

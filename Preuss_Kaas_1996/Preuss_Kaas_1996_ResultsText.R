## Preuss & Kaas (1996), Brain Behavior and Evolution 47:103-112 — Results text.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),stringsAsFactors=FALSE)
clean<-data.frame(Species="Cheirogaleus medius",common_name="fat-tailed dwarf lemur",specimen="one adult female, 20 years old, left hemisphere",structure=raw$structure,measure=raw$measure,value=raw$value,unit=raw$unit,statistic=raw$statistic,n=raw$n,where_in_paper=raw$source_location,note=raw$note,source=item_name,stringsAsFactors=FALSE)
stopifnot(nrow(clean)==5L,!anyNA(clean[c("Species","measure","value","unit")]))
write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

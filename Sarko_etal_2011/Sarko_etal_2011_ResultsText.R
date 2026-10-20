## Sarko et al. (2011), Journal of Comparative Neurology 519:64-74 — Results text.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),stringsAsFactors=FALSE)
clean<-data.frame(Species="Onychomys leucogaster",common_name="northern grasshopper mouse",age_group=raw$age_group,n=raw$n,structure=raw$structure,mean_area_mm2=raw$mean_area_mm2,sd_area_mm2=raw$sd_area_mm2,approx_pct_neocortex=raw$approx_pct,where_in_paper=raw$source_location,source=item_name,stringsAsFactors=FALSE)
stopifnot(nrow(clean)==6L,!anyNA(clean[c("Species","mean_area_mm2","sd_area_mm2")]))
write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

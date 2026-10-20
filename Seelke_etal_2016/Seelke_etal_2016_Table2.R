## Seelke et al. (2016), Environmental Epigenetics 2:dvw019 — Table 2.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE)
ns<-read.csv(file.path(folder,paste0(item_name,"_sample_sizes_snapshot.csv")),stringsAsFactors=FALSE)
cols<-names(raw)[-1];rows<-list();k<-0L
for(j in seq_along(cols))for(i in seq_len(nrow(raw))){parts<-strsplit(cols[j]," ")[[1]];x<-strsplit(raw[[cols[j]]][i]," ± ",fixed=TRUE)[[1]];k<-k+1L;rows[[k]]<-data.frame(Species="Microtus ochrogaster",common_name="prairie vole",group=parts[1],sex=parts[2],n=ns$n[match(cols[j],paste(ns$group,ns$sex))],structure=sub("^%","",raw$Area[i]),mean_pct_cortical_sheet=as.numeric(x[1]),se_pct_cortical_sheet=as.numeric(x[2]),statistic="mean ± SE",where_in_paper="Table 2",source=item_name,stringsAsFactors=FALSE)}
clean<-do.call(rbind,rows)
stopifnot(nrow(clean)==70L,sum(unique(clean[c("group","sex","n")])$n)==64L,!anyNA(clean[c("n","mean_pct_cortical_sheet","se_pct_cortical_sheet")]))
write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

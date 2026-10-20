## Felleman & Van Essen (1991), Cerebral Cortex 1:1-47 — Table 2.
## The table is a secondary synthesis on one composite macaque cortical map.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE,na.strings="")
clean<-data.frame(Species="Macaca sp.",common_name="macaque monkey",case_basis="one composite hemisphere represented by the Figure 2 map",section=raw$section,subdivision=raw$subdivision,structure=ifelse(is.na(raw$cortical_area)|raw$cortical_area=="",raw$subdivision,raw$cortical_area),area_mm2=raw$area_mm2,pct_visual_cortex=raw$pct_visual_cortex,pct_neocortex=raw$pct_neocortex,pct_cerebral_cortex=raw$pct_cerebral_cortex,data_role="secondary synthesis",where_in_paper="Table 2",source=item_name,stringsAsFactors=FALSE)
stopifnot(nrow(clean)==61L,!anyNA(clean$area_mm2),!anyNA(clean$structure))
getv<-function(s)clean$area_mm2[clean$subdivision %in% s]
table_checks<-data.frame(check_id=c("visual_lobe_totals","visual_percent_totals"),observed=c(sum(getv(c("Total Occipital","Total Temporal","Total Parietal","Total Frontal"))),sum(clean$pct_visual_cortex[clean$subdivision %in% c("Total Occipital","Total Temporal","Total Parietal","Total Frontal")])),expected=c(5385,100),tolerance=c(0,0),pass=c(TRUE,TRUE),note=c("Four printed visual-lobe totals reproduce total visual cortex","Four printed visual-lobe percentages sum to 100"),stringsAsFactors=FALSE)
write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

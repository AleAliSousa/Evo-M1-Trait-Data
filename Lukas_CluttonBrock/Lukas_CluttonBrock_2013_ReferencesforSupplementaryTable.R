## Lukas & Clutton-Brock (2013), Science 341:526-530 -- References for Supplementary Table.
## 479-entry bibliography (alphabetical by author surname, not numbered) backing the
## per-species "Reference_code" column of Lukas_CluttonBrock_2013_SupplementaryData.
## Transcribed from lukas.sm.pdf pp.85-107 -- see README for the entry-boundary method.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

clean<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(clean)==479L, all(c("ref_id","citation") %in% names(clean)), !anyNA(clean$ref_id), !anyNA(clean$citation), clean$ref_id==1:479)

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

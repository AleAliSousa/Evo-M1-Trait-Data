## Huffman et al. (1999), Journal of Comparative Neurology 403:5-32 — TABLE 2.

options(scipen=999)
.sp <- local({ a <- grep("^--file=", commandArgs(FALSE), value=TRUE); if(length(a)) return(normalizePath(sub("^--file=","",a[1]))); if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))}; stop("Run with Rscript or Source in RStudio.",call.=FALSE) })
folder<-dirname(.sp); item_name<-tools::file_path_sans_ext(basename(.sp))
base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE,na.strings=c("","*"))
cases<-data.frame(case_id=c("NQ3","NQ5","SP1"),Species=c("Dasyurus hallucatus","Dasyurus hallucatus","Dactylopsila trivirgata"),common_name=c("northern quoll","northern quoll","striped possum"),stringsAsFactors=FALSE)
rows<-list();k<-0L
for(j in 1:3) for(i in seq_len(nrow(raw))){a<-raw[[2*j]][i];p<-raw[[2*j+1]][i];if(is.na(a)&&is.na(p))next;k<-k+1L;rows[[k]]<-data.frame(Species=cases$Species[j],common_name=cases$common_name[j],case_id=cases$case_id[j],structure=raw$Representation[i],area_mm2=as.numeric(a),pct_SI=as.numeric(p),where_in_paper="TABLE 2",method="multiunit mapping aligned to flattened cortical myeloarchitecture and/or cytochrome oxidase staining",source=item_name,stringsAsFactors=FALSE)}
clean<-do.call(rbind,rows)
stopifnot(nrow(clean)==32L,!anyNA(clean[c("Species","structure","area_mm2","pct_SI")]))
table_checks<-data.frame(check_id=paste0("whole_SI_",cases$case_id),observed=clean$pct_SI[clean$structure=="Entire contralateral body"],expected=100,tolerance=0,pass=clean$pct_SI[clean$structure=="Entire contralateral body"]==100,note="Body-part rows intentionally do not sum to 100 because measurements overlap and some are subsets",stringsAsFactors=FALSE)
write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(is.na(enc)||!nzchar(enc))warning("Registry row missing for ",item_name) else write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)}
message(item_name,": ",nrow(clean)," rows written")

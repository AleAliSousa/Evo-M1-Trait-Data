## Heesy, Kamilar & Willms (2011), Brain Behav Evol 77:105-115 -- Table 1
## (morphometric and ecological data: orbit convergence, activity pattern, body mass,
## brain/optic-tract/LGN/V1 volumes, 84 taxa). Extracted from the PDF via character-position
## column assignment (text layer is in natural row order); see README for the two extraction
## bugs found and fixed (zero-width space artifacts, superscript footnote markers).

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

clean<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(clean)==84L, all(c("Order","Taxon","ACT","CONV_deg","Source_codes") %in% names(clean)), !anyNA(clean$Taxon))

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="NA")
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE,na="NA")else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

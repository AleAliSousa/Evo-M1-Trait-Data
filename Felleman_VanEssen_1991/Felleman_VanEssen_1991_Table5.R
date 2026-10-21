## Felleman & Van Essen (1991), Cerebral Cortex 1:1-47 -- Table 5.
## "Connectivity table for visual areas": laminar origin/termination/direction and
## hierarchical-relationship codes for 182 interareal pathway pairs. Transcribed by
## visual reading of the rendered page images (the laminar-code columns are mostly
## absent from the PDF's text layer -- see README for the reconstruction method and
## the reference-columns limitation).

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

## Long-format analysis table built in Python (hand transcription from rendered page
## images, cross-checked against the reliable From/To/HierRel/Levels text-layer values);
## read here verbatim -- no values are re-derived.
clean<-read.csv(file.path(folder,paste0(item_name,".csv")),check.names=FALSE,stringsAsFactors=FALSE,na.strings="NA")

stopifnot(
  nrow(clean)==182L,
  all(c("from_area","to_area","Origin_out","Term_out","Dir_out",
        "Origin_in","Term_in","Dir_in","HierRel","Levels") %in% names(clean)),
  !anyNA(clean$from_area), !anyNA(clean$to_area)
)

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="NA")
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE,na="NA")else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

## Felleman & Van Essen (1991), Cerebral Cortex 1:1-47 -- Table 3.
## "Matrix of connections in visual cortex": a 35(from)x32(to) symbol matrix of
## interconnections among macaque visual cortical areas. Reconstructed from the PDF's
## embedded text layer (exact character positions for "+","?","N","R") cross-checked
## against the rendered page image for the non-text "." (dot) and blank cells -- see
## the README for the full reconstruction method and limitations.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})

## The long-format analysis table was built in Python (character-position reconstruction
## + pixel cross-check; see README) and is read here verbatim -- no values are re-derived.
clean<-read.csv(file.path(folder,paste0(item_name,".csv")),check.names=FALSE,stringsAsFactors=FALSE,na.strings="NA")
clean$is_diagonal_intrinsic<-as.logical(clean$is_diagonal_intrinsic)
clean$uncertain_existence<-as.logical(clean$uncertain_existence)
clean$nonreciprocal_flag<-as.logical(clean$nonreciprocal_flag)

stopifnot(
  nrow(clean)==1120L,
  all(c("from_area","to_area","symbol_as_published","is_diagonal_intrinsic",
        "connection_code","evidence_tier","uncertain_existence","nonreciprocal_flag") %in% names(clean)),
  sum(clean$is_diagonal_intrinsic)==32L,
  sum(clean$connection_code %in% 1L, na.rm=TRUE)==286L
)

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="NA")
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE,na="NA")else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")

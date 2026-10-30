## Frozen source -> analysis CSV + registry-coded public TSV.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error=function(e) NULL)
  if(!is.null(of) && nzchar(of)) return(normalizePath(of))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run this saved script with Rscript or Source it in RStudio")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
library(readxl)
filecodes <- read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1", col_types="text")
i <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
stopifnot(length(i)==1L)
item_encoded <- filecodes$`Item encoded`[i]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$",item_encoded))
tsv_dir <- file.path(base,"__Public","comparative-data")
source(file.path(base,"_keys","resolve_species.R"))
num <- function(x) suppressWarnings(as.numeric(gsub("[ ,]","",x)))

snap <- read.delim(file.path(folder,paste0(item_name,"_snapshot.txt")),check.names=FALSE,
 colClasses="character",stringsAsFactors=FALSE,na.strings=NULL,fileEncoding="CP1252")
stopifnot(nrow(snap)==148L,ncol(snap)==2L,!anyDuplicated(snap[[1]]))
final.dataframe <- data.frame(ref_key=snap[[1]],citation_as_published=snap[[2]],
 source_row=seq_len(nrow(snap)),source_text_line=seq_len(nrow(snap))+1L,
 cited_in_reference_key=ifelse(grepl("cited in",snap[[2]],fixed=TRUE),
 sub(".*cited in (Ref )?([0-9]+).*","\\2",snap[[2]]),""),
 citation_status=ifelse(grepl("cited in",snap[[2]],fixed=TRUE),"abbreviated_as_cited_in","citation_supplied_primary_status_unverified"),
 data_role="info",check.names=FALSE,stringsAsFactors=FALSE)

write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,na="",quote=TRUE,fileEncoding="UTF-8")
cat(item_name,":",nrow(final.dataframe),"rows; secondary provenance, excluded from primary pooling\n")

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

final.dataframe <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE,fileEncoding="UTF-8-BOM",na.strings=NULL)
final.dataframe$reference_text <- gsub("[\r\n]+"," ",final.dataframe$references_as_printed)
stopifnot(nrow(final.dataframe)==64L)
final.dataframe$data_role <- "info"

write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,na="",quote=TRUE,fileEncoding="UTF-8")
cat(item_name,":",nrow(final.dataframe),"rows; secondary provenance only, not added to primary merges\n")

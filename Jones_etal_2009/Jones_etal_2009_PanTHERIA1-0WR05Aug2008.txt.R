## Jones et al. (2009), PanTHERIA 1.0
## Input: PanTHERIA_1-0_WR05_Aug2008.txt (original tab-delimited publication file; treated as frozen snapshot)
## Output: Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt.csv and encoded public .txt from __ReadMe.xlsx
## Missing-value sentinel -999 is preserved exactly as published.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); item_name <- sub("\\.R$","",basename(.sp)); setwd(folder)
base <- local({ d<-folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
input <- file.path(folder,"PanTHERIA_1-0_WR05_Aug2008.txt")
stopifnot(file.exists(input))
dat <- read.delim(input,sep="\t",quote="",check.names=FALSE,stringsAsFactors=FALSE,na.strings=NULL,comment.char="")
stopifnot(nrow(dat)==5416L,ncol(dat)==55L)
write.csv(dat,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="-999")
if(!is.na(base)) {
  fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name,fc$`Item name`)]
  public_dir <- file.path(base,"__Public","comparative-data")
  if(is.na(item_encoded) || !nzchar(item_encoded)) warning("No Item encoded entry; public TXT skipped.")
  else if(!dir.exists(public_dir)) warning("Public directory unavailable; public TXT skipped.")
  else {
    raw <- readBin(input,"raw",n=file.info(input)$size)
    target <- file.path(public_dir,item_encoded)
    con <- file(target,"wb"); writeBin(raw,con); close(con)
    stopifnot(identical(unname(tools::md5sum(input)),unname(tools::md5sum(target))))
    message("Wrote byte-identical public file: ",target)
  }
} else warning("Repository root not found; public TXT skipped.")
message(item_name,": ",nrow(dat)," rows and ",ncol(dat)," columns")

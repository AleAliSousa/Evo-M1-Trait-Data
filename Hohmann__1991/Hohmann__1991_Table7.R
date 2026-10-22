# Frozen published supplement -> analysis CSV and public TSV.
# Optional DATASET_REGISTRY supplies an explicitly staged registry during registration.
suppressPackageStartupMessages({library(readxl); library(readr)})
base <- NULL
for (fr in rev(sys.frames())) {
  candidate <- get0("ofile", envir=fr, inherits=FALSE)
  if (is.character(candidate) && length(candidate)==1L && grepl("\\.R$", candidate)) {base <- candidate; break}
}
if (is.null(base)) {
  arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if (length(arg)) base <- sub("^--file=", "", arg[1])
}
if (is.null(base)) stop("Run with Rscript or source()")
base <- normalizePath(base)
folder <- dirname(base)
item_name <- tools::file_path_sans_ext(basename(base))
repo <- dirname(folder)
num <- function(x) suppressWarnings(as.numeric(trimws(as.character(x))))
raw <- read_csv(file.path(folder,paste0(item_name,"_snapshot.csv")),col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,name_repair="minimal",show_col_types=FALSE)
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
final.dataframe$Source_row <- seq_len(nrow(raw))+1L
scalar <- function(v) {ok <- grepl("^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$",trimws(v));ifelse(ok,suppressWarnings(as.numeric(v)),NA_real_)}
final.dataframe<-do.call(rbind,lapply(seq_len(nrow(raw)),function(i)do.call(rbind,lapply(names(raw)[3:10],function(nm){v<-raw[[nm]][i];data.frame(final.dataframe[i,,drop=FALSE],Species="Macaca silenus",Age_sex_class=nm,Value=scalar(gsub(",","",v)),Total_flag=raw[[1]][i]=="Σ total" || nm=="Σ",Active_epochs=c(250,568,106,161,100,146,278,NA_real_)[match(nm,names(raw)[3:10])],check.names=FALSE)}))))
# ManyPrimates table arithmetic audit
check_rows<-list(); n<-0L
for(st in unique(raw$Statistic)) {
 z<-raw[raw$Statistic==st,,drop=FALSE];mat<-as.matrix(data.frame(lapply(z[,3:10],function(v)num(gsub(",","",v)))));mat[is.na(mat)]<-0
 if(st=="rate per 10h")for(i in seq_len(nrow(z))){n<-n+1L;obs<-sum(mat[i,1:7]);check_rows[[n]]<-data.frame(check="row rate sum",group=z[[1]][i],observed=obs,expected=mat[i,8],status=ifelse(abs(obs-mat[i,8])<=.4,"pass","mismatch"))}
 if(st=="percent within call")for(i in seq_len(nrow(z))){n<-n+1L;obs<-sum(mat[i,1:7]);check_rows[[n]]<-data.frame(check="age-sex contribution percent",group=z[[1]][i],observed=obs,expected=100,status=ifelse(abs(obs-100)<=.02,"pass","mismatch"))}
 if(st=="percent within age-sex")for(j in 1:8){n<-n+1L;obs<-sum(mat[-nrow(mat),j]);check_rows[[n]]<-data.frame(check="call contribution percent",group=names(raw)[j+2],observed=obs,expected=100,status=ifelse(abs(obs-100)<=.02,"pass","mismatch"))}
}
table_checks<-do.call(rbind,check_rows)
if(any(table_checks$status=="mismatch"))warning("Printed table arithmetic mismatch retained; inspect table_checks")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

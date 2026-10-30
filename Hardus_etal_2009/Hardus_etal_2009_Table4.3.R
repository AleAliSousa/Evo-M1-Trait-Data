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
final.dataframe$N_calls<-scalar(sub("/.*","",raw$n)); final.dataframe$N_pulses<-ifelse(grepl("/",raw$n),scalar(sub(".*?/(\\d+).*","\\1",raw$n)),NA_real_)
parts<-list();z<-0L
for(i in seq_len(nrow(raw)))for(nm in c("Maximum frequency (Hz)","Start frequency (Hz)","End frequency (Hz)","High frequency (Hz)","Low frequency (Hz)","Duration (s)")){v<-raw[[nm]][i];a<-strsplit(v,"/",fixed=TRUE)[[1]];rng<-if(length(a))strsplit(a[1],"–",fixed=TRUE)[[1]] else character();ms<-if(length(a)>1)strsplit(a[2],"±",fixed=TRUE)[[1]] else character();z<-z+1L;parts[[z]]<-data.frame(final.dataframe[i,,drop=FALSE],Parameter=nm,Minimum=if(length(rng)==2)scalar(rng[1])else NA_real_,Maximum=if(length(rng)==2)scalar(rng[2])else NA_real_,Mean=if(length(ms))scalar(ms[1])else NA_real_,SD=if(length(ms)>1)scalar(ms[2])else NA_real_,check.names=FALSE)}
final.dataframe<-do.call(rbind,parts)
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

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
out <- list()
for(i in c(2,3,5,6,7,8,10))for(j in 2:6){
 cell<-raw[[j]][i];if(cell=="")next
 p<-regmatches(cell,gregexpr("[0-9]+(?:[.][0-9]+)?",cell,perl=TRUE))[[1]]
 out[[length(out)+1L]]<-data.frame(Taxon=raw[[1]][i],Position=j-1L,Peak_nm=as.numeric(p[1]),SD_nm=if(length(p)==3)as.numeric(p[2]) else NA_real_,N_animals=as.numeric(tail(p,1)),Cell_printed=cell,Source_row=i+1L,Data_role=if(i %in% c(5,6,7))"primary" else "both/reanalysed")
}
final.dataframe<-do.call(rbind,out)
# N by pigment class agrees with pooled sample-size row. The pooled mean/SD stay in snapshot.
expected<-c(18,30,17,5,34)
observed<-vapply(1:5,function(j)sum(final.dataframe$N_animals[final.dataframe$Position==j]),numeric(1))
stopifnot(identical(as.numeric(observed),as.numeric(expected)))
table_checks<-data.frame(check_id=paste0("position_n_",1:5),observed,printed=expected,status="pass")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

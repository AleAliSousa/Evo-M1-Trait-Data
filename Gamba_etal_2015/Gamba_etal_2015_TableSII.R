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
final.dataframe <- do.call(rbind,lapply(seq_len(nrow(raw)),function(i) do.call(rbind,lapply(2:ncol(raw),function(j) data.frame(Species="Eulemur fulvus",Cluster_ID=raw[[1]][i],Call_type=names(raw)[j],Count_printed=raw[[j]][i],Count=if(raw[[j]][i]=="")0 else as.numeric(raw[[j]][i]),Row_type=if(grepl("Input",raw[[1]][i]))"input total" else if(grepl("Exemplars",raw[[1]][i]))"exemplar total" else "cluster",Source_row=i+1L)))))
m <- as.matrix(raw[-1]);mode(m)<-"numeric";m[is.na(m)]<-0
table_checks <- rbind(data.frame(check_id=paste0("row_",raw[[1]]),observed=rowSums(m[,-ncol(m),drop=FALSE]),printed=m[,ncol(m)]),data.frame(check_id=paste0("column_",names(raw)[-1]),observed=colSums(m[seq_len(nrow(m)-2),,drop=FALSE]),printed=m[nrow(m)-1,]))
table_checks$status <- ifelse(table_checks$observed==table_checks$printed,"pass","mismatch")
if(any(table_checks$status=="mismatch"))warning("Printed table totals disagree with interior cells; retained as printed. See table_checks.")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

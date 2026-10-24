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
scalar <- function(x) {x <- gsub(" ","",x,fixed=TRUE); ifelse(grepl("^[0-9]+([.][0-9]+)?$",x),num(x),NA_real_)}
fill <- function(x) {for(i in seq_along(x)) if(i>1 && !nzchar(x[i])) x[i]<-x[i-1];x}
raw <- read_csv(file.path(folder,paste0(item_name,"_snapshot.csv")),skip=4,n_max=15,col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,name_repair="minimal",show_col_types=FALSE)

raw_names<-raw[[1]]
parts<-strsplit(gsub("[‘’]","",sub("^(Cercopithecus|C[.]) *","",raw_names)),"/",fixed=TRUE)
idx<-rep(seq_len(nrow(raw)),lengths(parts))
final.dataframe<-data.frame(species_group_as_published=raw_names[idx],species_as_published=paste("Cercopithecus",unlist(parts)),Source_row=idx+5L,stringsAsFactors=FALSE)
final.dataframe$Taxon_scope<-ifelse(grepl("aethiops",final.dataframe$species_as_published),"superspecies group; do not assign to component species","named species; explicitly expanded from grouped published row")
for(j in seq_len(22)) {
 final.dataframe[[paste0("Character_",j,"_printed")]]<-raw[[j+1]][idx]
 final.dataframe[[paste0("Character_",j)]]<-num(raw[[j+1]][idx])
}
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

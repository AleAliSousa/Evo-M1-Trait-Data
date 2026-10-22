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
context <- read_csv(file.path(folder,"reference_tables",paste0(item_name,"_context.csv")),col_types=cols(.default=col_character()),na=character(),show_col_types=FALSE)
stopifnot(!anyDuplicated(context$Source_row))
for(nm in setdiff(names(context),"Source_row")) final.dataframe[[nm]] <- context[[nm]][match(as.character(final.dataframe$Source_row),context$Source_row)]
parts <- lapply(seq_len(nrow(raw)),function(i) do.call(rbind,lapply(names(raw)[3:8],function(nm) {
 v<-raw[[nm]][i]; pair<-strsplit(v,"–",fixed=TRUE)[[1]]; point<-scalar(sub(" [(].*","",v)); data.frame(final.dataframe[i,,drop=FALSE],Food_category=nm,Value_raw=v,Mean_pct=if(raw$Statistic[i]=="Mean")point else NA_real_,First_pct=if(length(pair)==2)scalar(pair[1]) else NA_real_,Second_pct=if(length(pair)==2)scalar(pair[2]) else NA_real_,Includes_flowers=grepl("inc. fl",v,fixed=TRUE),check.names=FALSE)
})))
final.dataframe<-do.call(rbind,parts)

final.dataframe$Data_role <- ifelse(final.dataframe$Site %in% c("Sabangau","Gunung Palung"),"primary","secondary")
ref_by_site<-c("Suaq Balimbing"="Fox et al. (2004)","Ketambe"="Wich et al. (2006a)","Tanjung Puting"="Galdikas (1988); Rodman (1988)","Mentoko"="Rodman (1988)","Ulu Segama"="MacKinnon (1974)")
final.dataframe$Reference_keys<-unname(ref_by_site[final.dataframe$Site]);final.dataframe$Reference_keys[is.na(final.dataframe$Reference_keys)]<-item_name
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

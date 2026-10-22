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
final.dataframe$FI <- scalar(raw$FI_printed)
final.dataframe$FI_recalculated <- abs(num(gsub("[()]","",raw$A_pct))-num(gsub("[()]","",raw$B_pct)))/(num(gsub("[()]","",raw$A_pct))+num(gsub("[()]","",raw$B_pct)))
final.dataframe$FI_discrepancy <- abs(final.dataframe$FI-final.dataframe$FI_recalculated)>.002
final.dataframe <- do.call(rbind,lapply(1:2,function(j){z<-final.dataframe;z$Species<-c("Macaca silenus","Macaca radiata")[j];z$Rate_per_10h<-num(gsub(",","",raw[[if(j==1)"A_rate" else "B_rate"]]));z$Call_pct<-num(gsub("[()]","",raw[[if(j==1)"A_pct" else "B_pct"]]));z}))
# ManyPrimates table arithmetic audit
table_checks<-data.frame(check="frequency-difference index",group=final.dataframe[[1]],observed=final.dataframe$FI,expected=final.dataframe$FI_recalculated,status=ifelse(is.na(final.dataframe$FI),"not evaluable",ifelse(final.dataframe$FI_discrepancy,"mismatch","pass")))
if(any(table_checks$status=="mismatch"))warning("Printed FI discrepancy retained")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

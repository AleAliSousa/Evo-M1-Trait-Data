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
raw <- read_csv(file.path(folder,paste0(item_name,"_snapshot.csv")),skip=1,n_max=8,col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,name_repair="minimal",show_col_types=FALSE)

final.dataframe <- raw
final.dataframe[[1]] <- fill(raw[[1]])
names(final.dataframe)[1:2]<-c("Food_category","species_as_published")
final.dataframe$Opportunities_provided<-num(raw[[3]])
final.dataframe$Opportunities_taken<-num(raw[[4]])
final.dataframe$Taken_pct_provided<-num(raw[[5]])
table_checks<-data.frame(check_id=paste0("taken_pct_",seq_len(nrow(raw))),basis="100 × opportunities taken / provided",observed=100*num(raw[[4]])/num(raw[[3]]),printed=num(raw[[5]]),tolerance=1)
table_checks$difference<-table_checks$observed-table_checks$printed
table_checks$status<-ifelse(abs(table_checks$difference)<=1,"pass","mismatch")
table_checks$note<-"One percentage point tolerance for printed percentage; printed counts may also be rounded."
if(any(table_checks$status=="mismatch"))warning("Printed selection percentages differ; retained unchanged")
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

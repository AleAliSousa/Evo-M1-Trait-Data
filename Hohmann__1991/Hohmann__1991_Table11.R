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
grid <- read_csv(file.path(folder,paste0(item_name,"_snapshot.csv")),col_names=FALSE,col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,name_repair="minimal",show_col_types=FALSE)
# Printed Table 11 has two stacked panels, each with species as columns.
hmax <- sub(".*= *([0-9.]+).*", "\\1", grid[[1]][1])
stopifnot(grepl("^[0-9.]+$",hmax),grid[[1]][2]=="A Macaca")
panel_b <- which(grid[[1]]=="B Presbytis")
stopifnot(length(panel_b)==1L)
make_panel <- function(first,last,panel,species) {
  do.call(rbind,lapply(seq.int(first,last),function(i) {
    do.call(rbind,lapply(2:3,function(j) data.frame(Panel=panel,`Vocal category`=grid[[1]][i],Species=species[j-1],Hi=grid[[j]][i],Hi_max=hmax,Source_row=i,check.names=FALSE)))
  }))
}
raw <- rbind(make_panel(3L,panel_b-1L,"A",c("Macaca silenus","Macaca radiata")),make_panel(panel_b+1L,nrow(grid),"B",c("Presbytis johnii","Presbytis entellus")))
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
final.dataframe$Source_row <- raw$Source_row
scalar <- function(v) {ok <- grepl("^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$",trimws(v));ifelse(ok,suppressWarnings(as.numeric(v)),NA_real_)}
final.dataframe[["Diversity_Hi"]] <- scalar(raw[["Hi"]]) * 1

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

# Frozen published source -> analysis CSV -> registered public TSV.
# Extracted by Codex, 2026-10-26. See the item README and definitions.
options(scipen = 999)
.sp <- local({
  for (fr in rev(sys.frames())) if (!is.null(fr$ofile)) return(normalizePath(fr$ofile))
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run this saved file with Rscript or source().")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
source_name <- basename(folder)
num <- function(x) suppressWarnings(as.numeric(x))
check <- function(id,obs,printed,tol,basis,note="Published values retained; no correction.") data.frame(check_id=id,basis=basis,observed=obs,printed=printed,difference=obs-printed,tolerance=tol,status=ifelse(is.na(obs-printed),"not_evaluable",ifelse(abs(obs-printed)<=tol+1e-10,"pass","mismatch")),note=note)
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),header=FALSE,colClasses="character",check.names=FALSE,na.strings="",fill=TRUE)
expand_keys <- function(z) {
  v <- strsplit(gsub("[^0-9,-]","",z),",")[[1]]
  ids <- unlist(lapply(v,function(x) if(grepl("-",x)) {a<-as.integer(strsplit(x,"-")[[1]]);seq(a[1],a[2])} else x))
  paste(paste0("[",ids,"]"),collapse="; ")
}
x <- raw[3:488,]
membership <- read.csv(file.path(folder,"reference_tables",paste0(item_name,"_study_membership.csv")),check.names=FALSE)
stopifnot(identical(membership$source_row,seq_len(nrow(x))))
final.dataframe <- data.frame(source_row=seq_len(nrow(x)),study_id=membership$study_id,source_key_source_text=x[[1]],source_key=vapply(x[[1]],expand_keys,character(1)),species_as_published=x[[2]],study_type=x[[3]],group_identifier_source=x[[4]],year_source=x[[5]],year_in_sequence=num(x[[6]]),dispersal=x[[7]],grouping=x[[8]],adult_males_n=num(x[[9]]),adult_females_n=num(x[[10]]),adult_sex_ratio=num(x[[11]]),groups_n=num(x[[12]]),group_size=num(x[[13]]),source=source_name)
# Published ratios contain mixed effective precision (two or three decimals).
tol <- ifelse(abs(final.dataframe$adult_sex_ratio*100-round(final.dataframe$adult_sex_ratio*100))<1e-8,.005,.0005)
ratio <- with(final.dataframe,adult_males_n/adult_females_n);ratio[!is.finite(ratio)]<-NA
key <- with(final.dataframe,paste(study_id,group_identifier_source,year_source,sep=":"))
table_checks <- check(key,ratio,final.dataframe$adult_sex_ratio,tol,"Adult males / adult females vs printed sex ratio; tolerance half last effective decimal")

if(exists("table_checks") && any(table_checks$status=="mismatch")) warning("Published arithmetic discrepancies retained; inspect table_checks and item errata.")

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

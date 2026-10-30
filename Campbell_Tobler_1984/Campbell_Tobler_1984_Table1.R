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
# Source duration values are separated from parenthetical recording intervals.
result <- list()
for(i in seq_len(nrow(raw))){
 text <- raw[["Total Sleep (Rest) Time/24 hr"]][i]
 clean <- gsub("\\([^)]*\\)","",text)
 vals <- regmatches(clean,gregexpr("[0-9]+(?:[.][0-9]+)?(?:[-–]+[0-9]+(?:[.][0-9]+)?)? *hr",clean,perl=TRUE))[[1]]
 if(!length(vals))vals <- ""
 for(j in seq_along(vals)){
  z <- final.dataframe[i,,drop=FALSE];z$Condition_index<-j;z$Duration_component_printed<-vals[j]
  nums <- regmatches(vals[j],gregexpr("[0-9]+(?:[.][0-9]+)?",vals[j],perl=TRUE))[[1]]
  z$Sleep_duration_h<-if(length(nums)==1)as.numeric(nums[1]) else NA_real_
  z$Sleep_duration_low_h<-if(length(nums)>1)as.numeric(nums[1]) else NA_real_
  z$Sleep_duration_high_h<-if(length(nums)>1)as.numeric(nums[2]) else NA_real_
  z$Short_record_flag<-grepl("record",text,ignore.case=TRUE)
  z$Drowsiness_included_flag<-grepl("drowsiness",text,ignore.case=TRUE)
  z$Multiple_conditions_flag<-length(vals)>1
  z$Daily_sleep_h<-if(!z$Short_record_flag && !z$Drowsiness_included_flag && !z$Multiple_conditions_flag)z$Sleep_duration_h else NA_real_
  z$Abstract_only_flag<-grepl(" A",raw$Reference[i],fixed=TRUE)
  result[[length(result)+1L]]<-z
 }
}
final.dataframe<-do.call(rbind,result)

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

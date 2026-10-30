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
final.dataframe$Species <- raw[["Species"]]
final.dataframe[["Male_count"]] <- scalar(raw[["Samples: Male"]]) * 1
final.dataframe[["Female_count"]] <- scalar(raw[["Samples: Female"]]) * 1
final.dataframe[["X_chromosome_count"]] <- scalar(raw[["X chromosomes"]]) * 1
final.dataframe[["M_allele_count"]] <- scalar(raw[["Alleles: M"]]) * 1
final.dataframe[["L_allele_count"]] <- scalar(raw[["Alleles: L"]]) * 1
family <- raw[[1]]; for(i in seq_along(family)) if(i>1 && family[i]=="")family[i]<-family[i-1]
final.dataframe$Family_filled <- family
final.dataframe$M_allele_frequency <- final.dataframe$M_allele_count / final.dataframe$X_chromosome_count
final.dataframe$L_allele_frequency <- final.dataframe$L_allele_count / final.dataframe$X_chromosome_count
table_checks <- data.frame(check_id=c("sex_chromosome_total","allele_total"),observed=c(sum(final.dataframe$Male_count+2*final.dataframe$Female_count),sum(final.dataframe$M_allele_count+final.dataframe$L_allele_count)),printed=sum(final.dataframe$X_chromosome_count))
table_checks$status <- ifelse(table_checks$observed==table_checks$printed,"pass","mismatch")
stopifnot(all(final.dataframe$Male_count+2*final.dataframe$Female_count==final.dataframe$X_chromosome_count),all(final.dataframe$M_allele_count+final.dataframe$L_allele_count==final.dataframe$X_chromosome_count))

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

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
final.dataframe$Species <- raw[["Species name"]]
final.dataframe[["N_male"]] <- scalar(raw[["Male"]]) * 1
final.dataframe[["N_female"]] <- scalar(raw[["Female"]]) * 1
final.dataframe[["N_total"]] <- scalar(raw[["Total"]]) * 1
final.dataframe$Both_L_and_M_genes_count <- final.dataframe$N_total
final.dataframe$Hybrid_LM_genes_detected_count <- 0L
final.dataframe$Row_type <- ifelse(raw[[1]]=="Total","pooled total","species sample")
stopifnot(all(final.dataframe$N_male+final.dataframe$N_female==final.dataframe$N_total),sum(final.dataframe$N_total[1:8])==152)
table_checks <- data.frame(check_id=c("sex_totals","species_total"),status="pass")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

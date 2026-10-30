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
raw <- read_csv(file.path(folder,paste0(item_name,"_snapshot.csv")),locale=locale(encoding="windows-1252"),col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,name_repair="minimal",show_col_types=FALSE)
# The unlabeled final source column has three study notes. Preserve it.
names(raw)[names(raw)==""] <- "Unnamed_source_note"
names(raw)[names(raw)=="Species"] <- "Species_source"
names(raw)[names(raw)=="Species (ITIS)"] <- "Species_ITIS"
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
final.dataframe$Species <- ifelse(raw$Species_source %in% c("","NA","NI"),raw$Species_ITIS,raw$Species_source)
final.dataframe$Species_label_basis <- ifelse(raw$Species_source %in% c("","NA","NI"),"source ITIS column; source Species missing","source Species column")
final.dataframe$Source_row <- seq_len(nrow(raw))+1L
# Preserve source corruption and ranges in original columns. Only strict scalar numbers
# become point values; decimal commas, dates, percentages and prose are NOT guessed.
scalar <- function(v) {ok <- grepl("^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$",trimws(v));ifelse(ok,suppressWarnings(as.numeric(v)),NA_real_)}
final.dataframe[["Diet_fruit_pct"]] <- scalar(raw[["Fruit"]]) * 1
final.dataframe[["Diet_fruit_pct"]][final.dataframe[["Diet_fruit_pct"]] < 0 | final.dataframe[["Diet_fruit_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_leaves_pct"]] <- scalar(raw[["Leaves"]]) * 1
final.dataframe[["Diet_leaves_pct"]][final.dataframe[["Diet_leaves_pct"]] < 0 | final.dataframe[["Diet_leaves_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_flowers_pct"]] <- scalar(raw[["Flowers"]]) * 1
final.dataframe[["Diet_flowers_pct"]][final.dataframe[["Diet_flowers_pct"]] < 0 | final.dataframe[["Diet_flowers_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_seeds_pct"]] <- scalar(raw[["Seeds"]]) * 1
final.dataframe[["Diet_seeds_pct"]][final.dataframe[["Diet_seeds_pct"]] < 0 | final.dataframe[["Diet_seeds_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_animal_pct"]] <- scalar(raw[["Animal"]]) * 1
final.dataframe[["Diet_animal_pct"]][final.dataframe[["Diet_animal_pct"]] < 0 | final.dataframe[["Diet_animal_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_gums_pct"]] <- scalar(raw[["Gums"]]) * 1
final.dataframe[["Diet_gums_pct"]][final.dataframe[["Diet_gums_pct"]] < 0 | final.dataframe[["Diet_gums_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_nectar_pct"]] <- scalar(raw[["Nectar"]]) * 1
final.dataframe[["Diet_nectar_pct"]][final.dataframe[["Diet_nectar_pct"]] < 0 | final.dataframe[["Diet_nectar_pct"]] > 100] <- NA_real_
final.dataframe[["Diet_other_pct"]] <- scalar(raw[["Other"]]) * 1
final.dataframe[["Diet_other_pct"]][final.dataframe[["Diet_other_pct"]] < 0 | final.dataframe[["Diet_other_pct"]] > 100] <- NA_real_
final.dataframe[["N_groups_numeric"]] <- scalar(raw[["N_groups"]]) * 1
final.dataframe[["Mean_group_size"]] <- scalar(raw[["Mean_individuals"]]) * 1
final.dataframe[["Study_months"]] <- scalar(raw[["Study_duration_months"]]) * 1
final.dataframe[["Refs_keys"]] <- gsub(", *", "; ",raw[["Refs"]])
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

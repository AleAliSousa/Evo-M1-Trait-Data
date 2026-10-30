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
doc <- xml2::read_xml(unz(file.path(folder,paste0(item_name,"_snapshot.docx")),"word/document.xml"))
tr <- xml2::xml_find_all(doc,".//w:tbl[1]/w:tr",xml2::xml_ns(doc))
rows <- lapply(tr,function(r) vapply(xml2::xml_find_all(r,"./w:tc",xml2::xml_ns(doc)),function(c) paste(xml2::xml_text(xml2::xml_find_all(c,".//w:t",xml2::xml_ns(doc))),collapse=""),character(1)))
stopifnot(length(rows)==132L,all(lengths(rows)==7L))
raw <- as.data.frame(do.call(rbind,rows[-1]),stringsAsFactors=FALSE)
names(raw) <- c("Species","Site","Group_count","Group_size","Grooming_pct","Source","Comments")
final.dataframe <- raw
final.dataframe$Source_row <- seq_len(nrow(raw))+1L
final.dataframe$Group_count_printed <- raw$Group_count
final.dataframe$Group_size_printed <- raw$Group_size
final.dataframe$Grooming_pct_printed <- raw$Grooming_pct
final.dataframe$Group_count <- num(raw$Group_count)
final.dataframe$Group_size <- num(sub(" *\\(.*", "",raw$Group_size))
has_community <- grepl("\\(",raw$Group_size)
final.dataframe$Community_band_size <- ifelse(has_community,num(sub(".*\\(([^)]+)\\).*","\\1",raw$Group_size)),NA_real_)
final.dataframe$Grooming_pct <- num(raw$Grooming_pct)
final.dataframe$Grooming_operator <- ifelse(grepl("grooming <",raw$Comments,fixed=TRUE),"<","=")
final.dataframe$Group_size_operator <- ifelse(grepl("Group size >",raw$Comments,fixed=TRUE),">","=")
final.dataframe$Source_keys <- vapply(raw$Source,function(s) {
 z <- regmatches(s,gregexpr("\\([0-9 ,]+\\)",s))[[1]]
 if(!length(z)) return(trimws(s))
 paste(trimws(unlist(strsplit(gsub("[()]","",z),","))),collapse="; ")
},character(1))
final.dataframe$Data_role <- ifelse(grepl("Karisoke, long term records",raw$Source,fixed=TRUE),"primary","secondary")
final.dataframe$Observation_level <- "group or population mean"

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

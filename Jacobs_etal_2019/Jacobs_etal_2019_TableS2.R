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
suppressPackageStartupMessages(library(xml2))
tmp <- tempfile(); dir.create(tmp)
unzip(file.path(folder,paste0(item_name,"_snapshot.docx")),files="word/document.xml",exdir=tmp)
doc <- read_xml(file.path(tmp,"word/document.xml"));ns <- xml_ns(doc)
tables <- xml_find_all(doc,"//w:tbl",ns)
rows <- lapply(xml_find_all(tables[[2]],"./w:tr",ns),function(r) vapply(xml_find_all(r,"./w:tc",ns),function(c) paste0(xml_text(xml_find_all(c,".//w:t",ns)),collapse=""),character(1)))
rows <- rows[-1]
raw <- as.data.frame(do.call(rbind,rows),stringsAsFactors=FALSE)
names(raw) <- c("Family","Genus","Species","Vernacular","Plant part","% TK","% VL","% VT","% All","Spectral Data")
unlink(tmp,recursive=TRUE)
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
final.dataframe$Source_row <- seq_len(nrow(raw))+1L
scalar <- function(v) {ok <- grepl("^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$",trimws(v));ifelse(ok,suppressWarnings(as.numeric(v)),NA_real_)}
final.dataframe[["Foraging_TK_pct"]] <- scalar(raw[["% TK"]]) * 1
final.dataframe[["Foraging_VL_pct"]] <- scalar(raw[["% VL"]]) * 1
final.dataframe[["Foraging_VT_pct"]] <- scalar(raw[["% VT"]]) * 1
final.dataframe[["Foraging_All_pct"]] <- scalar(raw[["% All"]]) * 1
final.dataframe$Plant_species <- raw$Species
final.dataframe$Species <- "Eulemur rubriventer"

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

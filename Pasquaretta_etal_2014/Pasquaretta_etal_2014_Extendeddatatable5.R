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
# The untouched legacy Word document is the frozen source. macOS textutil extracts
# its original cell separator (ASCII 7); no values are read from the convenience view.
converter <- Sys.which("textutil")
if(converter=="")stop("This legacy Word reader requires macOS textutil")
txt <- paste(system2(converter,c("-convert","txt","-stdout",shQuote(file.path(folder,paste0(item_name,"_snapshot.doc")))),stdout=TRUE),collapse="\n")
section <- strsplit(txt,"Extended data table 5: Dataset of the 78 primates groups\n",fixed=TRUE)[[1]][2]
section <- strsplit(section,"Supplementary Figures",fixed=TRUE)[[1]][1]
sep <- intToUtf8(7)
blocks <- strsplit(section,paste0("\nGroup",sep),fixed=TRUE)[[1]]
parse_block <- function(z){if(!startsWith(z,"Group"))z<-paste0("Group",sep,z);rs<-strsplit(trimws(z),paste0(sep,sep),fixed=TRUE)[[1]];rs<-rs[nzchar(trimws(rs))];lapply(rs,function(r)strsplit(trimws(r),sep,fixed=TRUE)[[1]])}
blocks<-lapply(blocks,function(z)Filter(function(r)length(r)>1L,parse_block(z)));a<-blocks[[1]];b<-blocks[[2]]
stopifnot(length(a)==79L,length(b)==79L,identical(vapply(a[-1],`[`,character(1),1),vapply(b[-1],`[`,character(1),1)))
raw<-as.data.frame(do.call(rbind,Map(function(r,t)c(r,t[-1]),a[-1],b[-1])),stringsAsFactors=FALSE)
names(raw)<-c(a[[1]],b[[1]][-1])
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
final.dataframe$Source_row <- seq_len(nrow(raw))+1L
scalar <- function(v) {ok <- grepl("^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$",trimws(v));ifelse(ok,suppressWarnings(as.numeric(v)),NA_real_)}
final.dataframe$Species <- raw[["Species"]]
final.dataframe[["Male_fraction"]] <- scalar(raw[["Sex ratio"]]) * 1
final.dataframe[["Group_size"]] <- scalar(raw[["Group Size N"]]) * 1
final.dataframe[["Connections_count"]] <- scalar(raw[["Number of connections I"]]) * 1
final.dataframe[["Network_diameter"]] <- scalar(raw[["Diameter D"]]) * 1
final.dataframe[["Network_density"]] <- scalar(raw[["Density"]]) * 1
final.dataframe[["Neocortex_ratio"]] <- scalar(raw[["Neocortex ratio Cr"]]) * 1
final.dataframe[["Global_efficiency"]] <- scalar(raw[["Global Efficiency"]]) * 1
final.dataframe[["Average_dyadic_efficiency"]] <- scalar(raw[["Average Dyadic Efficiency"]]) * 1
final.dataframe[["Centralisation_index"]] <- scalar(raw[["Centralisation index"]]) * 1
final.dataframe[["Modularity"]] <- scalar(raw[["Modularity"]]) * 1
final.dataframe[["Observation_months"]] <- scalar(raw[["Observation period (months)"]]) * 1
final.dataframe[["Focal_hours"]] <- scalar(raw[["focal hours per group"]]) * 1
expand_keys <- function(s) paste(unlist(lapply(strsplit(s,",",fixed=TRUE)[[1]],function(z){if(grepl("–",z,fixed=TRUE)){a<-as.integer(strsplit(z,"–",fixed=TRUE)[[1]]);as.character(seq(a[1],a[2]))}else z})),collapse="; ")
final.dataframe$Reference_keys <- vapply(raw$Reference,expand_keys,character(1))
final.dataframe$Species <- trimws(gsub(" +"," ",raw$Species))
table_checks <- data.frame(check_id=paste0("density_group_",raw$Group),observed=final.dataframe$Connections_count/(final.dataframe$Group_size*(final.dataframe$Group_size-1)/2),printed=final.dataframe$Network_density)
table_checks$status<-ifelse(abs(table_checks$observed-table_checks$printed)<=0.00051,"pass","mismatch")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")

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

x <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),colClasses="character",check.names=FALSE,na.strings=c("NA",""))
final.dataframe <- x
names(final.dataframe)[names(final.dataframe)=="value"] <- "value_source_units"
for(c in c("value_source_units","n","sd")) final.dataframe[[c]]<-num(final.dataframe[[c]])
final.dataframe$sd_source_text <- x$sd
final.dataframe$species <- x$latin_name
final.dataframe$common_name <- x$species
units <- c(indiff="s",bodywt="g",ecv="mm3",homerange="ha",lifespan="years",groupsize="individuals")
factor <- ifelse(x$measure=="ecv",1000,1)
final.dataframe$value <- final.dataframe$value_source_units*factor
final.dataframe$sd_standard_units <- final.dataframe$sd*factor
final.dataframe$unit <- unname(units[x$measure])
for(m in names(units)) {
 final.dataframe[[paste0(m,"_value")]] <- ifelse(x$measure==m,final.dataframe$value,NA_real_)
 final.dataframe[[paste0(m,"_SD")]] <- ifelse(x$measure==m,final.dataframe$sd_standard_units,NA_real_)
}
final.dataframe$data_role <- "secondary"
final.dataframe$source <- source_name
refs <- read.csv(file.path(folder,"reference_tables",paste0(item_name,"_references.csv")),colClasses="character")
final.dataframe$reference_resolution <- refs$note[match(x$reference,refs$ref_key)]
stopifnot(nrow(x)==941,sum(x$measure=="indiff")==96,length(unique(x$latin_name))==13,!anyNA(final.dataframe$unit),!anyNA(final.dataframe$reference_resolution))

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

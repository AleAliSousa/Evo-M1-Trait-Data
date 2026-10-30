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
raw <- readxl::read_excel(file.path(folder,paste0(item_name,"_snapshot.xlsx")),sheet=1,trim_ws=FALSE,col_names=FALSE,col_types="text",.name_repair="minimal")
x <- raw[5:234,];fam <- x[[1]];for(i in seq_along(fam)) if(is.na(fam[i]) && i>1) fam[i]<-fam[i-1]
final.dataframe <- data.frame(species=x[[2]],family_source_group=fam,common_name=x[[3]],mating_system=x[[4]],paternal_care=x[[5]],female_ranging=x[[6]],gestation_days=num(x[[7]]),weaning_days=num(x[[8]]),weaning_proportion=num(x[[9]]),seasonal_breeding=x[[10]],infanticide=x[[11]],total_publications=num(x[[12]]),additional_source_key=gsub(", *","; ",x[[13]]),source=source_name)
for(j in c(4,5,6,7,8,10,11)) {
 code <- c("mating_system","paternal_care","female_ranging","gestation_days","weaning_days","weaning_proportion","seasonal_breeding","infanticide")[j-3]
 final.dataframe[[paste0(code,"_source_key")]] <- gsub(", *","; ",raw[4,j][[1]])
}
final.dataframe$data_role <- "secondary"
stopifnot(nrow(final.dataframe)==230,!anyDuplicated(final.dataframe$species))
table_checks <- check(final.dataframe$species,final.dataframe$weaning_days/(final.dataframe$gestation_days+final.dataframe$weaning_days),final.dataframe$weaning_proportion,1e-10,"L/(G+L) vs supplied weaning proportion")

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

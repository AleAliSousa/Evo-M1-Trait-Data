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
z <- raw[3:(nrow(raw)-1),];current <- NA_character_;out <- list()
for(i in seq_len(nrow(z))) {
 r <- z[i,]
 if(is.na(r[[1]])) next
 if(is.na(r[[4]])) {current <- r[[1]];next}
 out[[length(out)+1]] <- data.frame(species=r[[1]],order=current,common_name=r[[2]],AHN_evidence_source_text=r[[3]],source_key_source_text=r[[4]])
}
final.dataframe <- do.call(rbind,out)
final.dataframe$source_key <- gsub(", *","; ",sub("^e.g. *","",final.dataframe$source_key_source_text))
final.dataframe$AHN_reported <- ifelse(final.dataframe$AHN_evidence_source_text=="AHN absent","not detected by study assay","presence reported using listed markers")
final.dataframe$data_role <- ifelse(final.dataframe$source_key=="2","primary","secondary")
final.dataframe$source <- source_name
stopifnot(nrow(final.dataframe)==96,sum(final.dataframe$source_key=="2")==71)

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

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

raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")), header=FALSE, colClasses="character", check.names=FALSE, na.strings="", fill=TRUE)

starts <- seq(3,by=10,length.out=5)
final.dataframe <- do.call(rbind,lapply(starts,function(i) {
 x <- raw[(i+1):(i+5),]
 data.frame(species="Homo sapiens",patient_id=as.character(1:5),age_years=num(x[[1]]),sex="male",structure=raw[i,1],sections_assessed=num(x[[2]]),points_counted=num(x[[3]]),CE_points=num(x[[4]]),nuclei_counted=num(x[[5]]),frames_assessed=num(x[[6]]),mean_nuclei_per_frame=num(x[[7]]),CE_mean_nuclei=num(x[[8]]),reference_layer_volume_mm3=num(x[[9]]),neuronal_density_cells_mm3=num(x[[10]])*1e6,neurons_n=num(x[[11]])*1e6,CE_neurons=num(x[[12]]),hemisphere_scope="one hippocampus per donor; figure shows left, cohort side not explicitly stated",source=source_name)
}))
stopifnot(nrow(final.dataframe)==25,!anyDuplicated(final.dataframe[c("patient_id","structure")]))
# Full printed summaries stay in snapshot, never duplicated as additional donors.
table_checks <- do.call(rbind,lapply(seq_along(starts),function(j) {
 i <- starts[j];x <- raw[(i+1):(i+5),]
 obs <- c(mean(num(x[[9]])),mean(num(x[[10]])),mean(num(x[[11]])))
 printed <- num(raw[i+6,c(9,10,11)])
 tol <- c(if(j==1).1 else 1,if(j %in% c(2,5)) .00001 else if(j==1).001 else .0001,if(j %in% c(1,4)) .1 else .01)
 data.frame(check_id=paste(raw[i,1],c("V mean","Nv mean","N mean")),basis="individual means vs printed summary in original units",observed=obs,printed=printed,difference=obs-printed,tolerance=tol,status=ifelse(abs(obs-printed)<=tol+1e-10,"pass","mismatch"),note="Rounded inputs; printed summaries not substituted for individual data.")
}))

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

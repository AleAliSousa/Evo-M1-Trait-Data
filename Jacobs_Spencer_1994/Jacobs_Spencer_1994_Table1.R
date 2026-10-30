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
x <- raw[c(4:6,8:10,12),]
mn <- function(z) num(sub(" ±.*","",z));se <- function(z) num(sub(".*± ","",z))
final.dataframe <- data.frame(species=rep(c("Dipodomys merriami","Dipodomys spectabilis","Dipodomys ordii"),c(3,3,1)),sex_group=x[[1]],n=num(x[[2]]),body_mass_mean_g=mn(x[[3]]),body_mass_SE_g=se(x[[3]]),brain_mass_mean_mg=mn(x[[4]])*1000,brain_mass_SE_mg=se(x[[4]])*1000,hippocampus_volume_mean_mm3=mn(x[[5]]),hippocampus_volume_SE_mm3=se(x[[5]]),relative_brain_size=mn(x[[6]]),relative_brain_size_SE=se(x[[6]]),relative_hippocampal_volume=mn(x[[7]]),relative_hippocampal_volume_SE=se(x[[7]]),hemisphere_scope="whole-brain serial sections; total hippocampal volume",age_class="adult",sample_location="Portal, Arizona; March 1989 breeding season",source=source_name)
table_checks <- do.call(rbind,lapply(c(1,4),function(k) {
 a <- final.dataframe[k:(k+2),];cs <- c("body_mass_mean_g","brain_mass_mean_mg","hippocampus_volume_mean_mm3")
 check(paste(a$species[1],cs),sapply(cs,function(c) weighted.mean(a[[c]][1:2],a$n[1:2])),sapply(cs,function(c) a[[c]][3]),c(.1,10,.1),"n-weighted sex means vs all-animal mean")
}))

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

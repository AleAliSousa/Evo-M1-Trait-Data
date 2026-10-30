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
x <- raw[4:16,]
final.dataframe <- do.call(rbind,lapply(1:4,function(j) {
 vcol <- c(5,6,9,10)[j];sicol <- c(7,8,11,12)[j];refcol <- if(j<=2) 3 else 4
 data.frame(species=if(j<=2) "Tupaia glis" else "Callithrix jacchus",specimen_id=c("T1","T2","M1","M2")[j],structure=x[[1]],standardized_volume_mm3=num(x[[vcol]]),size_index=num(x[[sicol]]),hypothetical_hedgehog_reference_mm3=num(x[[refcol]]),printed_hedgehog_mean_mm3=num(x[[2]]),printed_species_mean_SI=num(x[[if(j<=2) 13 else 14]]),hemisphere_scope="not explicitly resolved",normalization_source_key="Stephan1981",specimen_source_key="CurrentStudy",source=source_name)
}))
table_checks <- check(paste(final.dataframe$specimen_id,final.dataframe$structure),100*final.dataframe$standardized_volume_mm3/final.dataframe$hypothetical_hedgehog_reference_mm3,final.dataframe$size_index,.6,"100 × standardized / hypothetical reference volume vs SI")

# Component sums are meaningful only within the same specimen and normalization.
component_checks <- do.call(rbind,lapply(unique(final.dataframe$specimen_id),function(id) {
 z <- final.dataframe[final.dataframe$specimen_id==id,];v <- z$standardized_volume_mm3
 obs <- c(sum(v[c(2,9,10,13)]),sum(v[c(3,4)]),sum(v[c(5,6)]),sum(v[c(7,8)]),sum(v[c(11,12)]))
 check(paste(id,c("total hippocampus","area dentata","fascia dentata","molecular layer","Ammon horn")),obs,v[c(1,2,4,6,10)],c(.025,.015,.015,.015,.015),"Sum of printed component volumes vs printed composite; rounding tolerance")
}))
table_checks <- rbind(table_checks,component_checks)

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

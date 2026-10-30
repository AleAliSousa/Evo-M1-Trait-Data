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

x <- raw[4:20,]
final.dataframe <- do.call(rbind,lapply(1:3,function(j) data.frame(species=c("Apodemus flavicollis","Apodemus sylvaticus","Apodemus sylvaticus")[j],population=c("Aarhus, Denmark","Copenhagen, Denmark","Montpelier, France")[j],sex="male",age_class="adult",n=6L,hemisphere="left",structure=x[[1]],volume_mean_mm3=num(x[[2*j]]),volume_SD_mm3=num(x[[2*j+1]]),body_mass_mean_g=c(25,17,21)[j],body_mass_SD_g=c(1.1,1.9,4.3)[j],source=source_name)))
# Keep the two distinct A. sylvaticus populations; never collapse to a first row.
stopifnot(nrow(final.dataframe)==51,!anyDuplicated(final.dataframe[c("species","population","structure")]))
table_checks <- do.call(rbind,lapply(1:3,function(j) {
 v <- num(x[[2*j]])
 obs <- c(v[3]+v[10],sum(v[c(4:8)]),sum(v[c(11,12)]),sum(v[c(13:16)]),sum(v[c(8,16)]))
 printed <- v[c(2,3,13,10,17)];tol <- c(.015,.03,.015,.025,.015)
 data.frame(check_id=paste(j,c("Ammon+dentata","Ammon layers","superficial+intermediate","dentata layers","hilus+mossy"),sep=" / "),basis="sum of reported component means vs reported combined mean",observed=obs,printed=printed,difference=obs-printed,tolerance=tol,status=ifelse(abs(obs-printed)<=tol+1e-10,"pass","mismatch"),note="Tolerance from 0.01-mm3 rounding; overlapping definitions and source discrepancies retained.")
}))
if(any(table_checks$status=="mismatch")) warning("Published composite volumes have arithmetic discrepancies; see table_checks and errata.")

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

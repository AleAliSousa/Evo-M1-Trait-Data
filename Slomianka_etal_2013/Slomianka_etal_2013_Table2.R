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

starts <- seq(3,by=4,length.out=5)
final.dataframe <- do.call(rbind,lapply(starts,function(i) {
 x <- raw[(i+1):(i+3),]
 data.frame(species="Elephantulus myurus",cell_population=raw[i,1],sex_group=x[[1]],n=c(8,4,4),count_mean=num(x[[2]]),count_SD=num(x[[3]]),mean_CE=num(x[[4]]),CE2_CV2=num(x[[5]]),hemisphere="left",sections_assessed_mean=num(raw[i+1,7]),sections_assessed_range=raw[i+2,7],cells_counted_mean=num(raw[i+1,8]),cells_counted_range=raw[i+2,8],source=source_name)
}))
# Sampling means/ranges refer to the entire region sample, not each sex subgroup.
final.dataframe$sampling_scope <- "all animals; shared across sex rows"
stopifnot(nrow(final.dataframe)==15)
obs <- sapply(starts,function(i) mean(num(raw[(i+2):(i+3),2])))
printed <- num(raw[starts+1,2])
tol <- rep(1000,length(starts))
table_checks <- data.frame(check_id=raw[starts,1],basis="equal-n female/male average vs all-animal mean",observed=obs,printed=printed,difference=obs-printed,tolerance=tol,status=ifelse(abs(obs-printed)<=tol,"pass","mismatch"),note="Rounded summaries retained; groups overlap and must not be pooled as separate specimens.")
final.dataframe$counting_frame <- rep(raw[starts+1,6],each=3)

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

# Frozen published source -> analysis CSV -> registered public TSV.
# Extracted by Codex, 2026-10-25. See the item README and definitions.
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
raw <- utils::read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),header=FALSE,check.names=FALSE,colClasses="character",na.strings="",fill=TRUE)
x <- raw[3:10,]
regions <- c("Amygdala_superficial","Amygdala_centromedial","Amygdala_laterobasal","DentateGyrus","Hippocampus_CA1to3","Subiculum","HippocampoAmygdaloidTransitionArea","EntorhinalCortex","Amygdala","Hippocampus")
left <- c(x[[3]], x[1,5], x[4,5])
right <- c(x[[4]], x[1,6], x[4,6])
mean_of <- function(z) num(sub("±.*$","",z))
sd_of <- function(z) num(sub("^.*±","",z))
final.dataframe <- data.frame(species="Homo sapiens",n=10L,stringsAsFactors=FALSE)
for (j in seq_along(regions)) {
  r <- regions[j]
  final.dataframe[[paste0(r,"_left_mean_mm3")]] <- mean_of(left[j])
  final.dataframe[[paste0(r,"_left_SD_mm3")]] <- sd_of(left[j])
  final.dataframe[[paste0(r,"_right_mean_mm3")]] <- mean_of(right[j])
  final.dataframe[[paste0(r,"_right_SD_mm3")]] <- sd_of(right[j])
  final.dataframe[[paste0(r,"_bilateral_mean_mm3")]] <- mean_of(left[j])+mean_of(right[j])
}
# No bilateral SD: the left/right covariance is not published.
final.dataframe$source <- source_name
observed <- c(sum(mean_of(left[1:3])),sum(mean_of(right[1:3])),sum(mean_of(left[4:7])),sum(mean_of(right[4:7])))
printed <- c(mean_of(left[9]),mean_of(right[9]),mean_of(left[10]),mean_of(right[10]))
table_checks <- data.frame(check_id=c("Amygdala left","Amygdala right","Hippocampus left","Hippocampus right"), basis="sum of component means vs printed total mean",observed=observed,printed=printed,difference=observed-printed,tolerance=c(2,2,2.5,2.5),status=ifelse(abs(observed-printed)<=c(2,2,2.5,2.5),"pass","mismatch"),note="Integer-rounded means: tolerate half a unit for each component plus the total; preserve printed totals.")
stopifnot(all(table_checks$status=="pass"), final.dataframe$Amygdala_bilateral_mean_mm3==3042,final.dataframe$Hippocampus_bilateral_mean_mm3==9597)

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

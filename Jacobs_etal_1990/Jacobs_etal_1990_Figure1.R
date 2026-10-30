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
x <- raw[3:10,]
slope <- (num(x[[9]])-num(x[[11]]))/(num(x[[10]])-num(x[[8]]))
mn <- num(x[[11]])+(num(x[[10]])-num(x[[5]]))*slope
se <- abs(num(x[[7]])-num(x[[6]]))*slope/2
idx <- which(x[[1]] %in% c("A","C"));rel <- which(x[[1]] %in% c("B","D"))
m <- read.csv(file.path(folder,"reference_tables",paste0(source_name,"_species_from_methods.csv")),check.names=FALSE)
final.dataframe <- data.frame(species_as_published=m$species_as_published[match(x[[2]][idx],m$figure_label)],figure_species_label=x[[2]][idx],sex=x[[3]][idx],n=10,hippocampus_volume_estimate_mm3=round(mn[idx],1),hippocampus_volume_SE_estimate_mm3=round(se[idx],1),relative_axis_mean_estimate=round(mn[rel],4),relative_axis_SE_estimate=round(se[rel],4),digitization_resolution_mm3=.1,digitization_uncertainty_mm3=.1,age_class="adult; wild-caught during breeding season",hemisphere_scope="not explicitly specified; no doubling applied",anatomical_boundary="dentate gyrus plus Ammon's horn",measurement_status="figure-derived approximation",source=source_name)
# Preserve the plotted relative scale; axis x100 conflicts with the Methods' ratio wording.
# No conversion of those relative values into percentages or reconstructed brain volumes.

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

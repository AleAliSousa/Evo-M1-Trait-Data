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

z <- raw[-c(1,2),]; order <- character(nrow(z));current <- NA_character_
for(i in seq_len(nrow(z))) {if(is.na(z[i,2])) current<-z[i,1];order[i]<-current}
keep <- !is.na(z[[2]]);x <- z[keep,]
role <- function(k) ifelse(k=="19","primary",ifelse(grepl("(^|,)19(,|$)",k),"both","secondary"))
final.dataframe <- data.frame(species=x[[1]],order=order[keep],species_code=x[[2]],habitat=x[[3]],diet=x[[4]],body_mass_g=num(x[[5]])*1000,eye_axial_diameter_mm=num(x[[6]]),cribriform_plate_area_mm2=num(x[[7]]),tympanic_membrane_area_mm2=num(x[[8]]),residual_eye=num(x[[9]]),residual_nose=num(x[[10]]),residual_ear=num(x[[11]]),eye_source_key=x[[12]],nose_source_key=x[[13]],ear_source_key=x[[14]],eye_data_role=role(x[[12]]),nose_data_role=role(x[[13]]),ear_data_role=role(x[[14]]),ecology_source_key="Nowak1999",source=source_name)
stopifnot(nrow(final.dataframe)==119,!anyDuplicated(final.dataframe$species))
refs <- read.csv(file.path(folder,"reference_tables",paste0(item_name,"_references.csv")),colClasses="character")
stopifnot(all(unique(unlist(strsplit(c(x[[12]],x[[13]],x[[14]]),","))) %in% refs$ref_key))

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

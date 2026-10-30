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

x <- raw[3:9,]
mean_of <- function(z) num(gsub(",","",sub(" .*", "", z)))
se_of <- function(z) ifelse(grepl("±",z),num(gsub("[*]","",sub(".*± *","",z))),NA_real_)
final.dataframe <- data.frame(species=x[[1]], n=c(10,5,5,10,5,5,5), body_mass_g=mean_of(x[[2]])*1000, body_mass_SE_g=se_of(x[[2]])*1000, brain_mass_mg=mean_of(x[[3]])*1000, brain_mass_SE_mg=se_of(x[[3]])*1000, brain_body_ratio_g_kg=mean_of(x[[4]]), brain_body_ratio_SE_g_kg=se_of(x[[4]]), body_mass_basis=ifelse(grepl("estimated",x[[2]]),"estimated","weighed"), source=source_name)
# Ratio of means need not equal mean of individual ratios; retain reported ratio.
obs <- final.dataframe$brain_mass_mg/final.dataframe$body_mass_g
table_checks <- data.frame(check_id=final.dataframe$species,basis="ratio of means vs reported brain/body ratio (g/kg)",observed=obs,printed=final.dataframe$brain_body_ratio_g_kg,difference=obs-final.dataframe$brain_body_ratio_g_kg,tolerance=.01,status=ifelse(abs(obs-final.dataframe$brain_body_ratio_g_kg)<=.01,"pass","mismatch"),note="Mean of ratios need not equal ratio of means; no correction.")

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

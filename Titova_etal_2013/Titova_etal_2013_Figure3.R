## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "Titova_etal_2013_Figure3.R"
script_path <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a) && basename(sub("^--file=", "", a[1])) == me)
    return(normalizePath(sub("^--file=", "", a[1])))
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"), recursive = TRUE, full.names = TRUE)
  if (length(hits) != 1L) stop("Cannot locate script: ", me)
  normalizePath(hits)
})
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository root not found")
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), check.names=FALSE, colClasses="character", na.strings="")
stopifnot(nrow(snap)==9L, snap[[1]][9]=="Synthesis")
num <- function(x) as.numeric(gsub(",", ".", gsub("%", "", x, fixed=TRUE), fixed=TRUE))
final.dataframe <- data.frame(
 Species="Homo sapiens", species_as_published="human",
 control_condition="healthy controls", comparison_condition="current anorexia nervosa",
 Structure="cerebrospinal fluid", source_study=snap[[1]],
 series_role=ifelse(snap[[1]]=="Synthesis", "pooled", "study"),
 CohenD=num(snap[[4]]), CI_lower=num(snap[[5]]), CI_upper=num(snap[[6]]),
 Study_weight_pct=num(snap[[3]]), P_value_as_printed=snap[[2]],
 check.names=FALSE, stringsAsFactors=FALSE)

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="", fileEncoding="UTF-8")
reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet="Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_")) stop("Invalid Item encoded")
public <- file.path(root, "__Public", "comparative-data")
dir.create(public, recursive=TRUE, showWarnings=FALSE)
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="", fileEncoding="UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns\n", sep="")

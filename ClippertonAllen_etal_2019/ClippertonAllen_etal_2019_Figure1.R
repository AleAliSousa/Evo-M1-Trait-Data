## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "ClippertonAllen_etal_2019_Figure1.R"
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
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), check.names=FALSE, stringsAsFactors=FALSE)
stopifnot(nrow(snap)==12L)
convert <- function(pixel, d) d[["Axis min mm3"]] + (d[["Axis min pixel y"]] - pixel) * (d[["Axis max mm3"]]-d[["Axis min mm3"]]) / (d[["Axis min pixel y"]]-d[["Axis max pixel y"]])
mean <- convert(snap[["Bar top pixel y"]],snap)
upper <- convert(snap[["Upper SEM cap pixel y"]],snap)
final.dataframe <- data.frame(
 Species="Mus musculus", species_as_published="mouse",
 source_panel=snap$Panel, age=snap$Age, Structure_as_published=snap$Structure,
 genotype=snap$Genotype, condition=ifelse(snap$Genotype=="Pten+/+", "wild-type control", "Pten heterozygous"),
 n=snap$n, Axis_min.mm3=snap[["Axis min mm3"]], Axis_max.mm3=snap[["Axis max mm3"]],
 Volume.mm3=round(mean,2), SEM_approx.mm3=round(upper-mean,2),
 extraction_method="bar and upper SEM cap digitized from 300 dpi PDF page 4",
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

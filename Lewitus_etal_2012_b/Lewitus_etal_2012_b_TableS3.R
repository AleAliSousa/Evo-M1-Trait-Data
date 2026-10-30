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
raw <- readxl::read_excel(file.path(folder,paste0(item_name,"_snapshot.xls")), sheet="S3", col_names=FALSE, col_types="text", .name_repair="minimal")
# Species rows have numeric V1 neuronal density; headers/footnotes/blanks do not.
keep <- !is.na(num(raw[[4]]))
x <- raw[keep, ]
final.dataframe <- data.frame(species=trimws(x[[1]]), stringsAsFactors=FALSE)
codes <- c("glia_neuron_ratio_V1", "neuronal_density_V1_cells_mm3", "glial_density_V1_cells_mm3", "glia_neuron_ratio_CA1to3", "neuronal_density_CA1to3_cells_mm3", "glial_density_CA1to3_cells_mm3")
for (j in seq_along(codes)) final.dataframe[[codes[j]]] <- num(x[[c(3,4,5,6,7,8)[j]]])
final.dataframe$hemisphere <- "left"
final.dataframe$age_class <- ifelse(final.dataframe$species %in% c("Trachypithecus francoisi","Pithecia pithecia"),"juvenile","adult")
final.dataframe$V1_data_role <- "secondary"
final.dataframe$CA1to3_data_role <- "primary"
final.dataframe$V1_source_key <- "Lewitus2012BSF"
final.dataframe$source <- source_name
stopifnot(nrow(final.dataframe)==11, !anyDuplicated(final.dataframe$species))
# Ratios are independently reported estimates; diagnose, never replace with G/N.
table_checks <- do.call(rbind,lapply(c("V1","CA1to3"),function(region) {
  obs <- final.dataframe[[paste0("glial_density_",region,"_cells_mm3")]] / final.dataframe[[paste0("neuronal_density_",region,"_cells_mm3")]]
  printed <- final.dataframe[[paste0("glia_neuron_ratio_",region)]]
  difference <- obs-printed
  data.frame(check_id=paste(final.dataframe$species,region,"ratio",sep=" / "),basis="reported glial density / neuronal density vs reported ratio", observed=obs,printed=printed,difference=difference,tolerance=0.01,status=ifelse(is.na(difference),"not_evaluable",ifelse(abs(difference)<=0.01,"pass","mismatch")),note="Independent estimates/back-transformations; preserve all source values.")
}))
if(any(table_checks$status=="mismatch")) warning(sum(table_checks$status=="mismatch")," reported ratios differ from density quotients by >0.01; see table_checks.")

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

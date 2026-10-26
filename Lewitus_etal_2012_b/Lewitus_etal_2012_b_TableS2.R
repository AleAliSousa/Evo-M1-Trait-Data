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
raw <- readxl::read_excel(file.path(folder,paste0(item_name,"_snapshot.xls")), sheet="S2", col_names=FALSE, col_types="text", .name_repair="minimal")
x <- raw[!is.na(num(raw[[8]])), ]
final.dataframe <- data.frame(species=trimws(x[[1]]), StrGc_source=num(x[[3]]), StrMol_source=num(x[[4]]), CrbGc_source=num(x[[6]]), stringsAsFactors=FALSE)
# Figure 4 (p.2558) explicitly labels these three volumes um3; S2 caption says mm3.
# 1 mm3 = 1e9 um3. Preserve raw values and expose the interpreted units.
final.dataframe$DG_granular_layer_volume_mm3 <- final.dataframe$StrGc_source / 1e9
final.dataframe$DG_molecular_layer_volume_mm3 <- final.dataframe$StrMol_source / 1e9
final.dataframe$cerebellar_granular_layer_volume_mm3 <- final.dataframe$CrbGc_source / 1e9
final.dataframe$brain_mass_mg <- num(x[[8]]) * 1000 # g -> mg
final.dataframe$body_mass_g <- num(x[[9]]) * 1000 # kg -> g
final.dataframe$gestation_days <- num(x[[10]])
final.dataframe$body_gestation_source_key <- "Jones2009"
final.dataframe$volume_unit_basis <- "um3: Figure 4; S2 caption conflicts"
final.dataframe$volume_laterality <- "not explicitly stated for layer volumes"
final.dataframe$source <- source_name
stopifnot(!anyDuplicated(final.dataframe$species),nrow(final.dataframe)>58)

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")

# Freeze the author's born-digital species_predictors.xlsx without changing
# sheets, headers, row order, formulas, cell types, or workbook metadata.
# The item reader is a separate script and reads only this snapshot.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(args) != 1L) {
  stop("Run with Rscript ManyPrimates__2022_speciespredictors_snapshot.R")
}
.sp <- normalizePath(sub("^--file=", "", args[[1L]]))
folder <- dirname(.sp)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))
source_file <- file.path(folder, "species_predictors.xlsx")
snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
if (!file.exists(source_file)) stop("Missing source workbook: ", source_file)
if (!file.copy(source_file, snapshot_file, overwrite = TRUE)) {
  stop("Could not copy source workbook to snapshot")
}
if (!identical(unname(tools::md5sum(source_file)),
               unname(tools::md5sum(snapshot_file)))) {
  stop("Snapshot bytes differ from the source workbook")
}
message("Frozen byte-identical snapshot: ", snapshot_file)

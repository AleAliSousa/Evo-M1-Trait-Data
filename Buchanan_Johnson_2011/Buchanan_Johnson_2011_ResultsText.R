# Buchanan & Johnson (2011), constructed Results/Figures snapshot -> source item.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  for (f in rev(sys.frames())) if (!is.null(f$ofile)) return(normalizePath(f$ofile))
  stop("Run with Rscript or source()")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
snapshot <- file.path(folder, paste0(item_name, "_snapshot.csv"))
d <- read.csv(snapshot, stringsAsFactors=FALSE, check.names=FALSE, na.strings="")
stopifnot(nrow(d)==26L, !anyDuplicated(d$scientific_name_as_figure), !anyNA(d$scientific_name_as_figure))
state_cols <- c("insula_operculation_state", "opercular_cover_pattern", "anterior_claustral_bulb_observed", "superior_triangular_claustral_expansion_observed", "superior_insula_claustrum_free")
allowed <- list(
  insula_operculation_state=c("none", "proto", "operculated", "uncertain"),
  opercular_cover_pattern=c("temporal_and_frontoparietal", "temporal_only", "superior_frontoparietal_only"),
  anterior_claustral_bulb_observed=c("yes", "no"),
  superior_triangular_claustral_expansion_observed=c("yes", "no"),
  superior_insula_claustrum_free=c("yes", "no")
)
for (v in state_cols) stopifnot(all(is.na(d[[v]]) | d[[v]] %in% allowed[[v]]))
final.dataframe <- d[c("scientific_name_as_figure", "common_name_as_figure", "figure_panel", "figure_pdf_page", state_cols)]
final.dataframe$source <- item_name
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
# Registry is authoritative when this item is pasted into __ReadMe.xlsx.
doi <- "10.1111/j.1749-6632.2011.06022.x"
expected_encoded <- paste0(utils::URLencode(doi, reserved=TRUE), "_ResultsText")
item_encoded <- expected_encoded
registry_path <- file.path(base, "__ReadMe.xlsx")
if (file.exists(registry_path)) {
  if (!requireNamespace("readxl", quietly=TRUE)) stop("readxl is needed to check the registry")
  registry <- readxl::read_excel(registry_path, sheet="Sheet1")
  ix <- match(item_name, registry[["Item name"]])
  if (!is.na(ix)) {
    item_encoded <- registry[["Item encoded"]][ix]
    stopifnot(identical(item_encoded, expected_encoded))
  } else warning("Item not yet in __ReadMe.xlsx; using provisional DOI-coded TSV name")
}
public_dir <- file.path(base, "__Public", "comparative-data")
dir.create(public_dir, recursive=TRUE, showWarnings=FALSE)
write.table(final.dataframe, file.path(public_dir, paste0(item_encoded, ".tsv")), sep="\t", quote=TRUE, row.names=FALSE, na="")
cat("Built", item_name, nrow(final.dataframe), "species;", ncol(final.dataframe), "columns\n")

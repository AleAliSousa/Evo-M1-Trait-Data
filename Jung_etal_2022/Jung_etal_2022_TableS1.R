# Build Jung et al. (2022), Supplementary Table S1
# Run through the repository dataset builder, not by editing the snapshot.

if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required.")

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p))
      p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p))
      return(normalizePath(p))
  }
  
  stop("Cannot determine script path.")
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))

setwd(folder)
item_dir  <- dirname(.sp)          # folder containing this .R script
paper_dir <- dirname(item_dir)     # parent paper folder
item_name <- tools::file_path_sans_ext(basename(.sp))

setwd(paper_dir)

snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
output_file   <- file.path(folder, paste0(item_name, ".csv"))

stopifnot(file.exists(snapshot_file))
x <- readxl::read_excel(snapshot_file, sheet = "TableS1", skip = 2)

names(x) <- c(
  "species_as_published", "species", "V1_surface_area_mm2",
  "V1_surface_area_ref", "retina_surface_area_mm2", "retina_surface_area_ref",
  "V1_retina_surface_ratio", "V1_neurons_2D_x10_3", "V1_neurons_ref",
  "retinal_ganglion_cells_x10_3", "retinal_ganglion_cells_ref",
  "V1_neuron_RGC_ratio", "centroperipheral_density_ratio",
  "centroperipheral_density_ref"
)

x[] <- lapply(x, function(z) if (is.character(z)) trimws(z) else z)
write.csv(x, output_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("Wrote: ", output_file)

base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (!is.na(base)) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("Registry row pending for ", item_name, "; public TSV skipped.")
  } else {
    utils::write.table(x, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                       sep = "\t", row.names = FALSE, na = "")
    message("Wrote: ", file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")))
  }
} else warning("Repository root not found; public TSV skipped.")

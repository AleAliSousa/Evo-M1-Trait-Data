# Build Jung et al. (2022), Supplementary Table S1
# Run through the repository dataset builder, not by editing the snapshot.

if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required.")

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
if (is.na(script_path)) script_path <- normalizePath("Jung_etal_2022_TableS1.R", mustWork = FALSE)
item_dir <- dirname(script_path)

snapshot_file <- file.path(item_dir, "Jung_etal_2022_TableS1_snapshot.xlsx")
output_file <- file.path(item_dir, "Jung_etal_2022_TableS1.csv")

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

# Build Jung et al. (2022), Supplementary Table S2
# Run through the repository dataset builder, not by editing the snapshot.

if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required.")

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
if (is.na(script_path)) script_path <- normalizePath("Jung_etal_2022_TableS2.R", mustWork = FALSE)
item_dir <- dirname(script_path)

snapshot_file <- file.path(item_dir, "Jung_etal_2022_TableS2_snapshot.xlsx")
output_file <- file.path(item_dir, "Jung_etal_2022_TableS2.csv")

stopifnot(file.exists(snapshot_file))
x <- readxl::read_excel(snapshot_file, sheet = "TableS2", skip = 2)

names(x) <- c(
  "species_as_published", "species", "body_mass_g", "body_mass_ref",
  "orientation_pinwheel_density", "orientation_pinwheel_density_ref",
  "orientation_column_spacing", "orientation_column_spacing_ref"
)

x[] <- lapply(x, function(z) if (is.character(z)) trimws(z) else z)
write.csv(x, output_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("Wrote: ", output_file)

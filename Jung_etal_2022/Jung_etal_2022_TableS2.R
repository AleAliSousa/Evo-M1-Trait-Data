# Build Jung et al. (2022), Supplementary Table S2
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
x <- readxl::read_excel(snapshot_file, sheet = "TableS2", skip = 2)

names(x) <- c(
  "species_as_published", "species", "body_mass_g", "body_mass_ref",
  "orientation_pinwheel_density", "orientation_pinwheel_density_ref",
  "orientation_column_spacing", "orientation_column_spacing_ref"
)

x[] <- lapply(x, function(z) if (is.character(z)) trimws(z) else z)
write.csv(x, output_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("Wrote: ", output_file)

## Printed table S1: species across columns, measurements down rows.
## The source-layout snapshot is transposed here into the established analysis schema.
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required.")
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
snap <- as.data.frame(readxl::read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                       sheet = "TableS1", col_names = FALSE, col_types = "text"),
                      stringsAsFactors = FALSE)
snap[is.na(snap)] <- ""
stopifnot(nrow(snap) == 16L, ncol(snap) == 12L,
          snap[1, 1] == "Table S1. Experimental Data on retinal and V1 cell density.")
printed <- as.character(snap[2, -1])
stopifnot(identical(printed, c("Mouse", "Rat", "Rabbit", "Squirrel", "Ferret", "TS*",
                               "Cat", "Wallaby", "Macaque", "Agouti", "M.lemur")))
lookup <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_species_lookup.csv")),
                   stringsAsFactors = FALSE)
stopifnot(identical(lookup$printed_column, printed))
cell <- function(label) {
  i <- match(label, snap[[1]])
  stopifnot(!is.na(i))
  as.character(snap[i, -1])
}
reference <- function(label) {
  i <- match(label, snap[[1]])
  stopifnot(!is.na(i))
  x <- as.character(snap[i + 1L, -1])
  x <- gsub("^\\(|\\)$", "", x)
  x[x == "-"] <- ""
  x <- gsub(",\\s*", ", ", x)
  x[x == ""] <- NA_character_
  x
}
number <- function(x) {
  x[x == "-"] <- NA_character_
  as.numeric(x)
}
x <- data.frame(
  species_as_published = lookup$species_as_published,
  species = lookup$species,
  V1_surface_area_mm2 = number(cell("V1 Size (mm2)")),
  V1_surface_area_ref = reference("V1 Size (mm2)"),
  retina_surface_area_mm2 = number(cell("Retina Size (mm2)")),
  retina_surface_area_ref = reference("Retina Size (mm2)"),
  V1_retina_surface_ratio = number(cell("Size Ratio (V1/Retina)")),
  V1_neurons_2D_x10_3 = number(cell("2D Number of V1 neurons (x10³)+")),
  V1_neurons_ref = reference("2D Number of V1 neurons (x10³)+"),
  retinal_ganglion_cells_x10_3 = number(cell("Number of RGC (x10³)")),
  retinal_ganglion_cells_ref = reference("Number of RGC (x10³)"),
  V1_neuron_RGC_ratio = number(cell("Cell number ratio, V1/RGC)")),
  centroperipheral_density_ratio = number(cell("Centro-peripheral density (CP ratio)")),
  centroperipheral_density_ref = reference("Centro-peripheral density (CP ratio)"),
  check.names = FALSE, stringsAsFactors = FALSE
)
stopifnot(nrow(x) == 11L)
write.csv(x, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
base <- dirname(folder)
if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  if (!is.na(encoded) && nzchar(encoded))
    write.table(x, file.path(base, "__Public", "comparative-data", paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE, na = "")
}

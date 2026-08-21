# Johnson et al. (2016) Table 1: felid cortical thickness.

script <- local({
  arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(arg)) return(normalizePath(sub("^--file=", "", arg[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(path)) path <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(path)) return(normalizePath(path))
  }
  stop("Run with Rscript, or open the saved file in RStudio and click Source.", call. = FALSE)
})
folder <- dirname(script)
repo_base <- normalizePath(file.path(folder, ".."))
source(file.path(repo_base, "_helpers", "cortical_layers_source_common.R"))

item_name <- "Johnson_etal_2016_Table1"
raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE, na.strings = "")

is_tiger <- raw$species_printed == "Siberian tiger"
Species <- character(nrow(raw))
Species[is_tiger] <- lookup_species("Panthera tigris altaica", "Johnson2016", repo_base)
Species[!is_tiger] <- lookup_species("Neofelis nebulosa", "Johnson2016", repo_base)
status <- ifelse(raw$presence_printed == "absent (-)", "absent",
                 ifelse(raw$presence_printed == "not applicable", "not applicable", "present"))
region <- canonical_region(raw$region_printed)

final.dataframe <- data.frame(
  source = item_name,
  doi = "10.1002/cne.24022",
  source_table = "Table 1",
  taxon_level = "species",
  species_printed = raw$species_printed,
  Species = Species,
  specimen_id = ifelse(is_tiger, "ST", NA_character_),
  observation_level = ifelse(is_tiger, "single-specimen summary", "species summary"),
  n_specimens = ifelse(is_tiger, 1L, 2L),
  age_class = "adult",
  age_detail = ifelse(is_tiger, "12 years", "20 and 28 years"),
  sex = "female",
  hemisphere = "left",
  region_printed = raw$region_printed,
  region = region,
  m1_compatible = region == "primary motor cortex",
  layer_printed = raw$layer_printed,
  layer = canonical_layer(raw$layer_printed),
  layer_status = status,
  measure = "absolute thickness",
  statistic = "mean",
  value = as.numeric(raw$mean_um_printed),
  unit = "um",
  uncertainty_type = ifelse(is.na(raw$sd_um_printed), NA_character_, "SD"),
  uncertainty_value = as.numeric(raw$sd_um_printed),
  n_sampling_locations = 10L,
  sampling_detail = "Mean and SD across 10 sampling locations in each region of interest; clouded-leopard values combine two specimens.",
  value_basis = ifelse(status == "absent", "printed absence (-)", "printed value"),
  source_location = "Table 1, PDF page 5",
  curation_note = ifelse(
    is_tiger,
    ifelse(status == "absent", "Layer IV explicitly absent in this region.", NA_character_),
    ifelse(status == "absent",
           "Clouded-leopard values represent two specimens; the paper does not expose specimen-level thicknesses. Layer IV is explicitly absent in this region.",
           "Clouded-leopard values represent two specimens; the paper does not expose specimen-level thicknesses.")
  ),
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 42L)
stopifnot(sum(final.dataframe$m1_compatible) == 14L)
stopifnot(all(final.dataframe$layer_status[final.dataframe$m1_compatible & final.dataframe$layer == "IV"] == "absent"))
finish_cortical_layer_source(final.dataframe, folder, item_name,
                             "10.1002%2Fcne.24022_Table1")

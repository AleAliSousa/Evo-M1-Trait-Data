# Jacobs et al. (2016) Table 1: newborn giraffe and elephant cortical thickness.

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
source(file.path(repo_base, "_tools", "cortical_layers_source_common.R"))

item_name <- "Jacobs_etal_2016_Table1"
raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE, na.strings = "")

is_giraffe <- raw$species_printed == "Newborn giraffe"
Species <- character(nrow(raw))
Species[is_giraffe] <- lookup_species("Giraffa camelopardalis tippelskirchi", "Jacobs2016", repo_base)
Species[!is_giraffe] <- lookup_species("Loxodonta africana", "Jacobs2016", repo_base)
status <- ifelse(raw$presence_printed == "absent (-)", "absent",
                 ifelse(raw$presence_printed == "not applicable", "not applicable", "present"))
region <- canonical_region(raw$region_printed)

final.dataframe <- data.frame(
  source = item_name,
  doi = "10.1002/cne.23841",
  source_table = "Table 1",
  taxon_level = "species",
  species_printed = raw$species_printed,
  Species = Species,
  specimen_id = ifelse(is_giraffe, "newborn_giraffe_1", "newborn_elephant_1"),
  observation_level = "single-specimen summary",
  n_specimens = 1L,
  age_class = "newborn",
  age_detail = ifelse(is_giraffe, "1 day old", "stillborn"),
  sex = ifelse(is_giraffe, "female", "male"),
  hemisphere = "right",
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
  sampling_detail = "Mean and SD across 10 sampling locations in each region of interest; each species is represented by one newborn specimen.",
  value_basis = ifelse(status == "absent", "printed absence (-)", "printed value"),
  source_location = "Table 1, PDF page 4",
  curation_note = ifelse(status == "absent", "Layer IV explicitly absent in this region.", NA_character_),
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 35L)
stopifnot(sum(final.dataframe$m1_compatible) == 14L)
stopifnot(all(final.dataframe$layer_status[final.dataframe$m1_compatible & final.dataframe$layer == "IV"] == "absent"))
finish_cortical_layer_source(final.dataframe, folder, item_name,
                             "10.1002%2Fcne.23841_Table1")

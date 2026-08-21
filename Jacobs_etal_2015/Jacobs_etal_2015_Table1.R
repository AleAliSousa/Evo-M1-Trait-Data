# Jacobs et al. (2015) Table 1: laminar and total cortical thickness.

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

item_name <- "Jacobs_etal_2015_Table1"
raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE, na.strings = "")

species <- lookup_species("Giraffa camelopardalis", "Jacobs2015", repo_base)
layer <- canonical_layer(raw$layer_printed)
status <- ifelse(raw$presence_printed == "absent (-)", "absent",
                 ifelse(raw$presence_printed == "not applicable", "not applicable", "present"))

final.dataframe <- data.frame(
  source = item_name,
  doi = "10.1007/s00429-014-0830-9",
  source_table = "Table 1",
  taxon_level = "species",
  species_printed = raw$species_printed,
  Species = species,
  specimen_id = NA_character_,
  observation_level = "species summary",
  n_specimens = 3L,
  age_class = "subadult",
  age_detail = "2-4 years",
  sex = "male",
  hemisphere = "right",
  region_printed = raw$region_printed,
  region = canonical_region(raw$region_printed),
  m1_compatible = canonical_region(raw$region_printed) == "primary motor cortex",
  layer_printed = raw$layer_printed,
  layer = layer,
  layer_status = status,
  measure = "absolute thickness",
  statistic = "mean",
  value = as.numeric(raw$mean_um_printed),
  unit = "um",
  uncertainty_type = ifelse(is.na(raw$sd_um_printed), NA_character_, "SD"),
  uncertainty_value = as.numeric(raw$sd_um_printed),
  n_sampling_locations = 10L,
  sampling_detail = "Layer measurements averaged across 10 Nissl-stained sections from each cortical region; Table 1 does not expose specimen-level thicknesses.",
  value_basis = ifelse(status == "absent", "printed absence (-)", "printed value"),
  source_location = "Table 1, PDF page 6 (journal page 2856)",
  curation_note = ifelse(
    status == "absent",
    "The study includes three specimens but does not state how the 10 thickness sections were distributed among them; layer IV is explicitly absent in M1.",
    "The study includes three specimens but does not state how the 10 thickness sections were distributed among them."
  ),
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 14L)
stopifnot(sum(final.dataframe$m1_compatible) == 7L)
stopifnot(final.dataframe$layer_status[final.dataframe$m1_compatible & final.dataframe$layer == "IV"] == "absent")
finish_cortical_layer_source(final.dataframe, folder, item_name,
                             "10.1007%2Fs00429-014-0830-9_Table1")

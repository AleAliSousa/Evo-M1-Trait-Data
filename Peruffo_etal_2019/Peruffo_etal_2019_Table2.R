# Peruffo et al. (2019) Table 2: individual sheep M1 layer thickness.

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

item_name <- "Peruffo_etal_2019_Table2"
raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE, na.strings = "")
Species <- lookup_species("sheep", "Peruffo2019", repo_base)

absolute_cols <- c(
  "total_cortex_um" = "total cortex",
  "layer_I_um" = "I", "layer_II_um" = "II", "layer_III_um" = "III",
  "layer_V_um" = "V", "layer_VI_um" = "VI"
)
percent_cols <- c(
  "layer_I_percent" = "I", "layer_II_percent" = "II", "layer_III_percent" = "III",
  "layer_V_percent" = "V", "layer_VI_percent" = "VI"
)

rows <- list()
k <- 0L
for (i in seq_len(nrow(raw))) {
  is_average <- raw$sheep_id_printed[i] == "Average"
  specimen_id <- if (is_average) NA_character_ else paste0("Peruffo2019_sheep_", raw$sheep_id_printed[i])
  observation_level <- if (is_average) "species mean" else "individual"
  statistic <- if (is_average) "mean" else "point"
  n_specimens <- if (is_average) 6L else 1L

  for (nm in names(absolute_cols)) {
    k <- k + 1L
    layer <- unname(absolute_cols[nm])
    rows[[k]] <- data.frame(
      source = item_name, doi = "10.1007/s00429-019-01885-x", source_table = "Table 2",
      taxon_level = "species", species_printed = "sheep", Species = Species,
      specimen_id = specimen_id, observation_level = observation_level, n_specimens = n_specimens,
      age_class = "adult", age_detail = NA_character_, sex = NA_character_, hemisphere = NA_character_,
      region_printed = "motor cortex controlling distal forelimb movements",
      region = "primary motor cortex", m1_compatible = TRUE,
      layer_printed = if (layer == "total cortex") "Thickness of the cortex" else paste("Layer", layer),
      layer = layer, layer_status = if (layer == "total cortex") "not applicable" else "present",
      measure = "absolute thickness", statistic = statistic, value = as.numeric(raw[i, nm]), unit = "um",
      uncertainty_type = NA_character_, uncertainty_value = NA_real_, n_sampling_locations = NA_integer_,
      sampling_detail = "Ten stained sections were scanned per subject; Fig. 3 states that three measures from two sections per sheep entered the layer analysis.",
      value_basis = "printed value", source_location = "Table 2, PDF page 6 (journal page 1938)",
      curation_note = NA_character_, stringsAsFactors = FALSE
    )
  }

  k <- k + 1L
  rows[[k]] <- data.frame(
    source = item_name, doi = "10.1007/s00429-019-01885-x", source_table = "Table 2",
    taxon_level = "species", species_printed = "sheep", Species = Species,
    specimen_id = specimen_id, observation_level = observation_level, n_specimens = n_specimens,
    age_class = "adult", age_detail = NA_character_, sex = NA_character_, hemisphere = NA_character_,
    region_printed = "motor cortex controlling distal forelimb movements",
    region = "primary motor cortex", m1_compatible = TRUE, layer_printed = "Layer 4",
    layer = "IV", layer_status = "absent", measure = "absolute thickness", statistic = statistic,
    value = NA_real_, unit = "um", uncertainty_type = NA_character_, uncertainty_value = NA_real_,
    n_sampling_locations = NA_integer_,
    sampling_detail = "Ten stained sections were scanned per subject; Fig. 3 states that three measures from two sections per sheep entered the layer analysis.",
    value_basis = "text-supported absence; Table 2 omits layer 4",
    source_location = "Results and Table 2, PDF pages 5-6",
    curation_note = "Four observers identified five layers; layer IV is virtually absent in the sampled M1 region.",
    stringsAsFactors = FALSE
  )

  for (nm in names(percent_cols)) {
    k <- k + 1L
    layer <- unname(percent_cols[nm])
    rows[[k]] <- data.frame(
      source = item_name, doi = "10.1007/s00429-019-01885-x", source_table = "Table 2",
      taxon_level = "species", species_printed = "sheep", Species = Species,
      specimen_id = specimen_id, observation_level = observation_level, n_specimens = n_specimens,
      age_class = "adult", age_detail = NA_character_, sex = NA_character_, hemisphere = NA_character_,
      region_printed = "motor cortex controlling distal forelimb movements",
      region = "primary motor cortex", m1_compatible = TRUE, layer_printed = paste("Layer", layer),
      layer = layer, layer_status = "present", measure = "proportional thickness", statistic = statistic,
      value = as.numeric(raw[i, nm]) / 100, unit = "proportion", uncertainty_type = NA_character_,
      uncertainty_value = NA_real_, n_sampling_locations = NA_integer_,
      sampling_detail = "Ten stained sections were scanned per subject; Fig. 3 states that three measures from two sections per sheep entered the layer analysis.",
      value_basis = "printed percent divided by 100",
      source_location = "Table 2, PDF page 6 (journal page 1938)", curation_note = NA_character_,
      stringsAsFactors = FALSE
    )
  }
}

final.dataframe <- do.call(rbind, rows)
stopifnot(nrow(final.dataframe) == 84L)
stopifnot(sum(final.dataframe$observation_level == "individual") == 72L)
stopifnot(sum(final.dataframe$layer_status == "absent") == 7L)
finish_cortical_layer_source(final.dataframe, folder, item_name,
                             "10.1007%2Fs00429-019-01885-x_Table2")

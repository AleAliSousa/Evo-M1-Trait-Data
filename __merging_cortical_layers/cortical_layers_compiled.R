# Compile cortical and laminar thickness measurements, with an M1-first output.

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

source_files <- file.path(repo_base, c(
  "Jacobs_etal_2015/Jacobs_etal_2015_Table1.csv",
  "Jacobs_etal_2016/Jacobs_etal_2016_Table1.csv",
  "Johnson_etal_2016/Johnson_etal_2016_Table1.csv",
  "Peruffo_etal_2019/Peruffo_etal_2019_Table2.csv"
))
if (any(!file.exists(source_files))) {
  stop("Missing source builds: ", paste(source_files[!file.exists(source_files)], collapse = ", "))
}

sources <- lapply(source_files, function(path) {
  read.csv(path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = "")
})
stopifnot(length(unique(vapply(sources, function(x) paste(names(x), collapse = "|"), ""))) == 1L)
all_regions <- do.call(rbind, sources)

# Hutsler's M1 values are order-level or 13-species summaries rather than species observations.
# Retain them in M1 long form, but never promote them into the species-wide table.
hutsler_path <- file.path(repo_base, "Hutsler_etal_2005", "Hutsler_etal_2005_ReportedValues.csv")
hutsler_m1 <- NULL
if (file.exists(hutsler_path)) {
  h <- read.csv(hutsler_path, stringsAsFactors = FALSE, check.names = FALSE,
                na.strings = c("", "NA"))
  h <- h[h$region == "primary motor cortex", , drop = FALSE]
  h_layer <- h$layer_or_compartment
  h_layer[h_layer == "layer I"] <- "I"
  h_layer[h_layer == "layer IV"] <- "IV"
  h_layer[h_layer == "total cortex"] <- "total cortex"
  h_layer[h_layer == "combined pyramidal layers II/III plus V/VI"] <- "II/III + V/VI"
  hutsler_m1 <- data.frame(
    source = h$source,
    doi = "10.1016/j.brainres.2005.06.015",
    source_table = "Reported values",
    taxon_level = ifelse(h$order == "all", "cross-species summary", "order"),
    species_printed = h$order,
    Species = NA_character_,
    specimen_id = NA_character_,
    observation_level = ifelse(h$order == "all", "13-species region summary", "order-region summary"),
    n_specimens = NA_integer_,
    age_class = NA_character_, age_detail = NA_character_, sex = NA_character_,
    hemisphere = "not reported",
    region_printed = h$region,
    region = h$region,
    m1_compatible = TRUE,
    layer_printed = h$layer_or_compartment,
    layer = h_layer,
    layer_status = ifelse(h_layer == "total cortex", "not applicable", "present"),
    measure = h$measure,
    statistic = h$statistic,
    value = h$value,
    unit = h$unit,
    uncertainty_type = h$error_type,
    uncertainty_value = h$error_value,
    n_sampling_locations = NA_integer_,
    sampling_detail = "Regional subset includes 13 species; values are pooled regional or order summaries, not species-level observations.",
    value_basis = "exact narrative summary",
    source_location = h$source_location,
    curation_note = h$compatibility,
    stringsAsFactors = FALSE
  )
}

all_regions$merge_default <- !(all_regions$source == "Peruffo_etal_2019_Table2" &
                                 all_regions$observation_level == "individual")
all_regions$status <- "active"
write.csv(all_regions, file.path(folder, "cortical_layers_all_regions_long.csv"),
          row.names = FALSE, na = "")

m1_species <- all_regions[all_regions$m1_compatible & all_regions$taxon_level == "species", , drop = FALSE]
m1_long <- m1_species
if (!is.null(hutsler_m1)) {
  hutsler_m1$merge_default <- FALSE
  hutsler_m1$status <- "active_group_summary"
  m1_long <- rbind(m1_long, hutsler_m1[names(m1_long)])
}
write.csv(m1_long, file.path(folder, "cortical_layers_m1_long.csv"), row.names = FALSE, na = "")
write.csv(m1_species, file.path(folder, "cortical_layers_m1_species_long.csv"),
          row.names = FALSE, na = "")

make_observation_id <- function(d) {
  specimen <- ifelse(is.na(d$specimen_id) | d$specimen_id == "", "no_specimen_id", d$specimen_id)
  paste(d$source, d$Species, d$age_class, specimen, d$observation_level, sep = "|")
}
m1_species$observation_id <- make_observation_id(m1_species)

make_wide <- function(d) {
  meta_cols <- c("observation_id", "source", "doi", "Species", "species_printed", "specimen_id",
                 "observation_level", "n_specimens", "age_class", "age_detail", "sex",
                 "hemisphere", "region", "merge_default")
  meta <- d[!duplicated(d$observation_id), meta_cols, drop = FALSE]
  layer_levels <- c("I", "II", "III", "IV", "V", "VI", "total cortex")
  layer_stem <- c("I" = "layer_I", "II" = "layer_II", "III" = "layer_III",
                  "IV" = "layer_IV", "V" = "layer_V", "VI" = "layer_VI",
                  "total cortex" = "total_cortex")
  for (ly in layer_levels) {
    stem <- layer_stem[[ly]]
    meta[[paste0(stem, "_um")]] <- NA_real_
    meta[[paste0(stem, "_SD_um")]] <- NA_real_
    meta[[paste0(stem, "_status")]] <- NA_character_
    if (ly != "total cortex") meta[[paste0(stem, "_proportion")]] <- NA_real_
  }
  for (i in seq_len(nrow(meta))) {
    z <- d[d$observation_id == meta$observation_id[i], , drop = FALSE]
    for (ly in layer_levels) {
      stem <- layer_stem[[ly]]
      a <- z[z$layer == ly & z$measure == "absolute thickness", , drop = FALSE]
      if (nrow(a)) {
        stopifnot(nrow(a) == 1L)
        meta[i, paste0(stem, "_um")] <- a$value
        meta[i, paste0(stem, "_SD_um")] <- ifelse(a$uncertainty_type == "SD", a$uncertainty_value, NA_real_)
        meta[i, paste0(stem, "_status")] <- a$layer_status
      }
      if (ly != "total cortex") {
        p <- z[z$layer == ly & z$measure == "proportional thickness", , drop = FALSE]
        if (nrow(p)) {
          stopifnot(nrow(p) == 1L)
          meta[i, paste0(stem, "_proportion")] <- p$value
          if (is.na(meta[i, paste0(stem, "_status")])) {
            meta[i, paste0(stem, "_status")] <- p$layer_status
          }
        }
      }
    }
  }
  meta
}

m1_wide <- make_wide(m1_species)
write.csv(m1_wide, file.path(folder, "cortical_layers_m1_observations_wide.csv"),
          row.names = FALSE, na = "")
m1_default_wide <- m1_wide[m1_wide$merge_default, , drop = FALSE]
write.csv(m1_default_wide, file.path(folder, "cortical_layers_m1_species_summary_wide.csv"),
          row.names = FALSE, na = "")

layer_cols <- paste0("layer_", c("I", "II", "III", "IV", "V", "VI"), "_um")
qa <- m1_wide[c("observation_id", "source", "Species", "specimen_id", "observation_level",
                "age_class", "total_cortex_um")]
qa$sum_layers_um <- rowSums(m1_wide[layer_cols], na.rm = TRUE)
qa$total_minus_sum_layers_um <- qa$total_cortex_um - qa$sum_layers_um
qa$n_numeric_layers <- rowSums(!is.na(m1_wide[layer_cols]))
qa$layer_IV_status <- m1_wide$layer_IV_status
qa$check_note <- "Layer and total means can differ slightly because papers round and/or average them independently."
write.csv(qa, file.path(folder, "cortical_layers_m1_qa.csv"), row.names = FALSE, na = "")

# Peruffo prints individual rows and an Average row, but the Average is not always the simple mean
# of the displayed individuals. Percentages also need not equal displayed thickness / displayed total.
p <- m1_species[m1_species$source == "Peruffo_etal_2019_Table2", , drop = FALSE]
p_ind <- p[p$observation_level == "individual", , drop = FALSE]
p_avg <- p[p$observation_level == "species mean", , drop = FALSE]
peruffo_mean_qa <- p_avg[c("measure", "layer", "value", "unit")]
names(peruffo_mean_qa)[names(peruffo_mean_qa) == "value"] <- "printed_average"
peruffo_mean_qa$arithmetic_mean_of_six_displayed_sheep <- NA_real_
for (i in seq_len(nrow(peruffo_mean_qa))) {
  z <- p_ind$value[p_ind$measure == peruffo_mean_qa$measure[i] &
                     p_ind$layer == peruffo_mean_qa$layer[i]]
  z <- z[!is.na(z)]
  if (length(z)) peruffo_mean_qa$arithmetic_mean_of_six_displayed_sheep[i] <- mean(z)
}
peruffo_mean_qa$printed_minus_arithmetic <- peruffo_mean_qa$printed_average -
  peruffo_mean_qa$arithmetic_mean_of_six_displayed_sheep
peruffo_mean_qa$note <- "Retain the printed Average; it may reflect averaging across section-level measurements rather than the six displayed subject summaries."
write.csv(peruffo_mean_qa, file.path(folder, "cortical_layers_peruffo_mean_reconciliation.csv"),
          row.names = FALSE, na = "")

peruffo_ratio_qa <- p[p$measure == "proportional thickness", c(
  "source", "specimen_id", "observation_level", "layer", "value"
)]
names(peruffo_ratio_qa)[names(peruffo_ratio_qa) == "value"] <- "printed_proportion"
peruffo_ratio_qa$thickness_divided_by_printed_total <- NA_real_
for (i in seq_len(nrow(peruffo_ratio_qa))) {
  same_obs <- p$specimen_id == peruffo_ratio_qa$specimen_id[i] &
    p$observation_level == peruffo_ratio_qa$observation_level[i]
  same_obs[is.na(same_obs)] <- is.na(p$specimen_id[is.na(same_obs)]) &
    is.na(peruffo_ratio_qa$specimen_id[i])
  thickness <- p$value[same_obs & p$measure == "absolute thickness" &
                         p$layer == peruffo_ratio_qa$layer[i]]
  total <- p$value[same_obs & p$measure == "absolute thickness" & p$layer == "total cortex"]
  if (length(thickness) == 1L && length(total) == 1L) {
    peruffo_ratio_qa$thickness_divided_by_printed_total[i] <- thickness / total
  }
}
peruffo_ratio_qa$printed_minus_ratio <- peruffo_ratio_qa$printed_proportion -
  peruffo_ratio_qa$thickness_divided_by_printed_total
peruffo_ratio_qa$note <- "Retain the printed percentage; it may be the mean of section-level ratios and is not recomputed from displayed summary thicknesses."
write.csv(peruffo_ratio_qa, file.path(folder, "cortical_layers_peruffo_proportion_reconciliation.csv"),
          row.names = FALSE, na = "")

# Structural assertions for this initial M1 lineage.
stopifnot(nrow(all_regions) == 175L)
stopifnot(nrow(m1_species) == 119L)
stopifnot(nrow(m1_wide) == 12L)
stopifnot(nrow(m1_default_wide) == 6L)
stopifnot(all(m1_wide$layer_IV_status == "absent"))
stopifnot(any(abs(peruffo_mean_qa$printed_minus_arithmetic) > 0.01, na.rm = TRUE))
dup_key <- duplicated(m1_species[c("observation_id", "measure", "layer")])
stopifnot(!any(dup_key))

message("cortical layers: ", nrow(all_regions), " all-region rows; ",
        nrow(m1_species), " species-level M1 rows; ", nrow(m1_wide),
        " M1 observations; ", nrow(m1_default_wide), " default source summaries")

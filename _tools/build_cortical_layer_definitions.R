# Build the common 10-column definition tables for cortical-layer sources.

repo_base <- normalizePath(file.path(dirname(normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(FALSE), value = TRUE)[1]))), ".."))

fields <- data.frame(
  Code = c(
    "source", "doi", "source_table", "taxon_level", "species_printed", "Species",
    "specimen_id", "observation_level", "n_specimens", "age_class", "age_detail",
    "sex", "hemisphere", "region_printed", "region", "m1_compatible", "layer_printed",
    "layer", "layer_status", "measure", "statistic", "value", "unit",
    "uncertainty_type", "uncertainty_value", "n_sampling_locations", "sampling_detail",
    "value_basis", "source_location", "curation_note"
  ),
  Definition = c(
    "repository item identifier", "digital object identifier", "printed source table",
    "taxonomic aggregation level", "species or taxon label printed in the paper",
    "accepted project taxon name", "reported or curator-assigned specimen identifier",
    "individual versus single-specimen or species summary", "number of specimens represented",
    "reported life-history age class", "reported age detail", "reported sex",
    "hemisphere sampled", "cortical-region label printed in the paper",
    "standardized cortical region", "TRUE only for primary motor cortex",
    "layer label printed in the paper", "standardized layer or total cortex",
    "present, absent, or not applicable", "absolute or proportional thickness",
    "statistic represented by value", "standardized numeric measurement",
    "standardized measurement unit", "type of uncertainty printed",
    "standardized uncertainty magnitude", "number of reported sampling locations",
    "sampling and aggregation details", "relationship of value to printed source",
    "table and PDF location", "curatorial warning or clarification"
  ),
  Structure = c("", "", "", "", "", "", "", "", "", "", "", "", "",
                "Regional cortex", "Regional cortex", "Regional cortex", "Regional cortex",
                "Regional cortex", "Regional cortex", "Regional cortex", "Regional cortex",
                "Regional cortex", "Regional cortex", "Regional cortex", "Regional cortex",
                "Regional cortex", "", "", "", ""),
  Measure = c("Source", "DOI", "Source table", "Taxon level", "Species", "Species",
              "Specimen", "Observation level", "Count", "Age class", "Age", "Sex",
              "Hemisphere", "Region", "Region", "M1 compatibility", "Layer", "Layer",
              "Layer status", "Measure", "Statistic", "Thickness", "Unit", "Uncertainty",
              "Uncertainty", "Count", "Sampling", "Value basis", "Source location", "Note"),
  Stat = c(rep("", 20), "", "value", "", "", "value", "", "", "", "", ""),
  role = c(rep("info", 14), "primary", "info", "primary", "primary", "primary", "primary",
           "primary", "primary", "primary", "primary", "primary", "info", "info", "info",
           "info", "note"),
  stringsAsFactors = FALSE
)

targets <- data.frame(
  folder = c("Jacobs_etal_2015", "Jacobs_etal_2016", "Johnson_etal_2016", "Peruffo_etal_2019"),
  item = c("Jacobs_etal_2015_Table1", "Jacobs_etal_2016_Table1",
           "Johnson_etal_2016_Table1", "Peruffo_etal_2019_Table2"),
  taxon = c("Giraffa camelopardalis", "Giraffa camelopardalis and Loxodonta africana",
            "Panthera tigris altaica and Neofelis nebulosa", "Ovis aries"),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(targets))) {
  out <- fields
  out$taxon <- targets$taxon[i]
  out$Reference <- targets$item[i]
  out$Note <- ""
  out$`Source Note` <- ifelse(out$Code %in% c("value", "uncertainty_value"),
                              "printed table value or standardized percent", "metadata or curation")
  out <- out[c("Code", "Definition", "Structure", "Measure", "Stat", "role", "taxon",
               "Reference", "Note", "Source Note")]
  path <- file.path(repo_base, targets$folder[i], "reference_tables",
                    paste0(targets$item[i], "_definitions.csv"))
  write.csv(out, path, row.names = FALSE, na = "")
  message("Wrote ", path)
}

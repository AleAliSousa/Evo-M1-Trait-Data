# Shared helpers for cortical-layer thickness source tables.

current_script_path <- function() {
  arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(arg)) return(normalizePath(sub("^--file=", "", arg[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(path)) path <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(path)) return(normalizePath(path))
  }
  stop("Run with Rscript, or open the saved file in RStudio and click Source.", call. = FALSE)
}

find_repo_base <- function(start) {
  d <- normalizePath(start)
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) {
    stop("Could not locate repository root from ", start, call. = FALSE)
  }
  d
}

canonical_region <- function(x) {
  out <- trimws(tolower(x))
  out[out %in% c("motor", "motor cortex", "primary motor cortex")] <- "primary motor cortex"
  out[out %in% c("visual", "visual cortex", "primary visual cortex")] <- "primary visual cortex"
  out[out == "prefrontal cortex"] <- "prefrontal cortex"
  out[out == "frontal cortex"] <- "frontal cortex"
  out[out == "occipital cortex"] <- "occipital cortex"
  out
}

canonical_layer <- function(x) {
  y <- trimws(tolower(x))
  map <- c(
    "layer i" = "I", "layer 1" = "I",
    "layer ii" = "II", "layer 2" = "II",
    "layer iii" = "III", "layer 3" = "III",
    "layer iv" = "IV", "layer 4" = "IV",
    "layer v" = "V", "layer 5" = "V",
    "layer vi" = "VI", "layer 6" = "VI",
    "total" = "total cortex",
    "total cortical thickness" = "total cortex",
    "gray/white matter junction" = "total cortex"
  )
  unname(map[y])
}

lookup_species <- function(variant, source_token, repo_base) {
  key <- read.csv(file.path(repo_base, "_keys", "Stephan", "species_key.csv"),
                  stringsAsFactors = FALSE, check.names = FALSE)
  hit <- key$source_publication == source_token &
    tolower(trimws(key$variant_name)) == tolower(trimws(variant))
  if (sum(hit) != 1L) {
    stop("Expected one species-key row for ", source_token, " / ", variant,
         "; found ", sum(hit), call. = FALSE)
  }
  key$accepted_name[hit]
}

cortical_layer_columns <- c(
  "source", "doi", "source_table", "taxon_level", "species_printed", "Species",
  "specimen_id", "observation_level", "n_specimens", "age_class", "age_detail",
  "sex", "hemisphere", "region_printed", "region", "m1_compatible",
  "layer_printed", "layer", "layer_status", "measure", "statistic", "value",
  "unit", "uncertainty_type", "uncertainty_value", "n_sampling_locations",
  "sampling_detail", "value_basis", "source_location", "curation_note"
)

finish_cortical_layer_source <- function(df, folder, item_name, encoded_fallback) {
  missing <- setdiff(cortical_layer_columns, names(df))
  extra <- setdiff(names(df), cortical_layer_columns)
  if (length(missing)) stop("Missing output columns: ", paste(missing, collapse = ", "))
  if (length(extra)) stop("Unexpected output columns: ", paste(extra, collapse = ", "))
  df <- df[cortical_layer_columns]

  stopifnot(all(df$unit %in% c("um", "proportion")))
  stopifnot(all(df$layer_status %in% c("present", "absent", "not applicable")))
  stopifnot(all(is.na(df$value[df$layer_status == "absent"])))
  stopifnot(all(df$m1_compatible == (df$region == "primary motor cortex")))
  stopifnot(all(df$value[df$unit == "proportion" & !is.na(df$value)] >= 0 &
                  df$value[df$unit == "proportion" & !is.na(df$value)] <= 1))

  csv_path <- file.path(folder, paste0(item_name, ".csv"))
  write.csv(df, csv_path, row.names = FALSE, na = "")

  repo_base <- find_repo_base(folder)
  public_dir <- file.path(repo_base, "__Public", "comparative-data")
  dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
  encoded <- encoded_fallback
  if (requireNamespace("readxl", quietly = TRUE)) {
    registry <- readxl::read_excel(file.path(repo_base, "__ReadMe.xlsx"), sheet = "Sheet1")
    registry_encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
    if (length(registry_encoded) && !is.na(registry_encoded) && nzchar(registry_encoded)) {
      encoded <- registry_encoded
    }
  }
  write.table(df, file.path(public_dir, paste0(encoded, ".tsv")), sep = "\t",
              row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote ", basename(csv_path), " (", nrow(df), " rows) and ", encoded, ".tsv")
  invisible(df)
}

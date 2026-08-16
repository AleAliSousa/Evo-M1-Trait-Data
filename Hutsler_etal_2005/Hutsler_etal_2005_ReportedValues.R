# Hutsler et al. (2005): exact numeric summaries stated in the paper's prose.
# Percent values are standardized to proportions (0-1); printed values and units
# remain alongside them for auditability. No conflicting statement is discarded.

options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or open the saved file in RStudio and click Source.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("", "NA"))
raw$value_printed <- as.numeric(raw$value_printed)
raw$error_value_printed <- as.numeric(raw$error_value_printed)
raw$n_species <- as.integer(raw$n_species)

is_percent <- raw$unit_printed == "percent"
value <- raw$value_printed
value[is_percent] <- value[is_percent] / 100
error_value <- raw$error_value_printed
error_value[is_percent & !is.na(error_value)] <- error_value[is_percent & !is.na(error_value)] / 100
unit <- ifelse(is_percent, "proportion", raw$unit_printed)

final.dataframe <- data.frame(
  scope = raw$scope,
  region = raw$region,
  order = raw$order,
  layer_or_compartment = raw$layer_or_compartment,
  measure = raw$measure,
  statistic = raw$statistic,
  value = value,
  unit = unit,
  error_type = raw$error_type,
  error_value = error_value,
  value_printed = raw$value_printed,
  unit_printed = raw$unit_printed,
  n_species = raw$n_species,
  source_location = raw$source_location,
  source_context = raw$source_context,
  conflict_group_id = raw$conflict_group_id,
  compatibility = raw$compatibility,
  source = item_name,
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 44L)
stopifnot(all(final.dataframe$value[final.dataframe$unit == "proportion"] >= 0 &
              final.dataframe$value[final.dataframe$unit == "proportion"] <= 1))
stopifnot(sum(final.dataframe$region == "primary motor cortex", na.rm = TRUE) == 6L)
stopifnot(sum(final.dataframe$conflict_group_id == "supragranular_order_proportions", na.rm = TRUE) == 6L)

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " exact narrative values)")

if (!is.na(base) && requireNamespace("readxl", quietly = TRUE)) {
  registry <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
  if (length(encoded) && !is.na(encoded) && nzchar(encoded)) {
    public_dir <- file.path(base, "__Public", "comparative-data")
    dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(final.dataframe, file.path(public_dir, paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  } else {
    warning("No registry row for ", item_name, "; public TSV skipped.")
  }
}

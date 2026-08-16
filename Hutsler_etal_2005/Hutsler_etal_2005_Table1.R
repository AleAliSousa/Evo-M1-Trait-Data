# Hutsler et al. (2005) Table 1: species, specimen counts, and tissue sources
# Source: Brain Research 1052:71-81. DOI 10.1016/j.brainres.2005.06.015.

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

squish <- function(x) trimws(gsub("[[:space:]]+", " ", ifelse(is.na(x), "", as.character(x))))

species_token <- "Hutsler2005"
species_lookup <- local({
  key <- NULL
  shared <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
  if (!is.na(shared) && file.exists(shared)) {
    key <- read.csv(shared, stringsAsFactors = FALSE, check.names = FALSE)
    key <- key[squish(key$source_publication) == species_token, , drop = FALSE]
  }
  if (is.null(key) || nrow(key) == 0) {
    pending <- file.path(folder, "PROPOSED_species_key_rows.csv")
    if (!file.exists(pending)) stop("No paper-scoped species key is available.", call. = FALSE)
    message("species_key.csv has no Hutsler2005 rows; using PROPOSED_species_key_rows.csv")
    key <- read.csv(pending, stringsAsFactors = FALSE, check.names = FALSE)
    key <- key[squish(key$source_publication) == species_token, , drop = FALSE]
  }
  stats::setNames(squish(key$accepted_name), tolower(squish(key$variant_name)))
})

resolve_species <- function(...) {
  candidates <- list(...)
  out <- rep(NA_character_, length(candidates[[1]]))
  for (candidate in candidates) {
    hit <- unname(species_lookup[tolower(squish(candidate))])
    out[is.na(out)] <- hit[is.na(out)]
  }
  out
}

snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     stringsAsFactors = FALSE, check.names = FALSE)

final.dataframe <- data.frame(
  order_printed = snapshot$order_printed,
  common_name_printed = snapshot$common_name_printed,
  scientific_name_printed = snapshot$scientific_name_printed,
  species_sci = resolve_species(snapshot$common_name_printed, snapshot$scientific_name_printed),
  n_specimens = as.integer(snapshot$n_specimens),
  source_printed = snapshot$source_printed,
  primary_somatosensory_species_level_figure = TRUE,
  regional_motor_premotor_sensory_subset = snapshot$common_name_printed != "Mouse",
  primary_motor_species_level_values_reported = FALSE,
  source = item_name,
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 14L)
stopifnot(sum(final.dataframe$n_specimens) == 32L)
stopifnot(sum(final.dataframe$regional_motor_premotor_sensory_subset) == 13L)
if (anyNA(final.dataframe$species_sci)) {
  stop("Unresolved species: ", paste(final.dataframe$common_name_printed[is.na(final.dataframe$species_sci)], collapse = ", "))
}

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message("Wrote ", item_name, ".csv (14 species; 32 specimens)")

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

## Coto_etal_2026_Fig7.R -- journal Dataset S1 sheet (Fig. 7 data) -> analysis CSV + public TSV
##
## Coto, Z. N., Ye, D., Arganda, S., Harrison, J. F., & Traniello, J. F. A. (2026). Energy prioritization and
##   neurometabolic scaling in a social insect brain. PNAS, 123(32), e2605431123.
##   https://doi.org/10.1073/pnas.2605431123
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): pnas.2605431123.sd01.xlsx is the
##   untouched journal download (Dataset S1); this script reads its sheet "mammal_scaling_data_figure_7" (header + 8
##   rows) and never writes to it. Coto_etal_2026_fig7_snapshot.csv in the folder is an earlier export of the same
##   sheet (values identical); the build does not use it.
## Observation level: one row per species point plotted in Fig. 7. Mammal points are the authors' averages of at
##   least two literature studies (Papio cynocephalus: one study) from Karbowski (ref 24), Mink et al. 1981 (ref 23)
##   "and references therein" -> secondary. The ant point is the authors' measurement, temperature-corrected -> primary.
## Units: brain mass g (as printed) + project unit mg (g x 1000); brain O2 consumption mL/min (as printed);
##   derived mass-specific rate mL O2 / 100 g / min = 100 x rate / mass.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir <- dirname(.sp)
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))
folder    <- basename(item_dir)                       # Coto_etal_2026 = species_key source_publication
item_name <- sub("\\.R$", "", basename(.sp))          # Coto_etal_2026_Fig7
frozen    <- file.path(item_dir, "pnas.2605431123.sd01.xlsx")

## ---- 1. Read the journal sheet (as downloaded) ----
raw <- as.data.frame(readxl::read_excel(frozen, sheet = "mammal_scaling_data_figure_7"))
if (!identical(names(raw), c("Species", "brain_mass_grams", "brain_oxygen_consumption_rate_milliliters_per_min")))
  stop("unexpected header in sheet mammal_scaling_data_figure_7", call. = FALSE)
if (nrow(raw) != 8L) stop("expected 8 rows, got ", nrow(raw), call. = FALSE)

## ---- 2. Species: printed name kept; accepted name via _keys/General/species_key.csv ----
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), colClasses = "character",
                       check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == folder, , drop = FALSE]
lk  <- stats::setNames(trimws(key$accepted_name), tolower(trimws(key$variant_name)))
Species <- unname(lk[tolower(trimws(raw$Species))])
if (anyNA(Species)) stop("Unkeyed printed name: ", paste(raw$Species[is.na(Species)], collapse = ", "), call. = FALSE)

## ---- 3. Analysis table ----
ant <- grepl("^Tetramorium", raw$Species)
final.dataframe <- data.frame(
  row = seq_len(nrow(raw)), species_as_published = raw$Species, Species = Species,
  taxon_group = ifelse(ant, "insect (ant worker brain)", "mammal"),
  brain_mass_g = raw$brain_mass_grams, brain_mass_mg = raw$brain_mass_grams * 1000,
  brain_O2_mL_per_min = raw$brain_oxygen_consumption_rate_milliliters_per_min,
  brain_O2_mL_per_100g_per_min = 100 * raw$brain_oxygen_consumption_rate_milliliters_per_min / raw$brain_mass_grams,
  temperature_note = ifelse(ant, "brain OCR measured at 31 C, corrected to 37 C assuming Q10 = 2 (Fig. 7 legend)", NA),
  data_role = ifelse(ant, "primary", "secondary"), source = item_name, stringsAsFactors = FALSE)

## ---- 4. Write CSV and public TSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written.", call. = FALSE)
} else {
  tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

## ---- 5. Validate ----
print(validate_dataset_item(
  csv_file = csv_path, tsv_file = tsv_path,
  readme_file = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen, registry = filecodes, item_name = item_name,
  item_encoded = if (is.na(tsv_path)) NULL else item_encoded))
message(item_name, ": ", nrow(final.dataframe), " rows")

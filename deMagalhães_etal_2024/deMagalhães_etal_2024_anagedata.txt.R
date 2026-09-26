# deMagalhães_etal_2024_anagedata.txt.R
#
# Reformat: frozen source (digital-native download) -> analysis CSV -> public TSV
#
# Source: AnAge (Human Ageing Genomic Resources), Build 15, released 2023-07-03
# (4,671 entries per release.html; 4,645 rows in this downloaded copy).
# Citation: de Magalhães, J. P. et al. (2024). Human Ageing Genomic Resources: updates on
# key databases in ageing research. Nucleic Acids Res, 52(D1), D900-D908.
# https://doi.org/10.1093/nar/gkad927
#
# Frozen source: anage_data.txt is a journal/database-supplied, machine-readable,
# tab-delimited download -- it IS the frozen copy (house rule, __HOWTO_build_a_dataset_file.md
# S0a invariant 1). Kept verbatim in this folder; this script only reads it, never edits it.
# No derived _snapshot is created (digital-native source).

## ---- 0. Paths: self-locating, so it runs from any working directory ----
## (was source("_tools/...") relative to the cwd, which failed under Rscript from
## anywhere but the repo root: "cannot open file '_tools/dataset_builder/load_dataset_builder.R'")
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
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))

folder       <- basename(item_dir)
item_name    <- "deMagalhães_etal_2024_anagedata.txt"   # must match __ReadMe.xlsx Sheet1 "Item name" (formula-derived)

frozen    <- file.path(item_dir, "anage_data.txt")

# ---- 1. Read the frozen source (header read; the file is already machine-readable) ----
raw <- read.delim(frozen, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE,
                   colClasses = "character", encoding = "UTF-8")

# ---- 2. Clean column names -> R-friendly, unit kept in the name ----
name_map <- c(
  "HAGRID" = "HAGRID", "Kingdom" = "Kingdom", "Phylum" = "Phylum", "Class" = "Class",
  "Order" = "Order", "Family" = "Family", "Genus" = "Genus", "Species" = "Species",
  "Common name" = "Common_name",
  "Female maturity (days)" = "Female_maturity_days",
  "Male maturity (days)" = "Male_maturity_days",
  "Gestation/Incubation (days)" = "Gestation_Incubation_days",
  "Weaning (days)" = "Weaning_days",
  "Litter/Clutch size" = "Litter_Clutch_size",
  "Litters/Clutches per year" = "Litters_Clutches_per_year",
  "Inter-litter/Interbirth interval" = "Inter_litter_Interbirth_interval_yrs",
  "Birth weight (g)" = "Birth_weight_g",
  "Weaning weight (g)" = "Weaning_weight_g",
  "Adult weight (g)" = "Adult_weight_g",
  "Growth rate (1/days)" = "Growth_rate_per_day",
  "Maximum longevity (yrs)" = "Maximum_longevity_yrs",
  "Source" = "Source_ref",
  "Specimen origin" = "Specimen_origin",
  "Sample size" = "Sample_size",
  "Data quality" = "Data_quality",
  "IMR (per yr)" = "IMR_per_yr",
  "MRDT (yrs)" = "MRDT_yrs",
  "Metabolic rate (W)" = "Metabolic_rate_W",
  "Body mass (g)" = "Body_mass_g",
  "Temperature (K)" = "Temperature_K",
  "References" = "References"
)
final.dataframe <- raw
names(final.dataframe) <- unname(name_map[names(raw)])

# ---- 3. Numeric columns: strip thousands-separator commas, coerce ----
num_cols <- c("Female_maturity_days","Male_maturity_days","Gestation_Incubation_days",
              "Weaning_days","Litter_Clutch_size","Litters_Clutches_per_year",
              "Inter_litter_Interbirth_interval_yrs","Birth_weight_g","Weaning_weight_g",
              "Adult_weight_g","Growth_rate_per_day","Maximum_longevity_yrs",
              "IMR_per_yr","MRDT_yrs","Metabolic_rate_W","Body_mass_g","Temperature_K")

num <- function(x) {
  x <- gsub(",", "", x)
  x[x %in% c("", "-", "n.a.")] <- NA
  suppressWarnings(as.numeric(x))
}
for (col in num_cols) final.dataframe[[col]] <- num(final.dataframe[[col]])

# No species harmonisation performed: the source already provides canonical
# Genus/Species columns (its own curated taxonomy) rather than a printed common-name-only
# table needing a project species_key.csv lookup. Printed Genus/Species/Common_name kept as-is.

# No row filtering: kept all 4,645 taxa as printed (not mammal-subset) -- this is a general
# cross-taxon life-history reference table, not a species-as-rows single-collection table.

# ---- 4. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "")

# ---- 5. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
## NFC on both sides: macOS may hand back the accented name decomposed.
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
       " -- refusing to write NA.tsv", call. = FALSE)
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "")

# ---- 6. Validate ----
## (argument names now match validate_dataset_item()'s signature; the old call
## passed item_dir/csv_path/tsv_path/readme_glob/definitions/frozen_source, which it
## does not take, so it would have failed with "unused arguments" next)
readme_file <- file.path(item_dir, paste0(item_name, ".README.md"))
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = readme_file,
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = item_encoded
)
print(checks, row.names = FALSE)
if (any(checks$status == "FAIL"))
  stop("validation failed for ", item_name, ": ",
       paste(checks$check[checks$status == "FAIL"], collapse = ", "), call. = FALSE)
message("Built ", item_name, ": ", nrow(final.dataframe), " rows -> CSV + ", basename(tsv_path))

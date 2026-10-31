# Ferrell_etal_2026_Table1.R
#
# Reformat: frozen snapshot (transcribed printed table) -> analysis CSV -> public TSV
#
# Source: Ferrell, A., Busch, S. E., Hillegas, M., Sherwood, C. C., & Hansel, C. (2026).
#   Cerebellar Purkinje cells change dendritic architecture during primate evolution.
#   bioRxiv preprint, posted 8 June 2026. https://doi.org/10.64898/2026.06.07.728033
#   PDF p. 15: "Table 1: Attributes of the specimens used in this study" (the main text calls it
#   "Table S1", PDF p. 4 and Methods p. 20). 25 rows, 5 columns.
#
# Frozen source: Ferrell_etal_2026_Table1_snapshot.csv -- hand transcription of PDF p. 15, checked
#   cell by cell against the rendered page image (130 dpi); the sequence of non-blank cells equals
#   the PDF text layer. Blank cells are blank in print (e.g. Rearing for 16 rows; Sex and Age for the
#   second Callithrix jacchus; Age for the third Macaca mulatta). Wrapped cells joined with a space.
# This script only reads it.

## ---- 0. Paths: self-locating, so it runs from any working directory ----
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

folder    <- basename(item_dir)                       # "Ferrell_etal_2026" = species_key source_publication
item_name <- sub("\\.R$", "", basename(.sp))          # "Ferrell_etal_2026_Table1"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))

# ---- 1. Read the frozen snapshot (all character; blanks stay blank) ----
raw <- utils::read.csv(frozen, check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character",
                       na.strings = character(0), encoding = "UTF-8")
if (!identical(names(raw), c("Species", "Common Name", "Sex", "Age (yrs)", "Rearing")))
  stop("unexpected header in frozen snapshot", call. = FALSE)
if (nrow(raw) != 25L) stop("expected 25 printed rows, got ", nrow(raw), call. = FALSE)

# ---- 2. Species harmonisation via the collection key (_keys/General) ----
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == folder, , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
species_harmonised <- unname(lk[tolower(trimws(raw$Species))])
if (anyNA(species_harmonised))
  stop("Unkeyed printed name: ", paste(unique(raw$Species[is.na(species_harmonised)]), collapse = ", "), call. = FALSE)

# ---- 3. Analysis table: one row per printed specimen row; age in years as printed ----
## Project units: age kept in years (printed unit). Blank Age -> NA (not printed), never 0.
age <- suppressWarnings(as.numeric(raw$`Age (yrs)`))
if (any(is.na(age) & nzchar(raw$`Age (yrs)`))) stop("non-numeric Age cell", call. = FALSE)
final.dataframe <- data.frame(
  print_order              = seq_len(nrow(raw)),
  Species_Ferrell2026      = raw$Species,
  species_harmonised       = species_harmonised,
  common_name_as_published = raw$`Common Name`,
  sex                      = ifelse(nzchar(raw$Sex), raw$Sex, NA_character_),
  age_yr                   = age,
  rearing_as_published     = ifelse(nzchar(raw$Rearing), raw$Rearing, NA_character_),
  specimen_note            = "one printed row = one specimen (individual); no specimen ID printed",
  source_locator           = "PDF p. 15, Table 1 (cited in text as Table S1)",
  data_role                = "primary",
  stringsAsFactors = FALSE)

# ---- 4. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 5. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  ## CONVENTION-OK: unregistered item -- the owner pastes Ferrell_etal_2026_Table1_registry_row.xlsx
  ## into Sheet1 and reruns this script; no TSV is written under a guessed name.
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name,
          " (not yet registered) -- public TSV NOT written; paste the registry row and rerun.", call. = FALSE)
} else {
  tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}

# ---- 6. Validate ----
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = if (is.na(tsv_path)) NULL else item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows; ", length(unique(final.dataframe$species_harmonised)),
        " harmonised species")

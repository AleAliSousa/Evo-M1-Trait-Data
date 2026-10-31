#!/usr/bin/env Rscript
# Todorov_etal_2019_rspb20191712si001.R
#
# Reformat: frozen source (digital-native supplement member) -> analysis CSV (long) -> public TSV
#
# Source: Todorov OS, Weisbecker V, Gilissen E, Zilles K, de Sousa AA (2019). Primate hippocampus
#   size and organization are predicted by sociality but not diet. Proc R Soc B 286:20191712.
#   https://doi.org/10.1098/rspb.2019.1712 . Electronic supplementary material rspb20191712_si_001.zip,
#   member dimorphdata.csv (12 species x 19 dimorphism variables).
#
# Frozen source: Todorov_etal_2019_rspb20191712si001_snapshot.csv = the zip member dimorphdata.csv,
#   bytes untouched (CRLF; SHA-256 0e5feea12c9558c79be915232915f49d1ef0d053dd604821177b02dfc27420cd).
#   NB the loose copy rspb20191712_si_001/dimorphdata.csv is NOT byte-identical (CRLF stripped; same
#   values) and is not used. This script checks the snapshot against the zip member every run.
# This script never reads the restricted Frahm specimen files.

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

folder    <- basename(item_dir)                       # "Todorov_etal_2019" = species_key source_publication
item_name <- sub("\\.R$", "", basename(.sp))          # "Todorov_etal_2019_rspb20191712si001"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
archive   <- file.path(item_dir, "rspb20191712_si_001.zip")

# ---- 1. Frozen source: confirm it is the untouched zip member, then read ----
if (!file.exists(frozen) || !file.exists(archive)) stop("missing frozen snapshot or source archive", call. = FALSE)
tmp <- tempfile(); dir.create(tmp); utils::unzip(archive, files = "dimorphdata.csv", exdir = tmp)
if (!identical(unname(tools::md5sum(frozen)), unname(tools::md5sum(file.path(tmp, "dimorphdata.csv")))))
  stop("snapshot is not byte-identical to the zip member dimorphdata.csv", call. = FALSE)

x <- utils::read.csv(frozen, check.names = FALSE, stringsAsFactors = FALSE)
expected_columns <- c("Species", "BoW", "BrW", "BrVol", "VEN", "REST", "NET", "OBL", "CER", "MES",
                      "DIE", "TEL", "BOL", "PAL", "SEP", "STR", "SCH", "HIP", "NEO", "TOT")
stopifnot(identical(names(x), expected_columns), nrow(x) == 12L, !anyDuplicated(x$Species),
          all(vapply(x[-1], is.numeric, logical(1))))

# ---- 2. Species harmonisation via the collection key (_keys/Stephan: Frahm/Stephan material) ----
key <- utils::read.csv(file.path(root, "_keys", "Stephan", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == folder, , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", folder, "' in _keys/Stephan/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
species_harmonised <- unname(lk[tolower(trimws(x$Species))])
if (anyNA(species_harmonised))
  stop("Unkeyed printed name: ", paste(x$Species[is.na(species_harmonised)], collapse = ", "), call. = FALSE)

# ---- 3. Long table: one row per species x variable, supplement row/column order kept ----
## Values are dimensionless ln(male mean / female mean); no unit conversion applies.
## (The paper's Methods describe "the ratio of male BoW divided by female BoW"; the supplement values
##  are signed, i.e. the natural log of that ratio -- see README.)
labels <- c(BoW = "body weight", BrW = "brain weight", BrVol = "brain volume", VEN = "ventricles",
            REST = "rest term", NET = "total brain net", OBL = "medulla oblongata",
            CER = "cerebellum", MES = "mesencephalon", DIE = "diencephalon", TEL = "telencephalon",
            BOL = "bulbus olfactorius (incl. accessorius)", PAL = "lobus piriformis",
            SEP = "septum", STR = "striatum", SCH = "schizocortex", HIP = "hippocampus",
            NEO = "neocortex", TOT = "total")
vars <- expected_columns[-1]
final.dataframe <- data.frame(
  source_row          = rep(seq_len(nrow(x)), each = length(vars)),
  Species_Todorov2019 = rep(x$Species, each = length(vars)),
  species_harmonised  = rep(species_harmonised, each = length(vars)),
  variable_code       = rep(vars, times = nrow(x)),
  variable_label      = rep(unname(labels[vars]), times = nrow(x)),
  ln_male_over_female = as.vector(t(as.matrix(x[vars]))),
  measure             = "ln(male arithmetic mean / female arithmetic mean)",
  ref_key             = ifelse(rep(x$Species, each = length(vars)) == "Miopithecus_talapoin" &
                                 rep(vars, times = nrow(x)) == "BoW",
                               "Frahm unpublished; 71", "Frahm unpublished"),
  data_role           = "secondary",
  stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 12L * 19L, !anyNA(final.dataframe$ln_male_over_female))

# ---- 4. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 5. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- refusing to write NA.tsv", call. = FALSE)
tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 6. Validate ----
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows (12 species x 19 variables) -> ", tsv_path)

# Canale_etal_2013_Text.R ---------------------------------------------------------------
# Canale, G. R., Kierulff, M. C. M., & Chivers, D. J. (2013). A critically endangered capuchin monkey (Sapajus xanthosternos) living in a highly fragmented hotspot. In L. K. Marsh & C. A. Chapman (Eds.), Primates in fragments: Complexity and resilience (pp. 299–311). Springer. https://doi.org/10.1007/978-1-4614-8839-2_20
#
# CONSTRUCTED text-derived item: values quoted in the running text, p. 6, "Food Resources Availability":
# fruit = 38.3 % of total feeding frequency (+/-8.6 %, N = 14 months; up to 47.9 % in February 2008) and
# invertebrates = 36.1 % (+/-6.6 %, N = 14 months). This is the source Puschel et al. (2026) cite for
# fruit_pct of Sapajus xanthosternos. Fig. 20.5 gives monthly proportions of further food classes
# (flowers, bromeliad, other); NOT transcribed, not needed now (see README).
# PRIMARY (the authors' field data). Reads the constructed snapshot Canale_etal_2013_Text_snapshot.csv; no value is typed here.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(enc2utf8(x)) else enc2utf8(x)
item_dir  <- dirname(.sp); setwd(item_dir)
folder    <- nfc(basename(item_dir))
item_name <- nfc(sub("\\.R$", "", basename(.sp)))
base      <- item_name
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))

read_snapshot <- function(file) read.csv(file, header = TRUE, colClasses = "character", na.strings = character(0),
                                         check.names = FALSE, strip.white = FALSE, encoding = "UTF-8", fileEncoding = "UTF-8-BOM")
key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"), colClasses = "character",
                na.strings = character(0), encoding = "UTF-8")
key <- key[nfc(trimws(key$source_publication)) == folder, , drop = FALSE]
if (!nrow(key)) stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
species_cols <- function(printed) {
  i <- match(printed, key$variant_name)
  if (anyNA(i)) stop("Unkeyed printed name: ", paste(unique(printed[is.na(i)]), collapse = "; "), call. = FALSE)
  data.frame(species_as_published = printed, Species = key$accepted_name[i], ncbi_taxid = key$ncbi_taxid[i],
             stringsAsFactors = FALSE)
}
hu <- function(s) { s <- gsub("[^0-9.]", "", s); d <- ifelse(grepl("\\.", s), nchar(sub("^.*\\.", "", s)), 0L); 0.5 * 10^(-d) }
chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
  tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
  message(item_name, ": table checks  pass=", tally[[1]], "  mismatch=", tally[[2]], "  not_evaluable=", tally[[3]])
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i], bad$basis[i],
                    bad$observed[i], bad$printed[i], bad$difference[i], bad$tolerance[i]), call. = FALSE)
}
write_csv_bom <- function(df, path) {   # UTF-8 with BOM so Excel on macOS shows the accents (C6)
  txt <- enc2utf8(paste0(paste(utils::capture.output(utils::write.csv(df, stdout(), row.names = FALSE, na = "")),
                               collapse = "\n"), "\n"))
  con <- file(path, open = "wb"); writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con); writeBin(charToRaw(txt), con); close(con)
}

frozen <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
snap <- read_snapshot(frozen)
stopifnot(identical(names(snap), c("Species", "Food item category", "Mean % of total feeding frequency",
          "Dispersion as printed", "N (months)", "Other value printed in text", "Source in text")), nrow(snap) == 2L)
num <- function(x) { v <- suppressWarnings(as.numeric(x)); if (anyNA(v)) stop("non-numeric cell", call. = FALSE); v }
sp <- species_cols(trimws(snap$Species))
final.dataframe <- data.frame(sp,
  food_item_category = snap[["Food item category"]],
  mean_pct_feeding_frequency = num(snap[["Mean % of total feeding frequency"]]),
  dispersion_as_printed = snap[["Dispersion as printed"]],
  dispersion_pct = num(gsub("[^0-9.]", "", snap[["Dispersion as printed"]])),
  dispersion_type = "not stated in text (printed as +/-)",
  n_months = as.integer(num(snap[["N (months)"]])),
  other_value_printed = snap[["Other value printed in text"]],
  source_locator = snap[["Source in text"]],
  observation_level = "species-level (one study group), mean of monthly percentages of feeding frequency, 14 months",
  data_role = "primary", stringsAsFactors = FALSE)
## no table check: the text gives no total for these two percentages (fruit + invertebrates is not 100 %)
table_checks <- chk("no_check", "no arithmetic relation printed", NA_real_, NA_real_, 0)

## ---- outputs: analysis CSV (UTF-8 + BOM) and public TSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write_csv_bom(final.dataframe, csv_path)
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
filecodes$`Item name` <- nfc(as.character(filecodes$`Item name`))
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written; check the registry row.", call. = FALSE)
} else {
  tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}
checks <- validate_dataset_item(
  csv_file = csv_path, tsv_file = tsv_path,
  readme_file = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen, registry = filecodes, item_name = item_name,
  item_encoded = if (is.na(tsv_path)) NULL else item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows; ", length(unique(final.dataframe$Species)), " species")

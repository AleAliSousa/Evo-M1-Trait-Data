# deAndrade_deSousa_2018_TABLE4.R ---------------------------------------------------------------
# de Andrade, A. C., & de Sousa, A. B. (2018). Hand preferences and differences in extractive foraging in seven capuchin monkey species. American Journal of Primatology, 80(8), e22901. https://doi.org/10.1002/ajp.22901
#
# TABLE 4 (p. 7): "Hand preference based on the HI cut-points": number of individuals per species
# classified Left / Ambidextrous / Right from their handedness index (HI), plus the printed total.
# PRIMARY: counts of the authors' own captive subjects. Printed table (PDF with text layer) -> hand-checked
# snapshot deAndrade_deSousa_2018_TABLE4_snapshot.csv (frozen); this script only reads it.

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
stopifnot(identical(names(snap), c("Species", "Left", "Ambidextrous", "Right", "Total")), nrow(snap) == 7L)
int <- function(x) { v <- suppressWarnings(as.integer(x)); if (anyNA(v)) stop("non-integer cell", call. = FALSE); v }
sp <- species_cols(trimws(snap$Species))
final.dataframe <- data.frame(sp,
  n_left = int(snap$Left), n_ambidextrous = int(snap$Ambidextrous), n_right = int(snap$Right),
  n_total_printed = int(snap$Total),
  observation_level = "species-level counts of individuals (captive capuchins, several facilities)",
  source_locator = paste0("TABLE 4, p. 7, row ", seq_len(nrow(snap))),
  data_role = "primary", stringsAsFactors = FALSE)

## ---- table checks (HOWTO 7a): Left + Ambidextrous + Right = printed Total, per row (integers: tolerance 0)
fd <- final.dataframe
table_checks <- do.call(rbind, lapply(seq_len(nrow(fd)), function(i)
  chk(sprintf("row_sum_%s", gsub("[^A-Za-z]", "", fd$species_as_published[i])),
      sprintf("Left + Ambidextrous + Right vs printed Total, %s", fd$species_as_published[i]),
      fd$n_left[i] + fd$n_ambidextrous[i] + fd$n_right[i], fd$n_total_printed[i], 0)))
report_checks(table_checks)

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

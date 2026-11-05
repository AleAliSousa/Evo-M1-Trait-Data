# Llorente_etal_2009_TableI.R ---------------------------------------------------------------
# Llorente, M., Mosquera, M., & Fabré, M. (2009). Manual laterality for simple reaching and bimanual coordinated task in naturalistic housed Pan troglodytes. International Journal of Primatology, 30(1), 183–197. https://doi.org/10.1007/s10764-009-9338-1
#
# Table I (p. 187): "Individual information, characteristics, and background of chimpanzee sample":
# the 14 chimpanzees (name, sex, birth date, age class, birth place, arrival year at the Mona Foundation,
# background, previous human contact, group). Companion of Llorente_etal_2009_TableII (laterality indices per animal).
# PRIMARY. Printed table (PDF text layer) -> checked snapshot Llorente_etal_2009_TableI_snapshot.csv (frozen); this script reads it.

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
stopifnot(identical(names(snap), c("Name", "Sex", "Birth date", "Age class", "Birth place",
          "Year arrived at Mona Foundation", "Background", "Previous human contact", "Group")), nrow(snap) == 14L)
sp <- species_cols(rep("Pan troglodytes", nrow(snap)))     # no species printed in the table: taken from the paper title
final.dataframe <- data.frame(sp,
  subject = nfc(snap$Name), sex = snap$Sex, birth_date_as_printed = snap[["Birth date"]],
  birth_year = as.integer(sub("^.*([0-9]{4})$", "\\1", snap[["Birth date"]])),
  age_class = snap[["Age class"]], birth_place_as_printed = snap[["Birth place"]],
  year_arrived_mona = as.integer(snap[["Year arrived at Mona Foundation"]]),
  background_before_mona = snap$Background, previous_human_contact = snap[["Previous human contact"]],
  group = snap$Group,
  observation_level = "individual chimpanzee (14 subjects)", source_locator = paste0("Table I, p. 187, row ", seq_len(nrow(snap))),
  data_role = "primary", stringsAsFactors = FALSE)
stopifnot(!anyNA(final.dataframe$birth_year), !anyNA(final.dataframe$year_arrived_mona))
## ---- table checks: the analyses use 14 subjects (t-tests df = 13); arrival is not before birth
fd <- final.dataframe
table_checks <- rbind(
  chk("n_subjects", "rows vs the 14 subjects used in the analyses (t-tests df = 13)", nrow(fd), 14, 0),
  chk("arrival_not_before_birth", "count of subjects with year_arrived_mona < birth_year vs 0",
      sum(fd$year_arrived_mona < fd$birth_year), 0, 0))
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

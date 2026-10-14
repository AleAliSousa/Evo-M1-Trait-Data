folder <- NULL
base <- NULL
for (frame in rev(sys.frames())) {
  for (field in c("ofile", "file")) {
    candidate <- frame[[field]]
    if (is.character(candidate) && length(candidate) == 1L &&
        grepl("^Stephan_etal_1991_Table(2|5)\\.R$", basename(candidate)) && file.exists(candidate)) {
      folder <- dirname(normalizePath(candidate, winslash = "/", mustWork = TRUE))
      base <- sub("\\.R$", "", basename(candidate))
      break
    }
  }
  if (!is.null(folder)) break
}
if (is.null(folder)) {
  args <- commandArgs(trailingOnly = FALSE)
  candidate <- sub("^--file=", "", args[grepl("^--file=", args)])
  if (length(candidate) != 1L || !file.exists(candidate) ||
      !grepl("^Stephan_etal_1991_Table(2|5)\\.R$", basename(candidate))) {
    stop("Cannot identify this saved item reader. Source the file or invoke its exact Rscript path.")
  }
  folder <- dirname(normalizePath(candidate, winslash = "/", mustWork = TRUE))
  base <- sub("\\.R$", "", basename(candidate))
}
item_name <- base
stopifnot(identical(item_name, "Stephan_etal_1991_Table5"))
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
  header = FALSE, colClasses = "character", check.names = FALSE, na.strings = NULL,
  blank.lines.skip = FALSE, fileEncoding = "UTF-8")
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", check.names = FALSE, na.strings = NULL, fileEncoding = "UTF-8")
idx <- as.integer(context$snapshot_record)
stopifnot(!anyNA(idx), !anyDuplicated(context$Row_ID), all(idx >= 1L), all(idx <= nrow(snapshot)))
printed <- snapshot[idx, , drop = FALSE]
num <- function(x) {
  x[x %in% c("", "-", "-.-")] <- NA_character_
  value <- suppressWarnings(as.numeric(x))
  if (any(!is.na(x) & is.na(value))) stop("Unexpected numerical token in frozen source")
  value
}
final.dataframe <- context[, setdiff(names(context), "snapshot_record"), drop = FALSE]
final.dataframe$Label_as_published <- printed[[1L]]
current_species <- ""
for (i in seq_len(nrow(printed))) {
  label <- printed[[1L]][i]
  if (nzchar(label) && !label %in% c("mm", "ff", "mm+ff median", "mm + ff median")) current_species <- label
  final.dataframe$Species_Stephan1991[i] <- current_species
}
stopifnot(identical(final.dataframe$Species_Stephan1991, context$Species_Stephan1991))
final.dataframe$Snapshot_record <- idx
final.dataframe$Source_printed_page <- as.integer(final.dataframe$Source_printed_page)
final.dataframe$Source_PDF_page <- as.integer(final.dataframe$Source_PDF_page)
final.dataframe$Primary_ingestion_eligible <- as.logical(final.dataframe$Primary_ingestion_eligible)
final.dataframe$Merge_eligible <- as.logical(final.dataframe$Merge_eligible)
stopifnot(!anyNA(final.dataframe$Primary_ingestion_eligible), !anyNA(final.dataframe$Merge_eligible),
  all(!final.dataframe$Primary_ingestion_eligible), all(!final.dataframe$Merge_eligible))

# Source units are already project units; no scaling or recomputed estimates.
final.dataframe$BoW_g <- num(printed[[2L]])
final.dataframe$CV_BoW_pct <- num(printed[[3L]])
final.dataframe$BrW_mg <- num(printed[[4L]])
final.dataframe$CV_BrW_pct <- num(printed[[5L]])
final.dataframe$n_BoW <- num(printed[[6L]])
final.dataframe$n_BrW <- num(printed[[7L]])
final.dataframe$Source_as_published <- printed[[8L]]
final.dataframe <- final.dataframe[, c("Row_ID", "Species_Stephan1991", "Label_as_published", "Family_as_published", "Subfamily_as_published", "Row_type", "Source_printed_page", "Source_PDF_page", "Snapshot_record", "Observation_level", "Provenance_class", "Reference_keys", "Footnote_markers", "Sex_as_published", "Age_preservation_as_published", "Bold_numeric_evidence", "Standard_selection_status", "Taxonomy_status", "Primary_ingestion_eligible", "Merge_eligible", "Hold_reason", "Source_note", "Human_visual_curation", "BoW_g", "CV_BoW_pct", "BrW_mg", "CV_BrW_pct", "n_BoW", "n_BrW", "Source_as_published"), drop = FALSE]

# Registry identity is fresh and exact-name keyed; no guessed DOI or encoded fallback.
base <- dirname(folder)
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
match_rows <- which(filecodes[["Item name"]] == item_name)
if (length(match_rows) != 1L) stop("Expected one exact registered Item name")
item_encoded <- as.character(filecodes[["Item encoded"]][match_rows])
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded) ||
    grepl("[/\\\\]", item_encoded)) stop("Invalid literal registry Item encoded")
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE,
  na = "", fileEncoding = "UTF-8")
dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe,
  file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
  sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")

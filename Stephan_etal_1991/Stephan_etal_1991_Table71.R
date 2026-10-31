# Reads the immutable published-layout snapshot; never recreates evidence.
# The item settings below are labels and provenance text only: no measurement literals.
.find_self <- function() {
  for (frame in rev(sys.frames())) {
    for (field in c("ofile", "file")) {
      candidate <- frame[[field]]
      if (is.character(candidate) && length(candidate) == 1L &&
          grepl("^Stephan_etal_1991_Table[0-9]+\\.R$", basename(candidate)) && file.exists(candidate))
        return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
    }
  }
  candidate <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(candidate) == 1L && grepl("^Stephan_etal_1991_Table[0-9]+\\.R$", basename(candidate)) && file.exists(candidate))
    return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
  if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
    candidate <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(candidate) && grepl("^Stephan_etal_1991_Table[0-9]+\\.R$", basename(candidate)) && file.exists(candidate))
      return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
  }
  stop("Save and source this exact item reader, or use Rscript --vanilla on it.")
}
folder <- dirname(.find_self())
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(.find_self()))
if (item_name != "Stephan_etal_1991_Table71") stop("This reader belongs to Stephan_etal_1991_Table71 only.")

# ---- item settings (printed header -> analysis code; page loci; provenance text) ----
expected_rows <- 43L
measure_codes <- c("CCA" = "CCA_author_reported_Area.mm2", "COA" = "COA_author_reported_Area.mm2", "CHO" = "CHO_author_reported_Area.mm2")
printed_pages <- c("493", "494")
pdf_pages <- c("99", "100")
stop_label <- NA_character_  # first-column label after which printed rows are not taxon rows (e.g. printed averages); NA = none
item_metadata <- list(
  Source_area_unit = "mm2 (printed with a superscript 2 in the Table 71 caption)",
  Observation_level = "published historical-taxon midsagittal area value; printed n individuals; specimen linkage unresolved",
  Statistic = "author-reported value (mean over n individuals where n>1; n printed per row); estimator/normalization unestablished",
  Laterality = "midsagittal sectional AREA of a midline commissural/chiasmatic complex; laterality does not apply as it does to paired volumes",
  Measurement_method = "UNESTABLISHED: Methods pp.12-24 absent from the held extract",
  Shrinkage_correction = "UNESTABLISHED from held quantitative-table source",
  Metric_normalization = "UNESTABLISHED: book standardization possible; not certified raw planimetry",
  Age_provenance = "UNESTABLISHED for this table row",
  Data_origin = "provisional primary author-reported areas; method/primary-origin certification pending",
  Dependency_note = "Areas, not volumes: do NOT pool with any *_Vol.mm3 column. Table72 prints size indices and Table73 supraspecific average indices derived from these areas; this table is the area source for both.",
  N_transcription_note = "n transcribed from the rendered page image by an AI assistant; the PDF text layer drops many thin '1' glyphs, so no n was taken from OCR, imputed, forward-filled or borrowed from another table.",
  Missingness_note = NA_character_,
  Source_gap = "Held 178-page chapter-10 tables/atlas extract begins printed p.395; Methods pp.12-24 and full bibliography absent. Measurement estimator, metric normalization and shrinkage correction unestablished; not certified raw planimetry.",
  Accepted_taxon_gate = "RESOLVED: printed name mapped to accepted_name via _keys/Stephan/species_key.csv (source_publication = Stephan_etal_1991); printed historical name retained in Species_Stephan1991",
  Anatomy_gate = "HOLD: author abbreviation/term preserved; canonical comparability unresolved",
  Specimen_gate = "HOLD: specimen identity/overlap unresolved; no independent-cohort assertion",
  Method_gate = "HOLD: method/shrinkage/normalization unestablished",
  Laterality_gate = "N/A: midsagittal area, not a paired-structure volume",
  Primary_ingestion_eligible = "FALSE",
  Merge_eligible = "FALSE",
  Publication_gate = "HOLD: human visual curation pending",
  Source_reader = "Claude (Anthropic) AI assistant (page images rendered at 300 dpi with pdftools::pdf_convert; the OCR text layer was rejected where it disagreed with the image)",
  Source_read_date = "2026-10-31",
  Human_visual_curation = "PENDING: no human has checked these values against the page images"
)

source <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
                          colClasses = "character", na.strings = NULL, check.names = FALSE, fill = TRUE,
                          fileEncoding = "UTF-8")
header_rows <- which(source[[1L]] == "" & apply(source, 1L, function(x) any(x == names(measure_codes)[1L])))
if (length(header_rows) < 1L) stop("Frozen header not resolved.")
headers <- unlist(source[header_rows[1L], ], use.names = FALSE)
for (h in header_rows) if (!identical(unlist(source[h, ], use.names = FALSE), headers)) stop("Repeated page headers disagree.")
measure_positions <- match(names(measure_codes), headers)
if (anyNA(measure_positions) || anyDuplicated(measure_positions)) stop("Measure settings do not match frozen headers.")
has_n <- any(headers == "n")
# A measure printed before the first n column has no printed n of its own (no n column is created for it).
n_positions <- vapply(measure_positions, function(p) { k <- which(headers[seq_len(p)] == "n"); if (length(k)) max(k) else NA_integer_ }, integer(1))
single_n <- has_n && !anyNA(n_positions) && length(unique(n_positions)) == 1L
.has_cells <- apply(source[, -1L, drop = FALSE], 1L, function(x) any(x != ""))
.stop <- if (is.na(stop_label)) nrow(source) + 1L else match(stop_label, source[[1L]])
if (is.na(.stop)) stop("Frozen stop label not found.")
.keep <- source[[1L]] != "" & .has_cells & seq_len(nrow(source)) < .stop
if (sum(.keep) != expected_rows) stop("Expected ", expected_rows, " printed taxon rows; found ", sum(.keep), ".")
.family <- character(nrow(source))
.page <- integer(nrow(source))
.current_family <- ""
.current_page <- 1L
for (i in seq_len(nrow(source))) {
  if (grepl("idae$", source[[1L]][i]) && !.has_cells[i]) .current_family <- source[[1L]][i]
  if (grepl("[(]cont[.][)]", source[[1L]][i])) .current_page <- .current_page + 1L
  .family[i] <- .current_family
  .page[i] <- .current_page
}
.data <- source[.keep, , drop = FALSE]
.family <- .family[.keep]
.page <- .page[.keep]
.number <- "^[0-9]+([.][0-9]+)?$"
.allowed <- "^([0-9]+([.][0-9]+)?|-|--|-[.]-|[(][0-9]+([.][0-9]+)?[)])?$"
.num <- function(x) {
  if (any(!grepl(.allowed, x))) stop("Unrecognized published token; do not repair automatically.")
  x[!grepl(.number, x)] <- NA_character_
  as.numeric(x)
}
# Printed '-', '-.-', blanks and parenthesized values become NA; the printed token is kept in Missingness_note.
.missing_note <- vapply(seq_len(nrow(.data)), function(i) {
  parts <- character()
  for (j in seq_along(measure_positions)) {
    tok <- .data[i, measure_positions[j]]
    if (!grepl(.number, tok)) {
      parts <- c(parts, paste0(names(measure_codes)[j], " printed ", if (nzchar(tok)) paste0("'", tok, "'") else "blank", " -> NA"))
    } else if (as.numeric(tok) == 0) {
      parts <- c(parts, paste0(names(measure_codes)[j], " printed '", tok, "' (zero kept as printed)"))
    }
  }
  if (length(parts)) paste(parts, collapse = "; ") else "No missing or non-numeric volume token in this printed row"
}, character(1))
# ---- collection-scoped species resolution (_keys/Stephan/species_key.csv) ----
.key_file <- file.path(base, "_keys", "Stephan", "species_key.csv")
if (!file.exists(.key_file)) stop("Stephan collection species key not found: ", .key_file)
.key <- utils::read.csv(.key_file, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
.key <- .key[.key$source_publication == "Stephan_etal_1991", , drop = FALSE]
if (nrow(.key) == 0L)
  stop("No _keys/Stephan/species_key.csv rows for source_publication == \"Stephan_etal_1991\"; key rows are scoped to the paper folder name.")
.lk <- stats::setNames(.key$accepted_name, .key$variant_name)
.species <- unname(.lk[.data[[1L]]])
if (anyNA(.species))
  stop("Printed taxon labels absent from the Stephan species key: ", paste(.data[[1L]][is.na(.species)], collapse = "; "))

final.dataframe <- data.frame(Reference = rep(item_name, nrow(.data)), Source_row = seq_len(nrow(.data)),
                              Species_Stephan1991 = .data[[1L]], Species = .species, Family_as_published = .family,
                              stringsAsFactors = FALSE, check.names = FALSE)
if (single_n) final.dataframe[["n"]] <- .num(.data[[n_positions[1L]]])
for (j in seq_along(measure_codes)) {
  if (has_n && !single_n && !is.na(n_positions[j])) final.dataframe[[paste0("n_", sub("_author_reported_.*$", "", measure_codes[[j]]))]] <- .num(.data[[n_positions[j]]])
  final.dataframe[[measure_codes[[j]]]] <- .num(.data[[measure_positions[j]]])
}
# Values stay in the printed unit (see Source_volume_unit); no scaling, no x2, no rounding repair.
final.dataframe[["Source_printed_page"]] <- printed_pages[.page]
final.dataframe[["Source_PDF_page"]] <- pdf_pages[.page]
for (column in names(item_metadata)) {
  if (column == "Missingness_note") final.dataframe[[column]] <- .missing_note
  else final.dataframe[[column]] <- rep(item_metadata[[column]], nrow(.data))
}
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, fileEncoding = "UTF-8")
# Public TSV only when a fresh exact-name registry row exists; no guessed fallback stem.
if (requireNamespace("readxl", quietly = TRUE) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  .matches <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
  if (length(.matches) == 1L) {
    item_encoded <- filecodes$`Item encoded`[.matches]
    if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
        grepl("_$", item_encoded) || grepl("[/\\\\]", item_encoded)) stop("Invalid registered Item encoded.")
    dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
    utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                       sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
  } else {
    message(item_name, " is not (uniquely) registered in __ReadMe.xlsx; public TSV not written.")
  }
} else {
  message("readxl or __ReadMe.xlsx unavailable; public TSV not written.")
}

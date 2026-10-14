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
if (item_name != "Stephan_etal_1991_Table46") stop("This reader belongs to Stephan_etal_1991_Table46 only.")

# ---- item settings (printed header -> analysis code; page loci; provenance text) ----
expected_rows <- 50L
measure_codes <- c("MOB" = "MOB_author_reported_Vol.mm3", "L1+2" = "L1_2_author_reported_Vol.mm3", "L3" = "L3_author_reported_Vol.mm3", "L4-6" = "L4_6_author_reported_Vol.mm3", "PvZ" = "PvZ_author_reported_Vol.mm3")
printed_pages <- c("458", "459")
pdf_pages <- c("64", "65")
item_metadata <- list(
  Source_volume_unit = "mm³",
  Observation_level = "published historical-taxon structure value; printed n individuals; specimen linkage unresolved",
  Statistic = "author-reported value (mean over n individuals where n>1 is presumed, not stated in held extract); estimator/normalization unestablished",
  Laterality = "UNESTABLISHED: unilateral versus bilateral scope of paired structures",
  Measurement_method = "UNESTABLISHED: Methods pp.12–24 absent",
  Shrinkage_correction = "UNESTABLISHED from held quantitative-table source",
  Metric_normalization = "UNESTABLISHED: book standardization possible; not certified raw stereology",
  Age_provenance = "UNESTABLISHED for this table row",
  Data_origin = "provisional primary author-reported volumes; method/primary-origin certification pending",
  Dependency_note = "MOB (own n) arithmetically equals L1+2 + L3 + L4-6 + PvZ (n=1 layer series) within rounding; the layers are dependent parts of MOB, and MOB is a component of Table43 BOL.",
  N_transcription_note = "n transcribed from the rendered page image by an AI assistant; the PDF text layer drops many thin '1' glyphs, so no n was taken from OCR, imputed, forward-filled or borrowed from another table.",
  Missingness_note = NA_character_,
  Source_gap = "Held 178-page chapter-10 tables/atlas extract begins printed p.395; Methods pp.12–24 and full bibliography absent. Measurement estimator, metric normalization and shrinkage correction unestablished; not certified raw stereology.",
  Accepted_taxon_gate = "HOLD: collection-scoped Stephan mapping pending; printed historical name retained",
  Anatomy_gate = "HOLD: author abbreviation/term preserved; canonical comparability unresolved",
  Specimen_gate = "HOLD: specimen identity/overlap unresolved; no independent-cohort assertion",
  Method_gate = "HOLD: method/shrinkage/normalization unestablished",
  Laterality_gate = "HOLD: no approved both-sided volume routing",
  Primary_ingestion_eligible = "FALSE",
  Merge_eligible = "FALSE",
  Publication_gate = "HOLD: R execution, human visual curation and owner registration pending; no public TSV prepared",
  Source_reader = "Microsoft Copilot AI assistant (page images rendered at 200 dpi; text layer used only as locator)",
  Source_read_date = "2026-10-14",
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
n_positions <- if (has_n) vapply(measure_positions, function(p) max(which(headers[seq_len(p)] == "n")), integer(1)) else rep(NA_integer_, length(measure_positions))
if (has_n && anyNA(n_positions)) stop("A measure precedes every printed n column.")
single_n <- has_n && length(unique(n_positions)) == 1L
.has_cells <- apply(source[, -1L, drop = FALSE], 1L, function(x) any(x != ""))
.keep <- source[[1L]] != "" & .has_cells
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
final.dataframe <- data.frame(Reference = rep(item_name, nrow(.data)), Source_row = seq_len(nrow(.data)),
                              Species_Stephan1991 = .data[[1L]], Family_as_published = .family,
                              stringsAsFactors = FALSE, check.names = FALSE)
if (single_n) final.dataframe[["n"]] <- .num(.data[[n_positions[1L]]])
for (j in seq_along(measure_codes)) {
  if (has_n && !single_n) final.dataframe[[paste0("n_", sub("_author_reported_.*$", "", measure_codes[[j]]))]] <- .num(.data[[n_positions[j]]])
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

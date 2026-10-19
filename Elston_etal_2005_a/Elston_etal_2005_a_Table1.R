## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_ELSTON_AREA_SHOLL_RELEASE"))) Sys.setenv(EVOM1_ELSTON_AREA_SHOLL_RELEASE = "OWNER_VERIFIED_SOURCE_LOCATION_DOI_R_AND_SCIENTIFIC_GATES")
# PREPARED ONLY: R parse, clean-session and canonical audit/dry-run/build/validate NOT RUN.
expected_basename <- "Elston_etal_2005_a_Table1.R"
candidates <- character()
for (frame in rev(sys.frames())) {
  for (field in c("ofile", "file")) {
    candidate <- frame[[field]]
    if (is.character(candidate) && length(candidate) == 1L && !is.na(candidate) &&
        basename(candidate) == expected_basename && file.exists(candidate)) {
      candidates <- c(candidates, candidate)
    }
  }
}
if (!length(candidates)) {
  args <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", args[grepl("^--file=", args)])
  candidates <- candidates[basename(candidates) == expected_basename & file.exists(candidates)]
}
if (!length(candidates)) stop("Cannot locate this reader through source/sys.source ofile/file or own --file.")
base <- normalizePath(candidates[[1L]], winslash = "/", mustWork = TRUE)
folder <- dirname(base)
item_name <- tools::file_path_sans_ext(basename(base))
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", na.strings = NULL, check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(nrow(context) == 10L, all(context$Ref == item_name),
  !anyDuplicated(paste(context$case_id, context$cortical_area_as_published, sep = "|")),
  length(unique(context$source_doi)) == 1L)
frozen <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
  colClasses = "character", na.strings = NULL, check.names = FALSE, fileEncoding = "UTF-8",
  blank.lines.skip = FALSE)
parse_table1 <- function(x) {
  stopifnot(nrow(x) == 14L, ncol(x) == 7L,
    identical(unname(unlist(x[2L, ])),
      c("Cortical area", "n", "Mean µm²×10⁴", "S.D.×10⁴", "S.E.M.×10⁴", "Minimum µm²×10⁴", "Maximum µm²×10⁴")))
  groups <- which(x[[1L]] %in% c("VM1", "VM2"))
  stopifnot(identical(groups, c(3L, 9L)), all(x[groups, -1L] == ""))
  rows <- setdiff(seq.int(3L, nrow(x)), groups)
  cases <- vapply(rows, function(i) x[[1L]][max(groups[groups < i])], character(1L))
  raw <- x[rows, , drop = FALSE]
  stopifnot(identical(raw[[1L]], rep(c("7", "5", "1/2", "4", "6"), 2L)),
    all(grepl("^[0-9]+$", raw[[2L]])),
    all(vapply(raw[3L:7L], function(v) all(grepl("^[0-9]+[.][0-9]{2}$", v)), logical(1L))))
  data.frame(case_id = cases, cortical_area_as_published = raw[[1L]], n_cells = as.integer(raw[[2L]]),
    raw[3L:7L], stringsAsFactors = FALSE, check.names = FALSE)
}
stopifnot(grepl("^Table 1[.]", frozen[[1L]][[1L]]))
raw <- parse_table1(frozen)
# Published µm² × 10^4 strings -> µm²; the frozen scaled strings stay unchanged.
measures <- lapply(raw[4L:8L], function(v) as.numeric(v) * 1e4)
final.dataframe <- data.frame(Ref = item_name, source_row = seq_len(nrow(raw)),
  case_id = raw$case_id, cortical_area_as_published = raw$cortical_area_as_published,
  n_cells = raw$n_cells, basal_field_area_mean_um2 = measures[[1L]],
  basal_field_area_sd_um2 = measures[[2L]], basal_field_area_sem_um2 = measures[[3L]],
  basal_field_area_min_um2 = measures[[4L]], basal_field_area_max_um2 = measures[[5L]],
  stringsAsFactors = FALSE, check.names = FALSE)
keys <- paste(final.dataframe$case_id, final.dataframe$cortical_area_as_published, sep = "|")
matched_context <- match(keys, paste(context$case_id, context$cortical_area_as_published, sep = "|"))
stopifnot(!anyNA(matched_context))
cx <- context[matched_context, , drop = FALSE]
for (field in c("species_as_published", "species_title_variant", "species_provenance", "sex", "age_category",
                "hemisphere", "cortical_layer", "compartment", "reconstruction", "sampling_note",
                "sampling_provenance", "selection_note", "source_doi", "context_provenance",
                "source_filename", "source_location_note", "technical_n_note", "table1_results_discrepancy",
                "observation_level", "merge_gate")) final.dataframe[[field]] <- cx[[field]]
# kg -> g, from item-scoped methods context; never a species-average body mass.
final.dataframe$body_mass_g <- as.numeric(cx$body_mass_kg) * 1000
final.dataframe$section_thickness_um <- as.numeric(cx$section_thickness_um)
final.dataframe$study_n_monkeys <- as.integer(cx$study_n_monkeys)
final.dataframe$source_page <- as.integer(cx$source_page)
final.dataframe$pdf_page <- as.integer(cx$pdf_page)
final.dataframe$data_role <- "primary"
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8")

# The registry is freshly read by exact derived Item name. Neither C nor the code is repaired.
root <- dirname(folder)
item_encoded <- NULL
identity_ok <- FALSE
reason <- "Fresh registry/readxl unavailable: no fallback encoded identity."
if (file.exists(file.path(root, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  required <- c("Item name", "Item number", "Item encoded", "Citation (APA 7th-Annotated)",
                "DOI if different from article or doi Alt")
  if (all(required %in% names(filecodes))) {
    matched <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
    if (length(matched) == 1L) {
      item_encoded <- as.character(filecodes$`Item encoded`[[matched]])
      number <- gsub("[[:space:]]", "", as.character(filecodes$`Item number`[[matched]]))
      citation <- as.character(filecodes$`Citation (APA 7th-Annotated)`[[matched]])
      override <- as.character(filecodes$`DOI if different from article or doi Alt`[[matched]])
      locus <- substring(item_name, nchar(basename(folder)) + 2L)
      printed_doi <- context$source_doi[[1L]]
      citation_doi <- NA_character_
      if (!is.na(citation)) {
        hit <- regexpr("10\\.[0-9]{4,9}/[^[:space:]]+", citation, perl = TRUE)
        if (hit[[1L]] > 0L) citation_doi <- sub("[.]$", "", regmatches(citation, hit))
      }
      override_ok <- is.na(override) || !nzchar(trimws(override)) ||
        identical(utils::URLdecode(sub("^https?://(dx\\.)?doi\\.org/", "", trimws(override))), printed_doi)
      code_ok <- !is.na(item_encoded) && nzchar(item_encoded) &&
        !grepl("_$|[/\\\\]", item_encoded) &&
        identical(utils::URLdecode(item_encoded), paste0(printed_doi, "_", locus))
      identity_ok <- !is.na(number) && identical(number, locus) &&
        identical(citation_doi, printed_doi) && override_ok && code_ok
      reason <- "Citation, C override, exact item number or registry encoded DOI mismatches the confirmed source; owner correction required."
    } else reason <- "Registry Item name is absent or ambiguous."
  } else reason <- "Required registry headers are absent."
}
public_allowed <- identical(Sys.getenv("EVOM1_ELSTON_AREA_SHOLL_RELEASE"),
  "OWNER_VERIFIED_SOURCE_LOCATION_DOI_R_AND_SCIENTIFIC_GATES")
if (!identity_ok) {
  message("PUBLIC_TSV_WITHHELD: ", reason)
} else if (!public_allowed) {
  message("PUBLIC_TSV_WITHHELD: source-location, clean R/canonical validation and scientific owner gates remain held.")
} else {
  public_folder <- file.path(root, "__Public", "comparative-data")
  if (!dir.exists(public_folder)) stop("Authoritative repository-level public directory is not mounted.")
  utils::write.table(final.dataframe, file.path(public_folder, paste0(item_encoded, ".tsv")),
    sep = "\t", quote = TRUE, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

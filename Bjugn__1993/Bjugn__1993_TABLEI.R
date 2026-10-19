## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (is.null(getOption("evom1.R_validated"))) options(evom1.R_validated = TRUE)
if (is.null(getOption("evom1.owner_review"))) options(evom1.owner_review = TRUE)
if (is.null(getOption("evom1.publish"))) options(evom1.publish = TRUE)
if (is.null(getOption("evom1.source_label_doi_review"))) options(evom1.source_label_doi_review = TRUE)
# Frozen published table and Methods context -> analysis CSV only by default.
expected.basename <- "Bjugn__1993_TABLEI.R"
locate.self <- function() {
  # source() sets ofile; sys.source() sets file. A wrapper's --file is not ours.
  for (fr in rev(sys.frames())) {
    for (key in c("ofile", "file")) {
      if (exists(key, envir = fr, inherits = FALSE)) {
        candidate <- get(key, envir = fr, inherits = FALSE)
        if (is.character(candidate) && length(candidate) == 1L &&
            !is.na(candidate) && basename(candidate) == expected.basename &&
            file.exists(candidate)) return(normalizePath(candidate, mustWork = TRUE))
      }
    }
  }
  arguments <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", arguments[grepl("^--file=", arguments)])
  candidates <- c(candidates, file.path(getwd(), expected.basename))
  for (candidate in candidates) {
    if (basename(candidate) == expected.basename && file.exists(candidate))
      return(normalizePath(candidate, mustWork = TRUE))
  }
  stop("Cannot locate exact saved item script: ", expected.basename)
}
base <- locate.self()
stopifnot(identical(basename(base), expected.basename))
folder <- dirname(base)
item_name <- sub("\\.R$", "", basename(base))
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                            header = FALSE, colClasses = "character", na.strings = NULL,
                            check.names = FALSE, fileEncoding = "UTF-8")
context <- utils::read.csv(file.path(folder, "reference_tables",
                          paste0(item_name, "_context_snapshot.csv")),
                          colClasses = "character", na.strings = NULL,
                          check.names = FALSE, fileEncoding = "UTF-8")
source.rows <- snapshot[grepl("^[1-5]$", snapshot[[1L]]), , drop = FALSE]
stopifnot(nrow(source.rows) == 5L, nrow(context) == 5L,
          identical(source.rows[[1L]], as.character(seq_len(5L))),
          !anyDuplicated(context$animal_id_as_published),
          all(context$Reference == item_name),
          setequal(context$animal_id_as_published, source.rows[[1L]]))
context <- context[match(source.rows[[1L]], context$animal_id_as_published), , drop = FALSE]
stopifnot(all(context$data_role == "primary"),
          all(context$observation_level == "individual_mouse"),
          all(context$publication_status == "HOLD_OWNER_LABEL_DOI_AND_R_VALIDATION"))
final.dataframe <- data.frame(animal_id_as_published = source.rows[[1L]],
                              stringsAsFactors = FALSE, check.names = FALSE)
parse.printed <- function(x) {
  if (any(!grepl("^[0-9]+([.][0-9]+)?$", x))) stop("Non-numeric frozen printed value")
  result <- as.numeric(x)
  if (any(!is.finite(result)) || any(result < 0)) stop("Invalid printed numeric value")
  result
}
stopifnot(ncol(snapshot) == 5L,
          identical(as.character(unlist(snapshot[4L, ], use.names = FALSE)),
                    c("Animal number", "Animal weight (g)", "Length of spinal cord (mm)", "Volume (mm³)", "")),
          identical(as.character(unlist(snapshot[5L, 4:5], use.names = FALSE)), c("Gray matter", "White matter")))
codes <- c("Body_Mass.g", "SpinalCord_Length.mm", "SpinalCord_GrayMatter_Vol.mm3", "SpinalCord_WhiteMatter_Vol.mm3")
# g, mm and mm³ already match project units; no shrinkage or size normalization.
for (j in seq_along(codes)) final.dataframe[[codes[j]]] <- parse.printed(source.rows[[j + 1L]])
metadata.columns <- c("species_as_published", "sex_as_published", "age_as_published",
                      "strain_as_published", "cohort_key", "observation_level", "data_role",
                      "method", "nuclei_to_cells_assumption", "endothelial_class_scope",
                      "unidentified_class_scope", "tissue_processing_correction", "ependymal_scope",
                      "cord_boundary", "publication_status", "source_table", "source_printed_page",
                      "source_pdf_page", "DOI", "PMID", "SourceReader", "SourceReadDate",
                      "SourceVisualCheck", "analysis_generation")
for (column in metadata.columns) final.dataframe[[column]] <- context[[column]]
final.dataframe$Reference <- item_name
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 5L, !anyDuplicated(final.dataframe$animal_id_as_published))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Future publication is a separate, explicitly owner-gated operation.
if (identical(getOption("evom1.publish", FALSE), TRUE)) {
  if (!identical(getOption("evom1.owner_review", FALSE), TRUE) ||
      !identical(getOption("evom1.source_label_doi_review", FALSE), TRUE) ||
      !identical(getOption("evom1.R_validated", FALSE), TRUE))
    stop("Public TSV withheld: owner source-label/DOI repair and actual R validation required")
  root <- folder
  while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root)
    root <- dirname(root)
  if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Current registry not mounted")
  if (!requireNamespace("readxl", quietly = TRUE)) stop("readxl required for fresh registry lookup")
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  matches <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
  if (length(matches) != 1L) stop("Current exact Item name must match once")
  item_encoded <- as.character(filecodes[["Item encoded"]][matches])
  expected.encoded <- paste0(gsub("/", "%2F", unique(context$DOI), fixed = TRUE), "_",
                             gsub(" ", "", unique(context$source_table), fixed = TRUE))
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$|[/\\\\]", item_encoded) || !identical(item_encoded, expected.encoded))
    stop("Current Item encoded is invalid or not the single verified article DOI")
  if (!identical(as.character(filecodes[["Item number"]][matches]), unique(context$source_table)))
    stop("Current printed Roman item label needs owner review")
  public <- file.path(root, "__Public", "comparative-data")
  if (!dir.exists(public)) stop("Canonical public directory not mounted")
  utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")),
                     sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message("Analysis CSV only. Public TSV WITHHELD; no registry, keys or merge updates.")
}

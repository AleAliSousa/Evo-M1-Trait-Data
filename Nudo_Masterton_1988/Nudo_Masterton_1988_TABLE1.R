## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_SPINAL_NUDO_RELEASE"))) Sys.setenv(EVOM1_SPINAL_NUDO_RELEASE = "OWNER_VERIFIED_R_SOURCE_SCHEMA_AND_SCIENTIFIC_GATES")
# PREPARED ONLY. R audit/dry-run/build/validate have NOT RUN in this environment.
expected_basename <- "Nudo_Masterton_1988_TABLE1.R"
candidates <- character()
for (frame in rev(sys.frames())) {
  for (field in c("ofile", "file")) {
    candidate <- frame[[field]]
    if (is.character(candidate) && length(candidate) == 1L && !is.na(candidate) &&
        basename(candidate) == expected_basename && file.exists(candidate)) candidates <- c(candidates, candidate)
  }
}
if (!length(candidates)) {
  args <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", args[grepl("^--file=", args)])
  candidates <- candidates[basename(candidates) == expected_basename & file.exists(candidates)]
}
if (!length(candidates)) stop("Cannot locate own source/sys.source frame or own --file basename.")
base <- normalizePath(candidates[[1L]], winslash = "/", mustWork = TRUE)
folder <- dirname(base)
item_name <- tools::file_path_sans_ext(basename(base))
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
                           colClasses = "character", na.strings = NULL, check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(nrow(context) == 1L, context$Ref == item_name)
frozen <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
                          colClasses = "character", na.strings = NULL, check.names = FALSE,
                          fileEncoding = "UTF-8", blank.lines.skip = FALSE)
stopifnot(ncol(frozen) == 3L,
          identical(unname(unlist(frozen[2L, ])), c("Common name", "Scientific name", "No. subjects")))
roster <- frozen[seq.int(3L, nrow(frozen)), , drop = FALSE]
n <- as.integer(roster[[3L]])
stopifnot(!anyNA(n), sum(n) == as.integer(context$study_accepted_individuals),
          nrow(roster) == as.integer(context$study_n_taxa))
final.dataframe <- data.frame(Ref = item_name, source_row = seq_len(nrow(roster)),
  common_name_as_published = roster[[1L]], species_as_published = roster[[2L]], n_individuals = n,
  observation_level = "species roster entry; accepted subject count", data_role = "primary sampling metadata",
  source_page = context$source_page, source_section = context$source_section, source_doi = context$source_doi,
  study_accepted_individuals = context$study_accepted_individuals, study_n_taxa = context$study_n_taxa,
  merge_gate = context$merge_gate, stringsAsFactors = FALSE, check.names = FALSE)

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")
# No fallback DOI code, paper-folder TSV, private candidate TSV or automatic publication.
root <- dirname(folder)
item_encoded <- NULL
if (file.exists(file.path(root, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  required <- c("Item name", "Item number", "Item encoded")
  if (all(required %in% names(filecodes))) {
    matched <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
    if (length(matched) == 1L) {
      number <- gsub("[[:space:]]", "", as.character(filecodes$`Item number`[[matched]]))
      code <- as.character(filecodes$`Item encoded`[[matched]])
      if (!is.na(number) && number == "TABLE1" && !is.na(code) && nzchar(code) &&
          !code %in% c("NA", "notfound") && !grepl("_$|[/\\\\]", code)) item_encoded <- code
    }
  }
}
public_allowed <- identical(Sys.getenv("EVOM1_SPINAL_NUDO_RELEASE"),
                            "OWNER_VERIFIED_R_SOURCE_SCHEMA_AND_SCIENTIFIC_GATES")
if (is.null(item_encoded)) {
  message("PUBLIC_TSV_WITHHELD: unique fresh registry Item name/number/code required; no fallback.")
} else if (!public_allowed) {
  message("PUBLIC_TSV_WITHHELD: R/source/scientific owner gates remain held; local preview CSV only.")
} else {
  public_folder <- file.path(root, "__Public", "comparative-data")
  if (!dir.exists(public_folder)) stop("Authoritative repository-level public directory is not mounted.")
  utils::write.table(final.dataframe, file.path(public_folder, paste0(item_encoded, ".tsv")),
                     sep = "\t", quote = TRUE, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

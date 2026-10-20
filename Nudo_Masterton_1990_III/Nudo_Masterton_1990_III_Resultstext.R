## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_SPINAL_NUDO_RELEASE"))) Sys.setenv(EVOM1_SPINAL_NUDO_RELEASE = "OWNER_VERIFIED_R_SOURCE_SCHEMA_AND_SCIENTIFIC_GATES")
# PREPARED ONLY. R audit/dry-run/build/validate have NOT RUN in this environment.
expected_basename <- "Nudo_Masterton_1990_III_ResultsText.R"
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
frozen <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                          colClasses = "character", na.strings = NULL, check.names = FALSE, fileEncoding = "UTF-8")
quantity_map <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_quantity_map.csv")),
                                colClasses = "character", na.strings = NULL, check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(!anyDuplicated(frozen$source_id), !anyDuplicated(quantity_map$quantity_as_reported),
          all(frozen$quantity_as_reported %in% quantity_map$quantity_as_reported))
parts <- strsplit(frozen$numeric_literal, " ± ", fixed = TRUE)
central <- vapply(parts, function(x) x[[1L]], character(1L))
central <- gsub(",", "", central, fixed = TRUE)
censored <- grepl("^(less than |over )", central)
operator <- ifelse(grepl("^less than ", central), "<", ifelse(grepl("^over ", central), ">", ""))
central <- sub("^(less than |over )", "", central)
num <- as.numeric(central)
stopifnot(!anyNA(num))
uncertainty <- vapply(parts, function(x) if (length(x) == 2L) x[[2L]] else "", character(1L))
aggregate <- frozen$taxon_as_published %in% c("22 mammals", "all species", "all cases")
bad_unit <- frozen$quantity_as_reported == "absolute area" & frozen$unit_as_printed == "/mm²"
suspect <- frozen$region_as_published == "Region B" & frozen$source_criterion == "average" &
           frozen$quantity_as_reported %in% c("surface density", "absolute area")
flags <- vapply(seq_len(nrow(frozen)), function(i) {
  f <- character()
  if (nzchar(uncertainty[[i]])) f <- c(f, "HOLD_UNCERTAINTY_STAT_UNDEFINED")
  if (bad_unit[[i]]) f <- c(f, "HOLD_PRINTED_AREA_UNIT_CONFLICT")
  if (suspect[[i]]) f <- c(f, "HOLD_PRINTED_REGION_B_INTERNAL_CONFLICT")
  paste(c(f, "HOLD_SOURCE_OPERATIONAL_CST_NOT_M1"), collapse = "; ")
}, character(1L))
map_row <- match(frozen$quantity_as_reported, quantity_map$quantity_as_reported)
final.dataframe <- data.frame(Ref = item_name, frozen,
  observation_level = ifelse(aggregate, "multispecies aggregate", "species-specific reported extremum; not complete species mean"),
  n_taxa = ifelse(aggregate, context$study_n_taxa, "1"),
  n_taxa_basis = ifelse(aggregate, "22-species study context; aggregate denominator not restated per sentence", "one named taxon in quoted extremum"),
  n_individuals = "", hemisphere_basis = context$hemisphere_basis, count_method = context$count_correction,
  data_role = "primary origin; published summary or selected extremum", censor_operator = operator,
  censor_bound_as_printed = ifelse(censored, central, ""), uncertainty_as_printed = uncertainty,
  uncertainty_stat = ifelse(nzchar(uncertainty), "undefined", ""),
  unit_interpretation = ifelse(bad_unit, "HOLD: reciprocal unit printed for absolute area; no repair", quantity_map$canonical_unit[map_row]),
  ambiguous_literal_value = ifelse(bad_unit, central, ""), source_flags = flags,
  source_doi = context$source_doi, merge_gate = context$merge_gate, stringsAsFactors = FALSE, check.names = FALSE)
for (code in quantity_map$value_code) {
  final.dataframe[[code]] <- NA_real_
  selected <- quantity_map$value_code[map_row] == code & !censored & !bad_unit
  final.dataframe[[code]][selected] <- num[selected]
}
stopifnot(all(rowSums(!is.na(final.dataframe[quantity_map$value_code])) == as.integer(!censored & !bad_unit)))

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
      if (!is.na(number) && number == "ResultsText" && !is.na(code) && nzchar(code) &&
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

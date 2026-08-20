#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
restricted_file <- if (length(args)) args[[1]] else NA_character_

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_file <- normalizePath(sub("^--file=", "", script_arg[[1]]))
key_dir <- dirname(script_file)

read_key <- function(name) {
  read.csv(
    file.path(key_dir, name),
    check.names = FALSE,
    na.strings = c("", "NA"),
    stringsAsFactors = FALSE
  )
}

required <- c(
  "canonical_specimen", "record_type", "specimen_kind", "access_class",
  "evidence_source_ids", "specimen_name", "primary_identifier",
  "alternate_identifiers", "collection", "source_publication",
  "item_reference", "printed_name", "published_taxon", "resolved_taxon",
  "taxon_concept", "taxon_conflict", "match", "sex", "note"
)
allowed_kinds <- c(
  "historical_biological_specimen", "fossil_specimen",
  "in_vivo_subject", "unknown"
)

sources <- read_key("specimen_source_registry.csv")
concepts <- read_key("taxon_concept_registry.csv")
public <- read_key("specimen_crosswalk.csv")

stopifnot(!anyDuplicated(sources$source_id))
stopifnot(!anyDuplicated(concepts$taxon_concept))

validate_layer <- function(x, expected_access, label) {
  stopifnot(identical(names(x), required))
  stopifnot(all(x$record_type == "specimen"))
  stopifnot(all(x$specimen_kind %in% allowed_kinds))
  stopifnot(all(x$access_class == expected_access))
  stopifnot(!anyDuplicated(paste(
    x$canonical_specimen, x$source_publication, x$item_reference, sep = "\r"
  )))

  evidence <- strsplit(x$evidence_source_ids, ";", fixed = TRUE)
  evidence_ids <- unique(unlist(evidence, use.names = FALSE))
  missing_ids <- setdiff(evidence_ids, sources$source_id)
  if (length(missing_ids)) {
    stop(label, " cites unregistered evidence source(s): ",
         paste(missing_ids, collapse = ", "))
  }

  source_access <- setNames(sources$access_class, sources$source_id)
  if (expected_access == "public") {
    bad <- vapply(evidence, function(ids) {
      any(source_access[ids] != "public")
    }, logical(1))
    if (any(bad)) stop(label, " contains public rows backed by non-public evidence")
  } else {
    no_private_basis <- vapply(evidence, function(ids) {
      !any(source_access[ids] == "restricted")
    }, logical(1))
    if (any(no_private_basis)) {
      stop(label, " contains restricted rows with no registered restricted evidence")
    }
  }

  concept_values <- unique(x$taxon_concept[!is.na(x$taxon_concept)])
  missing_concepts <- setdiff(concept_values, concepts$taxon_concept)
  if (length(missing_concepts)) {
    stop(label, " cites unregistered taxon concept(s): ",
         paste(missing_concepts, collapse = ", "))
  }

  invisible(TRUE)
}

validate_layer(public, "public", "public crosswalk")

fossil <- read_key("fossil_specimen_crosswalk.csv")
stopifnot(all(fossil$record_type == "specimen"))
stopifnot(all(fossil$specimen_kind == "fossil_specimen"))
stopifnot(all(fossil$access_class == "public"))

external <- read_key("specimen_external_links.csv")
stopifnot(identical(
  names(external),
  c("canonical_specimen", "database", "external_id", "external_uri",
    "match_status", "evidence_source_ids", "access_class", "note")
))

if (!is.na(restricted_file)) {
  restricted_file <- normalizePath(restricted_file)
  restricted <- read.csv(
    restricted_file,
    check.names = FALSE,
    na.strings = c("", "NA"),
    stringsAsFactors = FALSE
  )
  validate_layer(restricted, "restricted", "restricted crosswalk")
  stopifnot(identical(names(public), names(restricted)))
  message(
    "validated public layer (", nrow(public), " rows) and restricted layer (",
    nrow(restricted), " rows)"
  )
} else {
  message("validated public layer (", nrow(public), " rows); restricted layer not requested")
}

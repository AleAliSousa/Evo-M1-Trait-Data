#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
restricted_file <- if (length(args)) args[[1]] else NA_character_
restricted_external_file <- if (length(args) >= 2) args[[2]] else NA_character_

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
allowed_match <- function(x) {
  x %in% c("matched", "probable", "unmatched") | grepl("-only$", x)
}

sources <- read_key("specimen_source_registry.csv")
concepts <- read_key("taxon_concept_registry.csv")
public <- read_key("specimen_crosswalk.csv")

stopifnot(!anyDuplicated(sources$source_id))
stopifnot(!anyDuplicated(concepts$taxon_concept))

validate_layer <- function(x, expected_access, label) {
  stopifnot(identical(names(x), required))
  stopifnot(all(x$record_type == "specimen"))
  stopifnot(all(x$specimen_kind %in% allowed_kinds))
  stopifnot(all(allowed_match(x$match)))
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
external_required <- c(
  "canonical_specimen", "database", "external_id", "external_uri",
  "match_status", "evidence_source_ids", "access_class", "note"
)

validate_external <- function(x, expected_access, valid_specimens, label) {
  stopifnot(identical(names(x), external_required))
  if (!nrow(x)) return(invisible(TRUE))
  stopifnot(all(x$match_status %in% c("matched", "probable", "unmatched")))
  stopifnot(all(x$access_class == expected_access))
  stopifnot(!anyDuplicated(paste(x$canonical_specimen, x$database,
                                 x$external_id, sep = "\r")))

  missing_specimens <- setdiff(unique(x$canonical_specimen), valid_specimens)
  if (length(missing_specimens)) {
    stop(label, " cites unregistered specimen(s): ",
         paste(missing_specimens, collapse = ", "))
  }

  evidence <- strsplit(x$evidence_source_ids, ";", fixed = TRUE)
  evidence_ids <- unique(unlist(evidence, use.names = FALSE))
  missing_ids <- setdiff(evidence_ids, sources$source_id)
  if (length(missing_ids)) {
    stop(label, " cites unregistered evidence source(s): ",
         paste(missing_ids, collapse = ", "))
  }
  source_access <- setNames(sources$access_class, sources$source_id)
  if (expected_access == "public") {
    if (any(vapply(evidence, function(ids) any(source_access[ids] != "public"),
                   logical(1)))) {
      stop(label, " contains public rows backed by non-public evidence")
    }
  } else if (any(vapply(evidence, function(ids) {
    !any(source_access[ids] == "restricted")
  }, logical(1)))) {
    stop(label, " contains restricted rows with no registered restricted evidence")
  }
  invisible(TRUE)
}

validate_external(external, "public", unique(public$canonical_specimen),
                  "public external links")

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

if (!is.na(restricted_external_file)) {
  if (is.na(restricted_file)) {
    stop("A restricted crosswalk is required when validating restricted external links")
  }
  restricted_external <- read.csv(
    normalizePath(restricted_external_file),
    check.names = FALSE,
    na.strings = c("", "NA"),
    stringsAsFactors = FALSE
  )
  validate_external(
    restricted_external, "restricted",
    unique(c(public$canonical_specimen, restricted$canonical_specimen)),
    "restricted external links"
  )
  message("validated restricted external links (", nrow(restricted_external), " rows)")
}

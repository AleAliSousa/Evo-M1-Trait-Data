## same_data.R -- the same data reached through two compilations, decided per data point.
##
## Owner's rule of 24 November 2026: a compilation's copy of another compilation (or of a primary)
## is registered as the same data, per data point, and the source it copies is served in its place.
## Exceptions are decided in writing: the copy corrected an error of the source, or the source is
## not available. _keys/compilation_cited_sources.csv says which citation keys of a compilation are
## items of this database. This file gives the merges two things:
##   amniote_value_sources(repo)  for every Mammalia cell of the Amniote database (Myhrvold et al.
##                                2015), the sources that produced its value, from the parsed
##                                per-cell derivations (reference_tables/..._cell_references_part*.csv):
##                                the single source, the two sources of a mean, or the record(s)
##                                selected from a median pool. Each is mapped through the key.
##   same_data_status(...)        per data point: "same_data" when every source of the value is an
##                                item that holds a value for the same species and measure in the
##                                merge and the values agree within 0.5 %; otherwise the reason.
SAME_DATA_TOLERANCE <- 0.005

same_data_key <- function(repo) {
  k <- read.csv(file.path(repo, "_keys", "compilation_cited_sources.csv"), colClasses = "character",
                check.names = FALSE, encoding = "UTF-8")
  need <- c("compilation_paper", "ref_key", "cited_paper", "status")
  if (!all(need %in% names(k))) stop("compilation_cited_sources.csv: columns missing", call. = FALSE)
  k[k$status == "confirmed with step 13" | grepl("^confirmed", k$status), , drop = FALSE]
}

amniote_value_sources <- function(repo) {
  dir <- file.path(repo, "Myhrvold_etal_2015", "reference_tables")
  files <- sort(list.files(dir, "^Myhrvold_etal_2015_cell_references_part[0-9]+\\.csv$", full.names = TRUE))
  if (!length(files)) stop("Amniote cell references not found in ", dir, call. = FALSE)
  cr <- do.call(rbind, lapply(files, function(f) read.csv(f, colClasses = "character", check.names = FALSE,
                                                           encoding = "UTF-8")[, c("class", "genus", "species", "subspecies", "trait", "value",
                                                                                     "ref_key_norm", "cell_form", "derivation_role")]))
  cr <- cr[cr$class == "Mammalia" & cr$derivation_role %in% c("direct", "mean_of_member", "selected_from_median_pool"), , drop = FALSE]
  key <- same_data_key(repo); key <- key[key$compilation_paper == "Myhrvold_etal_2015", , drop = FALSE]
  cr$cited_paper <- key$cited_paper[match(cr$ref_key_norm, key$ref_key)]
  cr$species_printed <- paste(cr$genus, cr$species)
  id <- paste(cr$species_printed, cr$trait, sep = "\r")
  first <- !duplicated(id)
  out <- data.frame(species_printed = cr$species_printed[first], trait = cr$trait[first], cell_form = cr$cell_form[first],
                    stringsAsFactors = FALSE)
  ids <- id[first]
  srcs <- split(ifelse(is.na(cr$cited_paper), paste0("(not in database: ", cr$ref_key_norm, ")"), cr$cited_paper), id)[ids]
  out$value_sources <- vapply(srcs, paste, character(1), collapse = " + ")
  out$n_value_sources <- lengths(srcs)
  out$all_in_database <- vapply(srcs, function(s) !any(startsWith(s, "(not in database")), logical(1))
  out$any_in_database <- vapply(srcs, function(s) any(!startsWith(s, "(not in database")), logical(1))
  out$cited_papers <- vapply(srcs, function(s) paste(s[!startsWith(s, "(not in database")], collapse = " + "), character(1))
  rownames(out) <- NULL
  out
}

## expected: the value the cited sources give in this merge (mean over the cell's value sources);
## NA when a source is an item of the database but holds no value for this species and measure here.
same_data_status <- function(all_in_database, any_in_database, value, expected) {
  rel <- abs(value - expected) / pmax(abs(expected), 1e-12)
  ifelse(!any_in_database, "cites_sources_not_in_database",
  ifelse(!all_in_database, "partly_from_sources_not_in_database",
  ifelse(is.na(expected), "cited_source_has_no_value_here",
  ifelse(rel <= SAME_DATA_TOLERANCE, "same_data", "same_sources_value_differs"))))
}

# Generate item-scoped source-match inputs and checking tables for Appendix A1-A14.
# Run after the per-table builds AND build_primary_reference_catalogs.py: the
# shared catalog is the authoritative citation/lineage lookup. Frozen snapshots
# and the shared catalog are inputs, never edited here.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(args)) stop("Run with Rscript Kaufman__2004_build_source_matches.R")
folder <- dirname(normalizePath(sub("^--file=", "", args[1])))
root <- dirname(folder)
ref_dir <- file.path(folder, "reference_tables")
source(file.path(root, "_tools", "dataset_builder", "source_match.R"))
catalog_path <- file.path(ref_dir, "Kaufman__2004_TablesA1-A14_references.csv")
catalog <- sm_read_csv(catalog_path)
required <- c("ref_key", "cited_in_column", "citation", "note", "source_reference_id",
              "reference_level", "source_type", "primary_reference_id", "bibliography_entry_id")
stopifnot(all(required %in% names(catalog)), !anyDuplicated(catalog$ref_key))

for (n in 1:14) {
  item <- paste0("Kaufman__2004_TableA", n)
  data <- sm_read_csv(file.path(folder, paste0(item, ".csv")))
  keys <- unique(trimws(data$Reference))
  keys <- keys[!sm_is_empty(keys)]
  missing <- setdiff(keys, catalog$ref_key)
  if (length(missing)) stop(item, ": references absent from shared catalog: ",
                            paste(missing, collapse = "; "),
                            ". Rebuild the shared catalog first.")
  refs <- catalog[match(keys, catalog$ref_key), , drop = FALSE]
  refs$cited_in_column <- "Reference"
  if ("cited_in_tables" %in% names(refs)) refs$cited_in_tables <- paste0("TableA", n)
  if ("occurrence_count" %in% names(refs))
    refs$occurrence_count <- as.character(vapply(keys, function(k) sum(trimws(data$Reference) == k), integer(1)))
  sm_write_csv(refs, file.path(ref_dir, paste0(item, "_references.csv")))
  result <- build_source_match(folder, item, strict = TRUE)
  if (nrow(result$long) && any(result$long$ref_key != result$long$key_cell_as_printed))
    stop(item, ": source matcher chose a different key from the exact row citation")
  if (nrow(result$long) != sum(!sm_is_empty(unlist(data[c(
      "CMRgl_umol_100g_min", "CMRgl_SD", "CMRO2_umol_100g_min", "CMRO2_SD",
      "CBF_ml_100g_min", "CBF_SD")])), na.rm = TRUE))
    stop(item, ": reference attribution count differs from filled measurement cells")
  # The generic matcher uses ref_key and full citation. Also carry the source-
  # local bibliography ID in its derived views for direct access to the one
  # maintained dissertation bibliography. Self-source and unresolved keys are
  # deliberately blank because they do not point to an entry in that list.
  for (view in c("long", "summary")) {
    value <- result[[view]]
    indices <- match(value$ref_key, refs$ref_key)
    if (anyNA(indices)) stop(item, ": source-match view contains an unknown reference")
    value$bibliography_entry_id <- refs$bibliography_entry_id[indices]
    suffix <- if (view == "long") "_source_match.csv" else "_source_match_summary.csv"
    sm_write_csv(value, file.path(ref_dir, paste0(item, suffix)))
  }
}

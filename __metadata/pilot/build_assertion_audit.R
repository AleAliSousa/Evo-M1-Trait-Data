# Export point-level assertions and evidence links from the ten-paper pilot.
# This is an audit of existing claims, not a new qualification decision.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __metadata/pilot/build_assertion_audit.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
for (pkg in c("readr", "readxl", "DBI", "RSQLite")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)
}
read_chars <- function(path, tsv = FALSE) {
  reader <- if (tsv) readr::read_tsv else readr::read_csv
  suppressWarnings(as.data.frame(reader(
    path, col_types = readr::cols(.default = readr::col_character()),
    na = character(), show_col_types = FALSE
  ), stringsAsFactors = FALSE))
}
plain <- function(x) {
  x <- trimws(ifelse(is.na(x), "", as.character(x)))
  x[x %in% c("NA", "N/A", "#N/A", "#VALUE!", "NULL", "nan")] <- ""
  x
}
require <- function(ok, message) if (!isTRUE(ok)) stop(message, call. = FALSE)
points_path <- file.path(root, "__measurements/pilot_metadata/pilot_points.csv")
scope_path <- file.path(root, "__measurements/pilot_metadata/scope.csv")
catalog_path <- file.path(here, "catalog.sqlite")
require(file.exists(points_path) && file.exists(scope_path) && file.exists(catalog_path),
        "Build the ten-paper qualification and metadata catalog first")
points <- read_chars(points_path)
scope <- read_chars(scope_path)
required_point_cols <- c(
  "point_id", "item", "column", "source_locator", "raw_value",
  "qualification_pass", "trait_id", "unit", "unit_status", "value_type",
  "printed_taxon", "source_snapshot_taxon", "accepted_species",
  "taxon_status", "taxon_basis", "reporting_reference",
  "reporting_reference_status", "upstream_reference", "upstream_keys",
  "upstream_reference_id",
  "upstream_status", "source_role", "measurement_method", "method_status",
  "anatomy_behavior_target", "trait_definition", "value_origin",
  "transformation_method", "transformation_status", "definition_evidence"
)
require(all(required_point_cols %in% names(points)),
        "pilot_points.csv lacks required assertion fields")
require(!anyDuplicated(points$point_id) && all(nzchar(points$point_id)),
        "pilot_points.csv has blank or duplicate point IDs")
require(all(points$qualification_pass %in% c("TRUE", "FALSE")),
        "qualification_pass must be TRUE or FALSE")
qualified <- points$qualification_pass == "TRUE"
require(sum(qualified) >= 699L, "Expected at least 699 qualified pilot points")
require(!anyDuplicated(scope[c("item", "column")]),
        "scope.csv has duplicate item/column keys")
scope_idx <- match(paste(points$item, points$column, sep = "\036"),
                   paste(scope$item, scope$column, sep = "\036"))
require(!anyNA(scope_idx), "A pilot point lacks its exact scope.csv row")
rule <- scope$rule[scope_idx]

con <- DBI::dbConnect(RSQLite::SQLite(), dbname = catalog_path,
                      flags = RSQLite::SQLITE_RO)
on.exit(DBI::dbDisconnect(con), add = TRUE)
routes <- DBI::dbGetQuery(con,
  "SELECT item_id, metadata_field, artifact_id, path, locator FROM metadata_routes")
artifacts <- DBI::dbGetQuery(con,
  "SELECT artifact_id, path FROM artifact")
route_key <- paste(routes$item_id, routes$metadata_field, sep = "\036")
route_for <- function(field) {
  match(paste(points$item, field, sep = "\036"), route_key)
}
output_route <- route_for("item_output")
definition_route <- route_for("item_definition")
registry_route <- route_for("reporting_reference")
snapshot_route <- route_for("frozen_snapshot")
original_route <- route_for("original_source")
require(!anyNA(output_route) && !anyNA(definition_route) &&
          !anyNA(registry_route) && !anyNA(snapshot_route) &&
          !anyNA(original_route),
        "A scoped item lacks a required catalog source route")

# The public TSV locator is a point-level cell, not a locator in the paper.
parts <- regmatches(points$source_locator,
                    regexec("^(.*\\.tsv):([0-9]+):(.+)$", points$source_locator))
require(all(lengths(parts) == 4L), "A source_locator is not TSV:line:column")
source_file <- vapply(parts, `[[`, "", 2L)
source_line <- as.integer(vapply(parts, `[[`, "", 3L))
source_column <- vapply(parts, `[[`, "", 4L)
output_path <- routes$path[output_route]
require(all(basename(output_path) == source_file),
        "A source_locator does not match its registered item output")
require(all(source_line >= 2L) && all(points$column == source_column),
        "A source_locator has an invalid row or measured column")
source_cache <- lapply(unique(output_path), function(path) {
  read_chars(file.path(root, path), tsv = TRUE)
})
names(source_cache) <- unique(output_path)
source_cell <- function(i, column = source_column[[i]]) {
  tab <- source_cache[[output_path[[i]]]]
  row <- source_line[[i]] - 1L
  if (row < 1L || row > nrow(tab) || !column %in% names(tab)) return(NA_character_)
  tab[[column]][[row]]
}
raw_matches <- vapply(seq_len(nrow(points)), function(i) {
  identical(source_cell(i), points$raw_value[[i]])
}, logical(1))
require(all(raw_matches),
        paste("Point TSV cell/raw value mismatch:",
              points$point_id[[which(!raw_matches)[[1L]]]]))

definition_path <- routes$path[definition_route]
require(all(definition_path == points$definition_evidence),
        "Pilot definition_evidence differs from the catalog item_definition path")
definition_cache <- lapply(unique(definition_path), function(path) {
  read_chars(file.path(root, path))
})
names(definition_cache) <- unique(definition_path)
definition_match <- vapply(seq_len(nrow(points)), function(i) {
  tab <- definition_cache[[definition_path[[i]]]]
  sum(!is.na(tab$Code) & tab$Code == points$column[[i]]) == 1L
}, logical(1))
require(all(definition_match[qualified]),
        "A qualified point lacks a unique Code=column definition row")

# A TSV taxon cell is exact in the processed item. Its location in the
# original paper or supplement is a separate, often less precise link.
species_column <- function(item) {
  if (startsWith(item, "Bahney_vonBartheld_2018")) return("species_as_published")
  if (item == "Boddy_etal_2012_TableS1") return("Species Name")
  if (item == "Boddy_etal_2012_brainbodydatabasev2.txt")
    return("Updated Species Name (from Wilson & Reeder Mammal Species of the World)")
  if (startsWith(item, "Buchsbaum_etal_1989")) return("species_as_published")
  if (startsWith(item, "Falcone_etal_2019")) return("Scientific name")
  if (startsWith(item, "Fobbs_etal_2011")) return("Species_binomial")
  if (startsWith(item, "Heffner_Heffner_2010_b")) return("binomial")
  if (startsWith(item, "Kaufman__2004")) return("Species")
  if (startsWith(item, "Kennedy_etal_1978")) return("species_as_published")
  if (startsWith(item, "ManyPrimates__2022")) return("Species")
  if (startsWith(item, "Mink_etal_1981")) return("species_as_published")
  ""
}
species_col <- vapply(points$item, species_column, "")
snapshot_taxon_match <- vapply(seq_len(nrow(points)), function(i) {
  cell <- source_cell(i, species_col[[i]])
  !is.na(cell) && identical(trimws(cell), trimws(points$source_snapshot_taxon[[i]]))
}, logical(1))
require(all(snapshot_taxon_match[qualified]),
        "A qualified point's snapshot taxon does not match its TSV row")

species_art <- artifacts[artifacts$artifact_id == "species-reference", , drop = FALSE]
require(nrow(species_art) == 1L, "Catalog lacks species-reference artifact")
accepted_names <- read_chars(file.path(root, species_art$path[[1L]]))$accepted_name
require(!anyDuplicated(accepted_names), "Accepted-name key has duplicate names")
accepted_match <- nzchar(points$accepted_species) &
  points$accepted_species %in% accepted_names
require(all(accepted_match[qualified]),
        "A qualified point lacks a unique active accepted-name row")

registry <- suppressWarnings(readxl::read_excel(
  file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text"
))
require(all(c("Item name", "DOI URL", "Citation (APA 7th-Annotated)") %in%
              names(registry)), "Live registry lacks required citation columns")
registry_name <- plain(registry[["Item name"]])
registry_hit <- match(points$item, registry_name)
registry_value <- ifelse(nzchar(plain(registry[["DOI URL"]][registry_hit])),
                         plain(registry[["DOI URL"]][registry_hit]),
                         plain(registry[["Citation (APA 7th-Annotated)"]][registry_hit]))
registry_match <- !is.na(registry_hit) &
  plain(points$reporting_reference) == registry_value &
  nzchar(registry_value)
require(all(registry_match[qualified]),
        "A qualified reporting reference differs from the live registry row")

basis_route <- routes[routes$item_id == "Boddy_etal_2012_TableS1" &
                        routes$metadata_field == "brain_mass_row_basis", , drop = FALSE]
require(nrow(basis_route) == 1L, "Catalog lacks the Boddy row-basis route")
basis <- read_chars(file.path(root, basis_route$path[[1L]]))
require(!anyDuplicated(basis$resolution_id), "Boddy resolution IDs are not unique")
basis_token <- rep("", nrow(points))
has_basis <- grepl("BBR-[A-Za-z0-9]+", points$taxon_basis)
basis_token[has_basis] <- sub(".*(BBR-[A-Za-z0-9]+).*", "\\1",
                              points$taxon_basis[has_basis])
basis_idx <- match(basis_token, basis$resolution_id)
basis_match <- !is.na(basis_idx) &
  vapply(seq_len(nrow(points)), function(i) {
    k <- basis_idx[[i]]
    !is.na(k) &&
      basis$source_records[[k]] == paste0(output_path[[i]], ":", source_line[[i]])
  }, logical(1))
require(all(basis_match[qualified & points$item == "Boddy_etal_2012_TableS1"]),
        "A qualified Boddy point lacks a matching row-basis resolution")

kaufman_route <- routes[routes$item_id == "Kaufman__2004_TableA3" &
                          routes$metadata_field == "upstream_reference", , drop = FALSE]
require(nrow(kaufman_route) == 1L, "Catalog lacks the Kaufman reference lookup")
kaufman_refs <- read_chars(file.path(root, kaufman_route$path[[1L]]))
require(!anyDuplicated(kaufman_refs$ref_key), "Kaufman lookup has duplicate keys")
kaufman_idx <- match(points$upstream_keys, kaufman_refs$ref_key)
kaufman_match <- points$item == "Kaufman__2004_TableA3" &
  !is.na(kaufman_idx) & nzchar(points$upstream_keys) &
  points$upstream_reference == kaufman_refs$citation[kaufman_idx] &
  nzchar(points$upstream_reference_id) &
  points$upstream_reference_id == kaufman_refs$source_reference_id[kaufman_idx]

# One assertion per point and field. pilot_status copies the existing gate
# status where available; 'present' never means independently verified.
present <- function(x) ifelse(nzchar(x) & x != "unresolved", "present", "unresolved")
fields <- list(
  reported_value = list(value = points$raw_value,
                        status = ifelse(raw_matches, "observed", "unresolved"),
                        scope = "cell"),
  measure = list(value = points$trait_id,
                 status = ifelse(nzchar(points$trait_id), "present", "unresolved"),
                 scope = "column"),
  unit = list(value = points$unit, status = points$unit_status, scope = "column"),
  value_type = list(value = points$value_type, status = present(points$value_type),
                    scope = "cell"),
  printed_taxon = list(value = points$printed_taxon,
                       status = present(points$printed_taxon), scope = "row_or_paper"),
  source_snapshot_taxon = list(value = points$source_snapshot_taxon,
                               status = ifelse(snapshot_taxon_match, "observed", "unresolved"),
                               scope = "row"),
  accepted_species = list(value = points$accepted_species,
                          status = points$taxon_status, scope = "point"),
  reporting_reference = list(value = points$reporting_reference,
                             status = points$reporting_reference_status,
                             scope = "item"),
  upstream_reference = list(
    value = ifelse(points$source_role == "primary", "", points$upstream_reference),
    status = ifelse(points$source_role == "primary", "not_applicable",
                    points$upstream_status), scope = "point"),
  source_role = list(value = points$source_role,
                     status = present(points$source_role), scope = "point"),
  measurement_method = list(value = points$measurement_method,
                            status = points$method_status, scope = "point"),
  anatomy_behavior_target = list(value = points$anatomy_behavior_target,
                                 status = present(points$anatomy_behavior_target),
                                 scope = "point"),
  trait_definition = list(value = points$trait_definition,
                          status = present(points$trait_definition),
                          scope = "column_or_point"),
  value_origin = list(value = points$value_origin,
                      status = present(points$value_origin), scope = "point"),
  transformation_method = list(
    value = points$transformation_method,
    status = points$transformation_status, scope = "point")
)
n <- nrow(points)
assertions <- do.call(rbind, lapply(names(fields), function(name) {
  f <- fields[[name]]
  data.frame(
    assertion_id = paste0(points$point_id, "::", name),
    point_id = points$point_id, field_name = name,
    value_text = plain(f$value), pilot_status = plain(f$status),
    qualification_pass = points$qualification_pass,
    applicability_scope = f$scope, derivation_rule = rule,
    stringsAsFactors = FALSE
  )
}))
rownames(assertions) <- NULL
require(!anyDuplicated(assertions$assertion_id), "Assertion IDs are not unique")

evidence_parts <- list()
add_evidence <- function(field, idx, artifact_id = "", path = "", locator = "",
                         relation, precision, link_status, work_id = "") {
  if (!length(idx)) return(invisible(NULL))
  k <- length(evidence_parts) + 1L
  evidence_parts[[k]] <<- data.frame(
    assertion_id = paste0(points$point_id[idx], "::", field),
    artifact_id = rep_len(artifact_id, length(idx)),
    evidence_path = rep_len(path, length(idx)),
    locator = rep_len(locator, length(idx)),
    evidence_relation = rep_len(relation, length(idx)),
    locator_precision = rep_len(precision, length(idx)),
    link_status = rep_len(link_status, length(idx)),
    work_id = rep_len(work_id, length(idx)),
    stringsAsFactors = FALSE
  )
  invisible(NULL)
}
all_idx <- seq_len(n)
exact_raw <- which(raw_matches)
cell_locator <- paste0("row=", source_line, ";column=", source_column)
add_evidence("reported_value", exact_raw,
             routes$artifact_id[output_route[exact_raw]], output_path[exact_raw],
             cell_locator[exact_raw], "processed_value", "tsv_cell", "exact_located")
for (route_idx in list(snapshot_route, original_route)) {
  relation <- if (identical(route_idx, snapshot_route))
    "snapshot_lead" else "original_source_lead"
  add_evidence("reported_value", all_idx,
               routes$artifact_id[route_idx], routes$path[route_idx],
               routes$locator[route_idx], relation,
               "table_or_file", "item_route_only")
}
def_idx <- which(definition_match)
def_locator <- paste0("Code=", points$column)
for (field in c("measure", "unit", "value_type", "trait_definition",
                "anatomy_behavior_target")) {
  add_evidence(field, def_idx,
               routes$artifact_id[definition_route[def_idx]],
               definition_path[def_idx], def_locator[def_idx],
               "definition_component", "key_row", "exact_located")
}
scope_locator <- paste0("item=", points$item, ";column=", points$column)
for (field in c("measure", "unit", "value_type")) {
  add_evidence(field, all_idx, path = "__measurements/pilot_metadata/scope.csv",
               locator = scope_locator,
               relation = "pilot_mapping_rule", precision = "key_row",
               link_status = "path_only_uncatalogued")
}
for (field in c("source_role", "value_origin", "transformation_method")) {
  idx <- if (field == "transformation_method")
    which(nzchar(points$transformation_method)) else all_idx
  add_evidence(field, idx,
               path = "__measurements/pilot_metadata/build_pilot.R",
               locator = paste0("rule=", rule[idx]),
               relation = "pilot_decision_rule", precision = "file_only",
               link_status = "rule_pointer_only")
}
tax_idx <- which(snapshot_taxon_match)
tax_cell_locator <- paste0("row=", source_line, ";column=", species_col)
for (field in c("source_snapshot_taxon", "printed_taxon")) {
  idx <- if (field == "printed_taxon")
    tax_idx[points$printed_taxon[tax_idx] == points$source_snapshot_taxon[tax_idx]]
    else tax_idx
  add_evidence(field, idx, routes$artifact_id[output_route[idx]],
               output_path[idx], tax_cell_locator[idx],
               "processed_taxon_cell", "tsv_cell", "exact_located")
}
add_evidence("printed_taxon", all_idx,
             routes$artifact_id[original_route], routes$path[original_route],
             routes$locator[original_route], "published_taxon_lead",
             "table_or_file", "item_route_only")
accepted_idx <- which(accepted_match)
add_evidence("accepted_species", accepted_idx,
             species_art$artifact_id[[1L]], species_art$path[[1L]],
             paste0("accepted_name=", points$accepted_species[accepted_idx]),
             "accepted_name_key", "key_row", "exact_located")
reg_idx <- which(registry_match)
add_evidence("reporting_reference", reg_idx,
             routes$artifact_id[registry_route[reg_idx]],
             routes$path[registry_route[reg_idx]],
             paste0("Sheet1;Item name=", points$item[reg_idx], ";",
                    ifelse(nzchar(plain(registry[["DOI URL"]][registry_hit[reg_idx]])),
                           "DOI URL", "Citation (APA 7th-Annotated)")),
             "reporting_work_registry_row", "key_row", "exact_located")

# Curation row IDs are point-specific; a short cited-work label is not a
# globally resolved bibliography ID or proof of shared specimens.
bidx <- which(basis_match)
for (field in c("accepted_species", "source_role", "measurement_method",
                "value_origin")) {
  add_evidence(field, bidx, basis_route$artifact_id[[1L]],
               basis_route$path[[1L]],
               paste0("resolution_id=", basis$resolution_id[basis_idx[bidx]]),
               "curated_row_decision", "key_row", "exact_located")
}
bref <- bidx[points$source_role[bidx] != "primary" &
               nzchar(points$upstream_reference[bidx]) &
               points$upstream_reference[bidx] ==
                 basis$original_reference[basis_idx[bidx]]]
add_evidence("upstream_reference", bref, basis_route$artifact_id[[1L]],
             basis_route$path[[1L]],
             paste0("resolution_id=", basis$resolution_id[basis_idx[bref]],
                    ";column=original_reference"),
             "cited_work_label", "key_row", "exact_located")
kidx <- which(kaufman_match)
for (field in c("upstream_reference", "source_role")) {
  add_evidence(field, kidx, kaufman_route$artifact_id[[1L]],
               kaufman_route$path[[1L]],
               paste0("ref_key=", points$upstream_keys[kidx]),
               "cited_work_lookup", "key_row", "exact_located",
               work_id = points$upstream_reference_id[kidx])
}

# These routes identify where to review the original protocol. They are not
# silently upgraded to per-point original-paper locators.
method_route <- route_for("original_method")
method_idx <- which(!is.na(method_route) & nzchar(points$measurement_method))
add_evidence("measurement_method", method_idx,
             routes$artifact_id[method_route[method_idx]],
             routes$path[method_route[method_idx]],
             routes$locator[method_route[method_idx]],
             "original_method_lead", "table_or_file", "item_route_only")
role_idx <- which(nzchar(points$source_role))
add_evidence("source_role", role_idx,
             routes$artifact_id[original_route[role_idx]],
             routes$path[original_route[role_idx]],
             routes$locator[original_route[role_idx]],
             "source_role_lead", "table_or_file", "item_route_only")
upstream_route <- route_for("upstream_reference")
upstream_idx <- which(points$source_role != "primary" &
                        nzchar(points$upstream_reference) &
                        !is.na(upstream_route))
add_evidence("upstream_reference", upstream_idx,
             routes$artifact_id[upstream_route[upstream_idx]],
             routes$path[upstream_route[upstream_idx]],
             routes$locator[upstream_route[upstream_idx]],
             "upstream_reference_lead", "table_or_file", "item_route_only")
transform_idx <- which(nzchar(points$transformation_method))
add_evidence("transformation_method", transform_idx,
             routes$artifact_id[definition_route[transform_idx]],
             definition_path[transform_idx], def_locator[transform_idx],
             "transformation_definition_component", "key_row", "exact_located")

# A method definition key can be exact even while the original paper method
# link above remains only an item-level lead.
method_code <- ifelse(points$item == "ManyPrimates__2022_STMperformance",
                      "Method:proportion.correct",
               ifelse(startsWith(points$item, "Falcone_etal_2019"), "Method",
               ifelse(points$item == "Buchsbaum_etal_1989_TableI", "Method:arms", "")))
method_key <- which(nzchar(method_code) &
  vapply(seq_len(n), function(i) {
    if (!nzchar(method_code[[i]])) return(FALSE)
    tab <- definition_cache[[definition_path[[i]]]]
    sum(tab$Code == method_code[[i]], na.rm = TRUE) == 1L
  }, logical(1)))
add_evidence("measurement_method", method_key,
             routes$artifact_id[definition_route[method_key]],
             definition_path[method_key],
             paste0("Code=", method_code[method_key]),
             "method_definition_component", "key_row", "exact_located")

# Some anatomical targets add a row-specific segment/region to the
# column-level definition. Store both components when the cell exists.
target_column <- ifelse(startsWith(points$item, "Bahney_vonBartheld_2018_TABLE1") |
                          startsWith(points$item, "Bahney_vonBartheld_2018_TABLE2"),
                        "segment",
                 ifelse(points$item == "Buchsbaum_etal_1989_TableI" |
                          points$item == "Kennedy_etal_1978_Table",
                        "structure_as_published",
                 ifelse(points$item == "Kaufman__2004_TableA3", "Region", "")))
target_idx <- which(nzchar(target_column) &
  vapply(seq_len(n), function(i) {
    if (!nzchar(target_column[[i]])) return(FALSE)
    cell <- source_cell(i, target_column[[i]])
    !is.na(cell) && nzchar(trimws(cell))
  }, logical(1)))
add_evidence("anatomy_behavior_target", target_idx,
             routes$artifact_id[output_route[target_idx]],
             output_path[target_idx],
             paste0("row=", source_line[target_idx], ";column=", target_column[target_idx]),
             "processed_anatomy_context", "tsv_cell", "exact_located")

evidence <- do.call(rbind, evidence_parts)
rownames(evidence) <- NULL
require(all(evidence$assertion_id %in% assertions$assertion_id),
        "Evidence refers to an unknown assertion")
known <- nzchar(evidence$artifact_id)
artifact_match <- match(evidence$artifact_id[known], artifacts$artifact_id)
require(!anyNA(artifact_match) &&
          all(evidence$evidence_path[known] == artifacts$path[artifact_match]),
        "Evidence catalog ID/path mismatch")
path_only <- !known & nzchar(evidence$evidence_path)
require(all(file.exists(file.path(root, evidence$evidence_path[path_only]))),
        "An uncatalogued evidence path does not exist")
needs_evidence <- which(!assertions$assertion_id %in% evidence$assertion_id &
                          assertions$pilot_status != "not_applicable")
if (length(needs_evidence)) {
  evidence <- rbind(evidence, data.frame(
    assertion_id = assertions$assertion_id[needs_evidence],
    artifact_id = "", evidence_path = "", locator = "",
    evidence_relation = "needs_evidence", locator_precision = "unknown",
    link_status = "unresolved", work_id = "", stringsAsFactors = FALSE
  ))
}
evidence <- unique(evidence)
evidence <- evidence[order(evidence$assertion_id, evidence$evidence_relation,
                           evidence$evidence_path), , drop = FALSE]

readr::write_csv(assertions, file.path(here, "point_assertions.csv"), na = "")
readr::write_csv(evidence, file.path(here, "assertion_evidence.csv"), na = "")

# Mirror the CSV audit in SQLite for relational queries. The catalog's
# artifact keys are copied so evidence links can have real local FKs.
db_temp <- tempfile("assertion_audit_", tmpdir = here, fileext = ".sqlite")
db <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_temp)
exec_sql <- function(sql) invisible(DBI::dbExecute(db, sql))
exec_sql("PRAGMA foreign_keys = ON")
exec_sql(paste(
  "CREATE TABLE point (point_id TEXT PRIMARY KEY, item TEXT NOT NULL,",
  "qualification_pass TEXT NOT NULL CHECK(qualification_pass IN ('TRUE','FALSE')))"
))
exec_sql("CREATE TABLE artifact (artifact_id TEXT PRIMARY KEY, path TEXT NOT NULL)")
exec_sql(paste(
  "CREATE TABLE point_assertion (assertion_id TEXT PRIMARY KEY,",
  "point_id TEXT NOT NULL REFERENCES point(point_id), field_name TEXT NOT NULL,",
  "value_text TEXT, pilot_status TEXT NOT NULL, applicability_scope TEXT NOT NULL,",
  "derivation_rule TEXT NOT NULL, UNIQUE(point_id, field_name))"
))
exec_sql(paste(
  "CREATE TABLE assertion_evidence (evidence_id INTEGER PRIMARY KEY,",
  "assertion_id TEXT NOT NULL REFERENCES point_assertion(assertion_id),",
  "artifact_id TEXT REFERENCES artifact(artifact_id), evidence_path TEXT,",
  "locator TEXT, evidence_relation TEXT NOT NULL, locator_precision TEXT NOT NULL,",
  "link_status TEXT NOT NULL, work_id TEXT)"
))
point_keys <- unique(points[c("point_id", "item", "qualification_pass")])
DBI::dbWriteTable(db, "point", point_keys, append = TRUE)
DBI::dbWriteTable(db, "artifact", artifacts, append = TRUE)
assertions_sql <- assertions[setdiff(names(assertions), "qualification_pass")]
DBI::dbWriteTable(db, "point_assertion", assertions_sql, append = TRUE)
evidence_sql <- evidence
evidence_sql$artifact_id[!nzchar(evidence_sql$artifact_id)] <- NA_character_
DBI::dbWriteTable(db, "assertion_evidence", evidence_sql, append = TRUE)
exec_sql("CREATE INDEX assertion_point_field ON point_assertion(point_id, field_name)")
exec_sql("CREATE INDEX evidence_assertion ON assertion_evidence(assertion_id)")
exec_sql("CREATE INDEX evidence_artifact ON assertion_evidence(artifact_id)")
exec_sql(paste(
  "CREATE VIEW qualified_assertions AS SELECT a.* FROM point_assertion a",
  "JOIN point p ON p.point_id = a.point_id WHERE p.qualification_pass = 'TRUE'"
))
require(!nrow(DBI::dbGetQuery(db, "PRAGMA foreign_key_check")),
        "Assertion audit SQLite foreign-key check failed")
require(DBI::dbGetQuery(db,
  "SELECT COUNT(*) AS n FROM point_assertion")$n[[1L]] == nrow(assertions),
  "SQLite assertion count differs from CSV")
require(DBI::dbGetQuery(db,
  "SELECT COUNT(*) AS n FROM assertion_evidence")$n[[1L]] == nrow(evidence),
  "SQLite evidence count differs from CSV")
DBI::dbDisconnect(db)
target_db <- file.path(here, "assertion_audit.sqlite")
require(file.copy(db_temp, target_db, overwrite = TRUE),
        "Could not publish assertion_audit.sqlite")
unlink(db_temp)
cat("Assertion audit:", nrow(points), "points,", sum(qualified), "qualified;",
    nrow(assertions), "assertions,", nrow(evidence), "evidence links;",
    sum(raw_matches), "registered TSV cells verified\n")

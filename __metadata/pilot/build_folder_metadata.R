# Derive metadata resource routes from each paper folder's file-level registry
# and expose them as relational tables. pipeline_files.csv is authoritative;
# metadata_sources.csv is a compatibility view and is not read here.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __metadata/pilot/build_folder_metadata.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
for (pkg in c("readr", "readxl", "DBI", "RSQLite", "dplyr"))
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)

folders <- c("ManyPrimates__2022", "Mink_etal_1981", "Boddy_etal_2012",
             "Falcone_etal_2019", "Buchsbaum_etal_1989", "Kaufman__2004",
             "Heffner_Heffner_2010_b", "Bahney_vonBartheld_2018",
             "Fobbs_etal_2011", "Kennedy_etal_1978")
required <- c("resource_id", "source_class", "path", "registered_item_id",
              "builder_r", "public_tsv_path", "content_role", "record_grain",
              "authority_status", "related_item_id", "note")
file_columns <- c("file_id", "path", "item_id", "file_role", "content_role",
  "record_grain", "creation_mode", "stage", "authority_status",
  "producer_id", "lifecycle_status", "note")
read_chars <- function(path) {
  x <- suppressWarnings(readr::read_csv(path, show_col_types = FALSE,
    col_types = readr::cols(.default = readr::col_character()), na = character()))
  if (nrow(readr::problems(x))) stop("CSV parse problem: ", path)
  x
}
is_local <- function(path, folder) {
  startsWith(path, paste0(folder, "/")) &&
    !grepl("(^|/)\\.\\.(/|$)", path) && !grepl("://", path, fixed = TRUE)
}
exists_local <- function(path) nzchar(path) && file.exists(file.path(root, path)) &&
  !dir.exists(file.path(root, path))

sources <- dplyr::bind_rows(lapply(folders, function(folder) {
  path <- file.path(root, folder, "pipeline_files.csv")
  if (!file.exists(path)) stop("Missing paper file registry: ", path)
  files <- as.data.frame(read_chars(path), stringsAsFactors = FALSE)
  if (!identical(names(files), file_columns))
    stop(folder, "/pipeline_files.csv needs the standard file columns in order")
  if (anyDuplicated(files$file_id) || anyDuplicated(files$path))
    stop(folder, " has duplicate file IDs or paths")
  file_by_id <- match(files$producer_id, files$file_id)
  if (any(nzchar(files$producer_id) & is.na(file_by_id)))
    stop(folder, " has an unknown producer ID")
  source_roles <- c("item_csv", "source_table", "snapshot", "metadata_table",
                    "pipeline_output", "source_document", "support_script",
                    "documentation")
  x <- files[files$file_role %in% source_roles &
               files$lifecycle_status == "active", , drop = FALSE]
  classes <- ifelse(x$file_role == "item_csv", "registered_matrix",
    ifelse(x$file_role %in% c("source_table", "snapshot", "metadata_table",
                               "pipeline_output"), "unregistered_matrix",
           "unregistered_other"))
  producer_path <- files$path[match(x$producer_id, files$file_id)]
  producer_path[is.na(producer_path)] <- ""
  item_public <- files[files$file_role == "public_tsv", c("item_id", "path"),
                       drop = FALSE]
  if (anyDuplicated(item_public$item_id))
    stop(folder, " has more than one public TSV per item")
  public_path <- item_public$path[match(x$item_id, item_public$item_id)]
  public_path[is.na(public_path) | classes != "registered_matrix"] <- ""
  out <- data.frame(resource_id = x$file_id, source_class = classes,
    path = x$path,
    registered_item_id = ifelse(classes == "registered_matrix", x$item_id, ""),
    builder_r = producer_path, public_tsv_path = public_path,
    content_role = x$content_role, record_grain = x$record_grain,
    authority_status = x$authority_status,
    related_item_id = ifelse(classes == "registered_matrix", "", x$item_id),
    note = x$note, folder = folder, stringsAsFactors = FALSE)
  if (any(!nzchar(out$builder_r[out$source_class == "registered_matrix"])) ||
      any(!nzchar(out$public_tsv_path[out$source_class == "registered_matrix"])))
    stop(folder, " has a registered item without builder or public TSV")
  out
}))
if (!nrow(sources) || anyDuplicated(sources$resource_id) ||
    anyDuplicated(sources$path))
  stop("Metadata resources need nonempty, globally unique IDs and paths")
for (field in c("resource_id", "path", "source_class", "content_role",
                "record_grain", "authority_status"))
  if (any(!nzchar(sources[[field]])))
    stop("Metadata source has blank ", field)
if (any(!sources$source_class %in%
        c("registered_matrix", "unregistered_matrix", "unregistered_other")))
  stop("Unknown source_class in folder metadata manifest")
role_vocab <- read_chars(file.path(here, "content_role_vocabulary.csv"))
if (!identical(names(role_vocab),
               c("content_role", "content_group", "definition")) ||
    anyDuplicated(role_vocab$content_role) ||
    any(!nzchar(role_vocab$content_role) | !nzchar(role_vocab$content_group)))
  stop("Content-role vocabulary is malformed")
sources$content_group <- role_vocab$content_group[
  match(sources$content_role, role_vocab$content_role)]
if (anyNA(sources$content_group))
  stop("A folder metadata content_role is missing from the vocabulary")
authority_vocab <- read_chars(file.path(here, "authority_status_vocabulary.csv"))
if (!identical(names(authority_vocab), c("authority_status", "definition")) ||
    anyDuplicated(authority_vocab$authority_status) ||
    any(!nzchar(authority_vocab$authority_status)) ||
    any(!sources$authority_status %in% authority_vocab$authority_status))
  stop("A folder metadata authority_status is missing from the vocabulary")
if (any(!mapply(is_local, sources$path, sources$folder)) ||
    any(!vapply(sources$path, exists_local, logical(1L))))
  stop("Metadata source path is outside its paper folder or missing")

registry <- suppressWarnings(readxl::read_excel(
  file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text"))
if (!all(c("Item name", "Item encoded") %in% names(registry)))
  stop("Registry is missing Item name or Item encoded")
registry <- as.data.frame(registry[, c("Item name", "Item encoded")],
                          stringsAsFactors = FALSE)
names(registry) <- c("item_id", "item_encoded")
registry <- registry[!is.na(registry$item_id) &
                       vapply(registry$item_id, function(item)
                         any(startsWith(item, paste0(folders, "_"))),
                         logical(1L)), , drop = FALSE]
if (anyDuplicated(registry$item_id) || anyDuplicated(registry$item_encoded))
  stop("Pilot-paper registry item IDs or encoded values are duplicated")
registry$folder <- vapply(registry$item_id, function(item)
  folders[which(startsWith(item, paste0(folders, "_")))][[1L]], character(1L))
registry$public_tsv_path <- file.path("__Public", "comparative-data",
                                     paste0(registry$item_encoded, ".tsv"))
registered <- sources[sources$source_class == "registered_matrix", , drop = FALSE]
if (!setequal(registered$registered_item_id, registry$item_id) ||
    nrow(registered) != nrow(registry) || anyDuplicated(registered$registered_item_id))
  stop("Folder manifests must list every live registered item exactly once; registry=",
       nrow(registry), ", manifest=", nrow(registered))
match_registry <- match(registered$registered_item_id, registry$item_id)
if (any(registered$folder != registry$folder[match_registry]) ||
    any(registered$public_tsv_path != registry$public_tsv_path[match_registry]) ||
    any(!nzchar(registered$builder_r)) ||
    any(!mapply(is_local, registered$builder_r, registered$folder)) ||
    any(!vapply(registered$builder_r, exists_local, logical(1L))) ||
    any(!vapply(registered$public_tsv_path, exists_local, logical(1L))) ||
    any(basename(registered$path) != paste0(registered$registered_item_id, ".csv")) ||
    any(basename(registered$builder_r) != paste0(registered$registered_item_id, ".R")))
  stop("Registered matrix lacks its matching R builder, CSV, public TSV, or registry identity")
builder_contract <- vapply(registered$builder_r, function(path) {
  code <- paste(readLines(file.path(root, path), warn = FALSE), collapse = "\n")
  grepl("__ReadMe.xlsx", code, fixed = TRUE) &&
    grepl("Item encoded", code, fixed = TRUE) &&
    grepl("write_csv|write.csv|write.table", code) &&
    grepl("write_tsv|write.table", code)
}, logical(1L))
if (any(!builder_contract))
  stop("Registered item R builder lacks the registry/CSV/TSV build contract: ",
       paste(registered$registered_item_id[!builder_contract], collapse = "; "))
supporting <- sources[sources$source_class != "registered_matrix", , drop = FALSE]
if (any(nzchar(supporting$registered_item_id)) ||
    any(nzchar(supporting$public_tsv_path)))
  stop("Unregistered source cannot claim a registered item ID or public TSV")
if (any(nzchar(sources$related_item_id) &
        !sources$related_item_id %in% registry$item_id))
  stop("A related_item_id is absent from the live registry")

artifacts <- read_chars(file.path(here, "artifacts.csv"))
routes <- read_chars(file.path(here, "field_routes.csv"))
if (anyDuplicated(artifacts$artifact_id)) stop("Duplicate catalog artifact ID")
artifact_resource_id <- sources$resource_id[match(artifacts$path, sources$path)]
registered_match <- match(artifacts$path, registered$public_tsv_path)
artifact_resource_id[is.na(artifact_resource_id) & !is.na(registered_match)] <-
  registered$resource_id[registered_match[is.na(artifact_resource_id) &
                                          !is.na(registered_match)]]
builder_match <- match(artifacts$path, registered$builder_r)
artifact_resource_id[is.na(artifact_resource_id) & !is.na(builder_match)] <-
  registered$resource_id[builder_match[is.na(artifact_resource_id) &
                                       !is.na(builder_match)]]
catalog_local <- vapply(artifacts$path, function(path)
  any(startsWith(path, paste0(folders, "/"))), logical(1L))
metadata_kinds <- c("item_definitions", "citation_lookup",
  "citation_scope_declaration", "item_taxon_lookup", "proposed_taxon_key",
  "proposed_species_crosswalk", "errata", "collection_manifest",
  "generated_citation_match", "generated_citation_summary",
  "generated_citation_issues", "cross_item_check_result",
  "ancillary_workbook", "publication_pdf", "supplement_doc", "item_readme",
  "ancillary_note", "source_correction_overlay")
missing_required <- artifacts$path[catalog_local &
  artifacts$artifact_kind %in% metadata_kinds & is.na(artifact_resource_id)]
if (length(missing_required))
  stop("Paper-local metadata evidence absent from folder manifest: ",
       paste(missing_required, collapse = "; "))
use_artifact <- match(routes$artifact_id, artifacts$artifact_id)
if (anyNA(use_artifact)) stop("Catalog route has an unknown artifact")
uses <- data.frame(
  route_id = seq_len(nrow(routes)),
  item_id = routes$item_id,
  resource_id = artifact_resource_id[use_artifact],
  evidence_path = artifacts$path[use_artifact],
  metadata_field = routes$metadata_field,
  locator = routes$locator,
  assertion_kind = routes$assertion_kind,
  granularity = routes$granularity,
  checkpoint = routes$checkpoint,
  stringsAsFactors = FALSE
)
uses <- uses[!is.na(uses$resource_id), , drop = FALSE]
if (!all(uses$item_id %in% registry$item_id) ||
    !all(uses$resource_id %in% sources$resource_id))
  stop("A folder metadata route has a missing item or resource")

registry_out <- registry[c("item_id", "folder", "item_encoded",
                           "public_tsv_path")]
sources_out <- as.data.frame(sources[c("resource_id", "folder", required[-1L])],
                             stringsAsFactors = FALSE)
sources_out$content_group <- sources$content_group
sources_out <- sources_out[c("resource_id", "folder", "source_class", "path",
  "registered_item_id", "builder_r", "public_tsv_path", "content_role",
  "content_group", "record_grain", "authority_status", "related_item_id",
  "note")]
sources_out$registered_item_id[!nzchar(sources_out$registered_item_id)] <- NA_character_
sources_out$related_item_id[!nzchar(sources_out$related_item_id)] <- NA_character_
db_temp <- tempfile("folder_metadata_", tmpdir = here, fileext = ".sqlite")
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_temp)
on.exit(try(DBI::dbDisconnect(con), silent = TRUE), add = TRUE)
exec_sql <- function(sql) invisible(DBI::dbExecute(con, sql))
exec_sql("PRAGMA foreign_keys = ON")
exec_sql(paste(
  "CREATE TABLE registered_item (item_id TEXT PRIMARY KEY, folder TEXT NOT NULL,",
  "item_encoded TEXT NOT NULL UNIQUE, public_tsv_path TEXT NOT NULL UNIQUE)"))
exec_sql(paste(
  "CREATE TABLE content_role_vocabulary (content_role TEXT PRIMARY KEY,",
  "content_group TEXT NOT NULL, definition TEXT NOT NULL)"))
exec_sql(paste(
  "CREATE TABLE authority_status_vocabulary (authority_status TEXT PRIMARY KEY,",
  "definition TEXT NOT NULL)"))
exec_sql(paste(
  "CREATE TABLE resource (resource_id TEXT PRIMARY KEY, folder TEXT NOT NULL,",
  "source_class TEXT NOT NULL, path TEXT NOT NULL UNIQUE,",
  "registered_item_id TEXT REFERENCES registered_item(item_id),",
  "builder_r TEXT, public_tsv_path TEXT,",
  "content_role TEXT NOT NULL REFERENCES content_role_vocabulary(content_role),",
  "content_group TEXT NOT NULL,",
  "record_grain TEXT NOT NULL,",
  "authority_status TEXT NOT NULL REFERENCES authority_status_vocabulary(authority_status),",
  "related_item_id TEXT REFERENCES registered_item(item_id), note TEXT)"))
exec_sql(paste(
  "CREATE TABLE field_use (route_id INTEGER PRIMARY KEY,",
  "item_id TEXT NOT NULL REFERENCES registered_item(item_id),",
  "resource_id TEXT NOT NULL REFERENCES resource(resource_id),",
  "evidence_path TEXT NOT NULL,",
  "metadata_field TEXT NOT NULL, locator TEXT, assertion_kind TEXT NOT NULL,",
  "granularity TEXT NOT NULL, checkpoint TEXT NOT NULL)"))
DBI::dbWriteTable(con, "registered_item", registry_out, append = TRUE)
DBI::dbWriteTable(con, "content_role_vocabulary", role_vocab, append = TRUE)
DBI::dbWriteTable(con, "authority_status_vocabulary", authority_vocab, append = TRUE)
DBI::dbWriteTable(con, "resource", sources_out, append = TRUE)
DBI::dbWriteTable(con, "field_use", uses, append = TRUE)
exec_sql(paste(
  "CREATE VIEW field_evidence AS SELECT u.item_id, u.metadata_field,",
  "u.locator, u.granularity, u.checkpoint, u.evidence_path,",
  "r.resource_id, r.source_class, r.path AS resource_path,",
  "r.content_role, r.content_group, r.authority_status FROM field_use u",
  "JOIN resource r ON r.resource_id = u.resource_id"))
fk <- DBI::dbGetQuery(con, "PRAGMA foreign_key_check")
if (nrow(fk)) stop("Folder metadata SQLite foreign keys failed")
DBI::dbDisconnect(con)
target <- file.path(here, "folder_metadata.sqlite")
if (!file.copy(db_temp, target, overwrite = TRUE))
  stop("Could not publish folder_metadata.sqlite")
unlink(db_temp)
audit <- sources |>
  dplyr::count(folder, source_class, name = "n_resources") |>
  dplyr::arrange(folder, source_class)
readr::write_csv(audit, file.path(here, "folder_metadata_audit.csv"), na = "")
gate_scope <- read_chars(file.path(root, "__measurements", "pilot_metadata", "scope.csv"))
route_counts <- table(routes$item_id)
route_coverage <- data.frame(
  item_id = registry$item_id,
  folder = registry$folder,
  in_measurement_gate = registry$item_id %in% gate_scope$item,
  has_definition_route = registry$item_id %in%
    routes$item_id[routes$metadata_field == "item_definition"],
  has_reported_value_route = registry$item_id %in%
    routes$item_id[routes$metadata_field == "reported_value"],
  has_source_role_review_route = registry$item_id %in%
    routes$item_id[routes$metadata_field == "source_role_review"],
  n_field_routes = as.integer(route_counts[registry$item_id]),
  stringsAsFactors = FALSE
)
if (anyNA(route_coverage$n_field_routes) ||
    any(!route_coverage$has_definition_route) ||
    any(!gate_scope$item %in% registry$item_id))
  stop("Registered item route coverage or measurement scope is incomplete")
readr::write_csv(route_coverage,
                 file.path(here, "item_route_coverage.csv"), na = "")
cat("Folder metadata validated:", nrow(registry), "registered matrices,",
    nrow(supporting), "unregistered sources,", nrow(uses),
    "catalogued field uses,", nrow(fk), "foreign-key issues\n")

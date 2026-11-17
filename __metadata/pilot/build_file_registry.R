# Combine and validate the paper-folder and shared pilot file registries.
# Run after the other pilot outputs have been built. Public item identity still
# comes from __ReadMe.xlsx; every other active file gets a file-level record.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __metadata/pilot/build_file_registry.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
for (pkg in c("readr", "readxl", "DBI", "RSQLite"))
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)

folders <- c("ManyPrimates__2022", "Mink_etal_1981", "Boddy_etal_2012",
  "Falcone_etal_2019", "Buchsbaum_etal_1989", "Kaufman__2004",
  "Heffner_Heffner_2010_b", "Bahney_vonBartheld_2018",
  "Fobbs_etal_2011", "Kennedy_etal_1978")
file_columns <- c("file_id", "path", "item_id", "file_role", "content_role",
  "record_grain", "creation_mode", "stage", "authority_status",
  "producer_id", "lifecycle_status", "note")
dependency_columns <- c("output_file_id", "input_file_id", "relation",
  "source_locator", "note")
read_chars <- function(path, expected) {
  if (!file.exists(path)) stop("Missing file registry input: ", path)
  x <- suppressWarnings(readr::read_csv(path, show_col_types = FALSE,
    col_types = readr::cols(.default = readr::col_character()), na = character()))
  if (nrow(readr::problems(x))) stop("CSV parse problem: ", path)
  if (!identical(names(x), expected))
    stop("Unexpected columns in ", path)
  as.data.frame(x, stringsAsFactors = FALSE)
}
file_inputs <- c(file.path(root, folders, "pipeline_files.csv"),
                 file.path(here, "shared_pipeline_files.csv"))
dep_inputs <- c(file.path(root, folders, "file_dependencies.csv"),
                file.path(here, "shared_pipeline_dependencies.csv"))
files <- do.call(rbind, lapply(file_inputs, read_chars, expected = file_columns))
deps <- do.call(rbind, lapply(dep_inputs, read_chars, expected = dependency_columns))
owners <- rep(c(folders, "shared"), lengths(lapply(file_inputs, function(path)
  read_chars(path, file_columns)$file_id)))
rownames(files) <- rownames(deps) <- NULL
if (!nrow(files) || any(!nzchar(files$file_id)) || any(!nzchar(files$path)) ||
    anyDuplicated(files$file_id) || anyDuplicated(files$path))
  stop("File registry needs globally unique, nonblank IDs and paths")
if (any(!nzchar(deps$output_file_id)) || any(!nzchar(deps$input_file_id)) ||
    anyDuplicated(deps[c("output_file_id", "input_file_id", "relation")]))
  stop("Dependency keys are blank or duplicated")

file_roles <- c("source_document", "source_table", "snapshot", "item_builder",
  "item_csv", "public_tsv", "metadata_table", "support_script",
  "pipeline_script", "pipeline_output", "documentation", "manifest")
creation_modes <- c("external", "transcribed", "copied", "manual_curated",
  "generated", "unknown")
stages <- c("source", "snapshot", "paper_metadata", "item_processing",
  "curation", "qualification", "selection", "audit", "registry",
  "documentation")
relations <- c("produced_by", "exported_from", "reads", "validates_against",
  "derives_from", "derived_from", "transcribed_from", "copied_from")
if (any(!files$file_role %in% file_roles) ||
    any(!files$creation_mode %in% creation_modes) ||
    any(!files$stage %in% stages) ||
    any(!files$lifecycle_status %in% c("active", "ancillary", "retired")) ||
    any(!deps$relation %in% relations))
  stop("Unknown file role, creation mode, stage, lifecycle, or dependency relation")
role_vocab <- read_chars(file.path(here, "content_role_vocabulary.csv"),
                         c("content_role", "content_group", "definition"))
authority_vocab <- read_chars(file.path(here, "authority_status_vocabulary.csv"),
                              c("authority_status", "definition"))
if (any(!files$content_role %in% role_vocab$content_role) ||
    any(!files$authority_status %in% authority_vocab$authority_status) ||
    any(!nzchar(files$record_grain)))
  stop("File registry uses an unknown content role, authority status, or blank grain")

safe_path <- function(path) {
  nzchar(path) && !startsWith(path, "/") &&
    !grepl("(^|/)\\.\\.(/|$)", path) &&
    !grepl("://", path, fixed = TRUE)
}
if (any(!vapply(files$path, safe_path, logical(1))))
  stop("File registry has a path outside the repository")
for (i in seq_along(folders)) {
  row_idx <- which(owners == folders[[i]])
  if (any(!startsWith(files$path[row_idx], paste0(folders[[i]], "/")) &
          files$file_role[row_idx] != "public_tsv"))
    stop("Paper-folder registry has a nonlocal path: ", folders[[i]])
  reference_dir <- file.path(root, folders[[i]], "reference_tables")
  if (dir.exists(reference_dir)) {
    actual <- list.files(reference_dir, recursive = TRUE, full.names = TRUE,
                         all.files = FALSE, no.. = TRUE)
    actual <- actual[file.exists(actual) & !dir.exists(actual)]
    actual <- substring(normalizePath(actual, winslash = "/"), nchar(root) + 2L)
    missing <- setdiff(actual, files$path[row_idx])
    if (length(missing))
      stop("Unregistered reference_tables file: ", missing[[1L]])
  }
}
own_outputs <- file.path("__metadata/pilot", c("file_registry.csv",
  "file_dependencies.csv", "file_registry.sqlite", "file_registry_audit.csv",
  "file_registration_issues.csv"))
missing <- files$path[!file.exists(file.path(root, files$path))]
if (length(setdiff(missing, own_outputs)))
  stop("Registered active file is missing: ", setdiff(missing, own_outputs)[[1L]])
if (!all(own_outputs %in% files$path))
  stop("The combined file registry must register its own outputs")
exclusions <- read_chars(file.path(here, "shared_pipeline_exclusions.csv"),
  c("path_glob", "reason"))
if (any(!nzchar(exclusions$path_glob)) || any(!nzchar(exclusions$reason)) ||
    anyDuplicated(exclusions$path_glob))
  stop("Shared file exclusions need unique patterns and reasons")
exclusion_rx <- vapply(exclusions$path_glob, glob2rx, character(1))
is_excluded <- function(path)
  any(vapply(exclusion_rx, function(rx) grepl(rx, path), logical(1)))
if (any(vapply(files$path, is_excluded, logical(1))))
  stop("An excluded shared-file pattern hides a registered file")
shared_dirs <- c("__metadata/pilot", "__measurements/pilot_metadata",
                 "__measurements/pilot_single_pipeline")
shared_actual <- unlist(lapply(shared_dirs, function(directory) {
  paths <- list.files(file.path(root, directory), full.names = TRUE,
                      all.files = TRUE, no.. = TRUE)
  paths[file.exists(paths) & !dir.exists(paths)]
}), use.names = FALSE)
shared_actual <- substring(normalizePath(shared_actual, winslash = "/"),
                           nchar(root) + 2L)
unregistered_shared <- setdiff(shared_actual, files$path)
unexplained_shared <- unregistered_shared[
  !vapply(unregistered_shared, is_excluded, logical(1))]
if (length(unexplained_shared))
  stop("Unregistered shared pilot file: ", unexplained_shared[[1L]])

if (any(nzchar(files$producer_id) &
        !files$producer_id %in% files$file_id) ||
    any(!deps$output_file_id %in% files$file_id) ||
    any(!deps$input_file_id %in% files$file_id) ||
    any(deps$output_file_id == deps$input_file_id))
  stop("File producer or dependency references an unknown/self file")
producer_roles <- files$file_role[match(files$producer_id[nzchar(files$producer_id)],
                                         files$file_id)]
if (any(!producer_roles %in% c("item_builder", "support_script",
                                "pipeline_script")))
  stop("A producer_id does not refer to an R/Python pipeline script")
if (any(files$creation_mode == "generated" & !nzchar(files$producer_id)))
  stop("A generated file lacks a producer_id")

registry <- suppressWarnings(readxl::read_excel(file.path(root, "__ReadMe.xlsx"),
  sheet = "Sheet1", col_types = "text"))
if (!all(c("Item name", "Item encoded") %in% names(registry)))
  stop("Live item registry lacks Item name or Item encoded")
pilot_registry <- as.data.frame(registry[, c("Item name", "Item encoded")],
                                stringsAsFactors = FALSE)
names(pilot_registry) <- c("item_id", "item_encoded")
pilot_registry <- pilot_registry[!is.na(pilot_registry$item_id) &
  vapply(pilot_registry$item_id, function(item)
    any(startsWith(item, paste0(folders, "_"))), logical(1)), , drop = FALSE]
if (anyDuplicated(pilot_registry$item_id) ||
    anyDuplicated(pilot_registry$item_encoded))
  stop("Live pilot item registry has duplicate names or encodings")
item_file_ids <- files$item_id[nzchar(files$item_id)]
if (any(!item_file_ids %in% pilot_registry$item_id))
  stop("File registry uses an item ID absent from the live public registry")
for (i in seq_len(nrow(pilot_registry))) {
  item <- pilot_registry$item_id[[i]]
  encoded <- pilot_registry$item_encoded[[i]]
  rows <- files[files$item_id == item, , drop = FALSE]
  for (role in c("item_builder", "item_csv", "public_tsv"))
    if (sum(rows$file_role == role) != 1L)
      stop(item, " must have exactly one ", role, " file record")
  builder <- rows[rows$file_role == "item_builder", , drop = FALSE]
  local_csv <- rows[rows$file_role == "item_csv", , drop = FALSE]
  public <- rows[rows$file_role == "public_tsv", , drop = FALSE]
  if (basename(builder$path) != paste0(item, ".R") ||
      basename(local_csv$path) != paste0(item, ".csv") ||
      public$path != file.path("__Public", "comparative-data",
                               paste0(encoded, ".tsv")) ||
      local_csv$producer_id != builder$file_id ||
      public$producer_id != builder$file_id)
    stop("Registered file chain differs from live item registry: ", item)
}
if (!setequal(pilot_registry$item_id, files$item_id[files$file_role == "item_csv"]))
  stop("File registry does not cover every live registered pilot matrix")

# The old artifact table remains a route-annotation index during migration.
# Its active file IDs/paths must agree exactly with the new file register.
artifacts <- read_chars(file.path(here, "artifacts.csv"),
  c("artifact_id", "path", "storage_zone", "artifact_kind",
    "registration_status", "owner_item", "authority_stage", "granularity",
    "producer", "note"))
active_artifacts <- artifacts[artifacts$authority_stage != "downstream_product", ,
                              drop = FALSE]
matched <- match(active_artifacts$artifact_id, files$file_id)
if (anyNA(matched) ||
    any(active_artifacts$path != files$path[matched]))
  stop("An active catalog artifact ID/path differs from the file registry")
routes <- read_chars(file.path(here, "field_routes.csv"),
  c("item_id", "metadata_field", "artifact_id", "locator",
    "assertion_kind", "granularity", "checkpoint"))
not_registered <- routes[!routes$artifact_id %in% files$file_id, , drop = FALSE]
if (nrow(not_registered) &&
    (any(not_registered$checkpoint != "source_choice") ||
     any(!not_registered$artifact_id %in%
           artifacts$artifact_id[artifacts$authority_stage == "downstream_product"])))
  stop("A current metadata route lacks a registered file")

files_out <- files[file_columns]
deps_out <- deps[dependency_columns]
readr::write_csv(files_out, file.path(here, "file_registry.csv"), na = "")
readr::write_csv(deps_out, file.path(here, "file_dependencies.csv"), na = "")
audit <- as.data.frame(table(registry_owner = owners,
  file_role = files$file_role, creation_mode = files$creation_mode),
  stringsAsFactors = FALSE)
audit <- audit[audit$Freq > 0L, , drop = FALSE]
names(audit)[names(audit) == "Freq"] <- "n_files"
readr::write_csv(audit, file.path(here, "file_registry_audit.csv"), na = "")
unknown_snapshot <- which(owners != "shared" & files$file_role == "snapshot" &
  files$lifecycle_status == "active" & files$creation_mode == "unknown")
paper_metadata <- which(owners != "shared" & files$file_role == "metadata_table" &
  files$lifecycle_status == "active" & files$creation_mode == "manual_curated")
has_source_edge <- vapply(paper_metadata, function(i) {
  related <- deps[deps$output_file_id == files$file_id[[i]] &
    deps$relation %in% c("reads", "derived_from", "derives_from",
                         "transcribed_from", "copied_from"), , drop = FALSE]
  if (!nrow(related)) return(FALSE)
  source_roles <- files$file_role[match(related$input_file_id, files$file_id)]
  any(source_roles %in% c("source_document", "source_table", "snapshot") &
      nzchar(related$source_locator))
}, logical(1))
metadata_without_source <- paper_metadata[!has_source_edge]
issue_rows <- rbind(
  data.frame(file_id = files$file_id[unknown_snapshot],
    path = files$path[unknown_snapshot], issue_code = "snapshot_creation_unknown",
    detail = "Snapshot producer or transcription method needs source review",
    stringsAsFactors = FALSE),
  data.frame(file_id = files$file_id[metadata_without_source],
    path = files$path[metadata_without_source],
    issue_code = "metadata_source_locator_missing",
    detail = "Manual paper metadata lacks a confirmed source-file edge with locator",
    stringsAsFactors = FALSE))
readr::write_csv(issue_rows, file.path(here, "file_registration_issues.csv"), na = "")

db_tmp <- tempfile("file_registry_", tmpdir = tempdir(), fileext = ".sqlite")
db <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_tmp)
on.exit(try(DBI::dbDisconnect(db), silent = TRUE), add = TRUE)
exec_sql <- function(sql) invisible(DBI::dbExecute(db, sql))
exec_sql("PRAGMA foreign_keys = ON")
exec_sql(paste("CREATE TABLE registered_item (item_id TEXT PRIMARY KEY,",
  "item_encoded TEXT NOT NULL UNIQUE)"))
exec_sql(paste("CREATE TABLE file (file_id TEXT PRIMARY KEY, path TEXT NOT NULL UNIQUE,",
  "item_id TEXT REFERENCES registered_item(item_id), file_role TEXT NOT NULL,",
  "content_role TEXT NOT NULL, record_grain TEXT NOT NULL,",
  "creation_mode TEXT NOT NULL, stage TEXT NOT NULL, authority_status TEXT NOT NULL,",
  "producer_id TEXT REFERENCES file(file_id) DEFERRABLE INITIALLY DEFERRED,",
  "lifecycle_status TEXT NOT NULL, note TEXT)"))
exec_sql(paste("CREATE TABLE dependency (output_file_id TEXT NOT NULL",
  "REFERENCES file(file_id), input_file_id TEXT NOT NULL REFERENCES file(file_id),",
  "relation TEXT NOT NULL, source_locator TEXT, note TEXT,",
  "PRIMARY KEY (output_file_id, input_file_id, relation))"))
exec_sql(paste("CREATE TABLE field_route (route_id INTEGER PRIMARY KEY,",
  "item_id TEXT NOT NULL REFERENCES registered_item(item_id),",
  "metadata_field TEXT NOT NULL, file_id TEXT NOT NULL REFERENCES file(file_id),",
  "locator TEXT, assertion_kind TEXT NOT NULL, granularity TEXT NOT NULL,",
  "checkpoint TEXT NOT NULL)"))
DBI::dbWriteTable(db, "registered_item", pilot_registry, append = TRUE)
db_files <- files_out
db_files$item_id[!nzchar(db_files$item_id)] <- NA_character_
db_files$producer_id[!nzchar(db_files$producer_id)] <- NA_character_
DBI::dbWriteTable(db, "file", db_files, append = TRUE)
DBI::dbWriteTable(db, "dependency", deps_out, append = TRUE)
active_routes <- routes[routes$artifact_id %in% files$file_id, , drop = FALSE]
active_routes <- data.frame(route_id = seq_len(nrow(active_routes)),
  item_id = active_routes$item_id,
  metadata_field = active_routes$metadata_field,
  file_id = active_routes$artifact_id,
  locator = active_routes$locator,
  assertion_kind = active_routes$assertion_kind,
  granularity = active_routes$granularity,
  checkpoint = active_routes$checkpoint, stringsAsFactors = FALSE)
DBI::dbWriteTable(db, "field_route", active_routes, append = TRUE)
fk <- DBI::dbGetQuery(db, "PRAGMA foreign_key_check")
if (nrow(fk)) stop("File registry foreign-key check failed")
exec_sql("CREATE INDEX dependency_input ON dependency(input_file_id)")
exec_sql("CREATE INDEX file_item_role ON file(item_id, file_role)")
exec_sql("CREATE INDEX field_route_item_field ON field_route(item_id, metadata_field)")
exec_sql(paste("CREATE VIEW metadata_evidence_route AS SELECT r.item_id,",
  "r.metadata_field, r.locator, r.assertion_kind, r.granularity, r.checkpoint,",
  "f.file_id, f.path, f.file_role, f.content_role, f.record_grain,",
  "f.creation_mode, f.authority_status, f.lifecycle_status FROM field_route r",
  "JOIN file f ON f.file_id = r.file_id"))
DBI::dbDisconnect(db)
if (!file.copy(db_tmp, file.path(here, "file_registry.sqlite"), overwrite = TRUE))
  stop("Could not publish file_registry.sqlite")
unlink(db_tmp)
cat("File registry validated:", nrow(files), "physical files,",
    nrow(deps), "declared dependencies,", nrow(pilot_registry),
    "public items,",
    sum(grepl("/reference_tables/", files$path, fixed = TRUE) &
        owners != "shared"), "paper reference-table files,",
    nrow(active_routes), "file-backed metadata routes,",
    nrow(active_artifacts), "aligned catalog artifacts,",
    nrow(issue_rows), "provenance review issues, 0 foreign-key issues\n")

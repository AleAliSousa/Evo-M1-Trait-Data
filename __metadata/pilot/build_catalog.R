# Build a small, typed catalog of metadata sources for the pilot items.
# The live registry and the three CSV manifests are read-only inputs.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L) stop("Run with Rscript __metadata/pilot/build_catalog.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")

for (pkg in c("readr", "readxl", "DBI", "RSQLite")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)
}

read_manifest <- function(name, required) {
  path <- file.path(here, name)
  if (!file.exists(path)) stop("Missing manifest: ", path)
  x <- suppressWarnings(readr::read_csv(
    path, show_col_types = FALSE,
    col_types = readr::cols(.default = readr::col_character()),
    na = character()
  ))
  if (nrow(readr::problems(x)))
    stop(name, " has a CSV parsing problem at row ",
         readr::problems(x)$row[[1L]])
  missing <- setdiff(required, names(x))
  if (length(missing)) stop(name, " missing columns: ", paste(missing, collapse = ", "))
  x[] <- lapply(x, trimws)
  as.data.frame(x, stringsAsFactors = FALSE)
}
require_nonempty <- function(x, fields, table) {
  for (field in fields) {
    bad <- which(!nzchar(x[[field]]) | is.na(x[[field]]))
    if (length(bad)) stop(table, " has blank ", field, " at row ", bad[[1L]])
  }
}
require_unique <- function(x, fields, table) {
  bad <- which(duplicated(x[fields]))
  if (length(bad)) stop(table, " has duplicate ", paste(fields, collapse = "+"),
                        " at row ", bad[[1L]])
}
require_ids <- function(x, field, table) {
  bad <- which(!grepl("^[A-Za-z0-9][A-Za-z0-9_.-]*$", x[[field]]))
  if (length(bad)) stop(table, " has invalid ", field, " at row ", bad[[1L]])
}
local_path <- function(path, table, row, require_exists = TRUE) {
  if (!nzchar(path) || startsWith(path, "/") ||
      grepl("(^|/)\\.\\.(/|$)", path) || grepl("://", path, fixed = TRUE)) {
    stop(table, " row ", row, " needs a repository-root-relative file path: ", path)
  }
  full <- file.path(root, path)
  if (!file.exists(full)) {
    if (require_exists)
      stop(table, " row ", row, " path does not exist: ", path)
    return(full)
  }
  if (dir.exists(full)) stop(table, " row ", row, " path is a directory: ", path)
  full <- normalizePath(full, winslash = "/")
  if (!startsWith(full, paste0(root, "/"))) {
    stop(table, " row ", row, " resolves outside repository: ", path)
  }
  full
}

items <- read_manifest(
  "items.csv", c("item_id", "item_kind", "public_tsv_path")
)
artifacts <- read_manifest(
  "artifacts.csv",
  c("artifact_id", "path", "storage_zone", "artifact_kind",
    "registration_status", "owner_item", "authority_stage",
    "granularity", "producer", "note")
)
routes <- read_manifest(
  "field_routes.csv",
  c("item_id", "metadata_field", "artifact_id", "locator",
    "assertion_kind", "granularity", "checkpoint")
)
require_nonempty(items, c("item_id", "item_kind", "public_tsv_path"), "items.csv")
require_nonempty(artifacts,
                 c("artifact_id", "path", "storage_zone", "artifact_kind",
                   "registration_status", "authority_stage", "granularity"),
                 "artifacts.csv")
require_nonempty(routes,
                 c("item_id", "metadata_field", "artifact_id",
                   "assertion_kind", "granularity", "checkpoint"),
                 "field_routes.csv")
require_unique(items, "item_id", "items.csv")
require_unique(items, "public_tsv_path", "items.csv")
require_unique(artifacts, "artifact_id", "artifacts.csv")
require_ids(items, "item_id", "items.csv")
require_ids(artifacts, "artifact_id", "artifacts.csv")
require_unique(routes,
               c("item_id", "metadata_field", "artifact_id",
                 "locator", "assertion_kind", "checkpoint"),
               "field_routes.csv")
if (!nrow(items) || !nrow(artifacts) || !nrow(routes))
  stop("The catalog requires items, artifacts, and field routes")
expected_items <- c(
  "ManyPrimates__2022_STMperformance",
  "ManyPrimates__2022_speciespredictors",
  "Mink_etal_1981_REFERENCES",
  "Mink_etal_1981_TABLE1",
  "Boddy_etal_2012_TableS1",
  "Boddy_etal_2012_brainbodydatabasev2.txt",
  "Falcone_etal_2019_TABLE1",
  "Falcone_etal_2019_TABLE2",
  "Buchsbaum_etal_1989_TableI",
  "Buchsbaum_etal_1989_Text",
  paste0("Kaufman__2004_TableA", seq_len(15L)),
  "Heffner_Heffner_2010_b_Table1",
  "Bahney_vonBartheld_2018_TABLE1",
  "Bahney_vonBartheld_2018_TABLE2",
  "Bahney_vonBartheld_2018_TABLE3",
  "Bahney_vonBartheld_2018_TABLE4",
  "Fobbs_etal_2011_TableS1a",
  "Fobbs_etal_2011_TableS1b",
  "Fobbs_etal_2011_TableS2",
  "Fobbs_etal_2011_TableS3",
  "Fobbs_etal_2011_TableS4",
  "Fobbs_etal_2011_TableS5a",
  "Fobbs_etal_2011_TableS5b",
  "Kennedy_etal_1978_Table",
  "Kennedy_etal_1978_Text"
)
if (!setequal(items$item_id, expected_items) ||
    nrow(items) != length(expected_items)) {
  stop("items.csv must contain all 39 registered items in the ten pilot folders exactly once")
}
if (any(!endsWith(items$public_tsv_path, ".tsv")))
  stop("Every item public_tsv_path must end in .tsv")
if (any(!startsWith(items$public_tsv_path, "__Public/comparative-data/")))
  stop("Every registered item output must live in __Public/comparative-data/")
invisible(mapply(local_path, items$public_tsv_path,
                 MoreArgs = list(table = "items.csv"),
                 row = seq_len(nrow(items))))
invisible(mapply(function(path, stage, row) {
  local_path(path, "artifacts.csv", row,
             require_exists = stage != "downstream_product")
}, artifacts$path, artifacts$authority_stage,
   seq_len(nrow(artifacts))))

if (any(nzchar(artifacts$owner_item) &
        !artifacts$owner_item %in% items$item_id)) {
  stop("artifacts.csv contains an owner_item absent from items.csv")
}
if (any(!routes$item_id %in% items$item_id))
  stop("field_routes.csv contains an item_id absent from items.csv")
if (any(!routes$artifact_id %in% artifacts$artifact_id))
  stop("field_routes.csv contains an artifact_id absent from artifacts.csv")
if (any(!items$item_kind %in% c("observation_table", "reference_list",
                                "specimen_catalog")))
  stop("item_kind must be observation_table, reference_list, or specimen_catalog")
allowed_checkpoints <- c("snapshot", "item_processing", "inventory_extraction",
                         "source_trace", "method_review", "taxon_review",
                         "qualification", "source_choice")
if (any(!routes$checkpoint %in% allowed_checkpoints))
  stop("field_routes.csv contains an unknown checkpoint")
check_route_count <- function(item_ids, field, expected = 1L) {
  counts <- vapply(item_ids, function(item) {
    sum(routes$item_id == item & routes$metadata_field == field)
  }, integer(1))
  bad <- which(counts != expected)
  if (length(bad)) stop("Expected ", expected, " ", field,
                        " route(s) for ", item_ids[[bad[[1L]]]],
                        "; found ", counts[[bad[[1L]]]])
}
for (field in c("item_definition", "reporting_reference", "item_output"))
  check_route_count(items$item_id, field)
# The catalog covers every registered matrix in the pilot folders; the
# reported-value routes below are deliberately limited to items whose cells
# the measurement gate has actually scoped and reviewed. A registered matrix
# without these routes is catalogued, not silently qualified.
observation_items <- unique(routes$item_id[
  routes$metadata_field == "reported_value" &
    routes$item_id %in% items$item_id[items$item_kind == "observation_table"]
])
for (field in c("reported_value", "printed_species", "accepted_species"))
  check_route_count(observation_items, field)
specimen_items <- items$item_id[items$item_kind == "specimen_catalog"]
for (field in c("specimen_metadata", "taxon_context"))
  check_route_count(specimen_items, field)

registered_code <- "registered_item_output"
support_code <- "supporting"
allowed_registration <- c(registered_code, support_code)
if (any(!artifacts$registration_status %in% allowed_registration)) {
  stop("registration_status must be registered_item_output or supporting")
}
allowed_stage <- c("source_evidence", "item_processing",
                   "curated_authority", "downstream_product")
if (any(!artifacts$authority_stage %in% allowed_stage)) {
  stop("authority_stage must be source_evidence, item_processing, ",
       "curated_authority, or downstream_product")
}
registered <- artifacts[artifacts$registration_status == registered_code, , drop = FALSE]
if (nrow(registered) != nrow(items) ||
    anyDuplicated(registered$owner_item) ||
    any(!registered$owner_item %in% items$item_id)) {
  stop("Each item must have exactly one registered_item_output artifact")
}
registered_item_path <- items$public_tsv_path[
  match(registered$owner_item, items$item_id)
]
if (any(registered$path != registered_item_path)) {
  stop("registered_item_output artifacts must match their owner's public_tsv_path")
}
if (any(registered$authority_stage != "item_processing")) {
  stop("registered_item_output artifacts must have authority_stage = item_processing")
}
if (any(artifacts$registration_status == support_code &
        artifacts$path %in% items$public_tsv_path)) {
  stop("A public item TSV cannot be classified as supporting")
}

route_stage <- artifacts$authority_stage[
  match(routes$artifact_id, artifacts$artifact_id)
]
bad_feedback <- which(route_stage == "downstream_product" &
                        routes$checkpoint != "source_choice")
if (length(bad_feedback)) {
  stop("A downstream product may route only to the source_choice audit: ",
       "field_routes.csv row ", bad_feedback[[1L]], " (",
       routes$metadata_field[[bad_feedback[[1L]]]], ")")
}

# Registry items and physical metadata artifacts are different entities. An
# item row is checked against the live workbook, not against a saved snapshot.
registry <- suppressWarnings(readxl::read_excel(
  file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text"
))
if (!all(c("Item name", "Item encoded") %in% names(registry)))
  stop("Live __ReadMe.xlsx lacks Item name or Item encoded")
registry_name <- trimws(registry[["Item name"]])
registry_stem <- trimws(registry[["Item encoded"]])
items$registry_item_encoded <- character(nrow(items))
for (i in seq_len(nrow(items))) {
  hits <- which(!is.na(registry_name) & registry_name == items$item_id[[i]])
  if (length(hits) != 1L)
    stop("Expected exactly one live registry row for ", items$item_id[[i]],
         "; found ", length(hits))
  stem <- registry_stem[[hits]]
  if (is.na(stem) || !nzchar(stem))
    stop("Live registry Item encoded is blank for ", items$item_id[[i]])
  filename_stem <- tools::file_path_sans_ext(basename(items$public_tsv_path[[i]]))
  if (stem != filename_stem)
    stop("Public TSV stem does not match live Item encoded for ",
         items$item_id[[i]], ": ", filename_stem, " versus ", stem)
  items$registry_item_encoded[[i]] <- stem
}

artifacts$owner_item[!nzchar(artifacts$owner_item)] <- NA_character_
db_temp <- tempfile("pilot_metadata_catalog_", fileext = ".sqlite")
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_temp)
exec_sql <- function(statement) invisible(DBI::dbExecute(con, statement))
exec_sql( "PRAGMA foreign_keys = ON")
exec_sql( paste(
  "CREATE TABLE item (item_id TEXT PRIMARY KEY, item_kind TEXT NOT NULL,",
  "public_tsv_path TEXT NOT NULL UNIQUE, registry_item_encoded TEXT NOT NULL UNIQUE)"
))
exec_sql( paste(
  "CREATE TABLE artifact (artifact_id TEXT PRIMARY KEY, path TEXT NOT NULL,",
  "storage_zone TEXT NOT NULL, artifact_kind TEXT NOT NULL,",
  "registration_status TEXT NOT NULL, owner_item TEXT REFERENCES item(item_id),",
  "authority_stage TEXT NOT NULL, granularity TEXT NOT NULL,",
  "producer TEXT, note TEXT)"
))
exec_sql( paste(
  "CREATE TABLE field_route (route_id INTEGER PRIMARY KEY,",
  "item_id TEXT NOT NULL REFERENCES item(item_id),",
  "metadata_field TEXT NOT NULL,",
  "artifact_id TEXT NOT NULL REFERENCES artifact(artifact_id),",
  "locator TEXT, assertion_kind TEXT NOT NULL,",
  "granularity TEXT NOT NULL, checkpoint TEXT NOT NULL)"
))
DBI::dbWriteTable(con, "item", items, append = TRUE)
DBI::dbWriteTable(con, "artifact", artifacts, append = TRUE)
DBI::dbWriteTable(con, "field_route", routes, append = TRUE)
exec_sql( "CREATE INDEX field_route_item_checkpoint ON field_route(item_id, checkpoint)")
exec_sql( "CREATE INDEX field_route_artifact ON field_route(artifact_id)")
exec_sql( paste(
  "CREATE VIEW metadata_routes AS",
  "SELECT r.item_id, i.item_kind, r.metadata_field, r.checkpoint,",
  "r.assertion_kind, r.granularity AS route_granularity, r.locator,",
  "a.artifact_id, a.path, a.storage_zone, a.artifact_kind,",
  "a.registration_status, a.authority_stage, a.owner_item, a.producer",
  "FROM field_route r JOIN item i ON i.item_id = r.item_id",
  "JOIN artifact a ON a.artifact_id = r.artifact_id"
))
exec_sql( paste(
  "CREATE VIEW checkpoint_coverage AS",
  "SELECT item_id, checkpoint, COUNT(*) AS n_routes,",
  "COUNT(DISTINCT metadata_field) AS n_fields,",
  "COUNT(DISTINCT artifact_id) AS n_artifacts",
  "FROM field_route GROUP BY item_id, checkpoint"
))
exec_sql( paste(
  "CREATE VIEW artifact_registration AS",
  "SELECT a.artifact_id, a.path, a.storage_zone, a.artifact_kind,",
  "a.registration_status, a.authority_stage, a.owner_item,",
  "i.item_kind, i.registry_item_encoded",
  "FROM artifact a LEFT JOIN item i ON i.item_id = a.owner_item"
))
exec_sql( paste(
  "CREATE VIEW stage_location_flags AS",
  "SELECT artifact_id, path, storage_zone, authority_stage, note",
  "FROM artifact WHERE path GLOB '__merging_*'",
  "AND authority_stage <> 'downstream_product'"
))
if (nrow(DBI::dbGetQuery(con, "PRAGMA foreign_key_check")))
  stop("SQLite foreign-key validation failed")
db_counts <- c(
  items = DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM item")$n[[1L]],
  artifacts = DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM artifact")$n[[1L]],
  routes = DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM field_route")$n[[1L]]
)
DBI::dbDisconnect(con)
target <- file.path(here, "catalog.sqlite")
if (!file.copy(db_temp, target, overwrite = TRUE))
  stop("Could not publish catalog.sqlite")
unlink(db_temp)
cat("Catalog built:", db_counts[["items"]], "registered items,",
    db_counts[["artifacts"]], "artifacts,",
    db_counts[["routes"]], "field routes\n")

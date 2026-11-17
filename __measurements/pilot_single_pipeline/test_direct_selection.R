# Ten-paper report -> qualification -> source-choice pilot.
# Inputs: prepared report metadata, supported lineage, and registered source items.
# No __merging_* table is read.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __measurements/pilot_single_pipeline/test_direct_selection.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
for (pkg in c("readr", "DBI", "RSQLite"))
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)

read_chars <- function(path, tsv = FALSE) {
  reader <- if (tsv) readr::read_tsv else readr::read_csv
  suppressWarnings(reader(path, show_col_types = FALSE,
                          col_types = readr::cols(.default = readr::col_character()),
                          na = character()))
}
write_out <- function(x, name) readr::write_csv(x, file.path(here, name), na = "")
one <- function(x, label) {
  if (nrow(x) != 1L) stop("Expected one ", label, "; found ", nrow(x))
  x[1L, , drop = FALSE]
}
require <- function(condition, message) {
  if (!isTRUE(condition)) stop(message)
}
catalog_path <- file.path(root, "__metadata", "pilot", "catalog.sqlite")
require(file.exists(catalog_path),
        "Build the typed metadata catalog before direct selection")
catalog_routes <- local({
  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = catalog_path,
                        flags = RSQLite::SQLITE_RO)
  on.exit(DBI::dbDisconnect(con))
  DBI::dbGetQuery(con,
    "SELECT item_id, metadata_field, path FROM metadata_routes")
})
route_file <- function(item, metadata_field) {
  x <- catalog_routes[catalog_routes$item_id == item &
                        catalog_routes$metadata_field == metadata_field, ,
                      drop = FALSE]
  require(nrow(x) == 1L,
          paste("Expected one catalog route for", item, metadata_field,
                "; found", nrow(x)))
  path <- file.path(root, x$path[[1L]])
  require(file.exists(path), paste("Catalog route file is missing:", path))
  path
}
metadata_dir <- file.path(root, "__measurements", "pilot_metadata")
reports <- read_chars(file.path(metadata_dir, "pilot_points.csv"))
lineage <- read_chars(file.path(metadata_dir, "lineage_links.csv"))
scope <- read_chars(file.path(metadata_dir, "scope.csv"))
required <- c("point_id", "item", "source_locator", "raw_value",
              "numeric_value", "accepted_species", "trait_id",
              "anatomy_behavior_target", "basis_group", "statistic", "unit",
              "source_role", "reporting_reference", "upstream_reference",
              "upstream_reference_id", "n_individuals_source_row",
              "dispersion_sd", "qualification_pass")
require(all(required %in% names(reports)),
        "Prepared pilot reports lack required metadata fields")
expected_items <- c(
  "ManyPrimates__2022_STMperformance",
  "ManyPrimates__2022_speciespredictors",
  "Mink_etal_1981_TABLE1",
  "Boddy_etal_2012_TableS1",
  "Boddy_etal_2012_brainbodydatabasev2.txt",
  "Falcone_etal_2019_TABLE1",
  "Falcone_etal_2019_TABLE2",
  "Buchsbaum_etal_1989_TableI",
  "Kaufman__2004_TableA3",
  "Heffner_Heffner_2010_b_Table1",
  "Bahney_vonBartheld_2018_TABLE1",
  "Bahney_vonBartheld_2018_TABLE2",
  "Bahney_vonBartheld_2018_TABLE3",
  "Bahney_vonBartheld_2018_TABLE4",
  "Fobbs_etal_2011_TableS1a",
  "Kennedy_etal_1978_Table",
  "Kennedy_etal_1978_Text"
)
require(setequal(unique(reports$item), expected_items),
        "Prepared reports do not cover the 17 measurement-scope items in ten papers")
require(!anyDuplicated(reports$point_id),
        "Prepared report point IDs are not unique")
require(all(reports$qualification_pass %in% c("TRUE", "FALSE")),
        "Qualification flag must be explicit for every report")
require(all(lineage$from_point_id %in% reports$point_id) &&
          all(lineage$to_point_id %in% reports$point_id),
        "Lineage references a point outside the ten-paper pilot")
qualified <- reports[reports$qualification_pass == "TRUE", , drop = FALSE]
held <- reports[reports$qualification_pass == "FALSE", , drop = FALSE]
require(nrow(qualified) > 0L && nrow(qualified) + nrow(held) == nrow(reports),
        "Qualification partition is incomplete")
for (field in c("accepted_species", "trait_id", "anatomy_behavior_target",
                "basis_group", "statistic", "unit", "reporting_reference"))
  require(all(nzchar(qualified[[field]])),
          paste("A qualified report lacks", field))

# Check the exact original -> secondary row against both public source items,
# their role definitions, and the later paper's reference lookup.
primary_id <- "DP-54cea553e335471d90eed8c5"
relay_id <- "DP-dfb56c7925a07c7938d0dbb3"
primary_point <- one(reports[reports$point_id == primary_id, , drop = FALSE],
                     "Buchsbaum thalamus point")
relay_point <- one(reports[reports$point_id == relay_id, , drop = FALSE],
                   "Kaufman Buchsbaum-thalamus point")
primary_path <- route_file("Buchsbaum_etal_1989_TableI", "item_output")
relay_path <- route_file("Kaufman__2004_TableA3", "item_output")
primary_source <- read_chars(primary_path, tsv = TRUE)
relay_source <- read_chars(relay_path, tsv = TRUE)
primary_match <- primary_source$printed_row == "16" &
  primary_source$section_as_published == "Subcortical gray" &
  primary_source$structure_as_published == "Thalamus" &
  primary_source$row_type == "region" & primary_source$arm_id == "awake"
relay_match <- relay_source$Reference == "(Buchsbaum et al., 1989)" &
  relay_source$Region == "Thalamus" & relay_source$Species == "Homo"
primary_row <- one(primary_source[which(primary_match), , drop = FALSE],
                   "Buchsbaum Table I awake thalamus row")
relay_row <- one(relay_source[which(relay_match), , drop = FALSE],
                 "Kaufman Table A3 Buchsbaum thalamus row")
primary_line <- which(primary_match) + 1L
relay_line <- which(relay_match) + 1L
primary_defs <- read_chars(route_file("Buchsbaum_etal_1989_TableI",
                                     "item_definition"))
relay_defs <- read_chars(route_file("Kaufman__2004_TableA3",
                                   "item_definition"))
primary_def <- one(primary_defs[
  primary_defs$Code == "CMRglc.umol_100g_min", , drop = FALSE],
  "Buchsbaum CMRglc definition")
thalamus_def <- one(primary_defs[
  primary_defs$Code == "Thalamus", , drop = FALSE],
  "Buchsbaum thalamus definition")
relay_def <- one(relay_defs[
  relay_defs$Code == "CMRgl_umol_100g_min", , drop = FALSE],
  "Kaufman CMRgl definition")
refs <- read_chars(route_file("Kaufman__2004_TableA3",
                              "upstream_reference"))
citation <- one(refs[
  refs$ref_key == relay_row$Reference[[1L]], , drop = FALSE],
  "Kaufman Buchsbaum citation")
require(primary_def$role[[1L]] == "primary" &&
          thalamus_def$role[[1L]] == "primary" &&
          thalamus_def$Structure[[1L]] == "Thalamus" &&
          relay_def$role[[1L]] == "secondary" &&
          primary_row$unit_as_printed[[1L]] == "micromoles/100g/min" &&
          grepl("umol/100 g/min", relay_def$Note[[1L]], fixed = TRUE),
        "Original and relay roles, anatomy, or units changed")
require(primary_row$n[[1L]] == "10" &&
          primary_row$mean_printed[[1L]] == "24.3" &&
          primary_row$dispersion_printed[[1L]] == "7.2" &&
          primary_row$dispersion_type[[1L]] == "SD" &&
          relay_row$n[[1L]] == primary_row$n[[1L]] &&
          relay_row$CMRgl_umol_100g_min[[1L]] == primary_row$mean_printed[[1L]] &&
          relay_row$CMRgl_SD[[1L]] == primary_row$dispersion_printed[[1L]] &&
          relay_row$Anesthesia[[1L]] == "none" &&
          relay_row$Mode[[1L]] == "PET",
        "Original and relay source rows differ on arm, n, mean, SD, or method")
require(citation$source_reference_id[[1L]] == "buchsbaum_1989" &&
          citation$source_type[[1L]] == "primary_report" &&
          citation$resolution_status[[1L]] == "resolved" &&
          grepl("TableA3", citation$cited_in_tables[[1L]], fixed = TRUE),
        "Kaufman's citation no longer resolves to Buchsbaum")
require(primary_point$source_locator[[1L]] ==
          paste0(basename(primary_path), ":", primary_line[[1L]],
                 ":CMRglc.umol_100g_min") &&
          relay_point$source_locator[[1L]] ==
          paste0(basename(relay_path), ":", relay_line[[1L]],
                 ":CMRgl_umol_100g_min") &&
          all(c(primary_point$qualification_pass, relay_point$qualification_pass) ==
                "TRUE") &&
          primary_point$source_role[[1L]] == "primary" &&
          relay_point$source_role[[1L]] == "secondary" &&
          primary_point$numeric_value[[1L]] == primary_row$mean_printed[[1L]] &&
          relay_point$numeric_value[[1L]] == relay_row$CMRgl_umol_100g_min[[1L]] &&
          primary_point$n_individuals_source_row[[1L]] == primary_row$n[[1L]] &&
          relay_point$n_individuals_source_row[[1L]] == relay_row$n[[1L]] &&
          primary_point$dispersion_sd[[1L]] == primary_row$dispersion_printed[[1L]] &&
          relay_point$dispersion_sd[[1L]] == relay_row$CMRgl_SD[[1L]],
        "Prepared pilot gate did not qualify the verified source pair")
pair_link <- lineage[
  lineage$from_point_id == primary_id &
    lineage$to_point_id == relay_id &
    lineage$relation == "reprinted_compilation_report", , drop = FALSE]
require(nrow(pair_link) == 1L, "Verified point-to-point relay link is absent")

# Exact duplicate relays can prefer one original point. Any other overlap
# remains undecided; equal numbers alone do not create a source link.
key_fields <- c("accepted_species", "trait_id", "anatomy_behavior_target",
                "basis_group", "statistic", "unit")
group_key <- do.call(paste, c(unname(qualified[key_fields]), sep = "\036"))
groups <- split(seq_len(nrow(qualified)), group_key)
linked_original <- function(x) {
  original <- x[x$source_role == "primary", , drop = FALSE]
  copied <- x[x$source_role == "secondary", , drop = FALSE]
  if (nrow(original) != 1L || nrow(copied) != nrow(x) - 1L ||
      nrow(copied) == 0L) return("")
  p <- original$point_id[[1L]]
  linked <- vapply(copied$point_id, function(id)
    sum(lineage$from_point_id == p & lineage$to_point_id == id &
          lineage$relation == "reprinted_compilation_report") == 1L,
    logical(1))
  if (!all(linked)) return("")
  for (field in c("numeric_value", "n_individuals_source_row", "dispersion_sd")) {
    values <- x[[field]]
    if (!all(nzchar(values)) || length(unique(values)) != 1L) return("")
  }
  p
}
choices <- lapply(names(groups), function(key) {
  x <- qualified[groups[[key]], , drop = FALSE]
  exact_original <- if (nrow(x) > 1L) linked_original(x) else ""
  selected_id <- if (nrow(x) == 1L) x$point_id[[1L]] else exact_original
  status <- if (nrow(x) == 1L) "provisional_singleton_in_pilot_scope" else
    if (nzchar(exact_original)) "verified_original_preferred_over_relay" else
      "needs_source_choice"
  data.frame(
    group_key = key,
    accepted_species = x$accepted_species[[1L]],
    trait_id = x$trait_id[[1L]],
    anatomy_behavior_target = x$anatomy_behavior_target[[1L]],
    basis_group = x$basis_group[[1L]],
    statistic = x$statistic[[1L]],
    unit = x$unit[[1L]],
    n_qualified_candidates = nrow(x),
    candidate_point_ids = paste(x$point_id, collapse = "; "),
    selected_point_id = selected_id,
    relayed_point_ids = if (nzchar(exact_original))
      paste(x$point_id[x$point_id != exact_original], collapse = "; ") else "",
    decision_status = status,
    decision_rule = if (nrow(x) == 1L)
      "only qualified candidate for this taxon/trait/anatomy/condition/basis" else
        if (nzchar(exact_original))
          "one primary plus exact linked secondary relay; same value, n, and SD" else
            "compare original methods, roles, and lineage before choosing",
    stringsAsFactors = FALSE
  )
})
selection <- do.call(rbind, choices)
selection <- selection[order(selection$accepted_species, selection$trait_id,
                             selection$anatomy_behavior_target,
                             selection$basis_group), , drop = FALSE]
row.names(selection) <- NULL
selection$selection_id <- sprintf("SEL-%05d", seq_len(nrow(selection)))
selection <- selection[c("selection_id", setdiff(names(selection), "selection_id"))]
selected_ids <- selection$selected_point_id[nzchar(selection$selected_point_id)]
require(!anyDuplicated(selected_ids) &&
          !any(selected_ids %in% held$point_id) &&
          all(selected_ids %in% qualified$point_id),
        "Held, duplicate, or absent report leaked into pilot selections")
pair_choice <- one(selection[
  grepl(primary_id, selection$candidate_point_ids, fixed = TRUE) &
    grepl(relay_id, selection$candidate_point_ids, fixed = TRUE), , drop = FALSE],
  "Buchsbaum/Kaufman same-group source choice")
require(pair_choice$n_qualified_candidates[[1L]] == 2L &&
          pair_choice$selected_point_id[[1L]] == primary_id &&
          pair_choice$relayed_point_ids[[1L]] == relay_id &&
          pair_choice$decision_status[[1L]] ==
            "verified_original_preferred_over_relay",
        "Buchsbaum/Kaufman pair was not chosen in the main pilot selection")

selected <- qualified[match(selected_ids, qualified$point_id), , drop = FALSE]
selected$selection_id <- selection$selection_id[
  match(selected$point_id, selection$selected_point_id)]
selected$decision_status <- selection$decision_status[
  match(selected$point_id, selection$selected_point_id)]
species_columns <- c(
  "selection_id", "point_id", "item", "source_locator",
  "printed_taxon", "accepted_species", "taxon_basis", "trait_id",
  "trait_definition", "anatomy_behavior_target", "basis_group",
  "statistic", "unit", "unit_evidence", "raw_value", "numeric_value",
  "dispersion_sd", "n_individuals_source_row", "sample_size_scope",
  "value_type", "value_origin", "source_role", "reporting_reference",
  "upstream_reference", "upstream_reference_id", "upstream_status",
  "measurement_method", "method_evidence", "transformation_method",
  "definition_evidence", "qualification_pass", "decision_status")
species_traits <- selected[species_columns]
species_traits <- species_traits[order(
  species_traits$accepted_species, species_traits$trait_id,
  species_traits$anatomy_behavior_target, species_traits$basis_group), ,
  drop = FALSE]
relay_check <- data.frame(
  selection_id = pair_choice$selection_id[[1L]],
  accepted_species = primary_point$accepted_species[[1L]],
  trait_id = primary_point$trait_id[[1L]],
  anatomy = primary_point$anatomy_behavior_target[[1L]],
  basis_group = primary_point$basis_group[[1L]],
  unit = primary_point$unit[[1L]],
  n = primary_point$n_individuals_source_row[[1L]],
  mean = primary_point$numeric_value[[1L]],
  sd = primary_point$dispersion_sd[[1L]],
  primary_point_id = primary_id,
  primary_source_locator = primary_point$source_locator[[1L]],
  primary_paper_locator = "Buchsbaum 1989 Table I, journal page 1354 (PDF page 6)",
  relay_point_id = relay_id,
  relay_source_locator = relay_point$source_locator[[1L]],
  relay_paper_locator = "Kaufman 2004 Table A3 (PDF page 125)",
  relay_citation = relay_row$Reference[[1L]],
  relay_reference_id = citation$source_reference_id[[1L]],
  report_relation = pair_link$relation[[1L]],
  selected_point_id = pair_choice$selected_point_id[[1L]],
  decision_status = pair_choice$decision_status[[1L]],
  stringsAsFactors = FALSE
)

# Persist the same report set and choices as relational tables. CSV columns
# containing joined candidate IDs are exports; the SQLite junctions carry
# one row per candidate and one row per reference relation. Heffner's
# generated source_match supplies one link per cell and printed key.
heffner_match <- read_chars(route_file(
  "Heffner_Heffner_2010_b_Table1", "source_match"))
require(nrow(heffner_match) == 48L &&
          all(heffner_match$status %in% c("matched", "matched_shared_key")),
        "Heffner source-match report has changed")
heffner_match$source_item_row <- as.character(
  as.integer(sub("^r", "", heffner_match$row_id)))
heffner_points <- reports[
  reports$item == "Heffner_Heffner_2010_b_Table1" &
    reports$column != "interaural_distance_functional_us",
  c("point_id", "source_item_row", "column", "upstream_status"), drop = FALSE]
heffner_key <- paste(heffner_points$source_item_row, heffner_points$column)
match_key <- paste(heffner_match$source_item_row, heffner_match$variable)
require(!anyDuplicated(heffner_key), "Heffner row/column point keys are not unique")
matched_index <- match(match_key, heffner_key)
require(!anyNA(matched_index) &&
          length(unique(heffner_points$point_id[matched_index])) == 42L,
        "Heffner cell-to-citation links did not cover 42 measured cells")
heffner_links <- data.frame(
  point_id = heffner_points$point_id[matched_index],
  reference_role = ifelse(
    heffner_points$upstream_status[matched_index] == "compound_citation_unresolved",
    "citation_bundle", ifelse(
      heffner_points$upstream_status[matched_index] == "bibliography_entry_missing",
      "citation_note", "upstream")),
  reference_text = heffner_match$citation,
  resolved_source_id = "",
  source_ref_keys = heffner_match$ref_key,
  stringsAsFactors = FALSE)
other_upstream <- reports[
  reports$item != "Heffner_Heffner_2010_b_Table1" &
    reports$source_role != "primary" &
    nzchar(reports$upstream_reference), , drop = FALSE]
point_references <- rbind(
  data.frame(point_id = reports$point_id,
             reference_role = "reporting",
             reference_text = reports$reporting_reference,
             resolved_source_id = "", source_ref_keys = ""),
  data.frame(point_id = other_upstream$point_id,
             reference_role = ifelse(
               other_upstream$upstream_status == "row_level_citation_scope_unverified",
               "row_context", ifelse(
                 other_upstream$upstream_status == "intermediate_review_reference",
                 "intermediate_review", ifelse(
                   other_upstream$upstream_status == "compound_citation_unresolved",
                   "citation_bundle", ifelse(
                     other_upstream$upstream_status == "bibliography_entry_missing",
                     "citation_note", "upstream")))),
             reference_text = other_upstream$upstream_reference,
             resolved_source_id = ifelse(
               other_upstream$upstream_status == "row_level_citation_scope_unverified",
               "", other_upstream$upstream_reference_id),
             source_ref_keys = other_upstream$upstream_keys),
  heffner_links)
point_references <- point_references[nzchar(point_references$reference_text), , drop = FALSE]
ref_text <- sort(unique(point_references$reference_text))
references <- data.frame(reference_id = sprintf("REF-%05d", seq_along(ref_text)),
                         reference_text = ref_text, stringsAsFactors = FALSE)
point_references$reference_id <- references$reference_id[
  match(point_references$reference_text, references$reference_text)]
point_references <- unique(point_references[
  c("point_id", "reference_id", "reference_role", "resolved_source_id",
    "source_ref_keys")])
require(!anyNA(point_references$reference_id),
        "A point reference lacks a reference-table row")
primary_ids <- reports$point_id[reports$source_role == "primary"]
require(!any(point_references$point_id %in% primary_ids &
               point_references$reference_role != "reporting"),
        "Primary report has a non-reporting source link")
qualified_group_key <- do.call(paste, c(unname(qualified[key_fields]),
                                         sep = "\036"))
candidates <- data.frame(
  selection_id = selection$selection_id[
    match(qualified_group_key, selection$group_key)],
  point_id = qualified$point_id, stringsAsFactors = FALSE)
require(!anyNA(candidates$selection_id), "A qualified point lacks a choice group")
db_selection <- selection[
  c("selection_id", key_fields, "n_qualified_candidates",
    "selected_point_id", "decision_status", "decision_rule")]
db_selection$selected_point_id[!nzchar(db_selection$selected_point_id)] <- NA_character_
db_path <- file.path(here, "pilot_single_pipeline.sqlite")
temp_db <- tempfile("pilot_sources_", tmpdir = tempdir(), fileext = ".sqlite")
db <- DBI::dbConnect(RSQLite::SQLite(), dbname = temp_db)
exec_sql <- function(sql) invisible(DBI::dbExecute(db, sql))
exec_sql("PRAGMA foreign_keys = ON")
DBI::dbWriteTable(db, "point_metadata", reports)
exec_sql("CREATE UNIQUE INDEX point_metadata_pk ON point_metadata(point_id)")
DBI::dbWriteTable(db, "item_variable", scope)
exec_sql("CREATE UNIQUE INDEX item_variable_pk ON item_variable(item, \"column\")")
DBI::dbWriteTable(db, "reference", references)
exec_sql("CREATE UNIQUE INDEX reference_pk ON reference(reference_id)")
exec_sql(paste(
  "CREATE TABLE point_reference (",
  "point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "reference_id TEXT NOT NULL REFERENCES reference(reference_id),",
  "reference_role TEXT NOT NULL, resolved_source_id TEXT, source_ref_keys TEXT,",
  "PRIMARY KEY (point_id, reference_id, reference_role))"))
DBI::dbWriteTable(db, "point_reference", point_references, append = TRUE)
exec_sql(paste(
  "CREATE TABLE lineage (",
  "from_point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "to_point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "relation TEXT NOT NULL, evidence TEXT,",
  "PRIMARY KEY (from_point_id, to_point_id, relation))"))
DBI::dbWriteTable(db, "lineage", lineage, append = TRUE)
exec_sql(paste(
  "CREATE TABLE selection_decision (",
  "selection_id TEXT PRIMARY KEY,",
  "accepted_species TEXT NOT NULL, trait_id TEXT NOT NULL,",
  "anatomy_behavior_target TEXT NOT NULL, basis_group TEXT NOT NULL,",
  "statistic TEXT NOT NULL, unit TEXT NOT NULL,",
  "n_qualified_candidates INTEGER NOT NULL,",
  "selected_point_id TEXT REFERENCES point_metadata(point_id),",
  "decision_status TEXT NOT NULL, decision_rule TEXT NOT NULL)"))
DBI::dbWriteTable(db, "selection_decision", db_selection, append = TRUE)
exec_sql(paste(
  "CREATE TABLE selection_candidate (",
  "selection_id TEXT NOT NULL REFERENCES selection_decision(selection_id),",
  "point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "PRIMARY KEY (selection_id, point_id))"))
DBI::dbWriteTable(db, "selection_candidate", candidates, append = TRUE)
exec_sql("CREATE VIEW qualified_reports AS SELECT * FROM point_metadata WHERE qualification_pass = 'TRUE'")
exec_sql("CREATE VIEW held_reports AS SELECT * FROM point_metadata WHERE qualification_pass = 'FALSE'")
exec_sql(paste(
  "CREATE VIEW selected_reports AS SELECT d.selection_id, p.*",
  "FROM selection_decision AS d JOIN point_metadata AS p",
  "ON d.selected_point_id = p.point_id"))
fk_issues <- DBI::dbGetQuery(db, "PRAGMA foreign_key_check")
require(nrow(fk_issues) == 0L, "Pilot SQLite foreign-key check failed")
db_counts <- DBI::dbGetQuery(db,
  "SELECT COUNT(*) AS n FROM selection_candidate")$n[[1L]]
require(db_counts == nrow(qualified),
        "SQLite candidate junction omitted a qualified report")
DBI::dbDisconnect(db)
if (file.exists(db_path) && !file.remove(db_path))
  stop("Could not replace previous pilot SQLite output")
if (!file.rename(temp_db, db_path)) {
  if (!file.copy(temp_db, db_path, overwrite = TRUE))
    stop("Could not install pilot SQLite output")
  unlink(temp_db)
}

write_out(selection[setdiff(names(selection), "group_key")],
          "selection_decisions.csv")
write_out(species_traits, "species_traits.csv")
write_out(held[c("point_id", "item", "source_locator", "column",
                 "printed_taxon", "accepted_species", "trait_id",
                 "anatomy_behavior_target", "basis_group", "blocker_codes",
                 "definition_evidence", "method_evidence", "taxon_basis",
                 "upstream_reference", "upstream_status", "source_note")],
          "held_reports.csv")
write_out(relay_check, "primary_relay_check.csv")
cat("Ten-paper direct selection:", nrow(reports), "reports;",
    nrow(qualified), "qualified;",
    nrow(selection), "comparison groups;",
    sum(selection$decision_status == "verified_original_preferred_over_relay"),
    "verified original/relay choice(s);",
    sum(selection$decision_status == "needs_source_choice"),
    "unresolved choice group(s); 0 __merging_* inputs\n")

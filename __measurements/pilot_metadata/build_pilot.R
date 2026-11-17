# Pilot qualification of report-level measurements. Reads the existing inventory
# and the typed metadata catalog; source tables and merges are never rewritten.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L) stop("Run with Rscript __measurements/pilot_metadata/build_pilot.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."))
flags <- commandArgs(trailingOnly = TRUE)
if (length(setdiff(flags, "--qualification-only")) || length(flags) > 1L)
  stop("Only --qualification-only is supported")
qualification_only <- "--qualification-only" %in% flags

for (pkg in c("DBI", "RSQLite", "dplyr", "dbplyr", "readr", "jsonlite")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)
}

read_chars <- function(path) {
  suppressWarnings(readr::read_csv(path, show_col_types = FALSE,
                                    col_types = readr::cols(.default = readr::col_character())))
}
plain <- function(x) {
  if (length(x) == 0L || is.na(x[1L])) return("")
  y <- trimws(as.character(x[1L]))
  if (y %in% c("NA", "N/A", "#N/A", "#VALUE!", "NULL", "nan")) "" else y
}
field <- function(x, key) plain(x[[key]])
collapse_nonempty <- function(x) paste(unique(x[nzchar(x)]), collapse = " | ")
catalog_path <- file.path(root, "__metadata", "pilot", "catalog.sqlite")
if (!file.exists(catalog_path)) {
  stop("Build the metadata catalog first: Rscript __metadata/pilot/build_catalog.R")
}
catalog_inputs <- file.path(root, "__metadata", "pilot",
                            c("items.csv", "artifacts.csv", "field_routes.csv"))
if (any(file.info(catalog_inputs)$mtime > file.info(catalog_path)$mtime)) {
  stop("Metadata catalog is older than its manifests; run Rscript __metadata/pilot/build_catalog.R")
}
catalog_con <- DBI::dbConnect(RSQLite::SQLite(), dbname = catalog_path,
                              flags = RSQLite::SQLITE_RO)
on.exit(DBI::dbDisconnect(catalog_con), add = TRUE)
catalog_routes <- DBI::dbGetQuery(catalog_con,
  "SELECT item_id, metadata_field, artifact_id, path, authority_stage, checkpoint FROM metadata_routes")
catalog_artifacts <- DBI::dbGetQuery(catalog_con,
  "SELECT artifact_id, path, artifact_kind, authority_stage FROM artifact")
route_path <- function(item, metadata_field, artifact_id = NULL) {
  x <- catalog_routes[catalog_routes$item_id == item &
                        catalog_routes$metadata_field == metadata_field, , drop = FALSE]
  if (!is.null(artifact_id)) x <- x[x$artifact_id == artifact_id, , drop = FALSE]
  if (nrow(x) != 1L) {
    stop("Expected one catalog route for ", item, "/", metadata_field,
         if (!is.null(artifact_id)) paste0("/", artifact_id) else "",
         "; found ", nrow(x))
  }
  x$path[[1L]]
}
item_folder <- function(item) {
  if (startsWith(item, "ManyPrimates__2022")) return("ManyPrimates__2022")
  if (startsWith(item, "Mink_etal_1981")) return("Mink_etal_1981")
  if (startsWith(item, "Boddy_etal_2012")) return("Boddy_etal_2012")
  if (startsWith(item, "Falcone_etal_2019")) return("Falcone_etal_2019")
  if (startsWith(item, "Buchsbaum_etal_1989")) return("Buchsbaum_etal_1989")
  if (startsWith(item, "Kaufman__2004")) return("Kaufman__2004")
  if (startsWith(item, "Heffner_Heffner_2010_b")) return("Heffner_Heffner_2010_b")
  if (startsWith(item, "Bahney_vonBartheld_2018")) return("Bahney_vonBartheld_2018")
  if (startsWith(item, "Fobbs_etal_2011")) return("Fobbs_etal_2011")
  if (startsWith(item, "Kennedy_etal_1978")) return("Kennedy_etal_1978")
  stop("No folder mapping for ", item)
}
definition_path <- function(item) {
  route_path(item, "item_definition")
}

scope <- read_chars(file.path(here, "scope.csv"))
stopifnot(!anyDuplicated(scope[c("item", "column")]))
con <- DBI::dbConnect(RSQLite::SQLite(),
                      dbname = file.path(root, "__measurements", "measurements.sqlite"),
                      flags = RSQLite::SQLITE_RO)
on.exit(DBI::dbDisconnect(con), add = TRUE)
items <- unique(scope$item)
all_points <- dplyr::tbl(con, "points") |>
  dplyr::filter(active == 1L, item %in% items) |>
  dplyr::select(point_id, item, column_name) |>
  dplyr::collect()
selected <- dplyr::tbl(con, "points") |>
  dplyr::filter(active == 1L, item %in% items) |>
  dplyr::inner_join(
    dplyr::tbl(con, "source_rows") |>
      dplyr::select(row_id, context_json),
    by = "row_id"
  ) |>
  dplyr::collect() |>
  dplyr::inner_join(scope, by = c("item", "column_name" = "column"))
stopifnot(!anyDuplicated(selected$point_id))
specimen_items <- DBI::dbGetQuery(catalog_con,
  "SELECT item_id FROM item WHERE item_kind = 'specimen_catalog'")$item_id
if (length(specimen_items)) {
  specimen_point_counts <- dplyr::tbl(con, "points") |>
    dplyr::filter(active == 1L, item %in% specimen_items) |>
    dplyr::count(item, column_name, name = "n_inventory_points") |>
    dplyr::collect()
  specimen_row_counts <- dplyr::tbl(con, "source_rows") |>
    dplyr::filter(item %in% specimen_items) |>
    dplyr::count(item, name = "n_source_rows") |>
    dplyr::collect()
  absent_numeric <- setdiff(specimen_items, specimen_point_counts$item)
  if (length(absent_numeric))
    specimen_point_counts <- dplyr::bind_rows(specimen_point_counts,
      data.frame(item = absent_numeric, column_name = "",
                 n_inventory_points = 0L))
  specimen_screen <- specimen_point_counts |>
    dplyr::left_join(specimen_row_counts, by = "item") |>
    dplyr::mutate(
      source_grain = ifelse(item == "Fobbs_etal_2011_TableS4", "box", "specimen"),
      disposition = ifelse(paste(item, column_name) %in%
        paste(scope$item, scope$column), "send_to_specimen_measurement_gate",
        "collection_or_preparation_context"),
      reason = ifelse(disposition == "send_to_specimen_measurement_gate",
        "Body length is a reported specimen value; definition, original method, age context, and aggregation need review before species-level use",
        "Catalog/process field; do not interpret as a species-level biological trait")) |>
    dplyr::arrange(item, column_name)
  readr::write_csv(specimen_screen,
                   file.path(here, "specimen_catalog_screen.csv"), na = "")
}
missing_scope <- scope |>
  dplyr::anti_join(selected |>
                     dplyr::distinct(item, column_name),
                   by = c("item", "column" = "column_name"))
if (nrow(missing_scope)) {
  stop("Pilot scope has no inventory points for: ",
       paste(paste(missing_scope$item, missing_scope$column, sep = "/"),
             collapse = ", "))
}

excluded_context <- all_points |>
  dplyr::anti_join(scope, by = c("item", "column_name" = "column")) |>
  dplyr::count(item, column_name, name = "n_inventory_candidates") |>
  dplyr::arrange(item, column_name)
readr::write_csv(excluded_context, file.path(here, "excluded_context.csv"), na = "")

definitions <- setNames(lapply(items, function(item) {
  read_chars(file.path(root, definition_path(item)))
}), items)
definition_problems <- dplyr::bind_rows(lapply(items, function(item) {
  x <- readr::problems(definitions[[item]])
  if (!nrow(x)) return(NULL)
  x$file <- ifelse(startsWith(x$file, paste0(root, "/")),
                   substring(x$file, nchar(root) + 2L), x$file)
  x$item <- item
  x$definition_file <- definition_path(item)
  x
}))
readr::write_csv(definition_problems, file.path(here, "definition_parse_issues.csv"), na = "")
definition_row <- function(item, code) {
  x <- definitions[[item]]
  y <- x[x$Code == code & !is.na(x$Code), , drop = FALSE]
  if (nrow(y) != 1L) return(NULL)
  y[1L, , drop = FALSE]
}
expected_unit_measure <- function(rule, column) {
  if (rule == "stm") return("proportion.correct")
  if (rule == "vocal") return("count.vocalizations")
  if (rule == "many_predictor") {
    measures <- c(
      life_expectancy = "life_expectancy",
      color_vision = "color_vision_category",
      group_size = "group_size",
      home_range = "home_range",
      day_journey_length = "day_journey_length",
      resting_time_percent_activitybudget = "percent.activity_budget",
      feeding_budget = "feeding_budget",
      dietary_breadth = "dietary_breadth",
      diet_diversity = "diet_diversity_category",
      percent_frugivory = "percent.frugivory",
      terrestriality = "terrestriality_category",
      body_size_kg = "Mass.kg"
    )
    return(unname(measures[[column]]))
  }
  if (rule %in% c("mink_brain_mass", "mink_spinal_mass", "boddy_summary")) return("Mass.g")
  if (rule == "mink_brain_oxygen") return("MR.cm3O2_100g_min")
  if (rule == "boddy_source_rows") return("mass_g")
  if (rule == "falcone_presence") return("category")
  if (rule == "buchsbaum_glucose") return("CMRglc.umol_100g_min")
  if (rule == "kaufman_glucose") return("CMRgl")
  if (rule == "kaufman_oxygen") return("CMRO2")
  if (rule == "kaufman_blood_flow") return("CBF")
  if (rule == "heffner_hearing") return("Frequency.kHz")
  if (rule == "heffner_interaural") return("Time.us")
  if (rule == "heffner_basilar") return("Length.mm")
  if (rule == "bahney_primary_cells") return("C.n")
  if (rule == "bahney_primary_pct") {
    return(c(nonneuronal_pct = "pct.nonneuronal", glia_pct = "pct.glia",
             neuron_pct = "pct.neurons", endothelial_pct = "pct.endothelial")[[column]])
  }
  if (rule == "bahney_primary_ratio") return("O.p.N")
  if (rule == "bahney_compiled_mass") return("Mass.mg")
  if (rule == "bahney_compiled_gnr") return("G.p.N")
  if (rule == "bahney_compiled_nnnr") return("O.p.N")
  if (rule == "fobbs_body_length") return("Length.mm")
  if (rule %in% c("kennedy_table_glucose", "kennedy_text_glucose"))
    return("CMRglc.umol_100g_min")
  if (rule == "kennedy_text_oxygen") return("CMRO2.umol_100g_min")
  if (column == "ILA linear density") return("Density.per_mm")
  if (column %in% c("ILA primary processes", "ILA total processes")) return("Count")
  if (column == "ILA total length") return("Length.um")
  if (column == "ILA complexity") return("Index")
  ""
}

registry <- dplyr::tbl(con, "item_context") |>
  dplyr::filter(item %in% items) |>
  dplyr::select(item, registry_json) |>
  dplyr::collect()
registry_meta <- setNames(lapply(registry$registry_json, jsonlite::fromJSON), registry$item)

basis <- read_chars(file.path(root,
  route_path("Boddy_etal_2012_TableS1", "brain_mass_row_basis"))) |>
  dplyr::filter(Source == "10.1111%2Fj.1420-9101.2012.02491.x_TableS1.tsv",
                column == "Brain Mass (g)")
basis$source_line <- suppressWarnings(as.integer(sub("^.*:", "", basis$source_records)))
stopifnot(nrow(basis) == 630L, !anyDuplicated(basis$source_line))
basis_by_line <- setNames(split(basis, basis$source_line), as.character(basis$source_line))

accepted_names <- unique(read_chars(file.path(root,
  route_path("Boddy_etal_2012_TableS1", "accepted_species")))$accepted_name)
species_key_files <- file.path(root,
  catalog_artifacts$path[catalog_artifacts$artifact_kind == "active_species_crosswalk" &
                           catalog_artifacts$authority_stage == "curated_authority"])
if (length(species_key_files) != 9L) stop("Expected nine active species crosswalks in catalog")
species_keys <- dplyr::bind_rows(lapply(species_key_files, function(path) {
  x <- read_chars(path)
  x$key_file <- substring(path, nchar(root) + 2L)
  x
}))
mink_refs <- read_chars(file.path(root,
  route_path("Mink_etal_1981_TABLE1", "upstream_reference", "mink-t1-lookup")))
kaufman_refs <- read_chars(file.path(root,
  route_path("Kaufman__2004_TableA3", "upstream_reference",
             "kaufman-reference-lookup")))
if (anyDuplicated(kaufman_refs$ref_key))
  stop("Kaufman reference keys are not unique")
heffner_refs <- read_chars(file.path(root,
  route_path("Heffner_Heffner_2010_b_Table1", "upstream_reference")))
heffner_scope <- read_chars(file.path(root,
  route_path("Heffner_Heffner_2010_b_Table1", "citation_scope_declaration")))
if (nrow(heffner_scope) != 2L ||
    !setequal(paste(heffner_scope$key_column, heffner_scope$applies_to, sep = ":"),
              c("ref_freq_key:audible_freq_high_60dBSPL_khz",
                "ref_bm_length_keys:basilar_membrane_length_mm")))
  stop("Heffner citations must have distinct hearing and basilar scopes")
bahney_refs <- setNames(lapply(c(3L, 4L), function(n) {
  item <- paste0("Bahney_vonBartheld_2018_TABLE", n)
  x <- read_chars(file.path(root, route_path(item, "upstream_reference")))
  if (anyDuplicated(x$ref_key)) stop(item, " has duplicate reference keys")
  x
}), c("3", "4"))
kennedy_refs <- read_chars(file.path(root,
  route_path("Kennedy_etal_1978_Text", "upstream_reference")))
if (!setequal(kennedy_refs$ref_key, c("20", "22")) ||
    anyDuplicated(kennedy_refs$ref_key))
  stop("Kennedy Text must resolve exactly bibliography refs 20 and 22")
for (n in c(3L, 4L)) {
  item <- paste0("Bahney_vonBartheld_2018_TABLE", n)
  scope_declaration <- read_chars(file.path(root,
    route_path(item, "citation_scope_declaration")))
  if (nrow(scope_declaration) != 1L ||
      field(scope_declaration, "key_column") != "references" ||
      field(scope_declaration, "applies_to") != "row_overall")
    stop(item, " must declare its citation as row_overall")
}
lookup_heffner <- function(ctx, key_column) {
  raw <- field(ctx, key_column)
  if (!nzchar(raw)) return(list(keys = "", citation = ""))
  keys <- trimws(strsplit(raw, ",", fixed = TRUE)[[1L]])
  matches <- heffner_refs[heffner_refs$ref_key %in% keys &
                            heffner_refs$cited_in_column == key_column, , drop = FALSE]
  missing <- setdiff(keys, matches$ref_key)
  if (length(missing)) stop("Heffner reference key(s) missing for ", key_column,
                            ": ", paste(missing, collapse = ", "))
  list(keys = paste(keys, collapse = "; "), citation = collapse_nonempty(matches$citation))
}
lookup_bahney <- function(ctx, item) {
  key <- field(ctx, "references")
  if (tolower(key) %in% c("this study", "current study"))
    return(list(key = key, citation = ""))
  x <- bahney_refs[[sub("^.*TABLE", "", item)]]
  found <- x[x$ref_key == key & !is.na(x$ref_key), , drop = FALSE]
  if (nrow(found) != 1L) stop(item, " citation key has no unique lookup: ", key)
  list(key = key, citation = field(found, "citation"))
}
mink_ref_col <- c(mink_brain_mass = "ref_keys_brain_weight",
                  mink_brain_oxygen = "ref_keys_brain_metabolic_rate",
                  mink_spinal_mass = "ref_keys_spinal_cord_weight")
mink_reference <- function(ctx, rule) {
  key_col <- unname(mink_ref_col[[rule]])
  raw_keys <- field(ctx, key_col)
  if (!nzchar(raw_keys)) return(list(keys = "", citation = ""))
  keys <- trimws(unlist(strsplit(raw_keys, ";", fixed = TRUE)))
  refs <- mink_refs[mink_refs$ref_key %in% keys &
                      grepl(key_col, mink_refs$cited_in_column, fixed = TRUE), , drop = FALSE]
  list(keys = paste(keys, collapse = "; "), citation = collapse_nonempty(refs$citation))
}
mink_footnote_reference <- function(ctx) {
  marks <- field(ctx, "printed_footnote_marks")
  mark <- sub("^.*C:", "", marks)
  if (!nzchar(mark) || identical(mark, marks)) return(list(keys = "", citation = ""))
  token <- paste0("printed_footnote_marks:", mark)
  refs <- mink_refs[grepl(token, mink_refs$cited_in_column, fixed = TRUE), , drop = FALSE]
  list(keys = collapse_nonempty(refs$ref_key), citation = collapse_nonempty(refs$citation))
}
taxon_from_keys <- function(item, printed) {
  if (printed %in% accepted_names) {
    return(list(name = printed, status = "verified",
                basis = "_keys/species_reference.csv exact accepted name"))
  }
  x <- species_keys[species_keys$variant_name == printed &
                      species_keys$accepted_name %in% accepted_names, , drop = FALSE]
  if (!nrow(x)) {
    return(list(name = "", status = "unresolved",
                basis = "No active accepted name or species-key match"))
  }
  source_x <- x[x$source_publication == item_folder(item), , drop = FALSE]
  if (nrow(source_x)) x <- source_x
  names <- unique(x$accepted_name)
  if (length(names) != 1L) {
    return(list(name = "", status = "ambiguous_key",
                basis = collapse_nonempty(paste(x$key_file, x$accepted_name))))
  }
  list(name = names[[1L]], status = "verified",
       basis = paste("active species-key consensus:",
                     collapse_nonempty(x$key_file)))
}

make_point <- function(i) {
  p <- selected[i, , drop = FALSE]
  item <- p$item[[1L]]
  column <- p$column_name[[1L]]
  rule <- p$rule[[1L]]
  ctx <- jsonlite::fromJSON(p$context_json[[1L]])
  d <- definition_row(item, column)
  def_text <- if (is.null(d)) "" else field(d, "Definition")
  target <- if (is.null(d)) "" else field(d, "Structure")
  statistic <- if (is.null(d)) "" else field(d, "Stat")
  def_evidence <- definition_path(item)
  source_url <- field(registry_meta[[item]], "DOI URL")
  if (!nzchar(source_url))
    source_url <- field(registry_meta[[item]], "Citation (APA 7th-Annotated)")
  locator <- paste0(p$source_file[[1L]], ":", p$row_number[[1L]], ":", column)
  printed <- ""
  accepted <- ""
  taxon_status <- "unresolved"
  taxon_basis <- ""
  source_role <- "unresolved"
  value_origin <- "unresolved"
  trait_id <- p$trait_id[[1L]]
  method <- ""
  method_evidence <- ""
  method_status <- "unresolved"
  transformation_method <- ""
  transformation_status <- "not_applicable"
  component_lineage_status <- "not_applicable"
  upstream <- ""
  upstream_keys <- ""
  upstream_reference_id <- ""
  basis_group <- ""
  pool_eligible <- TRUE
  source_note <- ""
  dispersion_sd <- ""
  dispersion_reported <- ""
  dispersion_type <- ""

  if (rule %in% c("stm", "vocal", "many_predictor")) {
    printed <- field(ctx, "Species")
    tax <- taxon_from_keys(item, printed)
    accepted <- tax$name
    taxon_status <- tax$status
    taxon_basis <- tax$basis
    basis_group <- if (rule == "stm") "three_cup_delay_task" else
      if (rule == "vocal") "call_type_catalogue" else column
    if (rule == "stm") {
      source_role <- "primary"
      value_origin <- "trial_aggregate"
      mr <- definition_row(item, "Method:proportion.correct")
      method <- if (is.null(mr)) "" else paste("Delayed three-cup choice task;", field(mr, "Definition"))
      method_evidence <- def_evidence
      method_status <- if (nzchar(method)) "verified" else "unresolved"
      transformation_method <- "Mean of each individual's proportion correct, with individuals weighted equally"
      transformation_status <- "verified"
    } else if (rule == "vocal") {
      source_role <- "secondary"
      value_origin <- "compiled_count"
      upstream <- field(ctx, "vocal_repertoire_source")
      source_note <- field(ctx, "vocal_repertoire_comment")
      method <- "Count of catalogued vocalization types; source-specific calling and sampling protocol unverified"
      method_evidence <- def_evidence
      method_status <- "unresolved"
      if (nzchar(source_note)) {
        taxon_status <- "source_value_taxon_mismatch"
        taxon_basis <- paste("source comment:", source_note)
      }
    } else {
      source_role <- "secondary"
      value_origin <- if (p$value_type[[1L]] == "category")
        "compiled_category" else "compiled_quantity"
      upstream <- field(ctx, paste0(column, "_source"))
      source_note <- field(ctx, paste0(column, "_comment"))
      method <- "Original study's observation and aggregation method requires per-value tracing"
      method_evidence <- paste(def_evidence, "and source sheet's paired Source/Comments columns")
      method_status <- "unresolved"
      if (grepl("^Source refers to ", source_note, ignore.case = TRUE)) {
        taxon_status <- "source_value_taxon_mismatch"
        taxon_basis <- paste("source comment:", source_note)
      }
    }
  } else if (startsWith(rule, "mink_")) {
    printed <- field(ctx, "species_as_published")
    taxon_status <- "source_key_unapproved"
    taxon_basis <- "Mink_etal_1981_species_key_proposed.csv is not an active species key"
    source_role <- "secondary"
    ref <- mink_reference(ctx, rule)
    upstream <- ref$citation
    upstream_keys <- ref$keys
    basis_group <- if (rule == "mink_brain_oxygen") "brain_oxygen_rate" else "measured_mass"
    if (rule == "mink_brain_oxygen" && !nzchar(upstream_keys)) {
      value_origin <- "predicted_model"
      trait_id <- "brain_oxygen_consumption_model_prediction"
      input_ref <- mink_reference(ctx, "mink_brain_mass")
      upstream <- input_ref$citation
      upstream_keys <- input_ref$keys
      transformation_method <- if (as.integer(field(ctx, "printed_row")) <= 8L)
        "Mink Eq. 3" else "Mink Eq. 1"
      transformation_status <- "verified"
      method <- "Original brain-mass measurement protocol needs source review"
      method_evidence <- "Mink_etal_1981_TABLE1_definitions.csv: brain_metabolic_rate; Table 1 footnote c"
      method_status <- "unresolved"
      basis_group <- "model_prediction"
    } else if (rule == "mink_spinal_mass" && field(ctx, "printed_row") == "40") {
      # The horse cell prints ref 52, but 260 = 650 / 2.5 rather than the
      # primary's measured 215 g. It is an extrapolation with two inputs.
      value_origin <- "extrapolated_proxy"
      trait_id <- "spinal_cord_mass_extrapolated"
      brain_ref <- mink_reference(ctx, "mink_brain_mass")
      upstream <- collapse_nonempty(c(brain_ref$citation, upstream))
      upstream_keys <- collapse_nonempty(c(brain_ref$keys, upstream_keys))
      transformation_method <- "Mink horse brain mass 650 g divided by published horse brain:cord ratio 2.5"
      transformation_status <- "verified"
      method <- "Original brain-mass and ratio measurement protocols need source review"
      method_evidence <- "Mink Table 1 horse row; Krompecher & Lipak 1966 ref 52 comparison in _DATAPOINT_PROVENANCE_PLAN.md"
      method_status <- "unresolved"
      basis_group <- "ratio_extrapolation"
    } else if (rule == "mink_spinal_mass" && !nzchar(upstream_keys)) {
      own_ratio <- field(ctx, "printed_footnote_marks") %in% c("C:j", "C:m", "C:n")
      value_origin <- if (own_ratio) "derived_from_own_observed_ratio" else "extrapolated_proxy"
      trait_id <- if (own_ratio) "spinal_cord_mass_ratio_derived" else "spinal_cord_mass_extrapolated"
      if (own_ratio) source_role <- "mixed"
      input_ref <- mink_reference(ctx, "mink_brain_mass")
      ratio_ref <- mink_footnote_reference(ctx)
      upstream <- collapse_nonempty(c(input_ref$citation, ratio_ref$citation))
      upstream_keys <- collapse_nonempty(c(input_ref$keys, ratio_ref$keys))
      transformation_method <- paste("Mink Table 1 footnote", field(ctx, "printed_footnote_marks"))
      transformation_status <- if (nzchar(field(ctx, "printed_footnote_marks")))
        "verified" else "unresolved"
      method <- "Input brain-mass and cord-ratio measurement protocols need source review"
      method_evidence <- "Mink_etal_1981_TABLE1_snapshot.xlsx: Table 1 footnotes j-x"
      method_status <- "unresolved"
      basis_group <- if (own_ratio) "own_ratio_derivation" else "ratio_extrapolation"
    } else {
      value_origin <- "copied_measurement"
      method_status <- "unresolved"
    }
  } else if (rule == "boddy_summary") {
    printed <- field(ctx, "Species Name")
    b <- basis_by_line[[as.character(p$row_number[[1L]])]]
    if (!is.null(b) && nrow(b) == 1L) {
      accepted <- field(b, "Species")
      taxon_status <- if (!nzchar(accepted)) "unresolved" else
        if (accepted %in% accepted_names) "verified" else "missing_project_species_entry"
      taxon_basis <- paste("__metadata/curation/brain_mass_row_basis.csv:", field(b, "resolution_id"))
      source_role <- field(b, "role_override")
      if (!source_role %in% c("primary", "secondary")) source_role <- "unresolved"
      upstream <- field(b, "original_reference")
      basis_group <- field(b, "poolable_group")
      pool_eligible <- identical(field(b, "pool_eligible"), "True")
      method_evidence <- paste("__metadata/curation/brain_mass_row_basis.csv:", field(b, "resolution_id"),
                               field(b, "evidence"))
      source_note <- field(b, "note")
      if (field(b, "basis") == "mass_estimated_from_endocranial_volume") {
        trait_id <- "brain_mass_estimated_from_ecv"
        value_origin <- "estimated_from_endocranial_volume"
        method <- "Original endocranial-volume acquisition protocol needs per-source review"
        method_status <- "unresolved"
        transformation_method <- "Endocranial volume converted to mass with density 1.036 g/cm3"
        transformation_status <- "verified"
        basis_group <- "mass_estimated_from_endocranial_volume"
      } else if (field(b, "poolable_group") == "mass_measured" &&
                 field(b, "original_quantity") == "mass") {
        value_origin <- if (source_role == "primary")
          "original_mass_summary" else "compiled_mass_summary"
        method <- "Direct mass reported by original study; preparation/fixation unspecified"
        method_status <- "verified"
        basis_group <- "mass_measured"
      } else if (field(b, "basis") == "mass_estimated_from_volume") {
        trait_id <- "brain_mass_estimated_from_volume_unknown_subtype"
        value_origin <- "estimated_from_volume"
        method <- "Volume-derived mass; tissue versus endocranial source unresolved"
        method_status <- "unresolved"
        transformation_method <- "Volume converted to mass with density 1.036 g/cm3"
        transformation_status <- "verified"
      }
      if (grepl("Sherwood data/this study", upstream, fixed = TRUE) &&
          grepl(";", upstream, fixed = TRUE)) {
        source_role <- "mixed"
        value_origin <- "mixed_original_and_relayed_mean"
        source_note <- paste(source_note,
          "Summary mean combines Boddy original data with cited external data; component inputs need tracing.")
      }
    }
  } else if (rule == "boddy_source_rows") {
    printed <- field(ctx, "Updated Species Name (from Wilson & Reeder Mammal Species of the World)")
    accepted <- if (printed %in% accepted_names) printed else ""
    taxon_status <- if (nzchar(accepted)) "verified" else "source_name_unresolved"
    taxon_basis <- "source updated name; exact match to _keys/species_reference.csv required"
    upstream <- field(ctx, "Source")
    source_role <- if (upstream == "Sherwood data/this study") "primary" else
      if (nzchar(upstream)) "secondary" else "unresolved"
    value_origin <- if (source_role == "primary") "original_mass_report" else "compiled_mass_report"
    method <- "Measurement or conversion method requires per-row original-source tracing"
    method_evidence <- "Boddy_etal_2012/brain_body_database_v2.txt: Source, Brain Volume, Notes"
    method_status <- "unresolved"
    basis_group <- "mass_basis_unresolved"
    pool_eligible <- FALSE
    source_note <- field(ctx, "Notes")
  } else if (rule == "buchsbaum_glucose") {
    printed <- field(ctx, "species_as_published")
    accepted <- "Homo sapiens"
    taxon_status <- if (accepted %in% accepted_names &&
                        printed == "normal volunteers (male subjects)")
      "verified" else "unresolved"
    taxon_basis <- paste(def_evidence,
      "and original paper Table I: human normal male volunteers")
    source_role <- "primary"
    value_origin <- if (field(ctx, "row_type") == "region")
      "original_group_mean" else "published_regional_summary"
    statistic <- "mean"
    dispersion_sd <- field(ctx, "dispersion_printed")
    source_note <- field(ctx, "note")
    arm <- field(ctx, "arm_id")
    region <- field(ctx, "structure_as_published")
    region_def <- definition_row(item, region)
    if (field(ctx, "row_type") == "region" && !is.null(region_def)) {
      target <- field(region_def, "Structure")
      def_text <- paste(def_text, field(region_def, "Definition"))
    } else {
      pool_eligible <- FALSE
      source_note <- paste(source_note,
        "Printed section/grand mean; not an independent measured region.")
    }
    basis_group <- paste0("PET:", region, ":", arm)
    method <- paste("In vivo [18F]FDG-PET;", arm,
                    "arm; group mean and SD from original study")
    method_evidence <- paste("Buchsbaum 1989 paper Table I, journal p. 1354;",
                             def_evidence, "Method:arms")
    method_status <- if (arm %in% c("awake", "nrem_sleep", "rem_sleep") &&
                         nzchar(field(ctx, "n")) &&
                         field(ctx, "dispersion_type") == "SD" &&
                         nzchar(dispersion_sd)) "verified" else "unresolved"
  } else if (startsWith(rule, "kaufman_")) {
    printed <- field(ctx, "Species")
    citation_key <- field(ctx, "Reference")
    citation_row <- kaufman_refs[kaufman_refs$ref_key == citation_key &
                                  !is.na(kaufman_refs$ref_key), , drop = FALSE]
    if (nrow(citation_row) != 1L)
      stop("Kaufman Table A3 citation key has no unique lookup: ", citation_key)
    source_role <- if (citation_key == "Present Study") "primary" else "secondary"
    value_origin <- if (source_role == "primary")
      "original_group_mean" else "compiled_study_mean"
    upstream <- if (source_role == "secondary") field(citation_row, "citation") else ""
    upstream_keys <- if (source_role == "secondary") citation_key else ""
    upstream_reference_id <- field(citation_row, "source_reference_id")
    target <- field(ctx, "Region")
    def_text <- paste(def_text, "Region:", target)
    statistic <- "mean"
    method_evidence <- paste("Kaufman 2004 Table A3 and reference lookup;",
                             "original acquisition method requires cited-paper review")
    method <- paste("Kaufman reports", field(ctx, "Mode"),
                    "and anesthesia", field(ctx, "Anesthesia"),
                    "; original acquisition method requires review")
    method_status <- "unresolved"
    basis_group <- paste0(field(ctx, "Mode"), ":", target, ":",
                           field(ctx, "Anesthesia"), ":unreviewed_study")
    dispersion_column <- c(kaufman_glucose = "CMRgl_SD",
                           kaufman_oxygen = "CMRO2_SD",
                           kaufman_blood_flow = "CBF_SD")[[rule]]
    dispersion_sd <- field(ctx, dispersion_column)
    source_note <- paste("Kaufman study row; printed reference key:", citation_key)
    # Only this cited study has been checked against its original paper in
    # this pilot. The genus label is resolved from that paper, not by a
    # blanket Homo -> Homo sapiens substitution for all Kaufman rows.
    buchsbaum_relay <- rule == "kaufman_glucose" &&
      citation_key == "(Buchsbaum et al., 1989)" &&
      field(citation_row, "source_reference_id") == "buchsbaum_1989" &&
      field(citation_row, "resolution_status") == "resolved" &&
      printed == "Homo" && target == "Thalamus" &&
      field(ctx, "Anesthesia") == "none" && field(ctx, "Mode") == "PET" &&
      field(ctx, "n") == "10" && p$raw_value[[1L]] == "24.3" &&
      dispersion_sd == "7.2"
    if (buchsbaum_relay) {
      accepted <- "Homo sapiens"
      taxon_status <- if (accepted %in% accepted_names) "verified" else "unresolved"
      taxon_basis <- paste("Kaufman citation resolves to Buchsbaum 1989;",
                           "original study identifies human volunteers")
      method <- "Original Buchsbaum study: in vivo [18F]FDG-PET, awake arm; Kaufman labels PET and no anesthesia"
      method_evidence <- paste("Buchsbaum 1989 Table I, journal p. 1354;",
                               "Kaufman 2004 Table A3, dissertation PDF p. 125;",
                               "resolved Kaufman reference lookup")
      method_status <- "verified"
      basis_group <- "PET:Thalamus:awake"
    } else {
      taxon_status <- "original_study_taxon_unverified"
      taxon_basis <- paste("Kaufman prints", printed,
                           "; verify species in the cited original study")
    }
  } else if (startsWith(rule, "heffner_")) {
    printed <- field(ctx, "species_as_published")
    snapshot_name <- field(ctx, "binomial")
    if (nzchar(printed) && printed == snapshot_name) {
      tax <- taxon_from_keys(item, printed)
      accepted <- tax$name
      taxon_status <- tax$status
      taxon_basis <- tax$basis
    } else {
      taxon_status <- "printed_name_differs_from_snapshot"
      taxon_basis <- paste("Heffner Table 1 p. 2081 prints", printed,
                           "but snapshot uses", snapshot_name,
                           "; requires a reviewed _keys correction")
    }
    source_role <- "secondary"
    value_origin <- if (rule == "heffner_interaural")
      "compiled_or_derived_travel_time" else "compiled_measurement"
    basis_group <- rule
    if (rule != "heffner_interaural") {
      key_column <- if (rule == "heffner_hearing") "ref_freq_key" else "ref_bm_length_keys"
      ref <- lookup_heffner(ctx, key_column)
      upstream <- ref$citation
      upstream_keys <- ref$keys
    }
    method <- if (rule == "heffner_hearing")
      "High-frequency hearing limit at 60-dB SPL; original audiometry protocol requires cited-paper review" else
      if (rule == "heffner_basilar")
        "Basilar membrane length; original acquisition protocol requires cited-paper review" else
          "Functional interaural travel time as defined in footnote b; acquisition and calculation require review"
    method_evidence <- paste(def_evidence, "Table 1 p. 2081, footnotes and per-cell keys")
    method_status <- "unresolved"
    source_note <- if (printed != snapshot_name)
      paste("Published taxon spelling differs from snapshot:", printed, "/", snapshot_name) else ""
  } else if (startsWith(rule, "bahney_primary_")) {
    printed <- field(ctx, "species_as_published")
    tax <- taxon_from_keys(item, printed)
    accepted <- tax$name
    taxon_status <- tax$status
    taxon_basis <- paste(tax$basis, "; species supplied by caption/Results, not a table cell")
    source_role <- "primary"
    value_origin <- "original_method_by_segment_mean"
    statistic <- "mean"
    segment <- field(ctx, "segment")
    raw_method <- field(ctx, "method")
    ratio_type <- field(ctx, "ratio_type")
    target <- paste("Spinal cord", segment, sep = " / ")
    method <- paste(raw_method, "cell counting; group mean for", segment,
                    "over", field(ctx, "n_specimens"), "specimens")
    method_evidence <- paste(def_evidence, field(d, "Source Note"),
                             "method block and Results")
    method_status <- if (raw_method %in% c("Isotropic fractionator (IF)", "Stereology") &&
                         field(ctx, "n_specimens") == "3") "verified" else "unresolved"
    basis_group <- paste(raw_method, segment, ratio_type, sep = ":")
    if (rule == "bahney_primary_ratio") {
      value_origin <- "ratio_derived_from_own_counts"
      trait_id <- if (ratio_type == "GNR") "spinal_cord_glia_neuron_ratio" else
        if (ratio_type == "nNNR") "spinal_cord_nonneuron_neuron_ratio" else trait_id
      def_text <- paste(def_text, "Reported ratio type:", ratio_type)
      dispersion_sd <- field(ctx, "ratio_sd")
      transformation_method <- if (ratio_type == "GNR")
        "Glial cell count divided by neuron count" else
          "Non-neuronal cell count divided by neuron count"
      transformation_status <- if (ratio_type %in% c("GNR", "nNNR"))
        "verified" else "unresolved"
      if (ratio_type == "GNR")
        source_note <- "Definition Measure=O.p.N is a non-neuron ratio code; GNR needs its own canonical mapping"
    } else if (rule == "bahney_primary_cells") {
      dispersion_sd <- field(ctx, "cells_sd_million")
      source_note <- "Definition Measure=O.n means non-neuronal cells; total cell nuclei require C.n, so mapping is held"
    } else if (rule == "bahney_primary_pct") {
      value_origin <- "fraction_derived_from_own_counts"
      transformation_method <- "Reported cell-type count divided by total cell count, expressed as percent"
      transformation_status <- "verified"
    }
    if (item == "Bahney_vonBartheld_2018_TABLE2" &&
        raw_method == "Isotropic fractionator (IF)" &&
        column %in% c("nonneuronal_pct", "neuron_pct", "ratio")) {
      value_origin <- "combined_if_stereology_estimate"
      method <- paste("IF total cell count combined with adjacent-tissue stereology cell-type percentages;",
                      "human fixed-tissue neuron antibody was unreliable")
      method_evidence <- paste(method_evidence,
        "; paper Methods/Results pp. 699-703 describe the cross-method estimate")
      transformation_method <- "Use stereological cell-type fractions with IF total counts to estimate human neuron/non-neuron fractions and nNNR"
      transformation_status <- "verified"
      pool_eligible <- FALSE
      source_note <- paste(source_note,
        "Derived from two methods; component cell lineage needs explicit linkage")
    }
    if (item == "Bahney_vonBartheld_2018_TABLE2" &&
        rule == "bahney_primary_pct" && raw_method == "Stereology" &&
        segment %in% c("Cervical (c)", "Total")) {
      pool_eligible <- FALSE
      source_note <- paste(source_note,
        "Printed stereology percentages do not sum to 100 within stated rounding; see TABLE2 README")
    }
  } else if (startsWith(rule, "bahney_compiled_")) {
    printed <- field(ctx, "species_as_published")
    taxon_key <- field(ctx, "species_variant_matched")
    tax <- taxon_from_keys(item, taxon_key)
    accepted <- tax$name
    taxon_status <- tax$status
    taxon_basis <- paste(tax$basis, "; paper-specific taxon key")
    if (!nzchar(printed)) {
      taxon_status <- "common_name_inference"
      taxon_basis <- paste(taxon_basis, "; Latin cell blank; inferred from common name")
    } else if (startsWith(printed, "(")) {
      taxon_status <- "most_likely_taxon_only"
      taxon_basis <- paste(taxon_basis, "; parentheses denote most likely species")
    }
    if (field(ctx, "common_name") == "Minke whale" &&
        grepl("Balaenoptera physales", printed, fixed = TRUE)) {
      taxon_status <- "source_common_scientific_conflict"
      taxon_basis <- paste(taxon_basis, "; paper pairs Minke whale with fin-whale binomial")
    }
    is_mass <- rule == "bahney_compiled_mass"
    own_study <- field(ctx, "data_role") == "primary"
    ref <- lookup_bahney(ctx, item)
    upstream <- ref$citation
    upstream_keys <- if (own_study) "" else ref$key
    source_role <- if (is_mass && own_study) "unresolved" else
      if (own_study) "primary" else "secondary"
    target <- if (is_mass) "Brain" else field(ctx, "cns_part")
    basis_group <- if (is_mass) "context_brain_mass" else
      paste(rule, field(ctx, "cns_part"), sep = ":")
    source_note <- paste("Published table row", field(ctx, "source_row"),
                         "; reference token:", ref$key)
    if (!is_mass && item == "Bahney_vonBartheld_2018_TABLE4" &&
        target == "Rest of brain") {
      pool_eligible <- FALSE
      source_note <- paste(source_note,
        "; Rest of brain lacks a reviewed active anatomy mapping")
    }
    if (is_mass) {
      value_origin <- if (field(ctx, "brain_mass_estimated") == "TRUE")
        "estimated_context_mass" else "compiled_context_mass"
      pool_eligible <- FALSE
      method <- "Original brain-mass acquisition and relation to ratio source require review"
      if (field(ctx, "brain_mass_estimated") == "TRUE") {
        transformation_method <- "Source prints brain mass in parentheses as an estimate; calculation unspecified"
        transformation_status <- "unresolved"
      }
      if (item == "Bahney_vonBartheld_2018_TABLE4")
        source_note <- paste(source_note, "; brain-mass unit g inferred from Table 3 and overlapping values")
      if (own_study)
        source_note <- paste(source_note,
          "; row's primary ratio status does not establish original brain-mass measurement")
    } else {
      value_origin <- if (own_study) "own_study_ratio_summary" else "compiled_ratio"
      method <- if (own_study)
        "Own spinal-cord ratio summarized across methods or segments; precise source-cell relation needs review" else
          "Original glia/non-neuron counting protocol requires cited-paper review"
    }
    method_evidence <- paste(def_evidence, field(d, "Source Note"),
                             "and item-specific References lookup")
    method_status <- "unresolved"
    low <- field(ctx, if (rule == "bahney_compiled_gnr") "GNR_min" else
                   if (rule == "bahney_compiled_nnnr") "nNNR_min" else "brain_mass_mg_min")
    high <- field(ctx, if (rule == "bahney_compiled_gnr") "GNR_max" else
                    if (rule == "bahney_compiled_nnnr") "nNNR_max" else "brain_mass_mg_max")
    if (nzchar(low) && nzchar(high) && low != high) {
      statistic <- "published_range_midpoint"
      transformation_method <- paste("Midpoint of printed range", low, "to", high)
      transformation_status <- "verified"
      source_note <- paste(source_note, "; midpoint is a generated representation, not a reported mean")
    } else statistic <- "reported_value"
  } else if (rule == "fobbs_body_length") {
    printed <- field(ctx, "Species_binomial")
    tax <- taxon_from_keys(item, printed)
    accepted <- tax$name
    taxon_status <- tax$status
    taxon_basis <- paste(tax$basis, "; Table S1a human collection context")
    source_role <- "unresolved"
    value_origin <- "legacy_specimen_catalog_length"
    statistic <- "individual_specimen"
    target <- if (column == "crown_to_rump_length_mm")
      "Body / crown to rump" else "Body / crown to heel"
    basis_group <- paste("developmental_specimen", field(ctx, "diagnostic_category"),
                         field(ctx, "subcategory_1"),
                         paste0("row", field(ctx, "source_row")), sep = ":")
    method <- "Length recorded in an earlier museum collection; original measurement protocol and observer not identified"
    method_evidence <- paste(def_evidence, "and legacy Table S1a Word supplement")
    method_status <- "unresolved"
    source_note <- paste("Catalog row", field(ctx, "source_row"),
                         ";", field(ctx, "diagnostic_category"),
                         "; age at death", field(ctx, "age_at_death"),
                         "; gestational age", field(ctx, "gestational_age"),
                         field(ctx, "time_unit"), "; sex", field(ctx, "sex"))
    pool_eligible <- FALSE
  } else if (rule %in% c("kennedy_table_glucose", "kennedy_text_glucose",
                           "kennedy_text_oxygen")) {
    is_table <- rule == "kennedy_table_glucose"
    printed <- field(ctx, "species_as_published")
    source_role <- if (is_table) "primary" else field(ctx, "data_role")
    status <- if (is_table) "group_mean" else field(ctx, "value_status")
    is_cited_monkey <- !is_table && source_role == "secondary" &&
      field(ctx, "cited_ref") == "20"
    if (is_cited_monkey) {
      taxon_status <- "cited_sample_taxon_mixed_or_unresolved"
      taxon_basis <- "Schmidt 1945 source mean may include rhesus and spider monkeys; Kennedy's own rhesus identity cannot be inherited"
    } else if (!is_table && source_role == "secondary" &&
               field(ctx, "cited_ref") == "22") {
      accepted <- "Homo sapiens"
      taxon_status <- if (accepted %in% accepted_names) "verified" else "unresolved"
      taxon_basis <- "Kennedy text prints normal conscious young men; _keys/species_reference.csv accepts Homo sapiens"
    } else {
      accepted <- "Macaca mulatta"
      taxon_status <- if (accepted %in% accepted_names) "verified" else "unresolved"
      taxon_basis <- "Kennedy 1978 Methods identifies its own sample as normal conscious rhesus monkeys; _keys/species_reference.csv accepts Macaca mulatta; applies only to this paper's original observations"
    }
    target <- if (is_table) field(ctx, "structure_as_published") else
      field(ctx, "region_as_printed")
    if (is_table) {
      region_def <- definition_row(item, target)
      if (!is.null(region_def)) {
        def_text <- paste(def_text, field(region_def, "Definition"))
        target <- paste(target, "[", field(region_def, "Structure"), "]")
      }
    } else {
      def_text <- paste(def_text, "Printed region:", target)
    }
    statistic <- if (is_table) "group_mean" else
      if (status == "new_single_animal") "individual_example" else
        if (status == "new_estimate") "derived_whole_brain_estimate" else
          if (status == "restatement") "restatement" else "reported_value"
    value_origin <- if (is_table) "original_group_mean" else
      if (status == "derived_from_cited") "calculated_from_cited_oxygen" else
        if (status == "new_estimate") "estimated_from_original_regional_means" else
          if (status == "new_single_animal") "original_single_animal_figure" else
            if (status == "restatement") "repeated_cited_value" else "cited_value"
    basis_group <- if (is_table) "14C_deoxyglucose:conscious_normal" else
      paste("text", status, field(ctx, "state_as_printed"), sep = ":")
    method <- if (is_table || source_role == "primary")
      "Quantitative [14C]deoxyglucose autoradiography in conscious macaques; local tissue radioactivity and plasma time course" else
        "Original cited study's measurement protocol requires source review"
    method_evidence <- if (is_table || source_role == "primary")
      paste(def_evidence, "; Kennedy 1978 Methods pp. 293-295") else
        paste(def_evidence, "; original cited work needs method tracing")
    method_status <- if (is_table || source_role == "primary") "verified" else "unresolved"
    if (is_table) {
      dispersion_reported <- field(ctx, "dispersion_printed")
      dispersion_type <- field(ctx, "dispersion_type")
      source_note <- paste("Printed row", field(ctx, "printed_row"),
                           ";", field(ctx, "section_as_published"),
                           "; dispersion", dispersion_type, dispersion_reported)
    } else {
      source_note <- paste("Text row", field(ctx, "text_row"),
                           ";", field(ctx, "location"),
                           ";", field(ctx, "note"))
      if (source_role == "secondary") {
        key <- field(ctx, "cited_ref")
        ref <- kennedy_refs[kennedy_refs$ref_key == key, , drop = FALSE]
        if (nrow(ref) != 1L) stop("Kennedy Text citation key unresolved: ", key)
        upstream <- field(ref, "citation")
        upstream_keys <- key
        upstream_reference_id <- field(ref, "source_reference_id")
      }
      if (status == "restatement") pool_eligible <- FALSE
      if (status == "new_estimate") {
        pool_eligible <- FALSE
        transformation_method <- "Average gray- and white-matter regional means assuming equal brain fractions"
        transformation_status <- "unresolved"
        source_note <- paste(source_note, "; printed 29 conflicts with approximately 30.04 recalculated from table; open proposed erratum")
      }
      if (status == "new_single_animal") pool_eligible <- FALSE
      if (status == "derived_from_cited") {
        pool_eligible <- FALSE
        transformation_method <- "Glucose equivalent of cited oxygen consumption under assumed stoichiometry"
        transformation_status <- "unresolved"
      }
      if (rule == "kennedy_text_oxygen") {
        transformation_method <- "Printed 3.7 mL O2/100 g/min multiplied by 44.64 umol/mL"
        transformation_status <- if (field(ctx, "value_printed") == "3.7" &&
          abs(as.numeric(p$raw_value[[1L]]) - 3.7 * 44.64) < 1e-8)
          "verified" else "unresolved"
      }
    }
  } else if (rule %in% c("falcone_presence", "falcone_morphology")) {
    printed <- field(ctx, "Scientific name")
    if (printed == "Cercopithecus kandti") {
      if (rule == "falcone_morphology") printed <- "Cercocebus kandti"
      taxon_status <- "conflicting_printed_tables"
      taxon_basis <- paste(
        "Falcone paper PDF Table 1 prints Cercopithecus kandti;",
        "Table 2 prints Cercocebus kandti, but the Table 2 snapshot transcribes",
        "Cercopithecus kandti; source-specific identity not adjudicated"
      )
    } else {
      tax <- taxon_from_keys(item, printed)
      accepted <- tax$name
      taxon_status <- tax$status
      taxon_basis <- tax$basis
    }
    source_role <- "primary"
    value_origin <- if (rule == "falcone_presence") "scored_presence" else
      if (column == "ILA complexity") "formula_derived_index" else "measured_morphometry"
    if (rule == "falcone_presence") statistic <- "category"
    mr <- definition_row(item, "Method")
    method <- if (is.null(mr)) "" else field(mr, "Definition")
    method_evidence <- if (is.null(mr)) "" else paste(def_evidence, field(mr, "Source Note"))
    method_status <- if (nzchar(method)) "verified" else "unresolved"
    if (column == "ILA complexity") {
      transformation_method <- "Complexity formula as specified in the Table 2 trait definition"
      transformation_status <- if (grepl("Complexity =", def_text, fixed = TRUE))
        "verified" else "unresolved"
    }
    basis_group <- if (rule == "falcone_presence") "GFAP_presence_score" else
      if (column == "ILA linear density") "GFAP_linear_density" else
        "GFAP_Neurolucida_morphometry"
  }

  if (source_role == "mixed") component_lineage_status <- "unresolved"
  report_status <- if (nzchar(source_url)) "verified" else "unresolved"
  upstream_status <- if (source_role == "primary") "same_as_reporting_source" else
    if (startsWith(rule, "bahney_compiled_") && nzchar(upstream))
      "row_level_citation_scope_unverified" else
        if (nzchar(upstream)) "cited_reference" else "unresolved"
  if (startsWith(rule, "heffner_") && upstream_keys %in% c("m", "q"))
    upstream_status <- "compound_citation_unresolved"
  if (startsWith(rule, "heffner_") &&
      any(strsplit(upstream_keys, "; ", fixed = TRUE)[[1L]] %in% c("h", "j")))
    upstream_status <- "bibliography_entry_missing"
  if (rule %in% c("kennedy_text_glucose", "kennedy_text_oxygen") &&
      source_role == "secondary" && upstream_keys == "22")
    upstream_status <- "intermediate_review_reference"
  definition_status <- if (nzchar(def_text) && nzchar(target) && nzchar(trait_id))
    "verified" else "unresolved"
  unit_basis <- expected_unit_measure(rule, column)
  if (rule == "bahney_primary_ratio" && field(ctx, "ratio_type") == "GNR")
    unit_basis <- "G.p.N"
  source_unit_verified <- if (rule == "buchsbaum_glucose") {
    field(ctx, "unit_as_printed") == "micromoles/100g/min" &&
      p$unit[[1L]] == "umol/100g/min"
  } else if (startsWith(rule, "kaufman_")) {
    expected_note <- if (rule == "kaufman_blood_flow")
      "mL/100 g/min" else "umol/100 g/min"
    grepl(expected_note, field(d, "Note"), fixed = TRUE) &&
      p$unit[[1L]] == if (rule == "kaufman_blood_flow")
        "ml/100g/min" else "umol/100g/min"
  } else {
    nzchar(p$unit[[1L]]) && p$unit[[1L]] != "unresolved" &&
      (!nzchar(field(p, "source_unit")) ||
         field(p, "source_unit") == p$unit[[1L]])
  }
  unit_status <- if (!is.null(d) && nzchar(unit_basis) &&
                     field(d, "Measure") == unit_basis && source_unit_verified)
    "verified" else "unresolved"
  if (rule == "bahney_compiled_mass" && item == "Bahney_vonBartheld_2018_TABLE4")
    unit_status <- "inferred_from_other_table"
  measure_status <- if (unit_status == "verified" && nzchar(trait_id))
    "verified" else "unresolved"
  unit_evidence <- if (rule == "buchsbaum_glucose") {
    paste(def_evidence, "Code=CMRglc.umol_100g_min; public TSV unit_as_printed=",
          field(ctx, "unit_as_printed"))
  } else if (startsWith(rule, "kaufman_")) {
    paste(def_evidence, paste0("Code=", column, ";"), field(d, "Note"))
  } else {
    paste(def_evidence, "Measure =", unit_basis)
  }
  value_status <- if (p$value_type[[1L]] == "category") {
    if (rule == "many_predictor" && nzchar(p$raw_value[[1L]])) "verified" else
      if (p$raw_value[[1L]] %in% c("Yes", "No", "rudimetary", "rudimentary"))
        "verified" else "unresolved"
  } else if (!is.na(p$numeric_value[[1L]])) "verified" else "unresolved"
  blockers <- character()
  if (measure_status != "verified") blockers <- c(blockers, "measure_or_unit")
  if (value_status != "verified") blockers <- c(blockers, "value_type")
  if (taxon_status != "verified") blockers <- c(blockers, "species_identity")
  if (report_status != "verified") blockers <- c(blockers, "report_reference")
  if (!source_role %in% c("primary", "secondary", "mixed"))
    blockers <- c(blockers, "source_role")
  if (source_role == "mixed" && component_lineage_status != "verified")
    blockers <- c(blockers, "component_lineage")
  if (!upstream_status %in% c("same_as_reporting_source", "cited_reference"))
    blockers <- c(blockers, "upstream_reference")
  if (method_status != "verified") blockers <- c(blockers, "method")
  if (transformation_status == "unresolved") blockers <- c(blockers, "transformation_method")
  if (definition_status != "verified") blockers <- c(blockers, "trait_definition")
  metadata_complete <- length(blockers) == 0L
  if (!pool_eligible) blockers <- c(blockers, "pool_eligibility")
  inventory_disagreement <- if (nzchar(source_role) &&
                                nzchar(field(p, "data_role")) &&
                                source_role != field(p, "data_role"))
    paste0("inventory=", field(p, "data_role"), "; pilot=", source_role) else ""

  data.frame(
    point_id = p$point_id[[1L]], source_row_id = p$row_id[[1L]],
    item = item, source_locator = locator,
    source_item_row = if (startsWith(rule, "heffner_")) field(ctx, "species_row") else
      if (startsWith(rule, "bahney_")) field(ctx, "source_row") else "",
    column = column, raw_value = p$raw_value[[1L]],
    numeric_value = p$numeric_value[[1L]], value_type = p$value_type[[1L]],
    unit = p$unit[[1L]], unit_status = unit_status,
    inventory_source_unit = field(p, "source_unit"),
    inventory_standard_unit = field(p, "standard_unit"),
    unit_evidence = unit_evidence,
    statistic = statistic, trait_id = trait_id,
    anatomy_behavior_target = target,
    trait_definition = def_text,
    definition_evidence = def_evidence, printed_taxon = printed,
    source_snapshot_taxon = if (rule %in% c("falcone_presence", "falcone_morphology"))
      field(ctx, "Scientific name") else
        if (startsWith(rule, "heffner_")) field(ctx, "binomial") else printed,
    accepted_species = accepted, taxon_status = taxon_status, taxon_basis = taxon_basis,
    reporting_reference = source_url, reporting_reference_status = report_status,
    upstream_reference = upstream, upstream_keys = upstream_keys,
    upstream_reference_id = upstream_reference_id,
    upstream_status = upstream_status, source_role = source_role,
    value_origin = value_origin, measurement_method = method,
    method_evidence = method_evidence, method_status = method_status,
    transformation_method = transformation_method,
    transformation_status = transformation_status,
    component_lineage_status = component_lineage_status,
    basis_group = basis_group, source_note = source_note,
    n_individuals_source_row = if (rule == "stm") field(ctx, "n_individuals") else
      if (rule == "boddy_source_rows") field(ctx, "No. Individuals") else
        if (startsWith(rule, "bahney_primary_")) field(ctx, "n_specimens") else
        if (rule == "buchsbaum_glucose" || startsWith(rule, "kaufman_") ||
            startsWith(rule, "kennedy_"))
          field(ctx, "n") else "",
    sample_size_scope = if (rule == "stm") "all_delay_conditions" else
      if (rule == "boddy_source_rows") "source_row" else
        if (startsWith(rule, "bahney_primary_")) "method_by_segment_mean" else
        if (rule == "buchsbaum_glucose") "source_arm" else
        if (rule == "kennedy_table_glucose") "source_arm" else
        if (startsWith(rule, "kennedy_text_")) "printed_text_value" else
          if (startsWith(rule, "kaufman_")) "compiled_study_row" else "",
    dispersion_sd = dispersion_sd,
    dispersion_reported = dispersion_reported,
    dispersion_type = dispersion_type,
    n_trials = if (rule == "stm") field(ctx, "n_trials") else "",
    age_class = if (rule == "boddy_source_rows") field(ctx, "Age Class") else "",
    metadata_complete = metadata_complete, qualification_pass = metadata_complete && pool_eligible,
    blocker_codes = paste(unique(blockers), collapse = "; "),
    inventory_role = field(p, "data_role"),
    inventory_review_reason = field(p, "review_reason"),
    inventory_disagreement = inventory_disagreement,
    stringsAsFactors = FALSE
  )
}

pilot <- dplyr::bind_rows(lapply(seq_len(nrow(selected)), make_point)) |>
  dplyr::arrange(item, source_locator)
stopifnot(nrow(pilot) == nrow(selected), !anyDuplicated(pilot$point_id))
readr::write_csv(pilot, file.path(here, "pilot_points.csv"), na = "")
readr::write_csv(pilot |> dplyr::filter(!qualification_pass),
                 file.path(here, "review_points.csv"), na = "")
summary <- pilot |>
  dplyr::count(item, source_role, value_origin, metadata_complete, qualification_pass,
               name = "n_points") |>
  dplyr::arrange(item, source_role, value_origin)
readr::write_csv(summary, file.path(here, "summary.csv"), na = "")
inventory_disagreements <- pilot |>
  dplyr::filter(nzchar(inventory_disagreement)) |>
  dplyr::count(item, inventory_role, source_role, name = "n_points") |>
  dplyr::arrange(item, inventory_role, source_role)
readr::write_csv(inventory_disagreements,
                 file.path(here, "inventory_disagreement_summary.csv"), na = "")

# Confirmed relationships among reports and derived values. These edges are
# deliberately limited to source-supported cases; equal numbers alone are not
# treated as independent or identical measurements.
edge <- function(from, to, relation, evidence) {
  data.frame(from_point_id = from, to_point_id = to, relation = relation,
             evidence = evidence, stringsAsFactors = FALSE)
}
edges <- list()
mink_mass <- pilot |>
  dplyr::filter(item == "Mink_etal_1981_TABLE1", column == "brain_weight.g") |>
  dplyr::select(source_row_id, mass_point_id = point_id)
mink_outputs <- pilot |>
  dplyr::filter(item == "Mink_etal_1981_TABLE1",
                value_origin %in% c("predicted_model", "extrapolated_proxy",
                                    "derived_from_own_observed_ratio")) |>
  dplyr::select(source_row_id, output_point_id = point_id, value_origin)
mink_inputs <- mink_outputs |>
  dplyr::inner_join(mink_mass, by = "source_row_id", relationship = "many-to-one")
if (nrow(mink_inputs)) {
  edges[[length(edges) + 1L]] <- data.frame(
    from_point_id = mink_inputs$mass_point_id,
    to_point_id = mink_inputs$output_point_id,
    relation = ifelse(mink_inputs$value_origin == "predicted_model",
                      "model_input_brain_mass",
                      ifelse(mink_inputs$value_origin == "extrapolated_proxy",
                             "extrapolation_input_brain_mass", "observed_ratio_input_brain_mass")),
    evidence = "Mink Table 1 footnotes c and j-x; brain weight is the same printed row",
    stringsAsFactors = FALSE
  )
}
homo_summary <- pilot |>
  dplyr::filter(item == "Boddy_etal_2012_TableS1",
                printed_taxon == "Homo sapiens", column == "Brain Mass (g)")
homo_original <- pilot |>
  dplyr::filter(item == "Boddy_etal_2012_brainbodydatabasev2.txt",
                printed_taxon == "Homo sapiens",
                upstream_reference == "Sherwood data/this study",
                column == "Brain Mass (g)")
if (nrow(homo_summary) != 1L || nrow(homo_original) != 7L ||
    !isTRUE(all.equal(mean(homo_original$numeric_value),
                      homo_summary$numeric_value[[1L]], tolerance = 1e-10))) {
  stop("Boddy Homo sapiens Sherwood aggregate did not reproduce")
}
edges[[length(edges) + 1L]] <- data.frame(
  from_point_id = homo_original$point_id,
  to_point_id = homo_summary$point_id[[1L]],
  relation = "mean_of_original_reports",
  evidence = "Seven Sherwood/this study brain masses in brain_body_database_v2.txt average to Table S1 1250.42857142857 g",
  stringsAsFactors = FALSE
)
for (species in c("Phocoena phocoena", "Neurotrichus gibbsii")) {
  a <- pilot |>
    dplyr::filter(item == "Boddy_etal_2012_TableS1", printed_taxon == species)
  b <- pilot |>
    dplyr::filter(item == "Boddy_etal_2012_brainbodydatabasev2.txt",
                  printed_taxon == species,
                  upstream_reference == a$upstream_reference[[1L]],
                  numeric_value == a$numeric_value[[1L]])
  if (nrow(a) != 1L || nrow(b) != 1L) stop("Boddy relay did not match: ", species)
  edges[[length(edges) + 1L]] <- edge(
    b$point_id[[1L]], a$point_id[[1L]], "reprinted_compilation_report",
    paste0("Same source citation, species and brain-mass value in Boddy raw database and Table S1: ",
           species)
  )
}
buchsbaum_original <- pilot |>
  dplyr::filter(item == "Buchsbaum_etal_1989_TableI",
                basis_group == "PET:Thalamus:awake",
                trait_id == "regional_cerebral_glucose_metabolic_rate")
kaufman_relay <- pilot |>
  dplyr::filter(item == "Kaufman__2004_TableA3",
                upstream_reference_id == "buchsbaum_1989",
                basis_group == "PET:Thalamus:awake",
                trait_id == "regional_cerebral_glucose_metabolic_rate")
if (nrow(buchsbaum_original) != 1L || nrow(kaufman_relay) != 1L ||
    !buchsbaum_original$qualification_pass[[1L]] ||
    !kaufman_relay$qualification_pass[[1L]] ||
    buchsbaum_original$source_role[[1L]] != "primary" ||
    kaufman_relay$source_role[[1L]] != "secondary" ||
    buchsbaum_original$accepted_species[[1L]] !=
      kaufman_relay$accepted_species[[1L]] ||
    buchsbaum_original$anatomy_behavior_target[[1L]] !=
      kaufman_relay$anatomy_behavior_target[[1L]] ||
    buchsbaum_original$unit[[1L]] != kaufman_relay$unit[[1L]] ||
    buchsbaum_original$statistic[[1L]] != kaufman_relay$statistic[[1L]] ||
    buchsbaum_original$numeric_value[[1L]] !=
      kaufman_relay$numeric_value[[1L]] ||
    buchsbaum_original$n_individuals_source_row[[1L]] !=
      kaufman_relay$n_individuals_source_row[[1L]] ||
    buchsbaum_original$dispersion_sd[[1L]] !=
      kaufman_relay$dispersion_sd[[1L]]) {
  stop("Buchsbaum original and Kaufman Table A3 relay do not qualify as one observation")
}
edges[[length(edges) + 1L]] <- edge(
  buchsbaum_original$point_id[[1L]], kaufman_relay$point_id[[1L]],
  "reprinted_compilation_report",
  paste("Kaufman Table A3 cites Buchsbaum 1989 and repeats the awake",
        "thalamus CMRglc mean 24.3, SD 7.2, n=10, PET, umol/100g/min;",
        "Buchsbaum paper Table I p. 1354; Kaufman dissertation PDF p. 125")
)
kennedy_regions <- c("Thalamus: dorsomedial nucleus",
                     "Thalamus: ventral posterolateral nucleus",
                     "Medial geniculate body", "Lateral geniculate body")
kennedy_inputs <- pilot[
  pilot$item == "Kennedy_etal_1978_Table" &
    sub(" \\[.*$", "", pilot$anatomy_behavior_target) %in% kennedy_regions,
  , drop = FALSE]
kennedy_composite <- pilot[
  pilot$item == "Kaufman__2004_TableA3" &
    pilot$upstream_reference_id == "kennedy_1978" &
    pilot$numeric_value == 50.3 &
    pilot$anatomy_behavior_target == "Thalamus", , drop = FALSE]
if (nrow(kennedy_inputs) != 4L || nrow(kennedy_composite) != 1L ||
    !setequal(sub(" \\[.*$", "", kennedy_inputs$anatomy_behavior_target),
              kennedy_regions) ||
    abs(mean(kennedy_inputs$numeric_value) - 50.25) > 1e-10 ||
    kennedy_composite$printed_taxon[[1L]] != "M fascic")
  stop("Kennedy-to-Kaufman four-region composite changed")
edges[[length(edges) + 1L]] <- data.frame(
  from_point_id = kennedy_inputs$point_id,
  to_point_id = kennedy_composite$point_id[[1L]],
  relation = "regional_mean_input_to_relayed_composite",
  evidence = paste("Kaufman Table A3 cites Kennedy 1978 and prints thalamus 50.3;",
                   "mean of Kennedy 54, 43, 65, 39 = 50.25 (printed to one decimal).",
                   "Kaufman mislabels the source species M fascic; this is not an exact one-cell relay."),
  stringsAsFactors = FALSE
)
lineage <- dplyr::bind_rows(edges) |>
  dplyr::arrange(relation, from_point_id, to_point_id)
stopifnot(all(lineage$from_point_id %in% pilot$point_id),
          all(lineage$to_point_id %in% pilot$point_id))
readr::write_csv(lineage, file.path(here, "lineage_links.csv"), na = "")

# The simpler pilot stops here: its selector reads only these prepared
# reports, so no species-merge product can feed the qualification gate.
if (qualification_only) {
  cat("Qualified reports prepared without merge inputs:", nrow(pilot),
      "points |", sum(pilot$qualification_pass), "qualified |",
      nrow(lineage), "lineage links\n")
  DBI::dbDisconnect(con)
  DBI::dbDisconnect(catalog_con)
  quit(save = "no", status = 0L)
}

# An actual cross-source preference audit. It retains the Boddy relays and
# identifies comparable primary candidates; it does not aggregate linked reports.
brain <- read_chars(file.path(root,
  route_path("Boddy_etal_2012_TableS1", "brain_mass_pool_audit")))
boddy_file <- "10.1111%2Fj.1420-9101.2012.02491.x_TableS1.tsv"
qualified_boddy_species <- pilot |>
  dplyr::filter(item == "Boddy_etal_2012_TableS1",
                source_role == "secondary", qualification_pass,
                basis_group == "mass_measured") |>
  dplyr::pull(accepted_species)
boddy_secondary <- brain |>
  dplyr::filter(Source == boddy_file, role == "secondary",
                pool_eligible == "True", poolable_group == "mass_measured",
                Species %in% qualified_boddy_species) |>
  dplyr::select(Species, poolable_group, boddy_value_g = Value_g)
external_primary <- brain |>
  dplyr::filter(Source != boddy_file, role == "primary", pool_eligible == "True",
                poolable_group == "mass_measured") |>
  dplyr::select(Species, poolable_group, primary_value_g = Value_g,
                primary_source = Source, primary_team = Team)
preference <- boddy_secondary |>
  dplyr::inner_join(external_primary, by = c("Species", "poolable_group"),
                    relationship = "many-to-many") |>
  dplyr::group_by(Species, boddy_value_g) |>
  dplyr::summarise(
    n_primary_report_rows = dplyr::n(),
    primary_sources = collapse_nonempty(primary_source),
    primary_values_g = collapse_nonempty(primary_value_g),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    decision = "primary candidates for review; no automatic selection",
    lineage_check = "verify method, taxon and shared original specimen/study before counting reports independently"
  ) |>
  dplyr::arrange(Species)
readr::write_csv(preference, file.path(here, "primary_preference_audit.csv"), na = "")

# Two source-choice review examples. The Stephan/Boddy value match identifies
# a likely relay, but the original specimen collection and sample size behind
# Stephan's report need review before choosing it. A secondary report can be
# retained provisionally when the current comparable pool has no primary candidate.
boddy_atelerix <- pilot |>
  dplyr::filter(point_id == "DP-ca27d31db641e41413a6dc8e")
boddy_ursus <- pilot |>
  dplyr::filter(point_id == "DP-c6475a496edd4341b7093215")
stephan_atelerix <- dplyr::tbl(con, "points") |>
  dplyr::filter(point_id == "DP-8a64543f70df323b4ac6907e") |>
  dplyr::collect()
stephan_pool <- brain |>
  dplyr::filter(Species == "Atelerix algirus",
                Source == "10.1159%2F000155963_TableI.tsv",
                column == "Brain_weight", Value_g == "3.2",
                role == "primary", pool_eligible == "True",
                poolable_group == "mass_measured", basis == "mass_fresh")
stephan_basis <- read_chars(file.path(root,
  route_path("Boddy_etal_2012_TableS1", "brain_size_basis"))) |>
  dplyr::filter(paper == "Stephan_etal_1981", column == "Brain_weight",
                role == "primary", basis == "mass_fresh")
stephan_taxon <- read_chars(file.path(root,
  route_path("Boddy_etal_2012_TableS1", "source_choice_species_key"))) |>
  dplyr::filter(variant_name == "Aethechinus algirus",
                accepted_name == "Atelerix algirus",
                source_publication == "Stephan_etal_1981")
ursus_primary <- brain |>
  dplyr::filter(Species == "Ursus americanus", role == "primary",
                pool_eligible == "True", poolable_group == "mass_measured")
if (nrow(boddy_atelerix) != 1L || nrow(boddy_ursus) != 1L ||
    nrow(stephan_atelerix) != 1L || nrow(stephan_pool) != 1L ||
    nrow(stephan_basis) != 1L || nrow(stephan_taxon) != 1L ||
    nrow(ursus_primary) != 0L ||
    stephan_atelerix$item[[1L]] != "Stephan_etal_1981_TableI" ||
    stephan_atelerix$raw_value[[1L]] != "3200" ||
    boddy_atelerix$upstream_reference[[1L]] != "Stephan 1981" ||
    boddy_atelerix$source_role[[1L]] != "secondary" ||
    !boddy_atelerix$qualification_pass[[1L]] ||
    boddy_ursus$source_role[[1L]] != "secondary" ||
    !boddy_ursus$qualification_pass[[1L]]) {
  stop("Source-choice review examples no longer match source evidence")
}
selection_examples <- dplyr::bind_rows(
  data.frame(
    case_id = "stephan_collection_lineage_pending",
    species = "Atelerix algirus", trait_id = "whole_brain_mass",
    selected_point_id = "",
    selected_item = "",
    selected_value_g = "",
    selected_role = "",
    relayed_point_id = boddy_atelerix$point_id[[1L]],
    relayed_value_g = as.character(boddy_atelerix$numeric_value[[1L]]),
    relayed_role = "secondary",
    n_primary_report_rows_current_pool = sum(brain$Species == "Atelerix algirus" &
      brain$role == "primary" & brain$pool_eligible == "True" &
      brain$poolable_group == "mass_measured"),
    decision = "Hold source choice. Trace the Stephan team's earlier and later collection reports and sample sizes before treating the 1981 value as an independent original observation. Do not average the Stephan and Boddy reports.",
    evidence = paste0("Boddy cites Stephan 1981; Stephan Table I point ",
      stephan_atelerix$point_id[[1L]], " prints 3200 mg and matches the Boddy 3.2 g relay. The taxon and mass-basis keys verify comparability, but do not establish specimen identity, collection lineage, or sample size."),
    decision_status = "source_lineage_unresolved",
    stringsAsFactors = FALSE
  ),
  data.frame(
    case_id = "secondary_fallback_in_current_pool",
    species = "Ursus americanus", trait_id = "whole_brain_mass",
    selected_point_id = boddy_ursus$point_id[[1L]],
    selected_item = boddy_ursus$item[[1L]],
    selected_value_g = as.character(boddy_ursus$numeric_value[[1L]]),
    selected_role = "secondary",
    relayed_point_id = "",
    relayed_value_g = "",
    relayed_role = "",
    n_primary_report_rows_current_pool = nrow(ursus_primary),
    decision = "Retain the Boddy 248 g secondary report as the current-pool fallback; trace Spitzka 1903 before final selection.",
    evidence = "Boddy Table S1 cites Spitzka 1903; current eligible measured-mass source pool has no primary Ursus americanus row.",
    decision_status = "pilot_selection_pending_original_review",
    stringsAsFactors = FALSE
  )
)
readr::write_csv(selection_examples, file.path(here, "selection_examples.csv"), na = "")

# The existing behaviour merge selects Schniter's updated compilation on
# overlap. Record the choice without equating its current role label with a
# verified original vocalization measurement.
beh_obs <- read_chars(file.path(root,
  route_path("ManyPrimates__2022_speciespredictors", "behaviour_overlap_audit"))) |>
  dplyr::filter(Measure == "VocalRepertoire",
                Team %in% c("ManyPrimates", "Schniter"))
beh_final <- read_chars(file.path(root,
  route_path("ManyPrimates__2022_speciespredictors", "behaviour_selected_audit"))) |>
  dplyr::filter(Measure == "VocalRepertoire") |>
  dplyr::select(Species, selected_value = Value, selected_teams = Teams,
                current_primary_used = primary_used)
many_beh <- beh_obs |>
  dplyr::filter(Team == "ManyPrimates") |>
  dplyr::select(Species, many_value = Value, many_current_role = role)
schn_beh <- beh_obs |>
  dplyr::filter(Team == "Schniter") |>
  dplyr::select(Species, schniter_value = Value, schniter_current_role = role)
many_pilot <- pilot |>
  dplyr::filter(item == "ManyPrimates__2022_speciespredictors",
                column == "vocal_repertoire_types") |>
  dplyr::select(Species = accepted_species, many_point_id = point_id,
                many_gate = qualification_pass, many_blockers = blocker_codes)
behavior_preference <- many_beh |>
  dplyr::inner_join(schn_beh, by = "Species", relationship = "one-to-one") |>
  dplyr::left_join(beh_final, by = "Species", relationship = "one-to-one") |>
  dplyr::left_join(many_pilot, by = "Species", relationship = "one-to-one") |>
  dplyr::mutate(
    selection_basis = "Current merge uses Schniter updated compilation on overlap",
    schniter_original_measurement_status = "unverified_in_this_pilot",
    next_check = "Trace each updated count to its original study and method; review shared McComb-Semple lineage before final use"
  ) |>
  dplyr::arrange(Species)
if (nrow(behavior_preference) != 15L ||
    any(is.na(behavior_preference$many_point_id)) ||
    any(behavior_preference$selected_value != behavior_preference$schniter_value) ||
    any(behavior_preference$many_gate != FALSE)) {
  stop("Behaviour-overlap audit no longer matches selected source and pilot gate")
}
readr::write_csv(behavior_preference,
                 file.path(here, "behavior_preference_audit.csv"), na = "")

mixed_teams <- brain |>
  dplyr::filter(pool_eligible == "True", role %in% c("primary", "secondary")) |>
  dplyr::group_by(Species, Measure, Team, poolable_group) |>
  dplyr::summarise(roles = collapse_nonempty(role),
                   n_primary = sum(role == "primary"),
                   n_secondary = sum(role == "secondary"),
                   sources = collapse_nonempty(Source), .groups = "drop") |>
  dplyr::filter(n_primary > 0L, n_secondary > 0L) |>
  dplyr::arrange(Species, Measure, Team, poolable_group)
readr::write_csv(mixed_teams, file.path(here, "mixed_team_audit.csv"), na = "")

# A small relational output for querying the same pilot with R/DBI or SQL.
# The inventory stays read-only. Reference text is preserved exactly as the
# source supplies it. Heffner's generated source_match gives one link per
# measured cell and printed key; a key that cites two works remains a
# reviewed citation bundle until the works can be attributed individually.
heffner_match <- read_chars(file.path(root,
  route_path("Heffner_Heffner_2010_b_Table1", "source_match")))
if (nrow(heffner_match) != 48L ||
    !all(heffner_match$status %in% c("matched", "matched_shared_key")) ||
    !all(heffner_match$variable %in%
           c("audible_freq_high_60dBSPL_khz", "basilar_membrane_length_mm")))
  stop("Heffner source-match coverage or status changed")
heffner_match$source_item_row <- as.character(
  as.integer(sub("^r", "", heffner_match$row_id)))
heffner_points <- pilot |>
  dplyr::filter(item == "Heffner_Heffner_2010_b_Table1",
                column != "interaural_distance_functional_us") |>
  dplyr::select(point_id, source_item_row, column, upstream_status)
if (anyDuplicated(heffner_points[c("source_item_row", "column")]))
  stop("Heffner point row/column keys are not unique")
heffner_point_links <- heffner_match |>
  dplyr::left_join(heffner_points,
                   by = c("source_item_row", "variable" = "column"),
                   relationship = "many-to-one")
if (anyNA(heffner_point_links$point_id) ||
    length(unique(heffner_point_links$point_id)) != 42L)
  stop("Heffner source-match citations did not cover all cited cells")
heffner_point_links <- heffner_point_links |>
  dplyr::transmute(point_id,
    reference_role = dplyr::case_when(
      upstream_status == "compound_citation_unresolved" ~ "citation_bundle",
      upstream_status == "bibliography_entry_missing" ~ "citation_note",
      TRUE ~ "upstream"),
    reference_text = citation, source_ref_keys = ref_key)
ref_values <- sort(unique(c(
  pilot$reporting_reference[nzchar(pilot$reporting_reference)],
  pilot$upstream_reference[pilot$item != "Heffner_Heffner_2010_b_Table1" &
                             nzchar(pilot$upstream_reference)],
  heffner_point_links$reference_text
)))
references <- data.frame(
  ref_id = sprintf("REF-%05d", seq_along(ref_values)),
  reference_text = ref_values,
  stringsAsFactors = FALSE
)
point_references <- dplyr::bind_rows(
  pilot |>
    dplyr::filter(nzchar(reporting_reference)) |>
    dplyr::transmute(point_id, reference_role = "reporting",
                     reference_text = reporting_reference, source_ref_keys = ""),
  pilot |>
    dplyr::filter(nzchar(upstream_reference), source_role != "primary",
                  item != "Heffner_Heffner_2010_b_Table1") |>
    dplyr::transmute(point_id, reference_role = dplyr::case_when(
                       upstream_status == "row_level_citation_scope_unverified" ~ "row_context",
                       upstream_status == "compound_citation_unresolved" ~ "citation_bundle",
                       upstream_status == "bibliography_entry_missing" ~ "citation_note",
                       upstream_status == "intermediate_review_reference" ~ "intermediate_review",
                       TRUE ~ "upstream"),
                     reference_text = upstream_reference,
                     source_ref_keys = upstream_keys),
  heffner_point_links
) |>
  dplyr::mutate(ref_id = references$ref_id[match(reference_text,
                                                 references$reference_text)]) |>
  dplyr::select(point_id, ref_id, reference_role, source_ref_keys)
stopifnot(!anyNA(point_references$ref_id),
          !anyDuplicated(point_references[c("point_id", "ref_id", "reference_role")]))

pilot_db_path <- file.path(here, "pilot_metadata.sqlite")
if (file.exists(pilot_db_path) && !file.remove(pilot_db_path)) {
  stop("Could not replace pilot SQLite output")
}
pilot_db <- DBI::dbConnect(RSQLite::SQLite(), dbname = pilot_db_path)
exec_sql <- function(sql) invisible(DBI::dbExecute(pilot_db, sql))
exec_sql("PRAGMA foreign_keys = ON")
DBI::dbWriteTable(pilot_db, "point_metadata", pilot)
exec_sql("CREATE UNIQUE INDEX point_metadata_pk ON point_metadata(point_id)")
DBI::dbWriteTable(pilot_db, "reference", references)
exec_sql("CREATE UNIQUE INDEX reference_pk ON reference(ref_id)")
DBI::dbWriteTable(pilot_db, "scope", scope)
exec_sql("CREATE UNIQUE INDEX scope_pk ON scope(item, \"column\")")
exec_sql(paste(
  "CREATE TABLE point_reference (",
  "point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "ref_id TEXT NOT NULL REFERENCES reference(ref_id),",
  "reference_role TEXT NOT NULL, source_ref_keys TEXT,",
  "PRIMARY KEY (point_id, ref_id, reference_role))"
))
DBI::dbWriteTable(pilot_db, "point_reference", point_references, append = TRUE)
exec_sql(paste(
  "CREATE TABLE lineage (",
  "from_point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "to_point_id TEXT NOT NULL REFERENCES point_metadata(point_id),",
  "relation TEXT NOT NULL, evidence TEXT,",
  "PRIMARY KEY (from_point_id, to_point_id, relation))"
))
DBI::dbWriteTable(pilot_db, "lineage", lineage, append = TRUE)
DBI::dbWriteTable(pilot_db, "selection_examples", selection_examples)
DBI::dbWriteTable(pilot_db, "behavior_preference_audit", behavior_preference)
exec_sql("CREATE VIEW qualified_points AS SELECT * FROM point_metadata WHERE qualification_pass = 1")
exec_sql("CREATE VIEW review_queue AS SELECT * FROM point_metadata WHERE qualification_pass = 0")
fk_issues <- DBI::dbGetQuery(pilot_db, "PRAGMA foreign_key_check")
if (nrow(fk_issues)) stop("Pilot SQLite foreign-key check failed")
DBI::dbDisconnect(pilot_db)

cat("Pilot points:", nrow(pilot),
    "| qualification pass:", sum(pilot$qualification_pass),
    "| review:", sum(!pilot$qualification_pass),
    "| primary-preference species:", nrow(preference),
    "| mixed-role team groups:", nrow(mixed_teams), "\n")

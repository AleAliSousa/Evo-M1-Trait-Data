args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L) stop("Run with Rscript __measurements/pilot_metadata/check_pilot.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
flags <- commandArgs(trailingOnly = TRUE)
if (length(setdiff(flags, "--qualification-only")) || length(flags) > 1L)
  stop("Only --qualification-only is supported")
qualification_only <- "--qualification-only" %in% flags
read_chars <- function(name) readr::read_csv(file.path(here, name),
                                             show_col_types = FALSE,
                                             col_types = readr::cols(.default = readr::col_character()))
points <- read_chars("pilot_points.csv")
lineage <- read_chars("lineage_links.csv")
excluded <- read_chars("excluded_context.csv")
specimen_screen <- read_chars("specimen_catalog_screen.csv")
if (!qualification_only) {
  preference <- read_chars("primary_preference_audit.csv")
  selection <- read_chars("selection_examples.csv")
  behavior <- read_chars("behavior_preference_audit.csv")
}
one <- function(id) {
  x <- points[points$point_id == id, , drop = FALSE]
  if (nrow(x) != 1L) stop("Pilot point missing or duplicated: ", id)
  x
}
one_item <- function(item, printed, column) {
  x <- points[points$item == item & points$printed_taxon == printed &
                points$column == column, , drop = FALSE]
  if (nrow(x) != 1L) stop("Pilot item point missing or duplicated: ", item, "/", printed, "/", column)
  x
}
check <- function(test, message) if (!isTRUE(test)) stop(message)

stm <- one("DP-b52626ecb5be2c9456c684b7")
check(stm$source_role == "primary" && stm$qualification_pass == "TRUE" &&
        grepl("three-cup", stm$measurement_method, fixed = TRUE),
      "ManyPrimates primary STM test failed")
vocal <- one_item("ManyPrimates__2022_speciespredictors",
                  "Pan paniscus", "vocal_repertoire_types")
check(vocal$source_role == "secondary" && vocal$method_status == "unresolved" &&
        nzchar(vocal$upstream_reference), "ManyPrimates vocal-source test failed")
ateles <- one_item("ManyPrimates__2022_speciespredictors",
                   "Ateles chamek", "vocal_repertoire_types")
check(ateles$taxon_status == "source_value_taxon_mismatch" &&
        ateles$qualification_pass == "FALSE", "ManyPrimates congeneric-value hold failed")
predictors <- points[points$item == "ManyPrimates__2022_speciespredictors", , drop = FALSE]
check(nrow(predictors) == 509L && length(unique(predictors$column)) == 13L &&
        all(predictors$source_role == "secondary"),
      "ManyPrimates source predictors were not all inventoried and classified")
life <- one_item("ManyPrimates__2022_speciespredictors",
                 "Pan paniscus", "life_expectancy")
check(life$unit_status == "unresolved" &&
        life$upstream_status == "unresolved" &&
        life$qualification_pass == "FALSE",
      "Uncited, unit-ambiguous life expectancy was not held")
vision <- one_item("ManyPrimates__2022_speciespredictors",
                   "Ateles chamek", "color_vision")
check(vision$source_role == "secondary" &&
        vision$taxon_status == "source_value_taxon_mismatch" &&
        vision$qualification_pass == "FALSE",
      "Congeneric color-vision source was not held for taxon review")

cat_rate <- one("DP-b8169f0d65e5bd08110dbbf8")
cat_mass <- points[points$item == "Mink_etal_1981_TABLE1" &
                     points$source_row_id == cat_rate$source_row_id &
                     points$column == "brain_weight.g", , drop = FALSE]
cat_spinal <- points[points$item == "Mink_etal_1981_TABLE1" &
                       points$source_row_id == cat_rate$source_row_id &
                       points$column == "spinal_cord_weight.g", , drop = FALSE]
check(nrow(cat_mass) == 1L && nrow(cat_spinal) == 1L &&
        cat_mass$upstream_keys == "57" && cat_spinal$upstream_keys == "57" &&
        cat_rate$upstream_keys == "30", "Mink point-specific source links failed")
sheep <- one("DP-5d09b0b077bb993f4a7964b5")
check(sheep$value_origin == "predicted_model" && sheep$transformation_method == "Mink Eq. 1" &&
        sheep$upstream_keys == "20", "Mink prediction lineage failed")
camel <- one("DP-ef5b925481390a2a40dc007d")
check(camel$value_origin == "extrapolated_proxy" &&
        grepl("20", camel$upstream_keys, fixed = TRUE) &&
        grepl("52", camel$upstream_keys, fixed = TRUE) &&
        camel$qualification_pass == "FALSE", "Mink camel extrapolation hold failed")
goldfish <- one("DP-27c2d3913e999b42abbc9bd0")
check(goldfish$source_role == "mixed" &&
        goldfish$value_origin == "derived_from_own_observed_ratio" &&
        goldfish$qualification_pass == "FALSE", "Mink own-ratio mixed lineage failed")
horse <- one("DP-152623a989a5106d9cca5aaf")
check(horse$value_origin == "extrapolated_proxy" &&
        grepl("76", horse$upstream_keys, fixed = TRUE) &&
        grepl("52", horse$upstream_keys, fixed = TRUE),
      "Mink horse printed-citation extrapolation failed")

homo <- one("DP-7b31c41fc349c3c8c58d4b7f")
phocoena <- one("DP-5571942f97dc2f17f1718665")
neuro <- one("DP-0069fef3df126d9e2e48a551")
check(homo$source_role == "primary" && homo$qualification_pass == "TRUE",
      "Boddy original Sherwood role failed")
check(homo$value_origin == "original_mass_summary",
      "Boddy original multi-report mean was mislabeled as a direct observation")
check(phocoena$source_role == "secondary" && phocoena$upstream_reference == "Crile & Quiring 1940" &&
        phocoena$qualification_pass == "TRUE", "Boddy secondary measured report failed")
check(neuro$value_origin == "estimated_from_endocranial_volume" &&
        neuro$trait_id == "brain_mass_estimated_from_ecv" &&
        neuro$transformation_status == "verified" &&
        neuro$method_status == "unresolved" &&
        neuro$qualification_pass == "FALSE", "Boddy endocranial method hold failed")
check(sum(lineage$to_point_id == homo$point_id &
            lineage$relation == "mean_of_original_reports") == 7L,
      "Boddy Homo original-report aggregate links failed")
check(sum(lineage$to_point_id == phocoena$point_id &
            lineage$relation == "reprinted_compilation_report") == 1L,
      "Boddy secondary relay link failed")
mixed_boddy <- one("DP-6489406fb96c650dbda38a9d")
check(mixed_boddy$source_role == "mixed" &&
        mixed_boddy$value_origin == "mixed_original_and_relayed_mean" &&
        mixed_boddy$component_lineage_status == "unresolved" &&
        mixed_boddy$qualification_pass == "FALSE",
      "Boddy original-plus-relayed mean was not held")

ila_presence <- one("DP-b1f31513738e4d628de5f153")
ila_complexity <- one("DP-d3bac2229c4f4ba142474b83")
ila_taxon_hold <- one("DP-0dd80e534abd9f58bbe28221")
check(ila_presence$value_type == "category" && ila_presence$unit == "category" &&
        ila_presence$accepted_species == "Notamacropus parma" &&
        ila_presence$qualification_pass == "TRUE", "Falcone categorical ILA failed")
check(ila_complexity$value_origin == "formula_derived_index" &&
        ila_complexity$source_role == "primary", "Falcone derived primary index failed")
check(ila_taxon_hold$qualification_pass == "FALSE" &&
        ila_taxon_hold$taxon_status == "unresolved", "Falcone unresolved taxon hold failed")
kandti <- one("DP-b061753cecd77ee3f7d30496")
check(kandti$printed_taxon == "Cercocebus kandti" &&
        kandti$source_snapshot_taxon == "Cercopithecus kandti" &&
        kandti$taxon_status == "conflicting_printed_tables" &&
        kandti$qualification_pass == "FALSE",
      "Falcone paper-versus-snapshot taxon conflict was not held")

buchsbaum <- points[points$item == "Buchsbaum_etal_1989_TableI", , drop = FALSE]
kaufman <- points[points$item == "Kaufman__2004_TableA3", , drop = FALSE]
check(nrow(buchsbaum) == 48L &&
        sum(buchsbaum$qualification_pass == "TRUE") == 36L &&
        sum(buchsbaum$qualification_pass == "FALSE") == 12L &&
        all(buchsbaum$source_role == "primary") &&
        all(buchsbaum$column == "CMRglc.umol_100g_min") &&
        all(grepl("pool_eligibility", buchsbaum$blocker_codes[
          buchsbaum$qualification_pass == "FALSE"], fixed = TRUE)),
      "Buchsbaum region reports and printed summaries were not separated")
check(nrow(kaufman) == 140L &&
        sum(kaufman$qualification_pass == "TRUE") == 1L &&
        sum(kaufman$qualification_pass == "FALSE") == 139L &&
        sum(kaufman$source_role == "primary") == 2L &&
        sum(kaufman$source_role == "secondary") == 138L &&
        all(kaufman$column %in% c("CMRgl_umol_100g_min",
                                  "CMRO2_umol_100g_min",
                                  "CBF_ml_100g_min")),
      "Kaufman measured quantities or row-level source roles changed")
original <- one("DP-54cea553e335471d90eed8c5")
relay <- one("DP-dfb56c7925a07c7938d0dbb3")
check(original$source_role == "primary" &&
        relay$source_role == "secondary" &&
        original$qualification_pass == "TRUE" &&
        relay$qualification_pass == "TRUE" &&
        original$accepted_species == "Homo sapiens" &&
        relay$accepted_species == original$accepted_species &&
        original$anatomy_behavior_target == "Thalamus" &&
        relay$anatomy_behavior_target == original$anatomy_behavior_target &&
        original$trait_id == relay$trait_id &&
        original$unit == "umol/100g/min" && relay$unit == original$unit &&
        original$numeric_value == "24.3" &&
        relay$numeric_value == original$numeric_value &&
        original$dispersion_sd == "7.2" &&
        relay$dispersion_sd == original$dispersion_sd &&
        original$n_individuals_source_row == "10" &&
        relay$n_individuals_source_row == original$n_individuals_source_row &&
        relay$upstream_reference_id == "buchsbaum_1989" &&
        original$method_status == "verified" &&
        relay$method_status == "verified",
      "The original Buchsbaum thalamus report and Kaufman relay do not qualify together")
present_study <- kaufman[kaufman$source_role == "primary", , drop = FALSE]
check(nrow(present_study) == 2L &&
        all(grepl("Present Study", present_study$source_note, fixed = TRUE)) &&
        all(present_study$qualification_pass == "FALSE") &&
        all(grepl("species_identity", present_study$blocker_codes, fixed = TRUE)) &&
        all(grepl("method", present_study$blocker_codes, fixed = TRUE)),
      "Kaufman's own two study rows were mislabeled or prematurely qualified")
check(sum(lineage$from_point_id == original$point_id &
            lineage$to_point_id == relay$point_id &
            lineage$relation == "reprinted_compilation_report") == 1L,
      "Buchsbaum-to-Kaufman observation link is missing")

heffner <- points[points$item == "Heffner_Heffner_2010_b_Table1", , drop = FALSE]
check(nrow(heffner) == 63L &&
        all(heffner$source_role == "secondary") &&
        all(heffner$qualification_pass == "FALSE") &&
        all(c("audible_freq_high_60dBSPL_khz",
              "interaural_distance_functional_us",
              "basilar_membrane_length_mm") %in% heffner$column),
      "Heffner's three compiled variables were not separated and held")
dolphin <- heffner[heffner$printed_taxon == "Tursiops truncates", , drop = FALSE]
check(nrow(dolphin) == 3L &&
        all(dolphin$source_snapshot_taxon == "Tursiops truncatus") &&
        all(dolphin$taxon_status == "printed_name_differs_from_snapshot") &&
        dolphin$upstream_keys[dolphin$column == "audible_freq_high_60dBSPL_khz"] == "ii" &&
        dolphin$upstream_keys[dolphin$column == "basilar_membrane_length_mm"] == "jj" &&
        dolphin$upstream_status[dolphin$column == "interaural_distance_functional_us"] == "unresolved",
      "Heffner's printed taxon and separate source keys were lost")
check(all(heffner$upstream_status[heffner$upstream_keys %in% c("m", "q")] ==
            "compound_citation_unresolved") &&
        all(heffner$upstream_status[heffner$upstream_keys %in% c("h", "j")] ==
            "bibliography_entry_missing"),
      "Heffner multi-work or unlocated footnotes were promoted to source IDs")

bahney1 <- points[points$item == "Bahney_vonBartheld_2018_TABLE1", , drop = FALSE]
bahney2 <- points[points$item == "Bahney_vonBartheld_2018_TABLE2", , drop = FALSE]
check(nrow(bahney1) == 36L && nrow(bahney2) == 36L &&
        all(c(bahney1$source_role, bahney2$source_role) == "primary") &&
        all(c(bahney1$n_individuals_source_row,
              bahney2$n_individuals_source_row) == "3") &&
        all(c("spinal_cord_glia_neuron_ratio",
              "spinal_cord_nonneuron_neuron_ratio") %in%
            c(bahney1$trait_id, bahney2$trait_id)),
      "Bahney's original methods, segment reports, or ratio types were conflated")
check(all(c(bahney1$unit_status[bahney1$column == "cells_million"],
            bahney2$unit_status[bahney2$column == "cells_million"]) == "unresolved") &&
        all(c(bahney1$unit_status[bahney1$trait_id == "spinal_cord_glia_neuron_ratio"],
              bahney2$unit_status[bahney2$trait_id == "spinal_cord_glia_neuron_ratio"]) == "unresolved"),
      "Bahney's total-cell and GNR definition mappings were prematurely accepted")
bahney3 <- points[points$item == "Bahney_vonBartheld_2018_TABLE3", , drop = FALSE]
bahney4 <- points[points$item == "Bahney_vonBartheld_2018_TABLE4", , drop = FALSE]
check(nrow(bahney3) == 86L && nrow(bahney4) == 224L &&
        sum(bahney3$source_role == "primary") == 2L &&
        sum(bahney4$source_role == "primary") == 2L &&
        sum(bahney3$source_role == "unresolved") == 2L &&
        sum(bahney4$source_role == "unresolved") == 2L &&
        all(bahney3$qualification_pass == "FALSE") &&
        all(bahney4$qualification_pass == "FALSE"),
      "Bahney literature rows or own-study estimated masses were misclassified")
check(all(bahney3$upstream_status[bahney3$source_role == "secondary"] ==
            "row_level_citation_scope_unverified") &&
        all(bahney4$upstream_status[bahney4$source_role == "secondary"] ==
            "row_level_citation_scope_unverified") &&
        all(bahney4$unit_status[bahney4$column == "brain_mass_mg"] ==
            "inferred_from_other_table") &&
        all(grepl("pool_eligibility",
                  bahney4$blocker_codes[bahney4$anatomy_behavior_target == "Rest of brain"],
                  fixed = TRUE)) &&
        all(bahney4$blocker_codes[bahney4$column == "brain_mass_mg"] != ""),
      "Bahney row citations or inferred mass units were treated as verified points")

fobbs <- points[points$item == "Fobbs_etal_2011_TableS1a", , drop = FALSE]
check(nrow(fobbs) == 802L &&
        setequal(unique(fobbs$column), c("crown_to_rump_length_mm",
                                        "crown_to_heel_length_mm")) &&
        all(fobbs$source_role == "unresolved") &&
        all(fobbs$inventory_role == "primary") &&
        all(nzchar(fobbs$inventory_disagreement)) &&
        all(fobbs$unit_status == "unresolved") &&
        all(fobbs$qualification_pass == "FALSE") &&
        all(grepl("pool_eligibility", fobbs$blocker_codes, fixed = TRUE)),
      "Fobbs specimen lengths were promoted as species traits or incorrectly typed")
check(length(unique(specimen_screen$item)) == 7L &&
        sum(as.integer(specimen_screen$n_source_rows[
          !duplicated(specimen_screen$item)])) == 2303L &&
        sum(as.integer(specimen_screen$n_inventory_points)) == 4252L &&
        sum(as.integer(specimen_screen$n_inventory_points[
          specimen_screen$disposition == "send_to_specimen_measurement_gate"])) == 802L &&
        specimen_screen$source_grain[
          specimen_screen$item == "Fobbs_etal_2011_TableS4"] == "box",
      "Fobbs seven-item catalog screening is incomplete")

kennedy_table <- points[points$item == "Kennedy_etal_1978_Table", , drop = FALSE]
kennedy_text <- points[points$item == "Kennedy_etal_1978_Text", , drop = FALSE]
check(nrow(kennedy_table) == 39L &&
        all(kennedy_table$source_role == "primary") &&
        all(kennedy_table$accepted_species == "Macaca mulatta") &&
        all(kennedy_table$dispersion_type == "SEM") &&
        all(is.na(kennedy_table$dispersion_sd) |
              !nzchar(kennedy_table$dispersion_sd)) &&
        all(kennedy_table$qualification_pass == "TRUE") &&
        all(kennedy_table$n_individuals_source_row %in% c("6", "7")),
      "Kennedy original regional means, species, sample size, or SEM were lost")
check(nrow(kennedy_text) == 10L &&
        sum(kennedy_text$source_role == "primary") == 5L &&
        sum(kennedy_text$source_role == "secondary") == 5L &&
        sum(kennedy_text$inventory_role == "primary" &
              kennedy_text$source_role == "secondary") == 4L &&
        all(kennedy_text$qualification_pass == "FALSE"),
      "Kennedy Text's mixed source roles or hold decisions changed")
kennedy_oxygen <- kennedy_text[kennedy_text$column == "CMRO2.umol_100g_min", , drop = FALSE]
check(nrow(kennedy_oxygen) == 1L &&
        kennedy_oxygen$upstream_reference_id == "schmidt_1945" &&
        kennedy_oxygen$taxon_status == "cited_sample_taxon_mixed_or_unresolved" &&
        kennedy_oxygen$transformation_status == "verified",
      "Kennedy cited Schmidt oxygen value was assigned the paper's rhesus species")
kennedy_human <- kennedy_text[which(
  kennedy_text$upstream_reference_id == "sokoloff_1976"), , drop = FALSE]
check(nrow(kennedy_human) == 2L &&
        all(kennedy_human$source_role == "secondary") &&
        all(kennedy_human$upstream_status == "intermediate_review_reference"),
      "Kennedy human value lost its intermediate review-source status")
kennedy_estimate <- kennedy_text[kennedy_text$value_origin ==
  "estimated_from_original_regional_means", , drop = FALSE]
check(nrow(kennedy_estimate) == 1L &&
        kennedy_estimate$raw_value == "29" &&
        kennedy_estimate$transformation_status == "unresolved" &&
        kennedy_estimate$qualification_pass == "FALSE",
      "Kennedy printed whole-brain estimate was prematurely accepted")
kennedy_composite <- lineage[lineage$relation ==
  "regional_mean_input_to_relayed_composite", , drop = FALSE]
check(nrow(kennedy_composite) == 4L &&
        length(unique(kennedy_composite$to_point_id)) == 1L &&
        all(kennedy_composite$from_point_id %in% kennedy_table$point_id),
      "Kennedy-to-Kaufman four-region composite lineage is missing")

check(any(excluded$item == "ManyPrimates__2022_STMperformance" &
            excluded$column_name == "n_trials") &&
        any(excluded$item == "Boddy_etal_2012_TableS1" &
              excluded$column_name == "Reference") &&
        any(excluded$item == "Buchsbaum_etal_1989_TableI" &
              excluded$column_name == "value_numeric") &&
        any(excluded$item == "Kaufman__2004_TableA3" &
              excluded$column_name == "CMRgl_SD") &&
        any(excluded$item == "Kaufman__2004_TableA3" &
              excluded$column_name == "n"),
      "Context fields were not excluded from observations")
ready <- points[points$qualification_pass == "TRUE", , drop = FALSE]
check(nrow(ready) > 0L &&
        all(nzchar(ready$trait_id) & nzchar(ready$unit) &
              nzchar(ready$accepted_species) & nzchar(ready$reporting_reference) &
              nzchar(ready$measurement_method) & nzchar(ready$trait_definition) &
              nzchar(ready$anatomy_behavior_target)) &&
        all(ready$taxon_status == "verified" & ready$method_status == "verified" &
              ready$unit_status == "verified" &
              ready$source_role %in% c("primary", "secondary", "mixed")) &&
        all(ready$source_role != "mixed" |
              ready$component_lineage_status == "verified"),
      "Qualified points have missing required metadata")
check(nrow(points) == 5285L && nrow(ready) == 699L &&
        nrow(lineage) == 67L,
      "Ten-paper scope or qualification counts changed")
if (!qualification_only) {
check(nrow(preference) > 0L && "Atelerix algirus" %in% preference$Species,
      "Cross-source primary preference audit is empty")
stephan_review <- selection[selection$case_id == "stephan_collection_lineage_pending", , drop = FALSE]
fallback_choice <- selection[selection$case_id == "secondary_fallback_in_current_pool", , drop = FALSE]
check(nrow(stephan_review) == 1L &&
        (is.na(stephan_review$selected_point_id) ||
           stephan_review$selected_point_id == "") &&
        stephan_review$relayed_point_id == "DP-ca27d31db641e41413a6dc8e" &&
        stephan_review$decision_status == "source_lineage_unresolved" &&
        grepl("DP-8a64543f70df323b4ac6907e", stephan_review$evidence, fixed = TRUE),
      "Stephan collection-lineage question was not held for review")
check(nrow(fallback_choice) == 1L &&
        fallback_choice$selected_point_id == "DP-c6475a496edd4341b7093215" &&
        fallback_choice$selected_role == "secondary" &&
        fallback_choice$n_primary_report_rows_current_pool == "0",
      "Boddy secondary fallback did not reflect current pool")
pan <- behavior[behavior$Species == "Pan paniscus", , drop = FALSE]
check(nrow(behavior) == 15L && nrow(pan) == 1L &&
        pan$many_value == "38" && pan$schniter_value == "11" &&
        pan$selected_value == "11" &&
        pan$schniter_original_measurement_status == "unverified_in_this_pilot",
      "Behavior overlap preference or provenance status failed")
}
if (qualification_only) {
  selector_db <- DBI::dbConnect(RSQLite::SQLite(),
    dbname = file.path(here, "..", "pilot_single_pipeline",
                       "pilot_single_pipeline.sqlite"),
    flags = RSQLite::SQLITE_RO)
  count_table <- function(name) DBI::dbGetQuery(selector_db,
    paste("SELECT COUNT(*) AS n FROM", name))$n[[1L]]
  db_ready <- DBI::dbGetQuery(selector_db,
    "SELECT COUNT(*) AS n FROM point_metadata WHERE qualification_pass = 'TRUE'")$n[[1L]]
  db_choice <- DBI::dbGetQuery(selector_db, paste(
    "SELECT selection_id, selected_point_id, n_qualified_candidates, decision_status",
    "FROM selection_decision WHERE selected_point_id = 'DP-54cea553e335471d90eed8c5'"
  ))
  db_relay <- DBI::dbGetQuery(selector_db, paste(
    "SELECT sc.point_id FROM selection_candidate sc",
    "JOIN selection_decision sd ON sd.selection_id = sc.selection_id",
    "WHERE sd.selected_point_id = 'DP-54cea553e335471d90eed8c5'"
  ))
  db_upstream <- DBI::dbGetQuery(selector_db, paste(
    "SELECT r.reference_text FROM point_reference pr",
    "JOIN reference r ON r.reference_id = pr.reference_id",
    "WHERE pr.point_id = 'DP-dfb56c7925a07c7938d0dbb3'",
    "AND pr.reference_role = 'upstream'"
  ))
  db_heffner_refs <- DBI::dbGetQuery(selector_db, paste(
    "SELECT COUNT(*) AS n_links, COUNT(DISTINCT pr.point_id) AS n_points",
    "FROM point_reference pr JOIN point_metadata p ON p.point_id = pr.point_id",
    "WHERE p.item = 'Heffner_Heffner_2010_b_Table1'",
    "AND pr.reference_role <> 'reporting'"
  ))
  db_bahney_row_refs <- DBI::dbGetQuery(selector_db, paste(
    "SELECT COUNT(*) AS n FROM point_reference pr",
    "JOIN point_metadata p ON p.point_id = pr.point_id",
    "WHERE p.item IN ('Bahney_vonBartheld_2018_TABLE3',",
    "'Bahney_vonBartheld_2018_TABLE4')",
    "AND pr.reference_role = 'row_context'"
  ))
  db_primary_extra_refs <- DBI::dbGetQuery(selector_db, paste(
    "SELECT COUNT(*) AS n FROM point_reference pr",
    "JOIN point_metadata p ON p.point_id = pr.point_id",
    "WHERE p.source_role = 'primary' AND pr.reference_role <> 'reporting'"
  ))
  db_intermediate_reviews <- DBI::dbGetQuery(selector_db, paste(
    "SELECT COUNT(*) AS n FROM point_reference pr",
    "JOIN point_metadata p ON p.point_id = pr.point_id",
    "WHERE p.upstream_status = 'intermediate_review_reference'",
    "AND pr.reference_role = 'intermediate_review'"
  ))
  db_review_points <- DBI::dbGetQuery(selector_db,
    "SELECT COUNT(*) AS n FROM point_metadata WHERE upstream_status = 'intermediate_review_reference'")
  fk_issues <- DBI::dbGetQuery(selector_db, "PRAGMA foreign_key_check")
  check(count_table("point_metadata") == nrow(points) &&
          count_table("item_variable") == 59L &&
          db_ready == nrow(ready) &&
          count_table("lineage") == nrow(lineage) &&
          count_table("selection_decision") == 698L &&
          count_table("selection_candidate") == nrow(ready) &&
          nrow(db_choice) == 1L &&
          db_choice$n_qualified_candidates[[1L]] == 2L &&
          db_choice$decision_status[[1L]] == "verified_original_preferred_over_relay" &&
          setequal(db_relay$point_id, c(original$point_id[[1L]],
                                        relay$point_id[[1L]])) &&
          nrow(db_upstream) == 1L &&
          grepl("Buchsbaum", db_upstream$reference_text[[1L]], fixed = TRUE) &&
          db_heffner_refs$n_links[[1L]] == 48L &&
          db_heffner_refs$n_points[[1L]] == 42L &&
          db_bahney_row_refs$n[[1L]] == 302L &&
          db_primary_extra_refs$n[[1L]] == 0L &&
          db_intermediate_reviews$n[[1L]] == db_review_points$n[[1L]] &&
          nrow(fk_issues) == 0L,
        "Ten-paper relational selection failed its count, relay, reference, or key check")
  DBI::dbDisconnect(selector_db)
} else {
  pilot_db <- DBI::dbConnect(RSQLite::SQLite(),
                             dbname = file.path(here, "pilot_metadata.sqlite"),
                             flags = RSQLite::SQLITE_RO)
  db_ready <- DBI::dbGetQuery(pilot_db,
    "SELECT COUNT(*) AS n FROM qualified_points")$n[[1L]]
  db_review <- DBI::dbGetQuery(pilot_db,
    "SELECT COUNT(*) AS n FROM review_queue")$n[[1L]]
  db_upstream <- DBI::dbGetQuery(pilot_db, paste(
    "SELECT r.reference_text FROM point_reference pr",
    "JOIN reference r ON r.ref_id = pr.ref_id",
    "WHERE pr.point_id = 'DP-ca27d31db641e41413a6dc8e'",
    "AND pr.reference_role = 'upstream'"
  ))
  fk_issues <- DBI::dbGetQuery(pilot_db, "PRAGMA foreign_key_check")
  DBI::dbDisconnect(pilot_db)
  check(db_ready == nrow(ready) && db_review == nrow(points) - nrow(ready) &&
          nrow(db_upstream) == 1L &&
          db_upstream$reference_text == "Stephan 1981" &&
          nrow(fk_issues) == 0L,
        "Legacy relational pilot output failed its count, reference, or key check")
}
cat("Pilot checks passed:", nrow(points), "points,", nrow(ready),
    "qualification passes,", nrow(lineage), "confirmed lineage links\n")

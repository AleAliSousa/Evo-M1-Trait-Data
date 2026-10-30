# =============================================================================
# _tools/build_coverage_index.R
#
# Builds the coverage index behind the Finder's "Coverage & gaps" tab.
# Read-only over the repository; writes only into __Finder/data/.
#
#   Rscript _tools/build_coverage_index.R
#
# The build READS mappings, it never defines them. Every structure link, every
# boundary-basis ruling and every acquisition target comes from _keys/:
#
#   _keys/anatomy_crosswalk.csv          concept x domain x term, relation, link_class
#   _keys/structure_boundary_basis.csv   per paper: boundary basis + source role
#   _keys/coverage_targets.csv           named acquisition targets (planned / wanted)
#
# Status of one record (one concept x species x term x measurement x source):
#   harmonized      direct link AND primary source AND active in its merge
#   not_harmonized  proxy link, OR secondary / compilation / derived source,
#                   OR flagged in its merge, OR species name unverified
#   planned         named target in coverage_targets.csv (target_status = planned)
#   not_found       core species x project concept x measurement with no record
#
# Different boundary bases are never pooled: each record keeps its own
# boundary_basis, and the app shows them side by side.
#
# Outputs (__Finder/data/):
#   coverage_records.csv       one row per record
#   coverage_cooccurrence.csv  concept x species: which domains have direct data
#   coverage_targets.csv       copy of the targets key, for the app
#   coverage_build_log.md      counts, drops and unresolved items
# =============================================================================

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(stringr)
})

# ---- paths -------------------------------------------------------------------
script_path <- local({
  a <- commandArgs(trailingOnly = FALSE)
  f <- sub("^--file=", "", a[grepl("^--file=", a)])
  if (length(f)) normalizePath(f) else
    tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
})
repo <- if (!is.na(script_path)) normalizePath(file.path(dirname(script_path), "..")) else getwd()
stopifnot(dir.exists(file.path(repo, "_keys")))
out_dir <- file.path(repo, "__Finder", "data")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

rd <- function(...) read_csv(file.path(repo, ...), show_col_types = FALSE, guess_max = 1e5)
log <- c("# Coverage index build log", paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M")), "")

# ---- keys --------------------------------------------------------------------
xw <- rd("_keys", "anatomy_crosswalk.csv") |>
  mutate(across(everything(), ~ replace_na(as.character(.x), "")))
bb <- rd("_keys", "structure_boundary_basis.csv") |>
  mutate(role = word(source_role, 1))
tg <- rd("_keys", "coverage_targets.csv") |>
  mutate(across(everything(), ~ replace_na(as.character(.x), "")))

CORE <- c("Homo sapiens", "Mus musculus", "Macaca mulatta", "Callithrix jacchus")
PROJECT <- c("M1", "V1", "EC", "MEC", "LEC")
PROJECT_MEASURES <- tribble(
  ~measurement_class,  ~measurement,
  "Regional size",     "Surface area",
  "Regional size",     "Volume",
  "Regional size",     "Thickness",
  "Cell measurements", "Total cell count",
  "Cell measurements", "Neuron count",
  "Cell measurements", "Non-neuronal cell count",
  "Cell measurements", "Cell density",
  "Cell measurements", "Neuron density",
  "Cell measurements", "Non-neuronal density",
  "Metabolism",        "Glucose utilization (CMRglc)",
  "Metabolism",        "Oxygen consumption (CMRO2)",
  "Metabolism",        "Blood flow (CBF)",
  "Cytoarchitecture",  "GLI"
)

# Source role of a record: look each cited paper up in structure_boundary_basis.
# A record is primary if at least one cited paper is primary (or unlisted:
# merges admit sources as primary unless the key says otherwise).
role_of <- function(src) {
  vapply(src, function(s) {
    parts <- str_trim(str_split(s, ";|\\|")[[1]])
    parts <- parts[nzchar(parts)]
    if (!length(parts)) return("primary")
    roles <- vapply(parts, function(p) {
      p <- sub("^[^:]+:\\s*", "", p)            # "Team: Paper" -> "Paper"
      hit <- bb$role[vapply(bb$paper, function(k) startsWith(p, k), logical(1))]
      if (length(hit)) hit[1] else "primary"
    }, character(1))
    if (any(roles == "primary")) "primary" else roles[1]
  }, character(1), USE.NAMES = FALSE)
}

# ---- domain readers ------------------------------------------------------------
# Each returns: species, measurement, measurement_class, dimension, units,
#               source, merge_status, flag_note, dataset_source, build_script
empty <- tibble(species = character(), measurement = character(), measurement_class = character(),
                dimension = character(), units = character(), source = character(),
                merge_status = character(), flag_note = character(),
                dataset_source = character(), build_script = character())

ca <- rd("__merging_cortical_areas", "cortical_areas_long.csv")
read_cortical_areas <- function(term, pat) {
  d <- ca |> filter(Standardized_Term == term)
  if (nzchar(pat)) d <- d |> filter(str_detect(source, fixed(pat)))
  dropped <- d |> filter(!(status == "active" | str_starts(status, "flagged")))
  if (nrow(dropped)) log <<- c(log, sprintf("- cortical_areas %s: %d row(s) not used (status %s)",
                              term, nrow(dropped), paste(unique(dropped$status), collapse = ", ")))
  d <- d |> filter(status == "active" | str_starts(status, "flagged"))
  meas <- case_when(str_detect(term, "Surface_Area") ~ "Surface area",
                    str_detect(term, "Thickness") ~ "Thickness", TRUE ~ term)
  d |> transmute(species = coalesce(accepted_name, Species), measurement = meas,
                 measurement_class = "Regional size",
                 dimension = if_else(meas == "Surface area", "2D", "1D"),
                 units = if_else(meas == "Surface area", "mm2", "mm"),
                 source, merge_status = status,
                 flag_note = if_else(status == "active", "", paste0("merge status: ", status)),
                 dataset_source = "__merging_cortical_areas/cortical_areas_long.csv",
                 build_script = "__merging_cortical_areas/cortical_areas_compiled.R")
}

vol <- rd("__merging_volumes", "volumes_long.csv")
read_volumes <- function(term, pat) {
  d <- vol |> filter(Variable == term)
  if (nzchar(pat)) d <- d |> filter(str_detect(Sources, fixed(pat)))
  d |> transmute(species = coalesce(accepted_name, Species),
                 measurement = "Volume", measurement_class = "Regional size",
                 dimension = "3D", units = "mm3", source = Sources, merge_status = "active",
                 flag_note = if_else(str_detect(term, "grey_matter"), "grey matter only", ""),
                 dataset_source = "__merging_volumes/volumes_long.csv",
                 build_script = "__merging_volumes/volumes_compiled.R")
}

cc <- rd("__merging_cellcounts", "cellcounts_long.csv")
CC_MEASURE <- tribble(
  ~code,    ~measurement,                 ~measurement_class,  ~units,
  "C.n",    "Total cell count",           "Cell measurements", "count",
  "N.n",    "Neuron count",               "Cell measurements", "count",
  "O.n",    "Non-neuronal cell count",    "Cell measurements", "count",
  "I.n",    "Microglia count",            "Cell measurements", "count",
  "N.p.mg", "Neuron density",             "Cell measurements", "per mg",
  "O.p.mg", "Non-neuronal density",       "Cell measurements", "per mg",
  "I.p.mg", "Microglia density",          "Cell measurements", "per mg",
  "O.p.N",  "Non-neuronal / neuron ratio","Cell measurements", "ratio",
  "Mass.g", "Mass",                       "Regional size",     "g"
)
read_cellcounts <- function(term, pat) {
  # Volumes are excluded here: __merging_volumes is authoritative (trait_authority RULE-1)
  d <- cc |> filter(str_starts(Variable, paste0(term, "_"))) |>
    mutate(code = str_remove(Variable, paste0("^", term, "_"))) |>
    inner_join(CC_MEASURE, by = "code")
  if (nzchar(pat)) d <- d |> filter(str_detect(Source, fixed(pat)))
  d |> transmute(species = coalesce(accepted_name, Species), measurement, measurement_class,
                 dimension = if_else(measurement == "Mass", "mass", "count"), units,
                 source = Source, merge_status = "active",
                 flag_note = if_else(str_detect(measurement, "Non-neuronal"),
                                     "isotropic fractionator 'other cells' (non-neuronal; mostly glia)", ""),
                 dataset_source = "__merging_cellcounts/cellcounts_long.csv",
                 build_script = "__merging_cellcounts/cellcounts_compiled.R")
}

cmr <- rd("__merging_cerebral_metabolic_rate", "cerebral_metabolic_rate_long.csv")
CMR_MEASURE <- c(CMRgl = "Glucose utilization (CMRglc)", CMRO2 = "Oxygen consumption (CMRO2)",
                 CBF = "Blood flow (CBF)", Total_glucose_utilization = "Total glucose utilization",
                 Total_O2_consumption = "Total O2 consumption")
read_cmr <- function(term, pat) {
  d <- cmr |> filter(Region == term, Measure %in% names(CMR_MEASURE))
  if (nzchar(pat)) d <- d |> filter(str_detect(Compilations, fixed(pat)))
  d |> transmute(species = coalesce(accepted_name, Species),
                 measurement = unname(CMR_MEASURE[Measure]), measurement_class = "Metabolism",
                 dimension = "rate", units = Units, source = Compilations, merge_status = "active",
                 flag_note = "",
                 dataset_source = "__merging_cerebral_metabolic_rate/cerebral_metabolic_rate_long.csv",
                 build_script = "__merging_cerebral_metabolic_rate/build_cerebral_metabolic_rate_merge.py")
}

gli <- rd("__merging_GLI", "GLI_long.csv")
read_gli <- function(term, pat) {
  d <- gli |> filter(area_as_published == term)
  if (nzchar(pat)) d <- d |> filter(str_detect(source, fixed(pat)))
  d |> transmute(species = coalesce(accepted_name, Species), measurement = "GLI",
                 measurement_class = "Cytoarchitecture", dimension = "index", units = "%",
                 source, merge_status = "active",
                 flag_note = "sampled cytoarchitectural index; not a cell count or stereological density",
                 dataset_source = "__merging_GLI/GLI_long.csv",
                 build_script = "__merging_GLI/GLI_compiled.py")
}

cl <- rd("__merging_cortical_layers", "cortical_layers_m1_long.csv")
read_layers <- function(term, pat) {
  d <- cl |> filter(m1_compatible %in% TRUE, taxon_level == "species", str_starts(status, "active"))
  if (nzchar(pat)) d <- d |> filter(str_detect(source, fixed(pat)))
  d |> transmute(species = coalesce(accepted_name, Species), measurement = "Thickness",
                 measurement_class = "Regional size", dimension = "1D",
                 units = if_else(measure == "proportional thickness", "proportion", coalesce(unit, "")),
                 source, merge_status = status,
                 flag_note = paste0("layer ", layer, "; ", measure),
                 dataset_source = "__merging_cortical_layers/cortical_layers_m1_long.csv",
                 build_script = "__merging_cortical_layers/cortical_layers_compiled.R")
}

READERS <- list(cortical_areas = read_cortical_areas, volumes = read_volumes,
                cellcounts = read_cellcounts, CMR = read_cmr, GLI = read_gli,
                cortical_layers = read_layers)

# Species names used anywhere: a record whose species is in none of them is flagged.
known_species <- unique(c(rd("_keys", "species_reference.csv")$accepted_name,
                          vol$accepted_name, cc$accepted_name, ca$accepted_name,
                          cmr$accepted_name, gli$accepted_name))

# ---- observed records ----------------------------------------------------------
obs <- list()
for (i in seq_len(nrow(xw))) {
  r <- xw[i, ]
  if (!r$domain %in% names(READERS)) next
  d <- READERS[[r$domain]](r$term, r$source_pattern)
  if (!nrow(d)) {
    log <- c(log, sprintf("- no rows: %s / %s / %s", r$concept, r$domain, r$term))
    next
  }
  obs[[length(obs) + 1]] <- d |>
    filter(!is.na(species), species != "") |>
    group_by(species, measurement, measurement_class, dimension, units, source,
             merge_status, flag_note, dataset_source, build_script) |>
    summarise(n_values = n(), .groups = "drop") |>
    mutate(concept = r$concept, scope = r$scope, region_group = r$region_group,
           domain = r$domain, term = r$term, relation = r$relation,
           link_class = r$link_class, boundary_basis = r$boundary_basis,
           link_basis = r$link_basis, link_note = r$note,
           role_key = r$source_role)
}
rec <- bind_rows(obs) |>
  mutate(
    source_role = if_else(nzchar(role_key), role_key, role_of(source)),
    species_unverified = !species %in% known_species,
    status = case_when(
      link_class == "proxy"              ~ "not_harmonized",
      source_role != "primary"           ~ "not_harmonized",
      str_starts(merge_status, "flagged") ~ "not_harmonized",
      species_unverified                 ~ "not_harmonized",
      TRUE                               ~ "harmonized"),
    reason = case_when(
      link_class == "proxy"              ~ paste0("proxy link: ", relation),
      source_role != "primary"           ~ paste0(source_role, " source"),
      str_starts(merge_status, "flagged") ~ paste0("flagged in merge: ", merge_status),
      species_unverified                 ~ "species name not found in species_reference or other merges",
      TRUE                               ~ "direct link, primary source, active in merge")
  ) |>
  select(-role_key)

# ---- planned + not_found -------------------------------------------------------
binomial <- function(x) str_detect(x, "^[A-Z][a-z]+ [a-z]+( [a-z]+)?$")
split_col <- function(x) str_trim(unlist(str_split(x, ";")))

planned <- tg |> filter(target_status == "planned") |>
  rename(measurement = measures, source = source_folder) |>
  separate_longer_delim(concept, ";") |>
  separate_longer_delim(species, ";") |>
  separate_longer_delim(measurement, ";") |>
  mutate(across(c(concept, species, measurement), str_trim)) |>
  filter(binomial(species)) |>
  left_join(distinct(xw, concept, region_group) |> distinct(concept, .keep_all = TRUE), by = "concept") |>
  left_join(bind_rows(PROJECT_MEASURES, distinct(CC_MEASURE, measurement_class, measurement)) |>
              distinct(measurement, .keep_all = TRUE), by = "measurement") |>
  transmute(concept, scope, region_group, species, domain, measurement,
            measurement_class = coalesce(measurement_class, "Regional size"),
            source, link_class, status = "planned",
            reason = paste0("target ", target_id, ": ", blocker),
            link_note = note, link_basis = paste0("_keys/coverage_targets.csv ", target_id),
            doi)

have <- bind_rows(rec, planned) |> distinct(concept, species, measurement)
wanted <- tg |> filter(target_status == "wanted")
want_note <- function(concept, species) {
  hit <- wanted |> filter(str_detect(concept, fixed(!!concept)) ,
                          species == "all" | str_detect(species, fixed(!!species)))
  if (nrow(hit)) paste0("wanted (", paste(hit$target_id, collapse = ", "), "): ",
                        paste(hit$note[nzchar(hit$note)], collapse = " ")) else ""
}
nf <- expand_grid(concept = PROJECT, species = CORE, PROJECT_MEASURES) |>
  anti_join(have, by = c("concept", "species", "measurement")) |>
  rowwise() |> mutate(link_note = want_note(concept, species)) |> ungroup() |>
  mutate(scope = "project_core", region_group = "Project", status = "not_found",
         reason = "no dataset currently identified")

records <- bind_rows(rec, planned, nf) |>
  mutate(is_core_species = species %in% CORE) |>
  relocate(scope, region_group, concept, species, measurement_class, measurement,
           status, reason, domain, term, relation, link_class, boundary_basis,
           source_role, source, n_values, units, dimension)
write_csv(records, file.path(out_dir, "coverage_records.csv"), na = "")

# ---- co-occurrence (direct links, observed data only) --------------------------
co <- rec |> filter(link_class == "direct") |>
  group_by(scope, region_group, concept, species) |>
  summarise(domains = paste(sort(unique(domain)), collapse = "; "),
            n_domains = n_distinct(domain),
            measurements = paste(sort(unique(measurement)), collapse = "; "),
            any_harmonized = any(status == "harmonized"), .groups = "drop") |>
  arrange(desc(n_domains), concept, species)
write_csv(co, file.path(out_dir, "coverage_cooccurrence.csv"), na = "")
write_csv(tg, file.path(out_dir, "coverage_targets.csv"), na = "")

# ---- log ---------------------------------------------------------------------
cnt <- count(records, status)
log <- c(log, "", "## Totals",
         sprintf("- %s: %d", cnt$status, cnt$n),
         sprintf("- concepts: %d; species with observed data: %d",
                 n_distinct(records$concept), n_distinct(rec$species)),
         sprintf("- species names flagged as unverified: %s",
                 paste(sort(unique(rec$species[rec$species_unverified])), collapse = "; ")))
writeLines(log, file.path(out_dir, "coverage_build_log.md"))
message(paste(sprintf("%s=%d", cnt$status, cnt$n), collapse = "  "))

## DRAFT (2026-09-27) — compile the comparative CELL MORPHOLOGY dataset:
## neuron/glial cell TYPE x SOMA SIZE x DENDRITIC / SPINE morphology, one row per printed statistic.
##
## Pattern: read each source's public TSV via the registry (__ReadMe.xlsx), relabel/reshape it
## through the stacked standardized-term map, stack to ONE long table. Like __merging_cortical_layers
## the product stays LONG (species x region x layer x cell_type x measure x statistic); no wide table
## is produced yet because cross-source pooling rules (Golgi vs stereology soma size, Betz vs
## gigantopyramidal naming, VEN counts on one hemisphere) need owner sign-off — see README__merging.md.
##
## What this script deliberately does NOT do (yet): average across sources, double hemispheres,
## resolve taxonomy through _keys/resolve_taxonomy.R (species are carried as the source's accepted
## column or the draft alias table; QA lists names absent from _keys/species_reference.csv).
##
## Outputs: cell_morphology_long.csv, cell_morphology_coverage.csv, cell_morphology_qa_*.csv
suppressWarnings(suppressMessages(library(tidyverse)))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  "."
})
setwd(dirname(.sp))
base   <- normalizePath(file.path(dirname(.sp), ".."))
tsvdir <- file.path(base, "__Public", "comparative-data")

## ---- sources -----------------------------------------------------------------------------
item_name <- c("Jacobs_etal_2018_Table3", "Jacobs_etal_2018_Table5", "Nguyen_etal_2019_Table2",
               "Bianchi_etal_2012_Table2", "Jacobs_etal_2015_Table4",
               "Elston__2000_Figure2", "Elston_etal_2001_Table1", "Elston_etal_2006_Table1",
               "Sherwood_etal_2003_Table1",
               "Nimchinsky_etal_1999_Table2", "Butti_etal_2009_Table5", "Butti_etal_2009_Table6",
               "Hakeem_etal_2009_Table1", "Raghanti_etal_2015_Table1",
               "Falcone_etal_2019_TABLE1", "Falcone_etal_2019_TABLE2",
               "Armstrong__1979_Tables1-9", "Nudo_etal_1995_TABLE2")

## Provisional team labels (owner to confirm against _keys/team_grouping_crosswalk.csv). "Jacobs" =
## the Golgi somatodendritic-tracing lineage (Jacobs lab; Bianchi 2012 and Nguyen 2019 use its
## protocol and, for human, its data). "Hof" = the Hof/Allman VEN stereology lineage.
team_of <- c(Jacobs_etal_2018_Table3 = "Jacobs", Jacobs_etal_2018_Table5 = "Jacobs",
             Nguyen_etal_2019_Table2 = "Jacobs", Bianchi_etal_2012_Table2 = "Jacobs",
             Jacobs_etal_2015_Table4 = "Jacobs",
             Elston__2000_Figure2 = "Elston", Elston_etal_2001_Table1 = "Elston",
             Elston_etal_2006_Table1 = "Elston",
             Sherwood_etal_2003_Table1 = "Sherwood",
             Nimchinsky_etal_1999_Table2 = "Hof", Butti_etal_2009_Table5 = "Hof",
             Butti_etal_2009_Table6 = "Hof", Hakeem_etal_2009_Table1 = "Hof",
             Raghanti_etal_2015_Table1 = "Sherwood",
             Falcone_etal_2019_TABLE1 = "Falcone", Falcone_etal_2019_TABLE2 = "Falcone",
             "Armstrong__1979_Tables1-9" = "Armstrong", Nudo_etal_1995_TABLE2 = "Nudo/Masterton")
stopifnot(all(item_name %in% names(team_of)))

## ---- registry ----------------------------------------------------------------------------
codes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")

## TEMPORARY filename overrides. The public TSV for Nimchinsky 1999 Table 2 is on disk with a
## stray space ("10.1073%2Fpnas.96.9.5268 _Table2.tsv") that the registry's `Item encoded` does
## not have. REMOVE this entry once Nimchinsky_etal_1999_Table2.R has been re-run and writes the
## registry-matching name; enc() will then resolve normally.
tsv_override <- c("Nimchinsky_etal_1999_Table2" = "10.1073%2Fpnas.96.9.5268 _Table2")

enc <- function(nm) {
  if (nm %in% names(tsv_override)) {
    f <- file.path(tsvdir, paste0(tsv_override[[nm]], ".tsv"))
    if (file.exists(f)) { warning("enc('", nm, "'): using TEMPORARY filename override -> ", basename(f), call. = FALSE); return(tsv_override[[nm]]) }
  }
  e <- codes$`Item encoded`[match(nm, codes$`Item name`)]
  if (length(e) != 1L || is.na(e) || !nzchar(e))
    stop("enc('", nm, "'): no 'Item encoded' in __ReadMe.xlsx 'Item name'.", call. = FALSE)
  f <- file.path(tsvdir, paste0(e, ".tsv"))
  if (!file.exists(f))
    stop("enc('", nm, "'): registry resolves to a TSV that is not on disk -> ", f, call. = FALSE)
  e
}
doi_of <- function(nm) { d <- codes$`DOI (or Alt)`[match(nm, codes$`Item name`)]; ifelse(is.na(d), "", d) }

## ---- vocabularies -------------------------------------------------------------------------
rc <- function(f) readr::read_csv(f, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
terms    <- rc("standardized_term_cell_morphology.csv")
defs     <- rc("cell_morphology_definitions.csv")
ct_defs  <- rc("cell_type_definitions.csv")
ct_xw    <- rc("cell_type_crosswalk.csv")
rg_xw    <- rc("region_crosswalk.csv")
sp_alias <- rc("species_aliases_draft.csv")
measure_codes <- defs$measure
key_roles <- c("Species", "species_printed", "region_printed", "cell_type_printed", "layer_printed",
               "n", "specimen_id", "hemisphere", "ref", "method", "note")
bad <- setdiff(unique(terms$Standardized_Term), c(measure_codes, key_roles, "DROP", "FILTER"))
if (length(bad)) stop("Standardized_Term not in cell_morphology_definitions.csv or key roles: ",
                      paste(bad, collapse = ", "))

## ---- one source -> long -------------------------------------------------------------------
compile_one <- function(nm) {
  d <- readr::read_tsv(file.path(tsvdir, paste0(enc(nm), ".tsv")), show_col_types = FALSE,
                       col_types = readr::cols(.default = "c"), na = c("", "NA"))
  tm <- terms |> filter(Reference == nm)
  miss <- setdiff(names(d), tm$Original_Term)
  if (length(miss)) stop(nm, ": TSV columns without a term-map row: ", paste(miss, collapse = ", "))

  ## source-specific FILTER (Armstrong: only perikaryal-volume rows are cell morphology)
  flt <- tm |> filter(Standardized_Term == "FILTER")
  if (nrow(flt)) d <- d[d[[flt$Original_Term[1]]] %in% "perikaryal_volume", , drop = FALSE]
  d$.row <- seq_len(nrow(d))

  ## key columns
  pick <- function(role) { o <- tm$Original_Term[tm$Standardized_Term == role]; if (length(o)) o else NULL }
  key <- tibble(.row = d$.row)
  for (role in setdiff(key_roles, c("n", "note"))) {
    o <- pick(role); key[[role]] <- if (is.null(o)) NA_character_ else d[[o[1]]]
  }
  note_cols <- pick("note")
  key$source_note <- if (is.null(note_cols)) NA_character_ else
    vapply(seq_len(nrow(d)), function(i) {
      r <- unlist(d[i, note_cols, drop = TRUE]); keep <- !is.na(r) & nzchar(r)
      if (!any(keep)) NA_character_ else paste(paste0(note_cols[keep], "=", r[keep]), collapse = "; ")
    }, character(1))
  ## generic n (applies to every measure of the row)
  n_generic <- pick("n")
  key$n_generic <- if (is.null(n_generic)) NA_character_ else d[[n_generic[1]]]
  key$n_basis   <- if (is.null(n_generic)) NA_character_ else tm$unit[tm$Original_Term == n_generic[1]]

  ## value columns -> long
  vt <- tm |> filter(Standardized_Term %in% measure_codes)
  long <- d |>
    select(.row, all_of(vt$Original_Term)) |>
    pivot_longer(-.row, names_to = "Original_Term", values_to = "value_text") |>
    filter(!is.na(value_text), nzchar(value_text)) |>
    left_join(vt |> select(Original_Term, measure = Standardized_Term, cell_type_term = cell_type,
                           region_term = region, layer_term = layer, statistic, unit,
                           hemisphere_term = hemisphere, term_note = note),
              by = "Original_Term")

  ## measure-specific n (e.g. Jacobs 2018 T3 n_length / n_area / n_volume)
  n_spec <- long |> filter(statistic == "n") |>
    transmute(.row, measure, n_specific = value_text, n_basis_specific = unit)
  long <- long |> filter(statistic != "n") |>
    left_join(n_spec, by = c(".row", "measure")) |>
    left_join(key, by = ".row") |>
    mutate(n = coalesce(n_specific, n_generic),
           n_basis = coalesce(n_basis_specific, n_basis),
           hemisphere = coalesce(na_if(hemisphere_term, ""), hemisphere),
           source = nm, team = team_of[[nm]], doi = doi_of(nm))
  long
}

raw <- bind_rows(lapply(item_name, compile_one))

## ---- harmonise: species, cell type, region, layer -----------------------------------------
alias_join <- sp_alias |> transmute(source = Reference, species_printed_key = species_printed,
                                    Species_alias = Species, taxon_level_alias = taxon_level, alias_note = note)
long <- raw |>
  mutate(species_printed_key = ifelse(is.na(species_printed), "(none printed)", species_printed)) |>
  left_join(alias_join, by = c("source", "species_printed_key")) |>
  mutate(Species = coalesce(Species, Species_alias, species_printed),
         taxon_level = case_when(!is.na(taxon_level_alias) ~ taxon_level_alias,
                                 grepl(" sp\\.$", Species) ~ "genus",
                                 TRUE ~ "species")) |>
  ## cell type: term-level code wins; else printed label through the crosswalk
  left_join(ct_xw |> transmute(source = Reference, cell_type_printed, cell_type_xw = cell_type, layer_xw = layer),
            by = c("source", "cell_type_printed")) |>
  mutate(cell_type = coalesce(na_if(cell_type_term, ""), cell_type_xw),
         cell_type = ifelse(is.na(cell_type) & !is.na(cell_type_printed),
                            paste0("UNMAPPED:", cell_type_printed), cell_type)) |>
  ## region: term-level label first, else printed; both go through the crosswalk
  mutate(region_key = coalesce(na_if(region_term, ""), region_printed),
         region_key = ifelse(source == "Jacobs_etal_2015_Table4", "pooled_multiregion", region_key),
         region_key = ifelse(source == "Nudo_etal_1995_TABLE2", "cortex_all_CS", region_key)) |>
  left_join(rg_xw |> filter(Reference == "*") |> transmute(region_key = region_printed, region_star = region),
            by = "region_key") |>
  left_join(rg_xw |> filter(Reference != "*") |> transmute(source = Reference, region_key = region_printed, region_src = region),
            by = c("source", "region_key")) |>
  mutate(region = coalesce(region_src, region_star),
         region = ifelse(is.na(region) & !is.na(region_key), paste0("UNMAPPED:", region_key), region),
         region_printed = coalesce(region_printed, region_term)) |>
  mutate(layer = coalesce(na_if(layer_term, ""), layer_xw, layer_printed, "not reported"))

## ---- unit fixes, data role, dependency, merge_default --------------------------------------
long <- long |>
  mutate(value = suppressWarnings(as.numeric(gsub(",", "", value_text))),
         curation_note = NA_character_) |>
  ## Elston 2001 prints basal dendritic field area in units of 10^4 um2 -> rescale to um2
  mutate(rescale = unit == "1e4 um2",
         value = ifelse(rescale, value * 1e4, value),
         curation_note = ifelse(rescale, "value rescaled x10^4 from the printed '10^4 um2' unit", curation_note),
         unit = ifelse(rescale, "um2", unit)) |> select(-rescale) |>
  mutate(
    data_role = case_when(
      source == "Bianchi_etal_2012_Table2" & Species == "Homo sapiens" ~ "secondary",
      source == "Jacobs_etal_2015_Table4" & !is.na(ref) & nzchar(ref)  ~ "secondary",
      source == "Elston_etal_2006_Table1" & ref %in% "w"                ~ "primary",
      source == "Elston_etal_2006_Table1"                               ~ "secondary",
      source == "Elston__2000_Figure2" & region %in% c("V1", "parietal_7a", "temporal_TE") ~ "secondary",
      TRUE ~ "primary"),
    dependency = case_when(
      source == "Bianchi_etal_2012_Table2" & Species == "Homo sapiens" ~ "reuses Jacobs_etal_1997 / Jacobs_etal_2001 human Golgi data (parents not tabulated per area in repo)",
      source == "Jacobs_etal_2015_Table4" & ref %in% "a" ~ "Jacobs et al. 2011 (elephant) - primary not in repo",
      source == "Jacobs_etal_2015_Table4" & ref %in% "b" ~ "Butti et al. 2014 (cetaceans) - primary not in repo",
      source == "Elston_etal_2006_Table1" & ref %in% "t" ~ "Elston_etal_2001_Table1 (same value already merged from its own table)",
      source == "Elston_etal_2006_Table1" & !ref %in% c("w", "t") ~ paste0("earlier Elston paper, footnote '", ref, "' (see article footnote key)"),
      source == "Elston__2000_Figure2" & region %in% c("V1", "parietal_7a", "temporal_TE") ~ "comparator values from earlier Elston studies",
      ## Elston 2001 'Macaque / Prefrontal' re-tabulates the Elston 2000 area-10 cells (same n = 29
      ## data set: 32.36 vs 32.35 branches, 13.3e4 vs 133.2e3 um2; see ELSTON_2000_SPECIES_EVIDENCE.md).
      ## Kept (2001 prints the SD that 2000 lacks) but the dependency is named.
      source == "Elston_etal_2001_Table1" & Species == "Macaca fascicularis" & region == "PFC" &
        measure %in% c("basal_dendritic_field_area", "peak_branching_complexity") ~
        "same cells as Elston__2000_Figure2 area 10 (re-tabulated; species named here)",
      TRUE ~ NA_character_),
    merge_default = !(source == "Elston_etal_2006_Table1" & ref %in% "t"),
    observation_level = case_when(
      source %in% c("Armstrong__1979_Tables1-9", "Hakeem_etal_2009_Table1") ~ "individual",
      TRUE ~ "species summary"),
    hemisphere = case_when(
      !is.na(hemisphere) ~ hemisphere,
      source %in% c("Butti_etal_2009_Table5", "Hakeem_etal_2009_Table1", "Armstrong__1979_Tables1-9") ~ "single (see row)",
      TRUE ~ "not reported"),
    method = case_when(
      !is.na(method) ~ method,
      team == "Elston" ~ "intracellular Lucifer Yellow injection, tangential slices (Elston protocol)",
      source %in% c("Bianchi_etal_2012_Table2", "Jacobs_etal_2015_Table4", "Nguyen_etal_2019_Table2") ~ "Golgi somatodendritic tracing (Jacobs protocol)",
      source == "Sherwood_etal_2003_Table1" ~ "planar rotator stereology, Nissl",
      source %in% c("Nimchinsky_etal_1999_Table2", "Butti_etal_2009_Table6") ~ "Nissl soma volume (nucleator/rotator)",
      source %in% c("Butti_etal_2009_Table5", "Hakeem_etal_2009_Table1") ~ "optical fractionator, Nissl",
      source == "Raghanti_etal_2015_Table1" ~ "Nissl counts, layer V, % of neurons",
      source == "Armstrong__1979_Tables1-9" ~ "Nissl perikaryal volumetry",
      grepl("Falcone", source) ~ "GFAP immunohistochemistry + Neurolucida 3-D reconstruction",
      TRUE ~ NA_character_),
    curation_note = case_when(
      source == "Butti_etal_2009_Table6" ~ ifelse(is.na(curation_note), "", paste0(curation_note, "; ")) %>% paste0("region ACC is the folder README's inference, not printed in the caption"),
      source == "Elston__2000_Figure2" ~ ifelse(is.na(curation_note), "", paste0(curation_note, "; ")) %>% paste0(
        "values transcribed from Results text, not a printed table; species not named in the paper ('macaque monkey') - ",
        "resolved to M. fascicularis from Elston 2001/2006 re-tabulation of the same cells (ELSTON_2000_SPECIES_EVIDENCE.md); ",
        "animal described as 12-y female here but 10-y male in Elston 2001/2006",
        ifelse(measure == "basal_dendritic_field_area" & statistic == "sd",
               "; printed 'SD' equals the SEM of the Elston 2001 SD for the same cells (19900/sqrt(29) = 3695) - label suspect", "")),
      TRUE ~ curation_note))

## ---- method class + app-ready variable label -------------------------------------------------
## The Shiny app averages every row that shares (Species, Variable), so the label must carry
## everything that must NOT be pooled: region, cell type, measure, and the METHOD CLASS (a Golgi
## soma area and a nucleator soma area are not the same quantity). Layer is implied by cell_type
## except for Falcone's pial (I) vs subpial (II) interlaminar astrocytes, which get a `variant`.
long <- long |>
  mutate(
    method_class = case_when(
      source %in% c("Jacobs_etal_2018_Table5", "Nguyen_etal_2019_Table2",
                    "Bianchi_etal_2012_Table2", "Jacobs_etal_2015_Table4") ~ "golgi",
      team == "Elston"                                                 ~ "LYinj",
      source %in% c("Jacobs_etal_2018_Table3", "Sherwood_etal_2003_Table1",
                    "Nimchinsky_etal_1999_Table2", "Butti_etal_2009_Table6") ~ "stereology",
      source %in% c("Butti_etal_2009_Table5", "Hakeem_etal_2009_Table1") ~ "fractionator",
      source == "Raghanti_etal_2015_Table1"  ~ "nissl_count",
      source == "Armstrong__1979_Tables1-9"  ~ "nissl_perikaryal",
      source == "Nudo_etal_1995_TABLE2"      ~ "HRP",
      grepl("^Falcone", source)              ~ "GFAP",
      TRUE ~ "unclassified"),
    variant = ifelse(source == "Falcone_etal_2019_TABLE1",
                     tolower(gsub(" ", "_", sub("^ILA ", "", Original_Term))), NA_character_),
    variable_label = paste0(region, "_", cell_type, "_", measure,
                            ifelse(is.na(variant), "", paste0("_", variant)),
                            " [", method_class, "]"))
stopifnot(!any(long$method_class == "unclassified"))

## ---- final column order --------------------------------------------------------------------
long <- long |>
  transmute(source, doi, team, Species, species_printed, taxon_level, observation_level, specimen_id,
            region, region_printed, layer, cell_type, cell_type_printed,
            measure, statistic, value, value_text, unit, n, n_basis, hemisphere, method, method_class,
            variant, variable_label,
            data_role, dependency, merge_default, ref, source_note, term_note, curation_note) |>
  arrange(source, Species, region, cell_type, measure, statistic)
## Species naming columns (SPECIES_NAMING.md v1): Species / species_printed stay as harmonised above
## (source accepted column or draft alias table); the shared resolver adds the identity anchor + basis
## from the printed name (or Species where nothing was printed), keyed by paper folder.
source(file.path(base, "_keys", "resolve_species.R"))
rs <- resolve_species(coalesce(long$species_printed, long$Species),
                      source_publication = paper_folder_of_item(long$source, base))
long <- long |> mutate(accepted_name = rs$accepted_name, species_basis = rs$species_basis,
                       reidentified = rs$reidentified)

readr::write_csv(long, "cell_morphology_long.csv", na = "")

## ---- coverage: which species x cell_type x region x measure exist, from how many sources ----
central <- long |> filter(merge_default, statistic %in% c("mean", "estimate", "value", "category"))
coverage <- central |>
  group_by(Species, taxon_level, region, layer, cell_type, measure, unit) |>
  summarise(n_sources = n_distinct(source), sources = paste(sort(unique(source)), collapse = " | "),
            n_values = n(), .groups = "drop") |>
  arrange(measure, cell_type, region, Species)
readr::write_csv(coverage, "cell_morphology_coverage.csv", na = "")

## ---- QA ---------------------------------------------------------------------------------
## (a) cross-source overlaps: same species x region x cell_type x measure from more than one source
qa_overlap <- central |>
  group_by(Species, region, layer, cell_type, measure) |>
  filter(n_distinct(source) > 1) |>
  select(Species, region, layer, cell_type, measure, source, team, method, value, unit, n, data_role) |>
  arrange(Species, measure, cell_type, region, source)
readr::write_csv(qa_overlap, "cell_morphology_qa_overlaps.csv", na = "")
## (b) unmapped labels
qa_unmapped <- long |> filter(grepl("^UNMAPPED:", cell_type) | grepl("^UNMAPPED:", region)) |>
  distinct(source, cell_type_printed, cell_type, region_printed, region)
readr::write_csv(qa_unmapped, "cell_morphology_qa_unmapped_labels.csv", na = "")
## (c) species names not in the project species reference
spref <- rc(file.path(base, "_keys", "species_reference.csv"))
qa_species <- long |> distinct(source, Species, species_printed, taxon_level) |>
  filter(!Species %in% spref$accepted_name) |> arrange(Species)
readr::write_csv(qa_species, "cell_morphology_qa_species_not_in_reference.csv", na = "")

message("cell_morphology: ", nrow(long), " long rows from ", n_distinct(long$source), " sources; ",
        n_distinct(long$Species), " taxa; ", n_distinct(long$cell_type), " cell types; ",
        n_distinct(long$measure), " measures. Overlap groups: ",
        nrow(distinct(qa_overlap, Species, region, layer, cell_type, measure)),
        "; unmapped labels: ", nrow(qa_unmapped), "; species not in reference: ", nrow(qa_species))

## Compile the comparative cortical-area dataset (number of areas + cortical surface area).
## Pattern mirrors __merging_volumes / __merging_cellcounts: read each source's public TSV, relabel
## its columns via the stacked standardized-term map, stack to long, summarise to wide.
## Outputs: cortical_areas_long.csv, cortical_areas_wide.csv, cortical_areas_source_species_ids.csv
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

## which tables feed this merge (Item names) -> their measure roles handled below
item_name <- c("Changizi__2001_Figure3",
               "Finlay_etal_2006_Table6.1",
               "Collins_etal_2010_DatasetS1",       # surface via collins_2010_surface_from_paper.csv
               "Young_etal_2013_Table1",            # REGIONAL M1 surface area (M1_Surface_Area.mm2)
               "Turner_etal_2016_Table1",           # whole-cortex surface via turner_2016_surface.csv (case dedupe)
               "Collins_etal_2016_Table1",          # ADDED 2026-08-25: chimp cortex/V1/V2/M1 areas (bespoke block; M1 superseded by Young 2013 — same specimen KAAS-PAN-11_38)
               "Mota_HerculanoHouzel_2015_TableS1",# ADDED 2026-08-25: OWN columns only (AG total surface, MHH folding index, thickness; per ONE hemisphere). "_other" columns are secondary compilations — never merged.
               "Mota_etal_2019_SupplementaryTableS1",# ADDED 2026-08-25: AT/AE/T only (per one hemisphere). VT/VG/VW volumes HELD for a __merging_volumes overlap audit; N (cortical neurons) skipped as a compilation.
               "Smaers_etal_2017_TableS1part2",     # ADDED 2026-08-25 (owner decision): SECONDARY — Brodmann 1909 regional surfaces via Smaers 2017. Ingested deliberately (primary not built); a future Brodmann-1909 build supersedes it.
               "Brodmann__1913_Table1",             # ADDED 2026-08-25: PRIMARY — Brodmann 1913 total cortical surface, one hemisphere, 38 taxa (bespoke block: one human row kept).
               "Campos_Welker_1976_Table1",         # ADDED 2026-10-19: PRIMARY — total cortical surface, fissure subset/percentage, and thickness; one specimen/species, hemisphere count unclear.
               "Huffman_etal_1999_TABLE2",          # ADDED 2026-10-19: PRIMARY — mapped S1 surface, averaged across cases within species.
               "VanEssen_Drury_1997_Table1",        # ADDED 2026-10-19: PRIMARY human total neocortex + authors' visual-cortex estimate; V1 and macaque rows are secondary and remain provenance-only.
               ## ---- RELATIVE + ABSOLUTE surface sources (ADDED 2026-10-21; see relative_absolute_helpers.R) ----
               "Krubitzer_Kaas_1990_Table1",        # PRIMARY, per case: % of total neocortex surface for 8 visual fields (17,18,DL,DM,DI,FST,MT,MST) -> *_Surface_Area.pct_Neocortex. No absolute denominator printed -> not convertible inside the merge.
               "Catania_etal_1999_Table1",          # PRIMARY, per case: total neocortex, V1, A1, S1+S2 block in mm2 AND % of neocortex -> printed absolutes kept, % re-derived as a check.
               "Catania_Remple_2002_Table1",        # PRIMARY, per case: total neocortex and S1 in mm2 (individuals); approximate species-level S1 % kept as relative; rat 21% comparator held as secondary.
               "Sarko_etal_2011_ResultsText",       # PRIMARY, age-group means: total neocortex, V1, PMBSF (mm2) + approximate % -> adults active, juveniles held. The source item's recomputed_pct column is wrong for adults and is NOT used; % is recomputed here.
               "Preuss_Kaas_1996_ResultsText",      # PRIMARY, one specimen: V1 66 mm2 + ~12% of cortical mantle -> denominator derived by inversion, held (approximate %).
               "Krubitzer_etal_1997_ResultsText",   # PRIMARY, approximate: total neocortex "about 15 mm2" (one hemisphere, includes cingulate) -> active, value_status approximate. PV/S2 (combined label) not wired.
               "Seelke_etal_2016_Table2",           # PRIMARY but GROUP-LEVEL % of adjusted cortical sheet (treatment x sex groups) -> all rows HELD (held_group_level_pct_only); listed as unconverted.
               "Felleman_VanEssen_1991_Table2")     # SECONDARY SYNTHESIS, one composite macaque hemisphere: V1/V2/MT/visual-cortex mm2 and % -> HELD (held_secondary_synthesis), provenance only.

## Species aliases — unify spelling variants across sources so the same animal joins on one Species.
## (Collins printed "Otolemur garnetti"/"Aotus nancymae"; Young the correct "garnettii"/"nancymaae";
##  the two Papio labels in Young are NCBI homotypic synonyms.)
sp_alias <- c("Otolemur garnetti" = "Otolemur garnettii",
              "Aotus nancymae"    = "Aotus nancymaae",
              "Papio hamadryas anubis" = "Papio cynocephalus anubis",
              ## Mota 2015/2019 printed-name repairs (2026-08-25). Mota 2019 re-reports the same
              ## hemisphere measurements (AT values identical to 2015's AG) under typo'd names;
              ## without these aliases the lineage supersede misses and one animal splits into two
              ## Species rows. Dasyprocta: both papers misspell D. prymnolopha (2015 "promnolopha",
              ## 2019 "primnolopha"). Papio: three labels, one olive-baboon taxon.
              "Girafa camelopardalis"     = "Giraffa camelopardalis",
              "Tragelaphus stripceros"    = "Tragelaphus strepsiceros",
              "Dasyprocta promnolopha"    = "Dasyprocta prymnolopha",
              "Dasyprocta primnolopha"    = "Dasyprocta prymnolopha",
              "Papio anubis"              = "Papio cynocephalus anubis",
              "Papio anubis cynocephalus" = "Papio cynocephalus anubis",
              "Hydrochoerus hydrochoerus" = "Hydrochoerus hydrochaeris",
              ## Smaers 2017 part2 prints the chimp as a trinomial (2026-08-25). NOTE: its
              ## Papio_cynocephalus and Papio_hamadryas are two SEPARATE Brodmann taxa — neither
              ## is aliased to the Kaas-lab "Papio cynocephalus anubis" (different animals).
              "Pan troglodytes troglodytes" = "Pan troglodytes")
unify <- function(s) ifelse(s %in% names(sp_alias), sp_alias[s], s)

## Trait classes: whole-cortex vs regional. Regional traits are NEVER pooled with whole-cortex ones.
regional_terms <- c("M1_Surface_Area.mm2", "V1_Surface_Area.mm2", "V2_Surface_Area.mm2",
                    "S1_Surface_Area.mm2", "VisualCortex_Surface_Area.mm2",
                    "Prefrontal_Surface_Area.mm2", "OtherAssociation_Surface_Area.mm2",
                    "FrontalMotor_Surface_Area.mm2",   # FrontalMotor = Brodmann's agranular frontal block, NOT M1
                    ## ADDED 2026-10-21 (relative/absolute integration): further regional absolute terms
                    "A1_Surface_Area.mm2", "S2_Surface_Area.mm2", "MT_Surface_Area.mm2",
                    "DL_Surface_Area.mm2", "DM_Surface_Area.mm2", "DI_Surface_Area.mm2",
                    "FST_Surface_Area.mm2", "MST_Surface_Area.mm2",
                    "SomatosensoryS1S2_Surface_Area.mm2",  # Catania 1999 "total somatosensory cortex (S1+S2)" block -- NOT S1; never pooled with S1
                    "S1_PMBSF_Surface_Area.mm2")           # Sarko 2011 posteromedial barrel subfield, a sub-field of S1 -- never pooled with S1
## Relative regional terms: <Region>_Surface_Area.pct_<Denominator>. trait_class = "regional_relative".
## Their denominator_term names the absolute term they are a fraction of; denominator_definition keeps
## the source's own wording (total neocortex / adjusted cortical sheet / cortical mantle / visual cortex).
source("relative_absolute_helpers.R")

## HEMISPHERE CONVENTION (2026-08-25; exception flagged 2026-10-20): the established surface
## sources measure ONE cortical hemisphere (Collins 2010/2016 flattened hemispheres, Turner
## per-hemisphere averaged per animal, Young M1 per hemisphere, Mota 2015/2019 "one cortical
## hemisphere only" per caption). Campos & Welker 1976 is an exception: Table 1 does not clearly
## establish the laterality or hemisphere count for its surface values, so those rows carry source
## flags and must not be doubled. Other CorticalSurface_Area.mm2 and
## CorticalExposedSurface_Area.mm2 values are per hemisphere unless their source says otherwise.

## NB 2026-09-27: the Mota & Herculano-Houzel 2015 item is keyed as
## "Mota_HerculanoHouzel_2015_TableS1" (registry column F now strips hyphens; the paper
## folder is Mota_HerculanoHouzel_2015). Its term file keeps its old file name,
## standardized_term_by_reference/Mota_Herculano-Houzel_2015_TableS1_standardized_terms.csv,
## but its Reference column carries the new key.
terms  <- readr::read_csv("standardized_term_cortical_areas.csv", show_col_types = FALSE)
codes  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
enc    <- function(nm) {
  # Fail loudly on an unresolved item name. This used to return NA, and
  # file.path(tsvdir, paste0(NA, ".tsv")) is "NA.tsv" -- a path that really existed
  # in __Public/comparative-data/ as a stale artefact of an earlier unresolved
  # build. So a lost registry row did not stop the merge; it fed it the WRONG
  # table. (2026-08-20: exactly this happened to the gyrification merge.)
  e <- codes$`Item encoded`[match(nm, codes$`Item name`)]
  if (length(e) != 1L || is.na(e) || !nzchar(e))
    stop("enc('", nm, "'): no 'Item encoded' in __ReadMe.xlsx 'Item name'. ",
         "Add or repair the registry row.", call. = FALSE)
  f <- file.path(tsvdir, paste0(e, ".tsv"))
  if (!file.exists(f))
    stop("enc('", nm, "'): registry resolves to a TSV that is not on disk -> ", f,
         " (run that source's own build script, or fix 'Item encoded').", call. = FALSE)
  e
}

## ---- long: one row per (Species, Standardized_Term, source) ----
long <- list()

# generic count/surface sources read straight from their TSV (Changizi 2001, Finlay, Young M1,
# Changizi & Shimojo 2005). The Species join column is resolved from each source's term map (the
# Original_Term mapped to Standardized_Term == "Species"), since e.g. C&S 2005 prints it as species_sci.
for (nm in c("Changizi__2001_Figure3", "Finlay_etal_2006_Table6.1", "Young_etal_2013_Table1",
             "Changizi_Shimojo_2005_Table1",
             "Mota_HerculanoHouzel_2015_TableS1",     # own columns only (term map maps nothing else)
             "Mota_etal_2019_SupplementaryTableS1")) { # AT/AE/T only (term map maps nothing else)
  tsv <- file.path(tsvdir, paste0(enc(nm), ".tsv"))
  d   <- readr::read_tsv(tsv, show_col_types = FALSE)
  spcol <- terms$Original_Term[terms$Reference == nm & terms$Standardized_Term == "Species"]
  spcol <- if (length(spcol) && spcol %in% names(d)) spcol else "Species"
  tm  <- terms |> filter(Reference == nm, Standardized_Term != "Species")
  for (i in seq_len(nrow(tm))) {
    oc <- tm$Original_Term[i]; st <- tm$Standardized_Term[i]
    if (!oc %in% names(d)) next
    long[[paste(nm, st)]] <- tibble(
      Species = d[[spcol]], Standardized_Term = st,
      value = suppressWarnings(as.numeric(d[[oc]])), source = nm)
  }
}

# Collins: whole-hemisphere surface from the paper file (per-piece TSV undercounts galago #1)
cs <- readr::read_csv("collins_2010_surface_from_paper.csv", show_col_types = FALSE)
long[["Collins surface"]] <- tibble(Species = cs$Species, Standardized_Term = "CorticalSurface_Area.mm2",
                                    value = cs$`CorticalSurface_Area.mm2`, source = "Collins_etal_2010_DatasetS1")

# Turner 2016: whole-cortex ("brain") surface, CASE-LEVEL DEDUPE — drop cases that are the same
# specimen already contributed by another source (09-27 = Collins 2010 baboon). Multiple hemispheres/
# cases of one animal are averaged to one per-species-per-specimen value first, then to species.
ts <- readr::read_csv("turner_2016_surface.csv", show_col_types = FALSE) |>
  filter(dedupe_status == "include") |>
  group_by(Species, case) |> summarise(v = mean(`CorticalSurface_Area.mm2`), .groups = "drop")  # avg hemispheres of one animal
long[["Turner surface"]] <- tibble(Species = ts$Species, Standardized_Term = "CorticalSurface_Area.mm2",
                                   value = ts$v, source = "Turner_etal_2016_Table1")

# Collins 2016 (ADDED 2026-08-25): one chimp (Texas Biomedical, specimen crosswalk KAAS-PAN-11_38),
# right hemisphere, flattened-cortex areas by structure (cm2 -> mm2). Only architectonic regions are
# wired: whole cortex, V1, V2, M1. The "somatosensory/premotor block" and "Prefrontal Cortex" rows
# are dissection blocks with arbitrary boundaries — provenance only, not comparable areas.
# The left-hemisphere V1 serial-section row is a volume (no area) and is excluded by the area filter.
c16map <- c("cerebral cortex" = "CorticalSurface_Area.mm2",
            "V1"              = "V1_Surface_Area.mm2",
            "V2"              = "V2_Surface_Area.mm2",
            "M1"              = "M1_Surface_Area.mm2")
c16 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Collins_etal_2016_Table1"), ".tsv")),
                       show_col_types = FALSE) |>
  filter(method == "flattened", structure %in% names(c16map), !is.na(area_cm2))
long[["Collins 2016 areas"]] <- tibble(
  Species = c16$Species, Standardized_Term = unname(c16map[c16$structure]),
  value = c16$area_cm2 * 100, source = "Collins_etal_2016_Table1")

# Smaers 2017 part2 (ADDED 2026-08-25, owner decision): SECONDARY source — Brodmann 1909's
# 4-region surface partition (primary visual / prefrontal / other association / frontal motor),
# reproduced in Smaers 2017 Table S1. Ingested deliberately because the Brodmann-1909 primary is
# not built; if it ever is, it supersedes these rows. Species arrive underscore-joined.
# ADDITIVITY AUDIT (see README): the four regions sum EXACTLY to Brodmann 1913's per-hemisphere
# totals for marmoset, gibbon and chimp — confirming values are per ONE hemisphere. Mandrill is
# off by exactly +10,000 (sum 31,321 vs total 21,321): one of the two sources carries a misprint,
# most plausibly other_association 23422 -> 13422. That single cell is EXCLUDED below.
s17 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Smaers_etal_2017_TableS1part2"), ".tsv")),
                       show_col_types = FALSE) |>
  mutate(species = gsub("_", " ", species))
s17map <- c(primary_visual_surface    = "V1_Surface_Area.mm2",
            prefrontal_surface        = "Prefrontal_Surface_Area.mm2",
            other_association_surface = "OtherAssociation_Surface_Area.mm2",
            frontal_motor_surface     = "FrontalMotor_Surface_Area.mm2")
for (oc in names(s17map)) {
  long[[paste("Smaers17", oc)]] <- tibble(
    Species = s17$species, Standardized_Term = unname(s17map[oc]),
    value = suppressWarnings(as.numeric(s17[[oc]])), source = "Smaers_etal_2017_TableS1part2")
}

# Brodmann 1913 Table 1 (ADDED 2026-08-25): PRIMARY — total cortical surface of ONE hemisphere,
# 38 taxa across mammal orders (historical planimetry; expect method-level conflicts with modern
# sources, surfaced by conflict_flag). Of the five human rows only "Europäer: Durchschnitt"
# (112,471 mm2) enters the merge: Maximal-/Minimalwert are the envelope of the same series, and
# the "Naturmenschen"/"Idioten" rows are historical subset categories (the latter pathological) —
# all four are documented in the source folder, none is a species mean.
b13 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Brodmann__1913_Table1"), ".tsv")),
                       show_col_types = FALSE) |>
  filter(Species != "Homo sapiens" | Species_Brodmann1913 == "Europäer: Durchschnitt")
long[["Brodmann 1913 surface"]] <- tibble(
  Species = b13$Species, Standardized_Term = "CorticalSurface_Area.mm2",
  value = b13$`CorticalSurface_1hemisphere.mm2`, source = "Brodmann__1913_Table1")

# Campos & Welker 1976 Table 1: one specimen per species; laterality/hemisphere count for surface
# measures is unclear. The table separates total cortical surface from the portion in fissures, so
# the latter gets its own term and is never treated as exposed surface. Surface area may be derived
# from volume/thickness and no shrinkage correction is stated; flags are propagated below.
# Neocortical volume and neuron-count rows belong to their own merges.
cw76map <- c("cortical_surface_area_mm2" = "CorticalSurface_Area.mm2",
             "cortical_fissure_area_mm2" = "CorticalBuriedSurface_Area.mm2",
             "cortical_surface_in_fissures_pct" = "CorticalSurfaceInFissures.pct",
             "cortical_thickness_mm" = "CorticalThickness.mm")
cw76 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Campos_Welker_1976_Table1"), ".tsv")),
                        show_col_types = FALSE) |>
  filter(product == "cortical_morphometry", code %in% names(cw76map), !is.na(value))
long[["Campos Welker 1976 cortical morphometry"]] <- tibble(
  Species = cw76$species_as_published,
  Standardized_Term = unname(cw76map[cw76$code]),
  value = cw76$value, source = "Campos_Welker_1976_Table1",
  source_flags = cw76$source_flags, source_issue_note = cw76$source_issue_note)

# Huffman et al. 1999 Table 2: primary multiunit maps of S1 in northern quoll and striped possum.
# "Entire contralateral body" is the table's 100%-of-S1 row. Average cases within species so this
# source contributes one Species x trait value (quoll NQ3 and NQ5; striped possum SP1). Body-part
# subdivisions stay in the source TSV and are not pooled as whole fields here.
h99 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Huffman_etal_1999_TABLE2"), ".tsv")),
                       show_col_types = FALSE) |>
  filter(structure == "Entire contralateral body", !is.na(area_mm2)) |>
  group_by(Species) |>
  summarise(value = mean(area_mm2), .groups = "drop")
long[["Huffman 1999 S1"]] <- tibble(
  Species = h99$Species, Standardized_Term = "S1_Surface_Area.mm2",
  value = h99$value, source = "Huffman_etal_1999_TABLE2")

# Van Essen & Drury 1997: use only the authors' primary Visible-Man measurements and their own
# visual-cortex synthesis. Left/right hemispheres are averaged within structure. The quoted human
# V1 values and macaque case 79-0 are tagged secondary in the source item and intentionally remain
# provenance-only pending a primary-source/overlap audit. Lobe and buried/gyral partitions are also
# retained in the item but not pooled into unlike regional definitions here.
ved97map <- c("cerebral neocortex" = "CorticalSurface_Area.mm2",
              "estimated visual cortex" = "VisualCortex_Surface_Area.mm2")
ved97 <- readr::read_tsv(file.path(tsvdir, paste0(enc("VanEssen_Drury_1997_Table1"), ".tsv")),
                         show_col_types = FALSE) |>
  filter(Species == "Homo sapiens", structure %in% names(ved97map),
         data_role %in% c("primary", "primary synthesis"), !is.na(area_cm2)) |>
  group_by(Species, structure) |>
  summarise(
    value = mean(area_cm2) * 100,
    source_flags = paste(sort(unique(source_flags)), collapse = "|"),
    source_issue_note = paste(unique(source_issue_note), collapse = " "),
    .groups = "drop"
  )
long[["Van Essen Drury 1997 surfaces"]] <- tibble(
  Species = ved97$Species,
  Standardized_Term = unname(ved97map[ved97$structure]),
  value = ved97$value, source = "VanEssen_Drury_1997_Table1",
  source_flags = ved97$source_flags, source_issue_note = ved97$source_issue_note)

## ===================== RELATIVE + ABSOLUTE surface sources (2026-10-21) =====================
## Each block emits specimen, grain, n, value_status, value_basis = "printed", denominator_term and
## denominator_definition so the same-specimen conversion can run after status assignment.
rel_cols <- function(d) d |> mutate(value_basis = "printed", derivation = NA_character_)

## Krubitzer & Kaas 1990 Table 1 -- % of total neocortex surface per case, 8 visual fields.
kk90 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Krubitzer_Kaas_1990_Table1"), ".tsv")), show_col_types = FALSE)
kk90map <- c(pct_17 = "V1_Surface_Area.pct_Neocortex", pct_18 = "V2_Surface_Area.pct_Neocortex",
             pct_DL = "DL_Surface_Area.pct_Neocortex", pct_DM = "DM_Surface_Area.pct_Neocortex",
             pct_DI = "DI_Surface_Area.pct_Neocortex", pct_FST = "FST_Surface_Area.pct_Neocortex",
             pct_MT = "MT_Surface_Area.pct_Neocortex", pct_MST = "MST_Surface_Area.pct_Neocortex")
long[["KK90 relative"]] <- kk90 |>
  select(Species, case_number, all_of(names(kk90map)), source_flags, source_issue_note) |>
  pivot_longer(all_of(names(kk90map)), names_to = "oc", values_to = "value") |>
  transmute(Species, Standardized_Term = unname(kk90map[oc]), value = as.numeric(value),
            source = "Krubitzer_Kaas_1990_Table1", source_flags, source_issue_note,
            specimen = as.character(case_number), grain = "individual", n = 1L, value_status = "as_reported",
            denominator_term = "CorticalSurface_Area.mm2",
            denominator_definition = "total neocortex surface of the hemisphere (Krubitzer & Kaas 1990 Table 1 footnote)") |>
  rel_cols()

## Catania et al. 1999 Table 1 -- per case: mm2 AND % of neocortex.
c99 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Catania_etal_1999_Table1"), ".tsv")), show_col_types = FALSE)
c99map <- c("total neocortex" = "CorticalSurface_Area.mm2", "V1" = "V1_Surface_Area.mm2",
            "A1" = "A1_Surface_Area.mm2", "total somatosensory cortex (S1+S2)" = "SomatosensoryS1S2_Surface_Area.mm2")
c99 <- c99 |> filter(structure %in% names(c99map)) |>
  mutate(abs_term = unname(c99map[structure]), pct_term = sub("\\.mm2$", ".pct_Neocortex", abs_term),
         specimen = as.character(case_id), grain = "individual", n = 1L, value_status = "as_reported",
         source = "Catania_etal_1999_Table1",
         denominator_definition = "total neocortex of the flattened hemisphere (Catania et al. 1999 Table 1)")
long[["Catania99 abs"]] <- c99 |> filter(!is.na(area_mm2)) |>
  transmute(Species, Standardized_Term = abs_term, value = area_mm2, source, source_flags, source_issue_note,
            specimen, grain, n, value_status, denominator_term = NA_character_, denominator_definition = NA_character_) |> rel_cols()
long[["Catania99 pct"]] <- c99 |> filter(!is.na(pct_neocortex), structure != "total neocortex") |>
  transmute(Species, Standardized_Term = pct_term, value = pct_neocortex, source, source_flags, source_issue_note,
            specimen, grain, n, value_status, denominator_term = "CorticalSurface_Area.mm2", denominator_definition) |> rel_cols()

## Catania & Remple 2002 Table 1 -- individual total neocortex and S1 (mm2); approximate S1 % (species level).
cr02 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Catania_Remple_2002_Table1"), ".tsv")), show_col_types = FALSE)
cr02map <- c("total neocortex" = "CorticalSurface_Area.mm2", "primary somatosensory cortex (S1)" = "S1_Surface_Area.mm2")
long[["CataniaRemple02 abs"]] <- cr02 |> filter(statistic == "individual", structure %in% names(cr02map), !is.na(area_mm2)) |>
  transmute(Species, Standardized_Term = unname(cr02map[structure]), value = area_mm2, source = "Catania_Remple_2002_Table1",
            source_flags = NA_character_, source_issue_note = NA_character_,
            specimen = as.character(case_id), grain = "individual", n = 1L, value_status = "as_reported",
            denominator_term = NA_character_, denominator_definition = NA_character_) |> rel_cols()
long[["CataniaRemple02 pct"]] <- cr02 |> filter(statistic == "approximate", percent_denominator == "total neocortex") |>
  transmute(Species, Standardized_Term = "S1_Surface_Area.pct_Neocortex", value = percent_value,
            source = "Catania_Remple_2002_Table1",
            source_flags = ifelse(Species == "Rattus norvegicus", "secondary_comparator_from_other_study", "approximate_species_level"),
            source_issue_note = ifelse(Species == "Rattus norvegicus",
                                       "Rat value is a comparator quoted from another study, not measured here.",
                                       "Approximate species-level percentage printed in text; individual S1 and neocortex areas are in the same table."),
            specimen = NA_character_, grain = "species_mean", n = as.integer(n), value_status = "approximate",
            denominator_term = "CorticalSurface_Area.mm2",
            denominator_definition = "total neocortex (Catania & Remple 2002 text)") |> rel_cols()

## Sarko et al. 2011 -- age-group means (juvenile n=2, adult n=4): mm2 and approximate % of neocortex.
## The source item's recomputed_pct_neocortex is wrong for the adult rows (divides by the wrong total) -> NOT used.
s11 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Sarko_etal_2011_ResultsText"), ".tsv")), show_col_types = FALSE)
s11map <- c("total neocortex" = "CorticalSurface_Area.mm2", "V1" = "V1_Surface_Area.mm2", "PMBSF of S1" = "S1_PMBSF_Surface_Area.mm2")
s11 <- s11 |> filter(structure %in% names(s11map)) |>
  mutate(abs_term = unname(s11map[structure]), specimen = paste0("group:", age_group), grain = "group_mean",
         source = "Sarko_etal_2011_ResultsText",
         denominator_definition = "total neocortex of one hemisphere (Sarko et al. 2011 Results)")
long[["Sarko11 abs"]] <- s11 |> filter(!is.na(mean_area_mm2)) |>
  transmute(Species, Standardized_Term = abs_term, value = mean_area_mm2, source, source_flags, source_issue_note,
            specimen, grain, n = as.integer(n), value_status = "as_reported",
            denominator_term = NA_character_, denominator_definition = NA_character_) |> rel_cols()
long[["Sarko11 pct"]] <- s11 |> filter(!is.na(approx_pct_neocortex)) |>
  transmute(Species, Standardized_Term = sub("\\.mm2$", ".pct_Neocortex", abs_term), value = approx_pct_neocortex,
            source, source_flags, source_issue_note, specimen, grain, n = as.integer(n), value_status = "approximate",
            denominator_term = "CorticalSurface_Area.mm2", denominator_definition) |> rel_cols()

## Preuss & Kaas 1996 -- one specimen: V1 = 66 mm2 and ~12 % of the cortical mantle.
pk96 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Preuss_Kaas_1996_ResultsText"), ".tsv")), show_col_types = FALSE) |>
  filter(structure == "V1", measure %in% c("surface area", "percent of cortical mantle"))
long[["PreussKaas96"]] <- pk96 |>
  transmute(Species, Standardized_Term = ifelse(measure == "surface area", "V1_Surface_Area.mm2", "V1_Surface_Area.pct_Neocortex"),
            value = as.numeric(value), source = "Preuss_Kaas_1996_ResultsText",
            source_flags = ifelse(measure == "surface area", "single_specimen", "single_specimen|approximate_percent|denominator_cortical_mantle"),
            source_issue_note = ifelse(measure == "surface area", "", "Denominator is the cortical mantle = isocortex + proisocortex, not neocortex sensu stricto."),
            specimen = "adult female, left hemisphere", grain = "individual", n = 1L,
            value_status = ifelse(measure == "surface area", "as_reported", "approximate"),
            denominator_term = ifelse(measure == "surface area", NA_character_, "CorticalSurface_Area.mm2"),
            denominator_definition = ifelse(measure == "surface area", NA_character_, "cortical mantle (isocortex + proisocortex), one hemisphere")) |> rel_cols()

## Krubitzer et al. 1997 -- approximate total neocortex ("about 15 mm2", one hemisphere incl. cingulate).
k97 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Krubitzer_etal_1997_ResultsText"), ".tsv")), show_col_types = FALSE) |>
  filter(structure == "total neocortex", measure == "surface area")
long[["Krubitzer97 total"]] <- k97 |>
  transmute(Species, Standardized_Term = "CorticalSurface_Area.mm2", value = as.numeric(value), source = "Krubitzer_etal_1997_ResultsText",
            source_flags = "approximate_text_value|includes_cingulate", source_issue_note = source_text,
            specimen = NA_character_, grain = "species_mean", n = NA_integer_, value_status = "approximate",
            denominator_term = NA_character_, denominator_definition = NA_character_) |> rel_cols()

## Seelke et al. 2016 Table 2 -- % of adjusted cortical sheet, treatment x sex group means. HELD (group level, % only).
se16 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Seelke_etal_2016_Table2"), ".tsv")), show_col_types = FALSE)
se16map <- c(V1 = "V1_Surface_Area.pct_Neocortex", V2 = "V2_Surface_Area.pct_Neocortex", S1 = "S1_Surface_Area.pct_Neocortex",
             "S2/PV" = "S2_Surface_Area.pct_Neocortex", M1 = "M1_Surface_Area.pct_Neocortex", AC = "A1_Surface_Area.pct_Neocortex")
long[["Seelke16 pct"]] <- se16 |> filter(structure %in% names(se16map), !is.na(mean_pct_cortical_sheet)) |>
  transmute(Species, Standardized_Term = unname(se16map[structure]), value = mean_pct_cortical_sheet, source = "Seelke_etal_2016_Table2",
            source_flags, source_issue_note, specimen = paste0("group:", group, "/", sex), grain = "group_mean", n = as.integer(n),
            value_status = "as_reported", denominator_term = "CorticalSurface_Area.mm2",
            denominator_definition = "adjusted cortical sheet (cingulate subtracted when visible); S2/PV mapped to S2 term, AC to A1 term") |> rel_cols()

## Felleman & Van Essen 1991 Table 2 -- SECONDARY composite macaque hemisphere. HELD.
fve91 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Felleman_VanEssen_1991_Table2"), ".tsv")), show_col_types = FALSE)
fve_abs <- c(V1 = "V1_Surface_Area.mm2", V2 = "V2_Surface_Area.mm2", MT = "MT_Surface_Area.mm2",
             "Total Visual Cortex" = "VisualCortex_Surface_Area.mm2", "Total Neocortex" = "CorticalSurface_Area.mm2")
fve91 <- fve91 |> filter(structure %in% names(fve_abs)) |>
  mutate(abs_term = unname(fve_abs[structure]), specimen = "composite hemisphere (Fig. 2 map)", grain = "composite", n = NA_integer_,
         source = "Felleman_VanEssen_1991_Table2")
long[["FVE91 abs"]] <- fve91 |> filter(!is.na(area_mm2)) |>
  transmute(Species, Standardized_Term = abs_term, value = area_mm2, source, source_flags, source_issue_note, specimen, grain, n,
            value_status = "as_reported", denominator_term = NA_character_, denominator_definition = NA_character_) |> rel_cols()
long[["FVE91 pct neocortex"]] <- fve91 |> filter(!is.na(pct_neocortex), structure != "Total Neocortex") |>
  transmute(Species, Standardized_Term = sub("\\.mm2$", ".pct_Neocortex", abs_term), value = pct_neocortex, source, source_flags,
            source_issue_note, specimen, grain, n, value_status = "as_reported", denominator_term = "CorticalSurface_Area.mm2",
            denominator_definition = "total neocortex of the composite hemisphere (Felleman & Van Essen 1991 Table 2)") |> rel_cols()
long[["FVE91 pct visual"]] <- fve91 |> filter(!is.na(pct_visual_cortex), !structure %in% c("Total Visual Cortex", "Total Neocortex")) |>
  transmute(Species, Standardized_Term = sub("\\.mm2$", ".pct_VisualCortex", abs_term), value = pct_visual_cortex, source, source_flags,
            source_issue_note, specimen, grain, n, value_status = "as_reported", denominator_term = "VisualCortex_Surface_Area.mm2",
            denominator_definition = "total visual cortex of the composite hemisphere (Felleman & Van Essen 1991 Table 2)") |> rel_cols()

## Specimen ids for existing bespoke blocks where they are free (skill improvement 5).
long[["Turner surface"]]$specimen     <- as.character(ts$case);  long[["Turner surface"]]$grain <- "individual"
long[["Collins 2016 areas"]]$specimen <- "KAAS-PAN-11_38";        long[["Collins 2016 areas"]]$grain <- "individual"

long <- bind_rows(long) |> filter(!is.na(value)) |>
  mutate(specimen = as.character(specimen),
         grain = replace_na(grain, "not_recorded"),          # pre-2026-10-21 blocks did not record grain
         value_status = replace_na(value_status, "as_reported"),
         value_basis = replace_na(value_basis, "printed")) |>
  mutate(source_flags = replace_na(source_flags, ""),
         source_issue_note = replace_na(source_issue_note, ""),
         species_printed = Species,                                 # name before this merge's unify()
         Species = unify(Species),                                  # harmonise spelling variants
         trait_class = case_when(str_detect(Standardized_Term, pct_term_regex) ~ "regional_relative",
                                 Standardized_Term %in% regional_terms ~ "regional",
                                 TRUE ~ "whole_cortex"))
## Species naming columns (SPECIES_NAMING.md v1): Species keeps this merge's unify() label; the shared
## resolver adds the identity anchor + basis from the printed name, keyed by paper folder.
source(file.path(base, "_keys", "resolve_species.R"))
rs <- resolve_species(long$species_printed, source_publication = paper_folder_of_item(long$source, base))
long <- long |> mutate(accepted_name = rs$accepted_name, species_basis = rs$species_basis,
                       reidentified = rs$reidentified)

## Mota 2019 printed-thickness repair (2026-08-25). The paper defines mean thickness as
## T = VG/AG (gray volume / total surface), and 31 of 38 printed T values satisfy VG/AT exactly.
## In 6 rows (Cavia, Dasyprocta, Hydrochoerus, Callimico, Macaca radiata, M. fascicularis) the
## printed T instead DUPLICATES the AT/AE folding ratio (equal to 3 decimals) and in Sarcophilus
## it slips a decimal (printed 1198). Where the SAME hemisphere appears in Mota 2015 (AG = AT
## identical), the 2015 printed T equals VG/AT (Dasyprocta 1.846, Hydrochoerus 2.814, Callimico
## 1.600, M. fascicularis 1.411) — confirming VG/AT is the intended value. One nested error:
## Cavia's printed VG (412.4) fails VG + VW = VT (506.9 vs 906.9) — an additivity sweep of all 38
## rows finds ONLY Cavia — so its gray volume is recovered as VT − VW = 812.4, giving
## T = 812.4/536.1 = 1.515, exactly the 2015 printed T for the same hemisphere. So: where printed
## T deviates >5% from (repaired) VG/AT, the definitional value replaces it here. The frozen TSV
## keeps the printed numbers; this is an export/spreadsheet artefact repair, same policy as the
## Sherwood 2004 en-dashes.
m19tab <- readr::read_tsv(file.path(tsvdir, paste0(enc("Mota_etal_2019_SupplementaryTableS1"), ".tsv")),
                          show_col_types = FALSE) |>
  mutate(VG_use = ifelse(!is.na(VT_mm3) & !is.na(VW_mm3) & !is.na(VG_mm3) &
                         abs(VG_mm3 + VW_mm3 - VT_mm3) / VT_mm3 > 0.02,
                         VT_mm3 - VW_mm3, VG_mm3),
         T_def  = VG_use / AT_mm2) |>
  filter(!is.na(T_mm), !is.na(T_def), abs(T_mm - T_def) / T_def > 0.05)
if (nrow(m19tab)) {
  message("Mota 2019 thickness repaired for ", nrow(m19tab), " species (printed T != VG/AT): ",
          paste(m19tab$Species, collapse = ", "))
  for (i in seq_len(nrow(m19tab))) {
    sel <- long$source == "Mota_etal_2019_SupplementaryTableS1" &
           long$Standardized_Term == "CorticalThickness.mm" &
           long$Species == unify(m19tab$Species[i])
    long$value[sel] <- m19tab$T_def[i]
  }
}

## ---- supersede: within the Changizi lineage, C&S 2005 (areas_shown) supersedes Changizi 2001
## (Fig.3 n_areas) for the SAME species. Same author, revised counts -> not independent, don't average.
## Superseded rows are kept in _long with status = "superseded_by_Changizi_Shimojo_2005" but excluded
## from _wide. Changizi 2001's species that C&S 2005 lacks (e.g. Homo sapiens) stay active.
newer <- long$Species[long$source == "Changizi_Shimojo_2005_Table1" &
                       long$Standardized_Term == "n_cortical_areas"]
long$status <- "active"
long$status[long$source == "Changizi__2001_Figure3" &
            long$Standardized_Term == "n_cortical_areas" &
            long$Species %in% newer] <- "superseded_by_Changizi_Shimojo_2005"

## supersede: Kaas-lab chimp (2026-08-25). Collins 2016 and Young 2013 measured the SAME Texas
## Biomedical chimpanzee (specimen crosswalk KAAS-PAN-11_38; Young = probable link). Their M1 areas
## (2497 vs 2700 mm2) differ only by dissection boundary — NOT independent, never average. Young 2013
## is the M1-dedicated methods paper, so Young keeps M1; the Collins 2016 M1 row is retained in
## _long as superseded. Collins 2016's whole-cortex/V1/V2 areas have no Young counterpart -> active.
y_m1 <- long$Species[long$source == "Young_etal_2013_Table1" &
                     long$Standardized_Term == "M1_Surface_Area.mm2"]
long$status[long$source == "Collins_etal_2016_Table1" &
            long$Standardized_Term == "M1_Surface_Area.mm2" &
            long$Species %in% y_m1] <- "superseded_by_Young_etal_2013"

## supersede: Mota lineage (2026-08-25). Mota 2019 is the same lab's later, larger release of its
## own hemisphere measurements; where it reports the same species x term as Mota 2015's own columns
## (total surface, thickness), the 2015 value is not independent -> 2019 wins, 2015 kept as
## superseded. FoldingIndex_MHH exists only in 2015 and stays active; AE exists only in 2019.
for (tt in c("CorticalSurface_Area.mm2", "CorticalThickness.mm")) {
  m19 <- long$Species[long$source == "Mota_etal_2019_SupplementaryTableS1" &
                      long$Standardized_Term == tt]
  long$status[long$source == "Mota_HerculanoHouzel_2015_TableS1" &
              long$Standardized_Term == tt &
              long$Species %in% m19] <- "superseded_by_Mota_etal_2019"
}
## FLAG: the ENTIRE Finlay 2006 source (owner decision 2026-08-25). The source-attribution audit
## (Finlay_etal_2006/Finlay_etal_2006_Table6.1_source_attribution.csv) found its traced surfaces
## systematically low for small mammals/marsupials, several rows with no citable primary, and the
## owl monkey high; the counts rest partly on unpublished maps. ALL Finlay rows are therefore held
## out of _wide (kept in _long) until verified against the Project Kaskan remeasuring dataset once
## that is built (restricted repo; registry stage already says "Species -- wait for Project
## Kaskan"). NOTE the side effect: n_visual_areas / n_somatomotor_areas lose their only source and
## drop out of _wide entirely; n_cortical_areas keeps Changizi 2001 / C&S 2005.
long$status[long$source == "Finlay_etal_2006_Table6.1"] <- "flagged_pending_ProjectKaskan_check"

## exclude: Smaers/Brodmann mandrill other-association cell (2026-08-25) — fails the additivity
## check against Brodmann 1913's own mandrill total by exactly +10,000 (misprint in one of the two
## sources; candidate repair 23422 -> 13422 is NOT applied — kept in _long, excluded from _wide).
long$status[long$source == "Smaers_etal_2017_TableS1part2" &
            long$Standardized_Term == "OtherAssociation_Surface_Area.mm2" &
            long$Species == "Mandrillus sphinx"] <- "excluded_additivity_vs_Brodmann1913"
## ---- statuses for the relative/absolute sources (2026-10-21) ----
long$status[long$source == "Seelke_etal_2016_Table2"] <- "held_group_level_pct_only"
long$status[long$source == "Felleman_VanEssen_1991_Table2"] <- "held_secondary_synthesis"
long$status[long$source == "Sarko_etal_2011_ResultsText" & long$specimen == "group:juvenile"] <- "held_juvenile_group"
long$status[long$source == "Catania_Remple_2002_Table1" & long$Species == "Rattus norvegicus" &
            long$Standardized_Term == "S1_Surface_Area.pct_Neocortex"] <- "held_secondary_comparator"

## ---- same-specimen relative -> absolute conversion (exact arithmetic only) ----
conv <- convert_relative_same_specimen(long, read_specimen_links("specimen_links.csv"))
long <- conv$long
message("relative->absolute: ", sum(long$value_basis == "derived_same_specimen"), " derived same-specimen rows; ",
        sum(long$value_basis == "derived_inverse_from_pct"), " inverse-derived denominators (held); ",
        nrow(conv$checks), " printed-vs-recomputed checks (", sum(grepl("MISMATCH", conv$checks$check)), " mismatches); ",
        nrow(conv$unconverted), " relative rows left for the external pre-analysis step")
readr::write_csv(conv$checks, "cortical_areas_conversion_checks.csv")
readr::write_csv(conv$unconverted, "cortical_areas_relative_unconverted.csv")

long <- long |>
  relocate(source_flags, source_issue_note, .after = source) |>
  relocate(specimen, grain, n, value_status, value_basis, derivation,
           denominator_term, denominator_definition, denominator_source, denominator_specimen, denominator_match,
           .after = source_issue_note) |>
  relocate(species_printed, accepted_name, species_basis, reidentified, .after = last_col())
readr::write_csv(long, "cortical_areas_long.csv")

## ---- wide: species x trait, mean across ACTIVE sources + conflict flag ----
## regional traits (e.g. M1_Surface_Area.mm2) are kept as SEPARATE columns, never pooled into
## whole-cortex surface.
## _wide: active rows only; independent sources averaged; derived same-specimen absolutes pool with
## printed ones (owner decision 2026-10-21) and the composition sidecar records the mix per cell.
cells <- long |>
  filter(status == "active") |>
  group_by(Species, Standardized_Term, trait_class) |>
  summarise(value_mean = mean(value), n_values = n(), n_sources = n_distinct(source),
            n_printed = sum(value_basis == "printed"), n_derived_same_specimen = sum(value_basis == "derived_same_specimen"),
            n_approximate = sum(value_status == "approximate"),
            n_individual_grain = sum(grain == "individual"),
            sources = paste(sort(unique(source)), collapse = "; "),
            value_min = min(value), value_max = max(value),
            cv = ifelse(n() > 1, sd(value) / mean(value), NA_real_),
            conflict_flag = ifelse(n_sources > 1 & (sd(value) / mean(value)) > 0.15, TRUE, FALSE),
            .groups = "drop")
wide <- cells |> pivot_wider(id_cols = Species, names_from = Standardized_Term, values_from = value_mean)
readr::write_csv(wide, "cortical_areas_wide.csv")
readr::write_csv(cells |> arrange(Species, trait_class, Standardized_Term), "cortical_areas_wide_composition.csv")
message("cortical areas: ", nrow(long), " long rows, ", nrow(wide), " species")

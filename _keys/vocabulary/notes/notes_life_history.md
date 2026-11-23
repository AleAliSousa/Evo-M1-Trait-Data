# Vocabulary links: life history, diet, ecology & ranging, body size & morphology, physiology & metabolism

Candidate links only (`mapping_status = candidate`), mapped on 2026-11-23. Nothing here licenses pooling. Files: [vocabulary_links_lifehistory_ecology_body.csv]({{artifact:98bfc6a1-7e8c-4aec-9c14-885ba589be9f}}) (the table), [vocabulary_links_lifehistory_ecology_body_members.csv]({{artifact:47caca9b-d733-46f6-84a3-c7f90dbd3c72}}) (which labels collapse onto each trait term), [build_vocabulary_links_lifehistory_ecology_body.py]({{artifact:5c52dc41-bb4c-452f-985a-3017714aa3f7}}) (the script), [vocabulary_links_lifehistory_ecology_body_cache.tar.gz]({{artifact:3a77410e-6cbc-4aca-bf52-1d60bf6697da}}) (`ols_cache/` and `standards_cache/`: raw OLS and standards responses). This file is written by the script; the artifact links in this paragraph were added afterwards.

## What was mapped

- Slice: 212 variable labels in the five domains of `_keys/variable_definitions.csv`.
- Input state at build time: 1516 rows, sha256 c6aee3a8d50ec46ca826f0d0eade841d4072c72b26f96fd078eef30620b6c0de. The file had 1,509 rows when the slice was first read in this session and gained 7 labels during it (all in `brain structure & size`, none in the slice; no slice row changed). `n_labels` on the domain rows is the build-time count, so `brain structure & size` shows 321, not 314.
- Project terms: 139 = 119 trait terms + 9 measure classes + 11 domains. All were processed; none was skipped.
- Terms with at least one candidate link: 108. Terms with no adequate term (`none`): 31.
- Rows: 210 (one per project term x ontology term).
- The `Measure` column has 203 distinct values for the 212 labels because it carries source and unit suffixes, and `Mass.g` is shared by adult, birth and weaning mass. Labels were therefore assigned to trait terms by explicit rules on the label (in the script); the member file lists every label, its `Measure` and the term it was assigned to.

## Method

1. Read the project definition of each label (`definition`, `_keys/glossary.csv`, the per-source definition tables and `__merging_supplementary/README__merging.md`) and the source tables' category values where the definition was only a header.
2. Searched OLS4 (`/api/search`, filtered by ontology) with several phrasings per concept; read the returned definitions and, where needed, the parents.
3. Chose on meaning. Relation vocabulary: exact, close, broad (ontology term broader than ours), narrow (ontology term narrower), related, none.
4. The script re-fetches every chosen identifier by id (`/api/ontologies/<onto>/terms?obo_id=`), aborts on a missing or obsolete id, and writes the label and ontology version OLS returns. For `none` rows it re-runs the listed searches in vt, oba, envo and pato and records the hit counts.

Ontology versions (from OLS): cmo 2026-11-14; ecocore 2026-10-08; envo 2026-10-23; fovt 2026-03-19; nbo 2023-07-04; oba 2026-10-10; pato 2026-10-01; vt 2026-11-06.

## Counts

| relation | rows |
|---|---|
| exact | 28 |
| close | 38 |
| broad | 53 |
| narrow | 7 |
| related | 53 |
| none | 31 |

| confidence | rows |
|---|---|
| high | 102 |
| medium | 77 |
| low | 31 |

| relation | high | medium | low |
|---|---|---|---|
| exact | 21 | 7 | 0 |
| close | 13 | 24 | 1 |
| broad | 32 | 19 | 2 |
| narrow | 2 | 5 | 0 |
| related | 5 | 20 | 28 |
| none | 29 | 2 | 0 |

For `none` rows the confidence is confidence that no adequate term exists in the four assigned vocabularies.

| ontology | rows |
|---|---|
| vt | 65 |
| oba | 54 |
| vt|oba|envo|pato | 31 |
| ecocore | 24 |
| envo | 17 |
| pato | 13 |
| cmo | 2 |
| fovt | 2 |
| nbo | 2 |

Terms with no adequate term: Development_mode, Breeding_season_duration, Dispersal_age, Expected_overlap, Interbirth_interval, Litters_per_year, Seasonality_r, peak_workspace, Diet_category, Diet_bark, Diet_breadth, Diet_dominant, Diet_flowers, Diet_other, Feeding_opportunities_provided, Feeding_opportunities_taken, Feeding_opportunities_taken_as_percent_provided, Midrange_latitude, Foraging_unit_size, Foraging_stratum, Habitat_breadth, IUCN_status_historical, Open_habitat, Predation_risk, Territoriality_index, Biomass_per_home_range_area, Day_range, Home_range, Max_home_range, range (measure_class), dataset metadata (domain).

## Supplementary vocabularies (outside the assigned set)

The task named vt, oba, envo and pato. They have almost nothing for diet composition, life history as a category, or locomotor substrate, so rows from four other OBO vocabularies on OLS were added where they hold the concept: ECOCORE (consumer roles and trophic processes, life history, territory), NBO (arboreal / terrestrial locomotion), FOVT (body length without tail, snout-vent length) and CMO (basal metabolic rate). Each such row starts its `reason` with 'Supplementary vocabulary'. 27 project terms carry at least one supplementary row; 21 have ONLY supplementary rows and would be `none` if the owner restricts the mapping to the assigned four: Diet_animal_matter, Diet_ectothermic_vertebrates, Diet_endothermic_vertebrates, Diet_fish, Diet_fruit, Diet_fruit_and_flowers, Diet_fruit_and_seeds, Diet_gums, Diet_invertebrates, Diet_leaves, Diet_nectar, Diet_other_plant_material, Diet_scavenging, Diet_seeds, Diet_vertebrates_unknown, Folivory, Territory_area, Trophic_guild, Trophic_level, life history, life_history.

## Trait-data standards checked

Cited in `reason` only where fetched in this session (raw files in `standards_cache/`):

- IUCN Red List API v4 classification lists: habitats (https://api.iucnredlist.org/api/v4/habitats/), Red List categories (https://api.iucnredlist.org/api/v4/red_list_categories/), population trends (https://api.iucnredlist.org/api/v4/population_trends/), biogeographical realms (https://api.iucnredlist.org/api/v4/biogeographical_realms/). The seven Galan-Acedo habitat columns coincide by name with IUCN habitat categories 1-6 and 8; IUCN status and population-trend values match the IUCN lists; the 'Realm' values do not match the IUCN realm list. These endpoints need the IUCN API token.
- Darwin Core term list (https://raw.githubusercontent.com/tdwg/dwc/master/vocabulary/term_versions.csv): dwc:habitat and dwc:decimalLatitude exist with status 'recommended'; neither is an exact match to a project term (see Habitat_type and Midrange_latitude).
- The Ecological Trait-data Standard term list was also fetched (https://raw.githubusercontent.com/EcologicalTraitData/ETS/master/ETS.csv); it defines dataset columns (traitName, traitValue, ...), not trait concepts, so no project term is matched to it.
- PanTHERIA, the Amniote database, AnAge and EltonTraits are datasets the project already cites by column name; their field lists were not fetched here and are not cited as standards.

## Ten least certain choices

1. **real_size, relative_size -> OBA manus size (related, low)**: the project definitions ('absolute size metric', 'relative hand/thumb size metric', Baker et al. derived) do not say how the metrics are built; the link could equally be `none`.
2. **PI_forefoot_* / PI_hindfoot_* -> OBA phalanx of manus / pes length (related, low)**: the phalangeal-index formula is not in the project definition; the link is to a component measurement only.
3. **Age_at_first_breeding -> VT onset of fertility (close, low)**: 'breeding' is undefined in Lewitus et al. 2014 Table S1 (first mating, conception or birth); if it means first birth the relation should be `related`, as for Age_at_first_birth.
4. **Juvenility -> PATO juvenile (related, low)**: a stage quality offered for a duration; start and end of the juvenile period are not defined in the project.
5. **Trophic_guild, Trophic_level -> ECOCORE heterotroph (related, low)**: variable-level link to the parent of the value classes; the real mapping is value by value (Frugivore -> frugivore, ...), and ECOCORE is outside the assigned vocabularies.
6. **Habitat_Rocky_areas -> ENVO inland cliff (related, low)**: covers only part of IUCN category 6 (mountain peaks, other rocky areas are not included).
7. **Teat_number -> VT / OBA nipple quantity (close, medium)**: project definition is unresolved (no source definition in variable_definitions.csv), so the counting convention is unknown.
8. **Population_density -> PATO population quality (broad, low)**: very generic class; the project term also mixes individuals/km2 with groups/km2.
9. **Potential_evapotranspiration -> ENVO volume of evapotranspiration (related, low)**: PET is a modelled potential, not an evapotranspiration volume; `none` is defensible.
10. **Weaning_age -> VT / OBA lactation duration (close, high)**: rests on the project's own decision to pool weaning age with lactation length; a reviewer who separates offspring weaning age from maternal lactation would call this `related`.

## What a reviewer should look at first

1. The label -> trait-term collapse in the members file (119 terms from 212 labels). It goes beyond stripping source suffixes in a few places and the owner should confirm them: Weaning_period_days under Weaning_age; Inter-litter_interval_days under Interbirth_interval; Weight_at_birth_g / Weight_at_weaning_g under Neonate_body_mass / Weaning_weight; Population_density (individuals/km2) with Population_density_Chivers1984 (groups/km2); three diet-breadth schemes under Diet_breadth; Terrestrial_Nunn2018 (binary) with Terrestriality_PanTHERIA (code); the two Trophic_level codings; percent-of-diet with percent-of-feeding-time labels under the Diet_* terms.
2. Every `exact` row. The 18 hand-bone rows are exact on entity and quality but the values are log10 mm; Sexual_maturity_age, Age_at_eye_opening, Hindlimb_length and Body_temperature (OBA) are exact on wording only, with source criteria unverified.
3. Whether to keep the supplementary vocabularies (ECOCORE for diet, life history and territory; NBO for locomotion; FOVT for head-body length; CMO for basal metabolic rate). They are outside the assigned vt/oba/envo/pato set and are flagged in `reason`; without them most diet terms and the life-history class and domain become `none`.
4. `related` rows where the ontology class is an entity or role and ours is a flag or share of it (7 habitat flags -> ENVO; diet shares -> ECOCORE roles/processes). Decide whether the database wants such links or a value-level mapping instead.
5. Project terms whose own definition is unresolved or is only a column header (Teat_number, Field_metabolic_rate, the PanTHERIA-suffixed labels, the Carnes et al. 2011 and Lewitus et al. 2014 columns). The mapping cannot be firmer than the definition; fixing the definition first is cheaper than reviewing the link.
6. The categorical variables (Trophic_guild, Diet_dominant, Locomotion, Foraging_stratum, Habitat_type, IUCN status, Population trend, Biogeographic realm): the variable-level row is weak by nature; a value-level crosswalk (e.g. to ECOCORE roles, PATO arboreal/fossorial, the IUCN lists) is the useful next step and was not attempted here.

## Leads outside this slice's vocabularies (not in the table, not re-fetched by id)

OLS searches across all ontologies returned classes that may cover some `none` or `broad` terms: EFO has 'birth weight' and 'age at first birth measurement'; CMO has 'maternal age at birth of first offspring' and 'body length, crown to rump'; MeSH has 'Population Density', 'Territoriality', 'Homing Behavior' and 'Life History Traits'; MP has estrus-length phenotype classes. The all-ontology searches run here (first 12 hits each) returned no class for interbirth interval, home range as an area, day range, diet breadth, habitat breadth, foraging stratum, field metabolic rate or altricial/precocial.

## Not done

- No project term in the slice was left unprocessed.
- Category VALUES of the categorical variables were not mapped (only the variables).
- Source papers were not opened; project definitions, source definition tables, README files and source-table value sets were the evidence. Where those are thin the row says so.
- Generic PATO qualities (duration, mass, length, count, rate, ratio) were not attached to every trait; PATO rows appear only where PATO has a specific matching quality.
- OBA has no counterpart for several VT terms used here (time of eyelid opening, onset of fertility, single birth offspring quantity, total life span, postnatal growth trait): OLS returned nothing for the mirrored ids, so those terms have a VT row only.

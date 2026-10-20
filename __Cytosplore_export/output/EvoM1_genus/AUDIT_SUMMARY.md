# EvoM1 variable audit -- sources and poolability (genus-level match)

Built 2026-10-20 by `__Cytosplore_export/audit_cytosplore_variables.py` from the tables in this folder and the repo keys.

## Q1. Secondary compilations vs primary sources

- 654 exported variables; 5793 species x variable cells.
- cells with at least one primary source: 3867
- cells fed only by compilations (secondary): 1376 in 188 variables
- of those, cells where a PRIMARY value for the same species and structure x measure exists in the compiled database (another variable of the same compatibility group): 70
- cells whose role could not be resolved: 550
- variables with NO primary source at all: 144
- variables whose sources have a declared supersedes/reprints/derives_from relationship: 111

Compilations contributing secondary-only cells (cells):

- Wilman_etal_2014: 360
- Jones_etal_2009: 255
- Karbowski__2007: 134
- deMagalhães_etal_2024: 121
- Kaufman__2004: 114
- Myhrvold_etal_2015: 83
- Heffner_Masterton_1975: 65
- Navarrete_etal_2016: 44
- Boyer_Harrington_2019: 42
- Iwaniuk_etal_2001: 36
- Lewitus (team): 31
- Genoud_etal_2018: 30
- Heiss_etal_2004: 26
- Elston_etal_2006: 25
- McDowell_etal_2024: 25

Variables with secondary-only cells for which a primary exists in the same group:

- `Depth` (13 sp): 12 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Length` (13 sp): 12 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Binocular_field_compiled_Heesy2004 (deg)` (12 sp): 11 secondary-only cells; primary for 5 of them via family: visual_field
- `Largest fiber diameter µm` (9 sp): 9 secondary-only cells; primary for 9 of them via CorticospinalTract | motor_pathway
- `Visual_acuity_anatomical_compiled (c/deg)` (9 sp): 9 secondary-only cells; primary for 3 of them via family: visual_acuity
- `Endocranial_volume_female (mL)` (9 sp): 7 secondary-only cells; primary for 7 of them via family: brain_size
- `V1_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (7 sp): 6 secondary-only cells; primary for 4 of them via family: basal_dendritic_field_area
- `V1_pyramidal_L3_spine_count [LYinj] (count)` (7 sp): 6 secondary-only cells; primary for 3 of them via family: spine_count
- `Number of fibers per tract` (11 sp): 5 secondary-only cells; primary for 5 of them via CorticospinalTract | motor_pathway
- `V2_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (5 sp): 5 secondary-only cells; primary for 3 of them via family: basal_dendritic_field_area
- `V2_pyramidal_L3_spine_count [LYinj] (count)` (5 sp): 5 secondary-only cells; primary for 2 of them via family: spine_count
- `Brain_Mass_mass_or_volume (g)` (25 sp): 2 secondary-only cells; primary for 2 of them via family: brain_size
- `Brain_size_sum_of_structures (g)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `Endocranial_volume (mL)` (13 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `parietal_7a_pyramidal_L3_spine_count [LYinj] (count)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count
- `PFC_area10_pyramidal_L3_dendritic_segment_count [golgi] (count)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: dendritic_segment_count
- `PFC_area10_pyramidal_L3_mean_segment_length [golgi] (um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: mean_segment_length
- `PFC_area10_pyramidal_L3_soma_area [golgi] (um2)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: soma_area
- `PFC_area10_pyramidal_L3_soma_depth [golgi] (um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: soma_depth
- `PFC_area10_pyramidal_L3_spine_count [golgi] (count)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count
- `PFC_area10_pyramidal_L3_spine_density [golgi] (spines/um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: spine_density
- `PFC_area10_pyramidal_L3_total_dendritic_length [golgi] (um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: total_dendritic_length
- `S1_3b_pyramidal_L3_dendritic_segment_count [golgi] (count)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: dendritic_segment_count
- `S1_3b_pyramidal_L3_mean_segment_length [golgi] (um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: mean_segment_length
- `S1_3b_pyramidal_L3_soma_area [golgi] (um2)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: soma_area

Source class of exported variables:

- primary-backed: 450
- compilation-only: 139
- mixed (some species compilation-only): 44
- role unknown (source lacks role in definitions): 16
- compilation of earlier literature; primaries not in database: 5

Suggested tier (cohort species covered):

- broad (10-19 sp): 207
- core (>=20 sp): 52
- minimal (<3 sp): 123
- sparse (3-9 sp): 272

## Q2. Poolability and individual relevance

- compatibility groups with >= 2 exported variables: 76
- groups where pooling would add >= 2 cohort species: 3
- groups spanning more than one measurement basis (do not pool across): 7
- variables with < 3 cohort species: 123
- laterality (left/right) variants: 21

Top pooling candidates (gain in cohort species):

- family: spine_count: 14 vars, best single 7 -> union 12 (+5); bases: spine_count__golgi: 6; spine_count__LYinj: 8 -- do not pool across bases; pool within a basis only
- family: soma_area: 8 vars, best single 6 -> union 9 (+3); bases: soma_area__golgi: 6; soma_area__stereology: 2 -- do not pool across bases; pool within a basis only
- family: cff: 2 vars, best single 8 -> union 10 (+2); bases: cff_behavioural: 1; cff_electrophysiological: 1 -- do not pool across bases; pool within a basis only
- WholeBrain | cerebral_absolute_rate: 2 vars, best single 8 -> union 9 (+1); bases: (none): 2 -- little to gain
- SpinalCord | motor_pathway: 5 vars, best single 14 -> union 15 (+1); bases: (none): 5 -- little to gain
- family: basal_dendritic_field_area: 9 vars, best single 7 -> union 8 (+1); bases: basal_dendritic_field_area__LYinj: 9 -- little to gain
- family: visual_field: 3 vars, best single 12 -> union 13 (+1); bases: binocular_field_optical: 2; field_of_best_vision_anatomical: 1 -- do not pool across bases; pool within a basis only

## Key gaps found upstream

Paper folders contributing to the export whose *_definitions.csv has no primary/secondary role
(so their cells count as role-unknown). Fill `role` in the folder's definitions file and rebuild
_keys/variable_catalog.csv:

- Myhrvold_etal_2015: 1573 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Jones_etal_2009: 1406 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- deMagalhães_etal_2024: 714 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Baker_etal_2025: 426 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Isler_etal_2008: 134 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Burish_etal_2010: 112 cells; catalog roles = {'review': 10}
- Powell_etal_2017: 89 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Boyer_Harrington_2019: 70 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Mota_etal_2019: 48 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Iwaniuk_etal_1999: 36 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- McDowell_etal_2024: 25 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Winkler_Bryant_2021: 22 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- MacLarnon__1996: 13 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- HerculanoHouzel_etal_2016: 5 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Stimpson_etal_2015: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Heffner_Heffner_1985: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Fox_Wilczynski_1986: 1 cells; catalog roles = {'info': 1, 'measure': 14}
- Heffner_etal_1994_c: 1 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)

Exported variables with no group (structure-agnostic label, no poolable_family in variable_domain.csv): 130. These cannot be assessed for cross-variable pooling until a family is assigned.

## Source identifiers not resolved to a repo folder

(merge team names such as 'Lewitus (team)' are fine -- their roles come from the merge's own roles column)

- Kochiyama_2018 x Heiss_2004 (s4): 16
- Herculano-Houzel 2015 (daily sleep): 13
- DERIVED from the merged limits: 4
- FISHER el al., 1969: 2

## How to read the columns

- `papers`: contributing folders with the paper's catalog role class in brackets (prim / seco / mixe / unkn).
- `cells_secondary_only`: cohort species whose value comes only from compilations.
- `species_secondary_only_with_primary_in_group`: those species for which a primary value exists in another
  exported variable of the same structure x measure group -- the viewer could show that instead.
- `primary_papers_in_group_not_used`: primary-role papers the catalog lists for this structure x measure that
  do not contribute to this variable -- places to look for a better version.
- `pool_candidates_same_basis` / `pool_species_gain`: exported variables that measure the same thing on the
  same basis, and the extra cohort species pooling them would give. `same_family_different_basis` lists
  variables that must NOT be pooled (different poolable_group).
- Pooling is a proposal only: nothing here is pooled. A decision belongs in _keys/variable_canonical.csv or
  the relevant merge, with its reason recorded.

# EC variable audit -- sources and poolability (genus-level match)

Built 2026-10-20 by `__Cytosplore_export/audit_cytosplore_variables.py` from the tables in this folder and the repo keys.

## Q1. Secondary compilations vs primary sources

- 651 exported variables; 3346 species x variable cells.
- cells with at least one primary source: 2405
- cells fed only by compilations (secondary): 843 in 185 variables
- of those, cells where a PRIMARY value for the same species and structure x measure exists in the compiled database (another variable of the same compatibility group): 48
- cells whose role could not be resolved: 98
- variables with NO primary source at all: 146
- variables whose sources have a declared supersedes/reprints/derives_from relationship: 111

Compilations contributing secondary-only cells (cells):

- Wilman_etal_2014: 210
- Jones_etal_2009: 158
- Kaufman__2004: 100
- Karbowski__2007: 79
- deMagalhães_etal_2024: 65
- Myhrvold_etal_2015: 43
- Heffner_Masterton_1975: 31
- Boyer_Harrington_2019: 27
- Heiss_etal_2004: 26
- Lewitus (team): 21
- Bianchi_etal_2012: 21
- Navarrete_etal_2016: 20
- Genoud_etal_2018: 19
- Iwaniuk_etal_2001: 18
- deSousa_etal_2022: 14

Variables with secondary-only cells for which a primary exists in the same group:

- `Binocular_field_compiled_Heesy2004 (deg)` (7 sp): 7 secondary-only cells; primary for 3 of them via family: visual_field
- `Depth` (6 sp): 6 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Largest fiber diameter µm` (6 sp): 6 secondary-only cells; primary for 6 of them via CorticospinalTract | motor_pathway
- `Length` (6 sp): 6 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Visual_acuity_anatomical_compiled (c/deg)` (6 sp): 6 secondary-only cells; primary for 1 of them via family: visual_acuity
- `Number of fibers per tract` (7 sp): 5 secondary-only cells; primary for 5 of them via CorticospinalTract | motor_pathway
- `V1_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (3 sp): 3 secondary-only cells; primary for 2 of them via family: basal_dendritic_field_area
- `V1_pyramidal_L3_spine_count [LYinj] (count)` (3 sp): 3 secondary-only cells; primary for 1 of them via family: spine_count
- `Endocranial_volume_female (mL)` (3 sp): 2 secondary-only cells; primary for 2 of them via family: brain_size
- `V2_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (2 sp): 2 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `Brain_size_sum_of_structures (g)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `Endocranial_volume (mL)` (6 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `parietal_7a_pyramidal_L3_spine_count [LYinj] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count
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
- `S1_3b_pyramidal_L3_soma_depth [golgi] (um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: soma_depth
- `S1_3b_pyramidal_L3_spine_count [golgi] (count)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count

Source class of exported variables:

- primary-backed: 449
- compilation-only: 141
- mixed (some species compilation-only): 39
- role unknown (source lacks role in definitions): 17
- compilation of earlier literature; primaries not in database: 5

Suggested tier (cohort species covered):

- broad (10-19 sp): 109
- minimal (<3 sp): 209
- sparse (3-9 sp): 333

## Q2. Poolability and individual relevance

- compatibility groups with >= 2 exported variables: 75
- groups where pooling would add >= 2 cohort species: 1
- groups spanning more than one measurement basis (do not pool across): 7
- variables with < 3 cohort species: 209
- laterality (left/right) variants: 21

Top pooling candidates (gain in cohort species):

- family: spine_count: 13 vars, best single 3 -> union 6 (+3); bases: spine_count__golgi: 6; spine_count__LYinj: 7 -- do not pool across bases; pool within a basis only
- family: soma_area: 8 vars, best single 3 -> union 4 (+1); bases: soma_area__golgi: 6; soma_area__stereology: 2 -- do not pool across bases; pool within a basis only
- family: basal_dendritic_field_area: 9 vars, best single 3 -> union 4 (+1); bases: basal_dendritic_field_area__LYinj: 9 -- little to gain
- family: visual_field: 3 vars, best single 7 -> union 8 (+1); bases: binocular_field_optical: 2; field_of_best_vision_anatomical: 1 -- do not pool across bases; pool within a basis only
- family: cff: 2 vars, best single 5 -> union 6 (+1); bases: cff_behavioural: 1; cff_electrophysiological: 1 -- do not pool across bases; pool within a basis only

## Key gaps found upstream

Paper folders contributing to the export whose *_definitions.csv has no primary/secondary role
(so their cells count as role-unknown). Fill `role` in the folder's definitions file and rebuild
_keys/variable_catalog.csv:

- Myhrvold_etal_2015: 1181 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Jones_etal_2009: 1059 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- deMagalhães_etal_2024: 485 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Baker_etal_2025: 281 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Burish_etal_2010: 87 cells; catalog roles = {'review': 10}
- Isler_etal_2008: 80 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Powell_etal_2017: 58 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Boyer_Harrington_2019: 45 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Mota_etal_2019: 30 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Iwaniuk_etal_1999: 18 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- McDowell_etal_2024: 13 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Winkler_Bryant_2021: 13 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- MacLarnon__1996: 7 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Stimpson_etal_2015: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- HerculanoHouzel_etal_2016: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Heffner_Heffner_1985: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Fox_Wilczynski_1986: 1 cells; catalog roles = {'info': 1, 'measure': 14}
- Heffner_etal_1994_c: 1 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)

Exported variables with no group (structure-agnostic label, no poolable_family in variable_domain.csv): 130. These cannot be assessed for cross-variable pooling until a family is assigned.

## Source identifiers not resolved to a repo folder

(merge team names such as 'Lewitus (team)' are fine -- their roles come from the merge's own roles column)

- Kochiyama_2018 x Heiss_2004 (s4): 16
- Herculano-Houzel 2015 (daily sleep): 9
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

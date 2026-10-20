# V1 variable audit -- sources and poolability (species-level match)

Built 2026-10-20 by `__Cytosplore_export/audit_cytosplore_variables.py` from the tables in this folder and the repo keys.

## Q1. Secondary compilations vs primary sources

- 634 exported variables; 3113 species x variable cells.
- cells with at least one primary source: 2173
- cells fed only by compilations (secondary): 843 in 186 variables
- of those, cells where a PRIMARY value for the same species and structure x measure exists in the compiled database (another variable of the same compatibility group): 46
- cells whose role could not be resolved: 97
- variables with NO primary source at all: 145
- variables whose sources have a declared supersedes/reprints/derives_from relationship: 111

Compilations contributing secondary-only cells (cells):

- Wilman_etal_2014: 225
- Jones_etal_2009: 134
- Kaufman__2004: 108
- Karbowski__2007: 101
- deMagalhães_etal_2024: 58
- Heffner_Masterton_1975: 42
- Myhrvold_etal_2015: 41
- Heiss_etal_2004: 26
- Bianchi_etal_2012: 21
- Lewitus (team): 20
- Genoud_etal_2018: 20
- Navarrete_etal_2016: 20
- Boyer_Harrington_2019: 18
- Iwaniuk_etal_2001: 15
- Kverkova_etal_2018: 13

Variables with secondary-only cells for which a primary exists in the same group:

- `Depth` (8 sp): 8 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Length` (8 sp): 8 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Largest fiber diameter µm` (7 sp): 7 secondary-only cells; primary for 7 of them via CorticospinalTract | motor_pathway
- `Binocular_field_compiled_Heesy2004 (deg)` (6 sp): 6 secondary-only cells; primary for 3 of them via family: visual_field
- `Number of fibers per tract` (7 sp): 4 secondary-only cells; primary for 4 of them via CorticospinalTract | motor_pathway
- `Brain_Mass_mass_or_volume (g)` (12 sp): 2 secondary-only cells; primary for 2 of them via family: brain_size
- `Endocranial_volume (mL)` (7 sp): 2 secondary-only cells; primary for 2 of them via family: brain_size
- `V1_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (2 sp): 2 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `V2_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (2 sp): 2 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `Brain_Mass_measured (g)` (17 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `Brain_size_sum_of_structures (g)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `Endocranial_volume_female (mL)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
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
- `S1_3b_pyramidal_L3_spine_density [golgi] (spines/um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: spine_density

Source class of exported variables:

- primary-backed: 431
- compilation-only: 140
- mixed (some species compilation-only): 41
- role unknown (source lacks role in definitions): 17
- compilation of earlier literature; primaries not in database: 5

Suggested tier (cohort species covered):

- broad (10-19 sp): 89
- minimal (<3 sp): 229
- sparse (3-9 sp): 316

## Q2. Poolability and individual relevance

- compatibility groups with >= 2 exported variables: 73
- groups where pooling would add >= 2 cohort species: 1
- groups spanning more than one measurement basis (do not pool across): 6
- variables with < 3 cohort species: 229
- laterality (left/right) variants: 21

Top pooling candidates (gain in cohort species):

- family: spine_count: 9 vars, best single 3 -> union 5 (+2); bases: spine_count__golgi: 6; spine_count__LYinj: 3 -- do not pool across bases; pool within a basis only
- family: basal_dendritic_field_area: 6 vars, best single 2 -> union 3 (+1); bases: basal_dendritic_field_area__LYinj: 6 -- little to gain
- family: cff: 2 vars, best single 4 -> union 5 (+1); bases: cff_behavioural: 1; cff_electrophysiological: 1 -- do not pool across bases; pool within a basis only
- family: visual_acuity: 4 vars, best single 11 -> union 12 (+1); bases: acuity_anatomical: 2; acuity_behavioural: 1; acuity_method_unstated: 1 -- do not pool across bases; pool within a basis only

## Key gaps found upstream

Paper folders contributing to the export whose *_definitions.csv has no primary/secondary role
(so their cells count as role-unknown). Fill `role` in the folder's definitions file and rebuild
_keys/variable_catalog.csv:

- Jones_etal_2009: 195 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Myhrvold_etal_2015: 151 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- deMagalhães_etal_2024: 150 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Baker_etal_2025: 88 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Burish_etal_2010: 49 cells; catalog roles = {'review': 10}
- Isler_etal_2008: 33 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Boyer_Harrington_2019: 30 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Mota_etal_2019: 27 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Iwaniuk_etal_1999: 24 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- McDowell_etal_2024: 12 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Powell_etal_2017: 11 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Winkler_Bryant_2021: 7 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- MacLarnon__1996: 5 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- HerculanoHouzel_etal_2016: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Fox_Wilczynski_1986: 1 cells; catalog roles = {'info': 1, 'measure': 14}
- Stimpson_etal_2015: 1 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Heffner_etal_1994_c: 1 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)

Exported variables with no group (structure-agnostic label, no poolable_family in variable_domain.csv): 131. These cannot be assessed for cross-variable pooling until a family is assigned.

## Source identifiers not resolved to a repo folder

(merge team names such as 'Lewitus (team)' are fine -- their roles come from the merge's own roles column)

- Kochiyama_2018 x Heiss_2004 (s4): 8
- Herculano-Houzel 2015 (daily sleep): 4
- DERIVED from the merged limits: 3
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

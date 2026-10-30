# HMBA variable audit -- sources and poolability (species-level match)

Built 2026-10-22 by `__Cytosplore_export/audit_cytosplore_variables.py` from the tables in this folder and the repo keys.

## Q1. Secondary compilations vs primary sources

- 671 exported variables; 1448 species x variable cells.
- cells with at least one primary source: 891
- cells fed only by compilations (secondary): 520 in 253 variables
- of those, cells where a PRIMARY value for the same species and structure x measure exists in the compiled database (another variable of the same compatibility group): 27
- cells whose role could not be resolved: 37
- variables with NO primary source at all: 247
- variables whose sources have a declared supersedes/reprints/derives_from relationship: 150

Compilations contributing secondary-only cells (cells):

- Kaufman__2004: 68
- Wilman_etal_2014: 60
- Kamilar_Cooper_2013: 59
- Karbowski__2007: 56
- Nunn_Samson_2018: 45
- GalánAcedo_etal_2019: 38
- Jones_etal_2009: 32
- Dunn_Smaers_2018: 29
- Heiss_etal_2004: 26
- Bianchi_etal_2012: 21
- Pasquaretta_etal_2014: 18
- deMagalhães_etal_2024: 13
- Boyer_Harrington_2019: 9
- Iwaniuk_etal_2001: 9
- Heffner_Masterton_1975: 9

Variables with secondary-only cells for which a primary exists in the same group:

- `Binocular_field_compiled_Heesy2004 (deg)` (3 sp): 3 secondary-only cells; primary for 1 of them via family: visual_field
- `Endocranial_volume (mL)` (3 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `Largest fiber diameter µm` (1 sp): 1 secondary-only cells; primary for 1 of them via CorticospinalTract | motor_pathway
- `Number of fibers per tract` (3 sp): 1 secondary-only cells; primary for 1 of them via CorticospinalTract | motor_pathway
- `PFC_area10_pyramidal_L3_dendritic_segment_count [golgi] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: dendritic_segment_count
- `PFC_area10_pyramidal_L3_mean_segment_length [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: mean_segment_length
- `PFC_area10_pyramidal_L3_soma_area [golgi] (um2)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: soma_area
- `PFC_area10_pyramidal_L3_soma_depth [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: soma_depth
- `PFC_area10_pyramidal_L3_spine_count [golgi] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count
- `PFC_area10_pyramidal_L3_spine_density [golgi] (spines/um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: spine_density
- `PFC_area10_pyramidal_L3_total_dendritic_length [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: total_dendritic_length
- `S1_3b_pyramidal_L3_dendritic_segment_count [golgi] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: dendritic_segment_count
- `S1_3b_pyramidal_L3_mean_segment_length [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: mean_segment_length
- `S1_3b_pyramidal_L3_soma_area [golgi] (um2)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: soma_area
- `S1_3b_pyramidal_L3_soma_depth [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: soma_depth
- `S1_3b_pyramidal_L3_spine_count [golgi] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count
- `S1_3b_pyramidal_L3_spine_density [golgi] (spines/um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: spine_density
- `S1_3b_pyramidal_L3_total_dendritic_length [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: total_dendritic_length
- `V1_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `V2_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `V2_pyramidal_L3_dendritic_segment_count [golgi] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: dendritic_segment_count
- `V2_pyramidal_L3_mean_segment_length [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: mean_segment_length
- `V2_pyramidal_L3_soma_area [golgi] (um2)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: soma_area
- `V2_pyramidal_L3_soma_depth [golgi] (um)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: soma_depth
- `V2_pyramidal_L3_spine_count [golgi] (count)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: spine_count

Source class of exported variables:

- primary-backed: 400
- compilation-only: 241
- role unknown (source lacks role in definitions): 18
- mixed (some species compilation-only): 6
- compilation of earlier literature; primaries not in database: 6

Suggested tier (cohort species covered):

- minimal (<3 sp): 407
- sparse (3-9 sp): 264

## Q2. Poolability and individual relevance

- compatibility groups with >= 2 exported variables: 73
- groups where pooling would add >= 2 cohort species: 0
- groups spanning more than one measurement basis (do not pool across): 6
- variables with < 3 cohort species: 407
- laterality (left/right) variants: 22

Top pooling candidates (gain in cohort species):

- family: spine_count: 8 vars, best single 1 -> union 2 (+1); bases: spine_count__golgi: 6; spine_count__LYinj: 2 -- do not pool across bases; pool within a basis only

## Key gaps found upstream

Paper folders contributing to the export whose *_definitions.csv has no primary/secondary role
(so their cells count as role-unknown). Fill `role` in the folder's definitions file and rebuild
_keys/variable_catalog.csv:

- Jones_etal_2009: 59 cells; catalog roles = {'data': 45, 'info': 20}
- Kamilar_Cooper_2013: 59 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Baker_etal_2025: 52 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Nunn_Samson_2018: 45 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- GalánAcedo_etal_2019: 38 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Dunn_Smaers_2018: 29 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Burish_etal_2010: 25 cells; catalog roles = {'review': 10}
- Pasquaretta_etal_2014: 18 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Isler_etal_2008: 15 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Boyer_Harrington_2019: 15 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Mota_etal_2019: 9 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Iwaniuk_etal_1999: 6 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- McDowell_etal_2024: 4 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Bowmaker_etal_1991: 4 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- MacLarnon__1996: 3 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Powell_etal_2017: 3 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Winkler_Bryant_2021: 3 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Sacher_Staffeldt_1974: 3 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Grueter_etal_2013: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Campbell_Tobler_1984: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- McComb_Semple_2005: 2 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- VanEssen_Drury_1997: 2 cells; catalog roles = {'primary or secondary': 1, 'derived-in-source': 1}

Exported variables with no group (structure-agnostic label, no poolable_family in variable_domain.csv): 232. These cannot be assessed for cross-variable pooling until a family is assigned.

## Source identifiers not resolved to a repo folder

(merge team names such as 'Lewitus (team)' are fine -- their roles come from the merge's own roles column)

- Kochiyama_2018 x Heiss_2004 (s4): 8
- Herculano-Houzel 2015 (daily sleep): 3
- DERIVED from the merged limits: 1

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

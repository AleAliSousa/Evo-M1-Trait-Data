# EvoM1 variable audit -- sources and poolability

Built 2026-10-14 by `__Cytosplore_export/audit_cytosplore_variables.py` from the tables in this folder and the repo keys.

## Q1. Secondary compilations vs primary sources

- 581 exported variables; 3639 species x variable cells.
- cells with at least one primary source: 2760
- cells fed only by compilations (secondary): 763 in 144 variables
- of those, cells where a PRIMARY value for the same species and structure x measure exists in the compiled database (another variable of the same compatibility group): 52
- cells whose role could not be resolved: 116
- variables with NO primary source at all: 111
- variables whose sources have a declared supersedes/reprints/derives_from relationship: 111

Compilations contributing secondary-only cells (cells):

- Wilman_etal_2014: 330
- Karbowski__2007: 132
- Kaufman__2004: 108
- Heffner_Masterton_1975: 64
- Heiss_etal_2004: 26
- Genoud_etal_2018: 26
- Lewitus (team): 23
- Bianchi_etal_2012: 21
- Kverkova_etal_2018: 13
- Veilleux_Kirk_2014: 11
- Elston_etal_2006: 10
- Koay_etal_1998: 10
- Isler_etal_2008: 9
- Haarlem_etal_2026: 9
- Powell_etal_2017: 6

Variables with secondary-only cells for which a primary exists in the same group:

- `Depth` (12 sp): 12 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Length` (12 sp): 12 secondary-only cells; primary for 1 of them via SpinalCord | motor_pathway
- `Largest fiber diameter µm` (8 sp): 8 secondary-only cells; primary for 8 of them via CorticospinalTract | motor_pathway
- `Endocranial_volume_female (mL)` (7 sp): 6 secondary-only cells; primary for 6 of them via family: brain_size
- `Brain_Mass_mass_or_volume (g)` (20 sp): 5 secondary-only cells; primary for 5 of them via family: brain_size
- `Number of fibers per tract` (9 sp): 4 secondary-only cells; primary for 4 of them via CorticospinalTract | motor_pathway
- `Endocranial_volume (mL)` (11 sp): 2 secondary-only cells; primary for 2 of them via family: brain_size
- `V1_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (2 sp): 2 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `V2_pyramidal_L3_basal_dendritic_field_area [LYinj] (um2)` (2 sp): 2 secondary-only cells; primary for 1 of them via family: basal_dendritic_field_area
- `Brain_Mass_measured (g)` (22 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
- `Brain_size_sum_of_structures (g)` (1 sp): 1 secondary-only cells; primary for 1 of them via family: brain_size
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
- `S1_3b_pyramidal_L3_total_dendritic_length [golgi] (um)` (2 sp): 1 secondary-only cells; primary for 1 of them via family: total_dendritic_length

Source class of exported variables:

- primary-backed: 420
- compilation-only: 105
- mixed (some species compilation-only): 33
- role unknown (source lacks role in definitions): 17
- compilation of earlier literature; primaries not in database: 6

Suggested tier (cohort species covered):

- broad (10-19 sp): 108
- core (>=20 sp): 20
- minimal (<3 sp): 147
- sparse (3-9 sp): 306

## Q2. Poolability and individual relevance

- compatibility groups with >= 2 exported variables: 73
- groups where pooling would add >= 2 cohort species: 3
- groups spanning more than one measurement basis (do not pool across): 7
- variables with < 3 cohort species: 147
- laterality (left/right) variants: 21

Top pooling candidates (gain in cohort species):

- family: brain_size: 8 vars, best single 22 -> union 25 (+3); bases: mass_measured_excl_ob: 1; mass_or_volume_mixed: 1; mass_measured: 1; sum_of_parts_incl_ob: 2; endocranial_volume: 1; endocranial_volume_female: 1; volume_net: 1 -- do not pool across bases; pool within a basis only
- family: spine_count: 9 vars, best single 4 -> union 6 (+2); bases: spine_count__golgi: 6; spine_count__LYinj: 3 -- do not pool across bases; pool within a basis only
- family: cff: 2 vars, best single 5 -> union 7 (+2); bases: cff_behavioural: 1; cff_electrophysiological: 1 -- do not pool across bases; pool within a basis only
- SpinalCord | motor_pathway: 5 vars, best single 13 -> union 14 (+1); bases: (none): 5 -- little to gain
- family: soma_area: 8 vars, best single 4 -> union 5 (+1); bases: soma_area__golgi: 6; soma_area__stereology: 2 -- do not pool across bases; pool within a basis only
- family: basal_dendritic_field_area: 6 vars, best single 2 -> union 3 (+1); bases: basal_dendritic_field_area__LYinj: 6 -- little to gain

## Key gaps found upstream

Paper folders contributing to the export whose *_definitions.csv has no primary/secondary role
(so their cells count as role-unknown). Fill `role` in the folder's definitions file and rebuild
_keys/variable_catalog.csv:

- Baker_etal_2025: 151 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Burish_etal_2010: 49 cells; catalog roles = {'review': 10}
- Isler_etal_2008: 44 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Zilles_etal_1986: 40 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Iwaniuk_etal_1999: 36 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Mota_etal_2019: 27 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Powell_etal_2017: 20 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Lassek_Rasmussen_1940: 9 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- MacLarnon__1996: 7 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Heffner_Heffner_1992_c: 6 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Fox_Wilczynski_1986: 1 cells; catalog roles = {'info': 1, 'measure': 14}
- Stimpson_etal_2015: 1 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)
- Heffner_etal_1994_c: 1 cells; catalog roles = no catalog rows (no *_definitions.csv in folder?)

Exported variables with no group (structure-agnostic label, no poolable_family in variable_domain.csv): 91. These cannot be assessed for cross-variable pooling until a family is assigned.

## Source identifiers not resolved to a repo folder

(merge team names such as 'Lewitus (team)' are fine -- their roles come from the merge's own roles column)

- Kochiyama_2018 x Heiss_2004 (s4): 8
- Herculano-Houzel 2015 (daily sleep): 5
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

# ManyPrimates 2022 — mp1_merged_data (short-term memory performance)

ManyPrimates et al. (2022). *The evolution of primate short-term memory.* Animal Behavior and
Cognition, 9(4). doi:10.26451/abc.09.04.06.2022

Source: `mp1_merged_data.csv` from the ManyPrimates public repository
(https://github.com/ManyPrimates/mp1_short_term_memory). Trial-level data: 12,375 trials,
421 individuals, 41 species, 29 sites; three delay conditions (short / medium / long); three cups
(chance = 1/3).

## Source -> Snapshot
Born-digital file, frozen untouched (byte-identical, verified with `cmp`) as
`ManyPrimates__2022_STMperformance_snapshot.csv`.

## Data readable
`ManyPrimates__2022_STMperformance.R` aggregates trials to one row per species (41 rows):
per-individual proportion correct first, then the mean across individuals (`stm_prop_correct`,
overall and per delay condition); the trial-pooled proportion is kept as an informational column.
Output: `ManyPrimates__2022_STMperformance.csv` and the DOI-named TSV
`10.26451%2Fabc.09.04.06.2022_STMperformance.tsv` in `__Public/comparative-data/`.
Columns: `reference_tables/ManyPrimates__2022_STMperformance_definitions.csv`.

Caveats: values are raw performance, not the paper's model-based estimates (age, site, experience,
test situation are not adjusted). Some species have 1–2 individuals (e.g. *Allenopithecus
nigroviridis*, n=2); see `n_individuals`. Species names come from the common-name token via the
sibling `ManyPrimates__2022_speciespredictors.csv` (all 41 tokens map).

## Species note
Mapped binomials are reconciled by `_keys/General/species_key.csv` (ManyPrimates__2022 rows).

## Apps
`____EvoM1_TraitTable/EvoM1_read_stm_manyprimates.R` -> `stm_manyprimates.xlsx`; ingested by
`__merging_behaviour/behaviour_compiled.R` as measures `ShortTermMemory_prop_correct` (+ `_short`,
`_medium`, `_long`), class `cognition`; the Shiny app reads `behaviour_long.csv` via `std_merge()`.

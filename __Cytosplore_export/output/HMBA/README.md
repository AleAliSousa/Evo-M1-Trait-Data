# HMBA species-trait tables for the Cytosplore M1 viewer (DRAFT)


Built 2026-10-22 from Evo-M1-Trait-Data commit `02ea210 (from .git/HEAD; git command unavailable)` by `__Cytosplore_export/build_cytosplore_traits.R`.
Re-run that script to regenerate everything here; do not edit these CSVs by hand.

## What this is

Comparative species traits for the 4-species `HMBA` cohort (`_keys/species_cohorts.csv`), drawn from the harmonised Evo-M1-Trait-Data compilation exactly as the public Shiny app serves it. Only *measurement* variables are in the wide tables (QC flags and provenance strings are excluded). Species names are the cohort's own names, i.e. the names the RNA dataset uses -- join on `species_sci`.

## Files

| file | one row per | use |
|---|---|---|
| `HMBA_species.csv` | species (4) | species list, taxonomy, which data labels were pooled (match level: species), per-domain counts |
| `HMBA_traits_wide.csv` | species x variable (671) | **recommended viewer input**: species x trait matrix, one value per cell |
| `HMBA_traits_wide_core.csv` | species x variable (79) | same, only traits held for >= 4 of 4 species (`in_core`) |
| `HMBA_variable_dictionary.csv` | variable (671) | column metadata for the wide tables: domain, structure, measure, unit, definition, coverage |
| `HMBA_traits_cells.csv` | species x variable cell (1448) | how each wide cell was made: n values, aggregation, min/max, sources |
| `HMBA_traits_long.csv` | value (1567) | full provenance: every source value behind every cell |
| `HMBA_domain_coverage.csv` | species | n distinct variables per domain |
| `BUILD_INFO.txt` | - | build stamp and counts |

Source audit (run `python3 __Cytosplore_export/audit_cytosplore_variables.py HMBA species off` after this script):

| file | one row per | use |
|---|---|---|
| `HMBA_variable_audit.csv` | variable | contributing papers and roles, compilation-only cells, primary availability, poolability, `suggested_tier`, `source_class`, flags |
| `HMBA_secondary_only_cells.csv` | species x variable | cells fed only by compilations, with whether a primary exists in the same group |
| `HMBA_pooling_candidates.csv` | compatibility group | variables measuring the same quantity; gain if pooled; bases that must not be pooled |
| `AUDIT_SUMMARY.md` | - | the audit's headline numbers and flagged cases |

## How a wide cell is filled

- A cohort species may hold data under several labels (e.g. *Gorilla gorilla gorilla*, *Gorilla gorilla*,
  *Gorilla sp.*). Which labels are pooled is decided in `_keys/species_cohorts.csv` (`lookup_name`,
  with the reason in `lookup_basis`), not here. `data_labels` in the species table lists them.
- Numeric: arithmetic mean of all values across pooled labels and sources (the Shiny app's plotting
  rule). `n_values`, `value_min`, `value_max`, `spread_pct` and `sources` are in the cells table.
  Cells with `spread_pct` > 50 deserve a look before being shown as a point estimate.
- Categorical (diet, locomotion, ...): the single distinct value, or distinct values joined with
  ` | ` and `unresolved_categorical = TRUE` in the cells table.
- `m1_motor_related` in the dictionary is an advisory regex flag (M1, motor, corticospinal, dexterity,
  hand/limb, locomotion terms) to help pick the traits most relevant to a motor-cortex viewer.
- Domain(s) excluded from the wide tables as not being animal traits: dataset metadata (still in the long table).
- Brain-size variables are kept on separate measurement bases (weighed mass, mass excluding
  olfactory bulbs, endocranial volume, sum of parts, ...). `poolable_group` in the dictionary says
  which columns are the same quantity; do not average across groups.

## Species

| species_sci | common_name | Order | n_variables | data_labels |
|---|---|---|---|---|
| Callithrix jacchus | Common marmoset | Primates | 360 | Callithrix jacchus |
| Homo sapiens | Human | Primates | 511 | Homo sapiens |
| Macaca mulatta | Rhesus macaque | Primates | 409 | Macaca mulatta |
| Mus musculus | Mouse | Rodentia | 172 | Mus musculus |

## Variables per domain (all / core / M1-motor flagged)

| domain | variables | core | m1_motor |
|---|---|---|---|
| brain structure & size | 163 | 9 | 4 |
| cellular composition | 89 | 28 | 3 |
| cortical & cerebellar folding | 9 | 1 | 0 |
| body size | 11 | 1 | 0 |
| metabolism | 72 | 3 | 2 |
| life history | 26 | 18 | 0 |
| diet & ecology | 51 | 17 | 0 |
| behaviour & cognition | 41 | 1 | 9 |
| sensorimotor & motor pathways | 19 | 0 | 19 |
| hand & limb morphology | 17 | 0 | 17 |
| sleep & torpor | 8 | 0 | 0 |
| Unclassified | 9 | 0 | 0 |
| behaviour | 1 | 0 | 0 |
| brain size | 10 | 0 | 1 |
| cellular morphology | 87 | 0 | 27 |
| communication | 2 | 0 | 0 |
| ecology | 22 | 0 | 1 |
| sensory | 4 | 0 | 0 |
| sensory performance | 20 | 1 | 0 |
| sociality | 10 | 0 | 0 |

## Known caveats carried over from the compilation

- `_keys/README_species_cohorts.md` records open name-fragmentation rulings (e.g. ferret
  *Mustela putorius furo* vs polecat *M. putorius*; *Sus scrofa* re-pointed to the domestic form).
  The `uncounted_name_variants` column in the species table lists, per species, labels that hold
  data but are **not** counted because no ruling has adopted them.
- Coverage is availability, not agreement: a cell is filled if any source gives a value.
- Values are as compiled; see the source TSVs under `__Public/comparative-data/` and the per-merge
  READMEs under `__merging_*/` for method and provenance detail.

## Regenerating

```
Rscript __ShinyApp/build_data.R                       # only if ____EvoM1_TraitTable/*.xlsx changed
Rscript __Cytosplore_export/build_cytosplore_traits.R HMBA species 0.80 off
python3 __Cytosplore_export/audit_cytosplore_variables.py HMBA species off
```

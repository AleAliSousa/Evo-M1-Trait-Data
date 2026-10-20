# EC species-trait tables for the Cytosplore M1 viewer (DRAFT)


Built 2026-10-20 from Evo-M1-Trait-Data commit `cb75ea9 (from .git/HEAD; git command unavailable)` by `__Cytosplore_export/build_cytosplore_traits.R`.
Re-run that script to regenerate everything here; do not edit these CSVs by hand.

## What this is

Comparative species traits for the 14-species `EC` cohort (`_keys/species_cohorts.csv`), drawn from the harmonised Evo-M1-Trait-Data compilation exactly as the public Shiny app serves it. Only *measurement* variables are in the wide tables (QC flags and provenance strings are excluded). Species names are the cohort's own names, i.e. the names the RNA dataset uses -- join on `species_sci`.

## Files

| file | one row per | use |
|---|---|---|
| `EC_species.csv` | species (14) | species list, taxonomy, which data labels were pooled (match level: species), per-domain counts |
| `EC_traits_wide.csv` | species x variable (630) | **recommended viewer input**: species x trait matrix, one value per cell |
| `EC_traits_wide_core.csv` | species x variable (28) | same, only traits held for >= 12 of 14 species (`in_core`) |
| `EC_variable_dictionary.csv` | variable (630) | column metadata for the wide tables: domain, structure, measure, unit, definition, coverage |
| `EC_traits_cells.csv` | species x variable cell (2694) | how each wide cell was made: n values, aggregation, min/max, sources |
| `EC_traits_long.csv` | value (2835) | full provenance: every source value behind every cell |
| `EC_domain_coverage.csv` | species | n distinct variables per domain |
| `BUILD_INFO.txt` | - | build stamp and counts |

Source audit (run `python3 __Cytosplore_export/audit_cytosplore_variables.py EC species` after this script):

| file | one row per | use |
|---|---|---|
| `EC_variable_audit.csv` | variable | contributing papers and roles, compilation-only cells, primary availability, poolability, `suggested_tier`, `source_class`, flags |
| `EC_secondary_only_cells.csv` | species x variable | cells fed only by compilations, with whether a primary exists in the same group |
| `EC_pooling_candidates.csv` | compatibility group | variables measuring the same quantity; gain if pooled; bases that must not be pooled |
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
| Aotus nancymaae | Owl monkey | Primates | 69 | Aotus nancymaae |
| Callithrix jacchus | Common marmoset | Primates | 271 | Callithrix jacchus |
| Dasypus novemcinctus | Armadillo | Cingulata | 98 | Dasypus novemcinctus |
| Heterocephalus glaber | Naked mole rat | Rodentia | 120 | Heterocephalus glaber |
| Homo sapiens | Human | Primates | 476 | Homo sapiens |
| Macaca mulatta | Rhesus macaque | Primates | 321 | Macaca mulatta |
| Microcebus murinus | Mouse lemur | Primates | 242 | Microcebus murinus |
| Monodelphis domestica | Opossum | Didelphimorphia | 60 | Monodelphis domestica |
| Mus musculus | Mouse | Rodentia | 170 | Mus musculus |
| Mustela putorius furo | Ferret | Carnivora | 97 | Mustela putorius furo |
| Pan troglodytes | Chimpanzee | Primates | 372 | Pan troglodytes |
| Rattus norvegicus | Rat | Rodentia | 228 | Rattus norvegicus |
| Sus scrofa | Pig | Artiodactyla | 107 | Sus scrofa domesticus |
| Tupaia belangeri | Treeshrew | Scandentia | 73 | Tupaia belangeri |

## Variables per domain (all / core / M1-motor flagged)

| domain | variables | core | m1_motor |
|---|---|---|---|
| brain structure & size | 187 | 1 | 5 |
| cellular composition | 125 | 0 | 4 |
| cortical & cerebellar folding | 9 | 0 | 0 |
| body size | 2 | 2 | 0 |
| metabolism | 72 | 1 | 2 |
| life history | 21 | 9 | 0 |
| diet & ecology | 29 | 15 | 0 |
| behaviour & cognition | 30 | 0 | 9 |
| sensorimotor & motor pathways | 21 | 0 | 21 |
| hand & limb morphology | 17 | 0 | 17 |
| sleep & torpor | 5 | 0 | 0 |
| Unclassified | 1 | 0 | 0 |
| cellular morphology | 91 | 0 | 28 |
| sensory performance | 20 | 0 | 0 |

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
Rscript __Cytosplore_export/build_cytosplore_traits.R EC species 0.80
python3 __Cytosplore_export/audit_cytosplore_variables.py EC species
```

# Hemispheres: one rule for every dataset

Owner rule of 2026-11-23: *"serve both hemisphere in the comparison but make it clear it is doubled;
and also offer single. There are many cases where a hemisphere is doubled, we should just always do
it the same way unless there is a specific note that it is a different kind of value."*

## The rule

1. The unit of comparison for a paired brain structure or region is **both hemispheres**.
2. Where a source measured **one hemisphere**, the value is served twice:
   - under the plain label, as **2 x the measured value**, marked as doubled by this project;
   - under the label with a one-side suffix before the measure code (`_unilateral_`, `_left_`,
     `_right_`; for example `Neocortex_unilateral_N.n`), **as measured**.
3. Where the source itself published 2 x one hemisphere, the value is served as published, marked as
   doubled by the source, and never doubled again.
4. **A different kind of value is not doubled**: densities, percentages, ratios, thickness and other
   values that do not grow with the amount of tissue. They keep one plain label, and their definition
   says which hemisphere was measured.
5. Anything else needs a written note in the merge README and a row in the table below.

## Where it is recorded

| What | Where |
|---|---|
| Which source columns are one-sided, and who doubled | the merge's laterality register (`laterality_known.csv` format: Reference, Original_Term, side, doubling, required_suffix, note) |
| Which served values are doubled | the merge's flags file (Species, Variable, flag, detail); flag `estimated_bilateral_from_unilateral` (this project) or `published_bilateral_estimate` (the source) |
| Which datasets follow the rule | `_keys/hemisphere_basis.csv`: dataset label, flags file, one-side suffixes |
| What a user sees | column `Hemispheres` of `__compiled/compiled_long.csv.gz`, filled by `__compiled/build_compiled.R` from the two files above |

Values of `Hemispheres`:

| Value | Meaning |
|---|---|
| *(empty)* | nothing recorded: both hemispheres or a whole structure as published, or not applicable |
| `2 x one hemisphere (doubled by this project)` | rule 2, plain label |
| `2 x one hemisphere (doubled by the source)` | rule 3 |
| `mean of sources, one of them 2 x one hemisphere (doubled by that source)` | rule 3, where the merge averaged several sources |
| `one hemisphere (as measured)` | rule 2, one-side label |

## Datasets

| Dataset | Status |
|---|---|
| Brain-structure volumes | Under the rule (`__merging_volumes/laterality_known.csv`, `volumes_flags.csv`). |
| Cell counts | Under the rule (`__merging_cell_counts_isotropic_fractionator/laterality_known.csv`, `cell_counts_isotropic_fractionator_flags.csv`): every one-hemisphere source of the merge is in its register (Seelke et al. 2014; Herculano-Houzel et al. 2013; Young et al. 2013; Collins et al. 2010 and 2016; the raccoon hippocampus mass of Jardim-Messeder et al. 2017). The bat neuron numbers and brain masses of Herculano-Houzel et al. 2020 are marked as doubled by the authors; *Chaerephon pumilus* was measured on both sides (`laterality_known_exceptions.csv`). |
| Brain mass | Under the rule (`__merging_brain_mass/laterality_known.csv`, `brain_mass_flags.csv`, written by `brain_mass_hemisphere_flags.R`). The merge doubles nothing itself; it marks what a source doubled. So far one source: the brain masses of the 12 one-hemisphere bats of Herculano-Houzel et al. 2020 (the same values and the same evidence as in the cell-count register). Other sources of this merge have not yet been read for one-hemisphere weights. |
| Cortical areas & surfaces | Written exception: cortical surface areas are served per one hemisphere (`__merging_cortical_areas/README__merging.md`). |
| Every other dataset | Not yet reviewed against the rule. |

A doubled value carries its mark in every dataset that serves it: when one publication feeds two
merges (the bat brain masses reach the table through Brain mass and through Cell counts), each
merge's register has its own row for it.

To bring a dataset under the rule: give its merge a register and a flags file as above, then add
one row to `_keys/hemisphere_basis.csv`. The builder stops if a listed flags file is missing.

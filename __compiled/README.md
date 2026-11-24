# `__compiled/` — the one table both apps read

`compiled_long.csv.gz` is the single feed from this database to the apps. The Evo-M1 app
(`__ShinyApp/app.R`) and TraitExplorer take every trait value from it. Neither app reads a
`__merging_*/..._long.csv` file for trait values any more (TraitExplorer's Region Comparison tab is
the one exception; see its README).

| File | What it is |
|---|---|
| `build_compiled.R` | Builds the table. It holds the loader that used to run inside `app.R` at every start-up, moved here line for line, so the values are the ones the app has always shown. |
| `subspecies_register.csv` | Written by every build: each subspecies filed under a species, with counts, and the three-word labels that are not filed. |
| `compiled_long.csv.gz` | The output: one row per species × variable × dataset value. Gzip, because the plain CSV is 55.7 MB (3.9 MB zipped on 2026-11-23). UTF-8, LF line ends. |

## Columns

The 14 columns the app's `compiled` table has, in its order: `Species`, `Dataset`, `Variable`,
`Value`, `Value_num`, `Source`, `Items`, `Source_details`, `Teams`, `N_sources`, `Variable_raw`,
`Unit`, `Unit_raw`, `population_verdict`. Then two category columns, one name column and one
note column:

- `domain` and `measure_class`: the two tiers of the app's variable picker, from
  `_keys/variable_definitions.csv`. A label with no row there is `Unclassified`; a blank class is
  `other`.
- `Subspecies`: empty, or the subspecies name the value was filed under by its merge. `Species`
  then holds the species (`_keys/species_pooling.csv`, `axis = subspecies`; rule in
  `_keys/README_species_pooling.md`).
- `Hemispheres`: empty, or how the value relates to the hemispheres measured:
  `2 x one hemisphere (doubled by this project)`, `2 x one hemisphere (doubled by the source)`,
  `mean of sources, one of them 2 x one hemisphere (doubled by that source)`, or
  `one hemisphere (as measured)` for the label with a one-side suffix. Filled from each merge's flags
  file as listed in `_keys/hemisphere_basis.csv`; rule in `_keys/README_hemisphere_basis.md`.

`Dataset` names the merge a row came from (28 values). Missing cells are `NA`; text is always
quoted, so an empty string stays distinct from missing. Rows are ordered by `Species`, then
`Variable`, in byte order; ties stay in feed order.

## Input

The feeds listed in `_keys/app_feeds.csv` (rows with `evo_m1_app = TRUE`): that list is now the
builder's input list. To add, move or drop a merge output, edit its row there and, for a new kind
of table, add its loader in `build_compiled.R`. A feed the builder loads that has no row, or whose
file is missing or unreadable, stops the build and names the feed. The builder also reads
`__merging_brain_mass/brain_mass_unfiltered.csv`, seven keys (`variable_canonical.csv`,
`species_display_aliases.csv`, `species_pooling.csv`, `population_status.csv`,
`variable_definitions.csv`, `label_precedence.csv`, `hemisphere_basis.csv`) and the flags files the
last one lists, and sources `__ShinyApp/explorer.R` for `brain_mass_items()`.

## What is not served

A label that `_keys/variable_definitions.csv` marks `is_measurement = False` is a note about the data
(for example the species name as printed, or the basis on which a name was resolved), not a
variable. Its rows are not served; they stay on record in the file they came from.

## One value per label and species

Where two datasets carry the same label for the same species, `_keys/label_precedence.csv` says
which one is served: one row per label and pair of datasets. The yielding dataset keeps the species
the winner lacks. A row naming a label or dataset that is not served stops the build.

## Building

```bash
Rscript __compiled/build_compiled.R            # writes __compiled/compiled_long.csv.gz
Rscript __compiled/build_compiled.R . /tmp/x   # same table into /tmp/x, repo untouched
```

- `__ShinyApp/build_data.R` runs it as its last step, so the updater (`__shinyapp_update.R`)
  regenerates the file before every push; with `--no-build` the updater runs the builder alone.
- The sweep (`_run_all_scripts_v2.R`) runs it after the merges.
- `_checks/check_compiled_current.R` rebuilds into a temporary folder and fails if the committed
  file differs. Run it before a push made by hand.

The apps read the file from GitHub, so a change to a merge or a key reaches them only when the
rebuilt file is pushed. The output does not depend on the session locale; two runs on the same
inputs give the same bytes.

Two blocks in the builder are marked "copy of app.R" (species aliases and the pooling key, which
the app still needs for its cohort views). If you change one, change the other.

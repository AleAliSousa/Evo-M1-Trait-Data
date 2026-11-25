# `__compiled/` — the one table both apps read

`compiled_long.csv.gz` is the single feed from this database to the apps. The Evo-M1 app
(`__ShinyApp/app.R`) and TraitExplorer take every trait value from it. Neither app reads a
`__merging_*/..._long.csv` file for trait values any more (TraitExplorer's Region Comparison tab is
the one exception; see its README).

| File | What it is |
|---|---|
| `build_compiled.R` | Builds the table. It holds the loader that used to run inside `app.R` at every start-up, moved here line for line, so the values are the ones the app has always shown. |
| `item_columns.csv` | The map of the one route: one row per source column that is served from data points (see below). Written by hand. |
| `datapoints.R` | The one route: reads the map, makes the data points, applies the rules, returns one row per species and trait. Sourced by `build_compiled.R`. |
| `point_decisions.csv` | Written by hand: decisions about single data points (role, cited work, not served), each with its reason, evidence, who decided and when. |
| `trait_definitions.csv` | Definitions of traits the one route serves whose definitions lived in a merge folder (picked up by `_keys/build_variable_definitions.R` like any `*_definitions.csv`). |
| `datapoints.csv.gz` | Written by every build: every data point of the one route, as printed, with its species, trait, source row and status. The provenance table. |
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

## The one route: data points (since step 16, 25 November 2026)

The merge folders are being retired, trait by trait, in favour of one organization of data points
(owner, 25 November 2026). A trait whose sources are listed in `item_columns.csv` is built here, not
in a merge folder:

1. **Map** (`item_columns.csv`): one row per source column: the registered item (or a `path` for a
   table that is not registered), the species column, the value column, the trait label and unit,
   the role (a literal, or an expression over the row), the cited work (`cites`: a literal, a column
   or an expression; blank when the point names none), the hemisphere (`R`, `L`), and optionally
   specimen and n columns. Where the species column is the item builder's
   identification (a table that prints common names), `printed_col` names the column as printed; the
   data point keeps both (`species_printed`, `species_named`) and the resolver reads the second. `species_col`, `value_col` and `n_col` take a
   column name or an R expression over the table's columns; a value computed by an expression says
   so in `derived`. `label` may contain `{column}` placeholders. `dataset` keeps the old dataset name
   for now, because both apps still offer it as a filter.
2. **Data points** (`datapoints.csv.gz`): one row per mapped source cell that holds a value, as
   printed. Nothing is averaged at this stage.
3. **Rules**, the same for every data point, in this order:
   - *Species* from the house resolver (`_keys/resolve_species.R`, which applies the species key's
     per-source decisions); a subspecies keeps its printed name so the subspecies rule below files it.
   - *Point decisions* (`point_decisions.csv`): a role or cited work set for one point, or a point
     not served.
   - *Same data* (owner, 24-25 November 2026: a copy counts once). Values agree when they are within
     0.5 % of each other. A secondary point that cites a work with a report here is `same_data` if it
     agrees with that report or one of its specimens, else `differs_from_cited_source` (not served).
     Secondary points that cite a work with no report here form one report on its behalf (they must
     agree, or the build stops). A secondary point that cites nothing is `same_data` if it agrees
     with another report or one of its specimens; if it differs from every other report it is
     `differs_from_other_reports` and not served (owner, 25 November 2026); with no other report it
     is served as its own report.
   - *Species value*: a report's value is the mean over its source rows of the row means (the
     hemispheres of one brain are averaged first); the served value is the **plain mean of the
     independent reports** (owner, 25 November 2026). `N_sources` is the number of reports.
   Every data point keeps its `status`, the `report` it belongs to and, for a copy, `same_as`.
4. The rows join the merge rows and get the same treatment as every other row (display aliases,
   Hemispheres, subspecies rule, population verdict, keys).

Moved so far: cerebral surface and folding (Heuer et al. 2019), cerebellar folding (Heuer et al. 2023,
Ashwell 2020), grey-level index (Palomero-Gallagher & Zilles 2018, Semendeferi et al. 1998 and 2001,
Sherwood et al. 2004, Zilles et al. 1986) in step 16; gyrification index (Zilles et al. 1989 and
2013, Manger et al. 2012, Lewitus et al. 2014 Tables S1 and S8) in step 17. A value the project
computes from printed values (Sherwood's supragranular and infragranular means) is marked `derived`
in the data points and in `Source_details`; the printed values it comes from are served too.

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
  table or data points differ. Run it before a push made by hand.

The apps read the file from GitHub, so a change to a merge or a key reaches them only when the
rebuilt file is pushed. The output does not depend on the session locale; two runs on the same
inputs give the same bytes.

Two blocks in the builder are marked "copy of app.R" (species aliases and the pooling key, which
the app still needs for its cohort views). If you change one, change the other.

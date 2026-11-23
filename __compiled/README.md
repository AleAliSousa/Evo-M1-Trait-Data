# `__compiled/` — the one table both apps read

`compiled_long.csv.gz` is the single feed from this database to the apps. The Evo-M1 app
(`__ShinyApp/app.R`) and TraitExplorer take every trait value from it. Neither app reads a
`__merging_*/..._long.csv` file for trait values any more (TraitExplorer's Region Comparison tab is
the one exception; see its README).

| File | What it is |
|---|---|
| `build_compiled.R` | Builds the table. It holds the loader that used to run inside `app.R` at every start-up, moved here line for line, so the values are the ones the app has always shown. |
| `compiled_long.csv.gz` | The output: one row per species × variable × dataset value. Gzip, because the plain CSV is 55.7 MB (3.9 MB zipped on 2026-11-23). UTF-8, LF line ends. |

## Columns

The 14 columns the app's `compiled` table has, in its order: `Species`, `Dataset`, `Variable`,
`Value`, `Value_num`, `Source`, `Items`, `Source_details`, `Teams`, `N_sources`, `Variable_raw`,
`Unit`, `Unit_raw`, `population_verdict`. Then two category columns:

- `domain` and `measure_class`: the two tiers of the app's variable picker, from
  `_keys/variable_definitions.csv`. A label with no row there is `Unclassified`; a blank class is
  `other`.

`Dataset` names the merge a row came from (26 values). Missing cells are `NA`; text is always
quoted, so an empty string stays distinct from missing. Rows are ordered by `Species`, then
`Variable`, in byte order; ties stay in feed order.

## Input

The feeds listed in `_keys/app_feeds.csv` (rows with `evo_m1_app = TRUE`): that list is now the
builder's input list. To add, move or drop a merge output, edit its row there and, for a new kind
of table, add its loader in `build_compiled.R`. A feed the builder loads that has no row, or whose
file is missing or unreadable, stops the build and names the feed. The builder also reads
`__merging_brain_mass/brain_mass_unfiltered.csv` and five keys (`variable_canonical.csv`,
`species_display_aliases.csv`, `species_pooling.csv`, `population_status.csv`,
`variable_definitions.csv`), and sources `__ShinyApp/explorer.R` for `brain_mass_items()`.

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

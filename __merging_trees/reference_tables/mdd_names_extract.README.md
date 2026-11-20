# `mdd_names_extract.csv` — Mammal Diversity Database name history

A 13-column extract of the Mammal Diversity Database (MDD) species table, used by
`make_tip_crosswalk_seed.py` and `build_species_universe.py` to link a data label to the
spelling a 2019 tree uses, and by `build_mammal_tree_augmented.R` for the list of current
living species.

| | |
|---|---|
| Source | `_data/mdd.csv` in the repository `mammaldiversity/mammaldiversity.github.io` on GitHub |
| Retrieved | 2026-11-19 |
| Repository tree at retrieval | `749c2de16a949099cfc13ccbd2b86d427641e844` |
| sha256 of the downloaded file (first 16) | `0d07a7e9409712fa` |
| Rows | 6,904 species |
| MDD version | not recorded in the file; cite by the retrieval date and tree hash above |

Columns kept, unchanged: `sciName`, `id`, `order`, `family`, `genus`, `specificEpithet`,
`originalNameCombination`, `nominalNames`, `CMW_sciName`, `MSW3_matchtype`, `MSW3_sciName`,
`extinct`, `domestic`. The other 39 columns (distribution, type specimens, notes) were dropped
to keep the file small; no value was edited.

- `CMW_sciName` — the species' name in the Checklist of the Mammals of the World (2020).
- `MSW3_sciName`, `MSW3_matchtype` — its name in Mammal Species of the World 3 (2005) and how
  MDD matched it. `unmatched` rows are ignored.
- `nominalNames` — every nominal name MDD places in the species' synonymy, `|`-separated.

To refresh: download the current `_data/mdd.csv`, keep the same 13 columns, update this table,
re-run the universe, seed and tree builds, and diff the coverage reports before committing.
MDD's licence and citation are on the MDD site; check them before redistributing this file.

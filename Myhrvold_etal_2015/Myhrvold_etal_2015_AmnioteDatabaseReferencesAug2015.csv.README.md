# Myhrvold et al. 2015 — Amniote_Database_References_Aug_2015.csv

## Source
Myhrvold, N. P., Baldridge, E., Chan, B., Sivam, D., Freeman, D. L., & Ernest, S. K. M. (2015).
An amniote life-history database to perform comparative analyses with birds, mammals, and
reptiles. *Ecology*, 96(11), 3109. https://doi.org/10.1890/15-0846R.1 (Ecological Archives E096-269)

## What this item is
**The per-cell source-tracking layer of the Amniote database.** It has exactly the shape, column
list and row order of `Amniote_Database_Aug_2015.csv`; where that file holds a value, this one
holds the citation string naming the study (or studies, or derivation) behind it. Myhrvold et al.
2015 is a compilation, and this table is what makes it traceable.

- 21,322 species rows × 29 trait columns in the published wide file
- **113,101 rows** in the long analysis table (one row per species × trait with a recorded reference)

## Frozen source — digital-native, bytes untouched
`Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv` was **already present** in this
folder (it is an input to the value item's `.py` build). It was checked this pass rather than
re-created: md5 `58ce0c047162154dd752cfdd16c1dd26`, **byte-identical** to
`Data_Files/Amniote_Database_References_Aug_2015.csv`. Reused as-is; nothing re-saved or converted.

## Build
`Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv.R` (R, matching the repo house dialect
and the three other `.R` scripts in this folder). Before pivoting it **asserts the alignment this
item exists to provide**: the References file and the value file must share a column list and be
row-for-row, taxon-for-taxon identical in the seven taxonomy columns. The build stops otherwise.
`row_id` is carried so any reference row can be matched back to its value cell exactly.

## Printed citation forms
The cells are not bare keys — the compilers encoded how a value was derived. `cell_form`
classifies each string; counts across the 113,101 rows:

| `cell_form` | printed shape | rows |
|---|---|---|
| `single` | `Key` | 50,604 |
| `mean_of_two` | `mean of A and B` | 26,684 |
| `median_select` | `K from median of N(pool)` | 25,657 |
| `mean_of_median_select` | `mean of A & B from median of N(pool)` | 10,156 |

## Source tracking — how to reach the primary study
`reference` keeps the printed string verbatim. The full chain is recorded in the `reference` Note
of `reference_tables/Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv_definitions.csv` and runs:

1. value in `Amniote_Database_Aug_2015.csv` at (taxonomy, trait);
2. this item's matching cell → the printed citation string (alignment asserted by the build);
3. `Myhrvold_etal_2015_cell_references.R` parses that string with the documented grammar into
   `reference_tables/Myhrvold_etal_2015_cell_references_part001` … `_part007.csv` —
   **322,572 rows**, one per (cell × contributing reference), **0 parse failures** — carrying
   `ref_key` as printed, `ref_key_norm` (the `BC <class> - ` prefix stripped), `cell_form` and
   `derivation_role`;
4. join `ref_key_norm` to `reference_tables/Myhrvold_etal_2015_references.csv` (1,003 distinct
   keys) for `full_citation`, matched against
   `Supplemental_Materials/Supplemental_Table_1_Database_Literature_Cited.pdf`.

**Resolution rate, verified this pass:** 924 of 1,003 keys resolve `matched_unique`; 62
`no_entry_found`, 8 `no_year_in_key`, 9 ambiguous (2–3 candidates, listed in
`Myhrvold_etal_2015_references_citation_candidates.csv`). So a value's key is recoverable in
essentially every case, and a full Chicago-style citation in 92.1% of keys.

For the individual records behind a compiled value, use the sibling item
`Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv`.

## Registry naming note
The registry `Item name` carries the source file's `.csv` extension, so the analysis CSV is
`…AmnioteDatabaseReferencesAug2015.csv.csv` and the public TSV
`…AmnioteDatabaseReferencesAug2015.csv.tsv` — as for `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt`.
The sibling `Myhrvold_etal_2015_AmnioteDatabaseAug2015` is registered without the extension; the
registry is the authority and was followed, but the inconsistency is flagged for the owner.

## Files
- `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv` — frozen source (byte copy, pre-existing, re-verified)
- `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv.R` — build script
- `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv.csv` — analysis CSV, 113,101 × 14
- `reference_tables/Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv_definitions.csv`
- `__Public/comparative-data/10.1890%2F15-0846r.1_AmnioteDatabaseReferencesAug2015.csv.tsv`

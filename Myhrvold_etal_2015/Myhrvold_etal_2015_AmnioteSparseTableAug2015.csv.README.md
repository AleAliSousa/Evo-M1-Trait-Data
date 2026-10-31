# Myhrvold et al. 2015 — Amniote_Sparse_Table_Aug_2015.csv

## Source
Myhrvold, N. P., Baldridge, E., Chan, B., Sivam, D., Freeman, D. L., & Ernest, S. K. M. (2015).
An amniote life-history database to perform comparative analyses with birds, mammals, and
reptiles. *Ecology*, 96(11), 3109. https://doi.org/10.1890/15-0846R.1 (Ecological Archives E096-269)

## What this item is
**The underlying literature records.** Where `Amniote_Database_Aug_2015.csv` publishes one
compiled value per species × trait, this file publishes the individual records those values were
selected or averaged from — one published row per record, with the `dataset` column naming the
study it came from. It is the shortest path in the whole database from a trait value to the study
it was measured in.

- 139,827 published record rows × 28 trait columns + `dataset`
- **279,459 rows** in the long analysis table (one row per record × trait carrying a value)
- 21,322 binomials; 1,028 distinct source strings; 20 records with no source string

## Frozen source — digital-native, bytes untouched
`Myhrvold_etal_2015_AmnioteSparseTableAug2015_snapshot.csv` is a copy-rename of
`Data_Files/Amniote_Sparse_Table_Aug_2015.csv` with the bytes unchanged — not opened, not
re-saved, not converted. Verified: md5 `03253b795e400f629b823e730cd7f75a` on both.

## Build
`Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv.R` (R, matching the repo house dialect and the
three other `.R` scripts in this folder). It pivots the 28 trait columns to long, drops the −999
missing sentinel, attaches units from the paper's own
`Supplemental_Table_9_Dataset_Field_Information.csv`, and carries `row_id` so any record traces
back to its line in the frozen source. The build stops if any retained value is non-numeric.

One naming difference from the database: this file writes `litters_or_clutches_n_or_y` where the
database writes `litters_or_clutches_per_y`; the build declares that single alias and asserts
every other trait maps 1:1 onto a Supplemental Table 9 field. The database trait `longevity_y`
has no column here.

## Source tracking — resolution rate, verified this pass
`reference` is the published `dataset` string. Strip the leading `BC <class> - ` prefix
(`BC Birds` / `BC mammals` / `BC Reptiles`) and join on `ref_key_norm` in
`reference_tables/Myhrvold_etal_2015_references.csv`:

| | keys | records | % of records |
|---|---|---|---|
| resolve to a reference-key row | 1,026 of 1,028 | 273,937 | **98.0%** |
| …and carry a full citation from Supplemental Table 1 | 947 | 238,567 | **85.4%** |

The two strings that do not resolve are `BC Reptiles -` (the compilers' blank record — an empty
key) and `Greer, A.E, 1997`. The remaining gap between the two rows of the table is keys that
exist but have no entry found in
`Supplemental_Materials/Supplemental_Table_1_Database_Literature_Cited.pdf`.

This join is recorded in the `reference` Note of
`reference_tables/Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv_definitions.csv`.

## Data role
`data_role = secondary` throughout — Myhrvold et al. 2015 compiled every one of these records from
another study. The `reference` column names that study.

## Species
No species resolution is performed — the printed binomials are the paper's own accepted names;
name transformations and synonyms are published in `Supplemental_Materials/Supplemental_Table_3` …
`_8`. This matches the established pattern for this paper's already-built value item.

## Registry naming note
The registry `Item name` carries the source file's `.csv` extension, so the analysis CSV is
`…AmnioteSparseTableAug2015.csv.csv` and the public TSV `…AmnioteSparseTableAug2015.csv.tsv` — as
for `Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt`. The sibling
`Myhrvold_etal_2015_AmnioteDatabaseAug2015` is registered without the extension; the registry is
the authority and was followed, but the inconsistency is flagged for the owner.

## Files
- `Myhrvold_etal_2015_AmnioteSparseTableAug2015_snapshot.csv` — frozen source (byte copy)
- `Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv.R` — build script
- `Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv.csv` — analysis CSV, 279,459 × 15
- `reference_tables/Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv_definitions.csv`
- `__Public/comparative-data/10.1890%2F15-0846r.1_AmnioteSparseTableAug2015.csv.tsv`

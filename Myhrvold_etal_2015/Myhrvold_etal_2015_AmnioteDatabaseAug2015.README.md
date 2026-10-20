# Myhrvold et al. 2015 — Amniote Life-History Database (Aug 2015 release)

## What this item is
Myhrvold, Baldridge, Chan, Sivam, Freeman, & Ernest (2015, *Ecology* 96:3109,
doi:10.1890/15-0846R.1) compiled a cross-taxon **life-history trait database** spanning
21,322 bird, mammal, and reptile species/subspecies across 29 numeric traits (body mass,
maturity age, litter/clutch size, gestation, longevity, egg/svl measurements, etc.) —
itself a *compilation* of ~900+ underlying literature sources, not new measurements by
these authors. No brain-related trait is in this database; it is built here as
body-size/life-history covariate data (e.g. for brain-body allometry).

## The two files combined
- **`Amniote_Database_Aug_2015.csv`** (Data_Files/) — one row per species/subspecies,
  one column per trait, value or `-999` (the source's own missing-value sentinel).
- **`Amniote_Database_References_Aug_2015.csv`** (Data_Files/) — row-for-row,
  column-for-column aligned with the above (verified identical taxon identity per row
  before merging); each cell is the free-text citation the paired value was taken or
  derived from (a single reference, a mean across named references, or
  `"X from median of N(ref1, ref2, ...)"`).

Both are frozen byte-identical as `Myhrvold_etal_2015_AmnioteDatabaseAug2015_snapshot.csv`
and `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv`.

## Build
`Myhrvold_etal_2015_AmnioteDatabaseAug2015.py` melts both wide tables to long (one row
per species x trait), attaches the matching reference string, drops rows whose value is
the `-999` sentinel (113,105 of 618,338 species x trait combinations have a value), and
adds `unit` from `Supplemental_Table_9_Dataset_Field_Information.csv`
(the paper's own field-definition table — not re-derived from training knowledge).
`data_role = secondary` throughout, since the value's own reference column names the
actual contributing source.

Note on filename: the registry row for this item was already present in `__ReadMe.xlsx`
with `Item name = "Myhrvold_etal_2015_AmnioteDatabaseAug2015.csv"` (the registered name
itself carries the `.csv` extension) — the build script and analysis CSV are named to
match that exactly, rather than following the usual `<item_name>.csv` pattern.

## Species identity
`genus`/`species`/`subspecies` are the paper's own printed binomial/trinomial names —
already a scientific identity, not a common name needing curator interpretation — so no
`interpreted_taxon` column or `_keys/*/species_key.csv` entry was added for this item
(unlike common-name-only sources). Species-identity resolution against this repo's
`accepted_name` authority still happens at merge time, per `_keys/SPECIES_NAMING.md`.

## Deferred — not built this pass
Three further registry rows already exist for this paper and remain unfulfilled as
standalone items, plus several un-registered supplemental tables
(`Supplemental_Table_2_Reference_Counts.csv`, `..._3/4/5_*_Name_Transformations.csv`,
`..._6/7/8_*_Synonyms.csv`). None were requested for this build (the ask was the main
database plus the references needed to make sense of it) and none are built here:

- **`Amniote_Database_References_Aug_2015.csv`** — has its own registry row
  (Item name `Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv`, "Public TSV
  match": notfound) distinct from this item's. Its content is fully *consumed* here (every
  value's reference string is in the `reference` column above), but no standalone CSV/TSV
  matching that row's own Item name/encoded was produced — that row's own TSV is still
  outstanding if a reference-indexed artifact of its own is wanted later.
- `Amniote_Range_Count_Aug_2015.csv` — min/max/count of the *underlying individual
  records* behind each pooled trait value (data-provenance metadata, not new trait
  values).
- `Amniote_Sparse_Table_Aug_2015.csv` — an alternate long-format export of the same
  Database values with a `dataset` origin-flag column; redundant with the long table
  built here once reshaped (not independently re-verified).
- The Reference-Counts / Name-Transformation / Synonym supplemental tables are
  bookkeeping for the compilers' own synonym-matching pipeline, not trait data.

## Source
`Amniote_Database_Aug_2015.csv` and `Amniote_Database_References_Aug_2015.csv`
(Data_Files/), Myhrvold et al. (2015), Ecological Archives E096-269-D1.

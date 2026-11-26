# Partial database inventory — 2026-11-26

Live `__ReadMe.xlsx` and staging `__ReadMeAddON.xlsx` Sheet1 were read through `readxl` without changing either workbook. File checks use exact current item names and encoded TSV stems. Main-registry counts are **rows**, including three repeated item names; file presence does not certify correct values, comparability, or human visual review. The main workbook was last saved 2026-11-25 23:26 local time.

## Status at a glance

| Check | Registry rows / files |
|---|---:|
| Registry item rows | 1241 |
| Additional staging-registry item rows, absent from main | 22 |
| Staging rows with all expected local and public files | 21 |
| Rows with CSV, R script, snapshot, item README, definitions, public TSV and matching folder | 838 |
| Rows missing at least one of those exact files | 403 |
| Registered rows without matching public TSV | 40 |
| Of those: all other build files present | 16 |
| Registered rows with public TSV but no exact local analysis CSV | 22 |
| Rows with CSV, TSV, script and snapshot but missing exact item README and/or definitions | 222 |
| Source-bearing folders without an exact match in either workbook | 41 |
| Public TSVs without an exact encoded name in either workbook | 28 |

## 1. Local build files present; public export pending

These 16 registered items have the six other expected local components. Their scripts, release gates, and source identity need checking before export; several READMEs still say “not registered” although the live registry now contains the exact item. The absent file here is the public TSV.

| Item | Registry row | Current stage |
|---|---:|---|
| `Hansen_etal_2022_PET-parcellated-scale033` | 387 | Built 2026-11-15 (AI assistant Claude): _snapshot.R + snapshot CSV, build R, CSV (3,403... |
| `Hevner_WongRiley_1990_OrdinalLaminar` | 503 | Built 2026-11-18: snapshot script, frozen snapshot (19 statements), build R, analysis C... |
| `Hevner_WongRiley_1990_Table1` | 504 | Built 2026-11-18: snapshot script, frozen snapshot (10 x 3), build R, analysis CSV (8 r... |
| `Hevner_WongRiley_1990_Text` | 505 | Built 2026-11-18: snapshot script, frozen constructed snapshot (5 x 11), build R, analy... |
| `Hevner_WongRiley_1992_OrdinalLaminar` | 507 | Built 2026-11-18: snapshot script, frozen snapshot (175 statements), build R, analysis ... |
| `Hevner_WongRiley_1992_Text` | 508 | Built 2026-11-18: snapshot script, frozen snapshot (39 values), build R, analysis CSV (... |
| `Hevner_etal_1995_Figure31` | 510 | Built 2026-11-18: snapshot script (programmatic digitisation), frozen snapshot, build R... |
| `Hevner_etal_1995_Figure32` | 511 | Built 2026-11-18: snapshot script (programmatic digitisation), frozen snapshot, build R... |
| `Hevner_etal_1995_OrdinalLaminar` | 512 | Built 2026-11-18: snapshot script, frozen snapshot (25 statements), build R, analysis C... |
| `Hevner_etal_1995_Text` | 513 | Built 2026-11-18: snapshot script, frozen snapshot, build R, analysis CSV, definitions,... |
| `Sokoloff_etal_1977_Table3` | 1089 | Built 2026-11-17: snapshot script, frozen snapshot, build R, analysis CSV, definitions,... |
| `Sokoloff_etal_1977_Table4` | 1090 | Built 2026-11-17: snapshot script, frozen snapshot, build R, analysis CSV, definitions,... |
| `Suner_Rakic_1996_Table1` | 1163 | Built; human snapshot check pending |
| `WongRiley_etal_1993_Text` | 1212 | Built 2026-11-18: snapshot script, frozen snapshot, build R, analysis CSV (84 x 37), de... |
| `WongRiley_etal_1993_OrdinalLaminar` | 1213 | Built 2026-11-18: snapshot script, frozen snapshot (55 statements), build R, analysis C... |
| `Zilles_PalomeroGallagher_2017_EBRAINSFingerprints` | 1228 | Built 2026-11-15 (snapshot script + snapshot CSV, build R, analysis CSV, definitions, r... |

## 2. Other registered rows without a public TSV

**Documented reference/hold/skip (10):** `Anderson_Gallup_2015_NoDatasetItem`, `Gallup__1977_NoDatasetItem`, `Ketten__2012_Text(TTSvalues)`, `Norlén_etal_2019_Figure1`, `Nunn_etal_2001_NoDatasetItem`, `Smaers_Soligo_2013_Supplement`, `Smith_Jungers_1997_Table5`, `Titova_etal_2013_Table4`, `Westergaard_Hyatt_1994_Figure1`, `Westergaard_Hyatt_1994_Figure2`. These need their stated decision or are intentionally not dataset exports.

**Blank-suffix citation placeholders (4):** `Hevner_WongRiley_1990_`, `Hevner_WongRiley_1992_`, `Hevner_etal_1995_`, `WongRiley_etal_1993_`. Resolve item-number/registration state before treating them as build targets.

**Other incomplete or mismatched items (10):**

| Item | Missing exact components |
|---|---|
| `Brodmann__1913_Tabelle1` | analysis_csv, build_script, snapshot, readme, definitions, public_tsv |
| `DosSantos_etal_2020_unpublished` | analysis_csv, build_script, snapshot, readme, definitions, public_tsv |
| `Frost_Masterton_1994_Figure3` | analysis_csv, build_script, snapshot, readme, definitions, public_tsv |
| `Halley_Krubitzer_2019_Figure1` | analysis_csv, build_script, snapshot, definitions, public_tsv |
| `Heffner_etal_2015_TABLEI` | snapshot, readme, definitions, public_tsv |
| `Isler_etal_2008_Tree.nex` | analysis_csv, snapshot, readme, definitions, public_tsv |
| `Plavcan_vanSchaik_1997_b_Table1` | analysis_csv, build_script, snapshot, readme, definitions, public_tsv |
| `Pontzer_etal_2014_TableS1` | analysis_csv, build_script, snapshot, readme, definitions, public_tsv |
| `Upham_etal_2019_Completed100` | analysis_csv, build_script, readme, definitions, public_tsv |
| `Wong_etal_2013_Table1` | folder_exists, analysis_csv, build_script, snapshot, readme, definitions, public_tsv |

## 3. Staging registry

`__ReadMeAddON.xlsx` has 22 item rows not present by exact name in the main registry. 21 have the full local and public file set. `Schenker__2007_Table3_1b` is explicitly **reference only / do not use**, so its missing CSV and TSV are intentional. These 22 items are present in the database staging layer but still await main-registry reconciliation; do not classify their TSVs as unlisted.

## 4. Partial local or registry linkage

The 22 rows with a public TSV but no exact local CSV include naming/folder mismatches and legacy layouts; inspect the CSV report before rebuilding. Four `Hardus_etal_2008` registry rows point at a `Hardus_etal_2009` folder, and `Phillips_Sherwood_2007_Table1` appears to have a suffixed paper folder. These are identity issues as well as missing exact paths.

52 source-bearing folders lack an exact main-registry folder name; 11 of these are covered by the staging registry, leaving 41 without an exact match in either workbook. `Barger__2012` is staged in the add-on and has its reference-only public TSV. The 28 public TSVs without an exact encoded name in either workbook include auxiliary/legacy series; this count does not by itself mean their values are orphaned.

## 5. Documentation and review backlog

Of the 838 file-complete rows, 420 have a blank human visual-check cell and 356 have text containing “pending” or equivalent. This is a **recording gap**, not proof that every source was never examined. Another 222 rows have CSV, TSV, R script and snapshot but lack an exact item README and/or definitions file.

The registry’s cached public-match column says `notfound` for 201 rows whose encoded TSV is present on disk. 49 file-complete rows still say “public TSV pending” in Progress stage. Refreshing the generated file list and reviewing progress text would reconcile these labels without rebuilding data.

The standing figure-replot backfill is also open: a filename scan finds 106 registered figure-named items with local CSVs, of which 96 lack an exact adjacent `_replot.R` and `_replot.png` pair. This is a **candidate** count; the handoff requires a registry/README review to exclude nonnumeric or nonfigure items (`____TODO/figure_replots_handoff.md`).

## Companion files

- `partial_database_inventory_2026-11-26.json`: main and staging registry items, file-presence flags, source-only folders and unlisted TSV names.
- `partial_database_items_2026-11-26.csv`: the 403 rows missing at least one exact expected file.

No build scripts, source snapshots, merges, public TSVs or registry cells were changed by this inventory.

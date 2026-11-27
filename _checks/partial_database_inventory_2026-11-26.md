# Partial database inventory — updated 2026-11-26

Live `__ReadMe.xlsx` and staging `__ReadMeAddON.xlsx` were read without changing either workbook. Counts below record the scan before the later same-day Plavcan build; the companion files remain that frozen scan. Counts are main-registry rows (three item names repeat). Exact filename checks can flag legacy aliases rather than missing measurements.

## Current status

| Check | Count |
|---|---:|
| Main-registry rows | 1241 |
| Fully matched local and public file set | 855 |
| Missing at least one exact component | 386 |
| Missing an exact public TSV | 23 |
| Otherwise fully built and awaiting only public export | 0 |
| Public TSV but no exact local CSV | 22 |
| CSV/TSV/script/snapshot present, item README and/or definitions absent | 222 |
| Add-on staging rows absent from main registry | 23 |
| Staging rows with complete local and public files | 22 |
| Source-bearing folders unmatched in either workbook | 41 |
| Public TSV stems unmatched in either workbook | 27 |

## Built and completed in this pass

- Completed the 16 registered items that previously had all local build files but no public TSV: nine Hevner, two Sokoloff, two Wong-Riley 1993, Suner & Rakic Table 1, Hansen PET scale033, and Zilles/EBRAINS fingerprints. Hevner Figures 31 and 32 also gained adjacent replot scripts and PNGs; their documented numerical mismatches remain unchanged.
- Built Pontzer et al. 2014 Table S1 from the supplied supplement: 19 population rows, frozen snapshot, R build, CSV, public TSV, definitions, README, and paper-scoped taxon key rows.
- File-complete main-registry rows increased from 838 to 855. The human visual-check column was not signed off by these builds.

## Remaining 23 rows without an exact public TSV

- 11 documented holds, reference-only entries, or skips: `Anderson_Gallup_2015_NoDatasetItem`, `Gallup__1977_NoDatasetItem`, `Halley_Krubitzer_2019_Figure1`, `Ketten__2012_Text(TTSvalues)`, `Norlén_etal_2019_Figure1`, `Nunn_etal_2001_NoDatasetItem`, `Smaers_Soligo_2013_Supplement`, `Smith_Jungers_1997_Table5`, `Titova_etal_2013_Table4`, `Westergaard_Hyatt_1994_Figure1`, `Westergaard_Hyatt_1994_Figure2`.
- 4 blank-suffix citation placeholders: `Hevner_WongRiley_1990_`, `Hevner_WongRiley_1992_`, `Hevner_etal_1995_`, `WongRiley_etal_1993_`.
- 8 other gaps or filename mismatches:

| Item | Next action |
|---|---|
| `Brodmann__1913_Tabelle1` | Completed local item is `..._Table1`; reconcile registry alias. |
| `DosSantos_etal_2020_unpublished` | Privately supplied unpublished source; check release status. |
| `Frost_Masterton_1994_Figure3` | Source PDF present; figure extraction and replot remain. ResultsText already captures headline values. |
| `Heffner_etal_2015_TABLEI` | Completed local item/public TSV use `..._TableI`; reconcile casing and downstream references. |
| `Isler_etal_2008_Tree.nex` | Local deliverable is a NEXUS tree, not a TSV. |
| `Plavcan_vanSchaik_1997_b_Table1` | Built later on 2026-11-26: 87-row analysis CSV and public TSV; this row was a gap in the frozen scan. |
| `Upham_etal_2019_Completed100` | Source is multi-tree NEXUS; reconcile expected file type. |
| `Wong_etal_2013_Table1` | No matching folder or source found; locate source. |

## Registry and review backlog

The add-on has 23 items absent from the main registry, 22 with full local and public files. `Schenker__2007_Table3_1b` remains reference-only. One staging row was added while this inventory was being refreshed.

The cached main-registry public-match column still says `notfound` for 218 rows whose TSV exists. 58 file-complete rows still say “public TSV pending” in progress text. The generated file-list workbook step was not run while the registry may be edited elsewhere.

Among 855 file-complete rows, 421 have a blank human visual-check cell and 371 have pending-style text. This records review status, not proof that sources were never viewed. Figure replot backfill remains active beyond the two Hevner figures completed here.

## Companion files

- `partial_database_items_2026-11-26.csv`: 386 rows with missing exact components.
- `partial_database_inventory_2026-11-26.json`: per-item file flags, unmatched folders and TSVs.

# Underscore-convention audit — 2026-08-29

> **Status: partly remediated the same day.** The P1 strings, the P2 hardcoded R labels, the
> 9 renames and the doc referrers have been applied — see
> `_checks/underscore_fixes_applied_20260829.md` for exactly what changed, what was held
> (the Armstrong snapshot/filter pair) and what is still outstanding. The findings below
> describe the state **before** those fixes; the CSV beside it has been refreshed to the
> **post-fix** residue (3,547 rows).

Scope: `Evo-M1-Trait-Data` (public) + `Evo-M1-Trait-Data-restricted`.
3,069 files seen, 2,156 text files parsed, 393 R/Rmd scripts, 267 public TSVs.
Machine-readable detail: `_checks/underscore_naming_audit_20260829.csv` (3,620 rows).

## The convention, as the workbook actually states it

Sheet1 `F` (Publication name) is a formula, and it is the authority:

    G & IF(H<>"", "_" & H, "_") & IF(I<>"", "_" & I, "_") & IF(B<>"", "_" & B, "")
    1st Author   other author(s) or nothing   year        optional sequence letter

So a missing `other author(s)` leaves an empty slot and the separators collapse into `__`:
single author -> `Armstrong__1979`; two or more -> `Bush_Allman_2003`, `Baron_etal_1983`.
Item name (`K`) = `TRIM(TEXTJOIN("_", FALSE, F, SUBSTITUTE(SUBSTITUTE(D," ",""),"_","")))`.
`Bush_Allman_2004_a`, `Matano_etal_1985_b`, `Sherwood_etal_2004_I`, `Young_etal_2013_b` take
their trailing token from column `B` and are correct, not defects.

## What the convention governs (clarified by the repo owner, 2026-08-29)

The `Author[_other]_Year` rule is **not** repo-wide. It always governs, with no exceptions:

- the folder name;
- the builder script for the csv/tsv;
- the csv and tsv themselves.

Snapshots follow it too, bar a couple of known exceptions.

It does **not** govern the source material: the paper PDF and any publisher-supplied source
table keep whatever name they arrived with, which may differ from the publication key or lack an
underscore entirely — the same goes for comparison inputs. Those filenames are therefore entered
by hand in each script rather than derived from the item token, and a name like
`Brodmann_1913_Verhandlungen.pdf` or `zilles_rehkamper_1988.xlsx` sitting in a `__`-named folder
is correct, not a defect.

Verified against the code: no script anywhere in either repo builds a non-snapshot source
filename from the publication token. All 28 places that assemble such a path use
`paste0(<directory variable>, "<literal filename>")`, so the source name is hardcoded per script
exactly as intended.

The audit CSV now carries an `in_scope` column recording this distinction.

## Verdict

- **Folder names: clean on the public side.** All 168 public paper folders resolve to a
  registry publication name with the right number of underscores — zero mismatches.
  On the restricted side 42 of the 43 `restricted_checks/` paper folders are canonical;
  the one exception is `Zilles__Rehkamper_1988` (see P1/P2 below).
- **File contents and filenames: not clean.** 16 non-canonical spellings remain, in
  3,620 places. They are concentrated: 11 publications account for everything, and
  the great majority of occurrences are one label repeated down a built column.
- **One script is still halting for this reason** (`Zilles_Rehkämper_1988_Table12-2.R`).
  The other 10 failures in `_checks/script_execution_log.csv` have other causes.

## The 16 remaining wrong spellings

| written | should be | occurrences | direction |
|---|---|---|---|
| Kaufman_2004 | Kaufman__2004 | 2253 | missing 2nd underscore |
| Karbowski_2007 | Karbowski__2007 | 533 | missing |
| Armstrong_1979 | Armstrong__1979 | 383 | missing |
| MacLeod_2000 | MacLeod__2000 | 124 | missing |
| Zilles__Rehkamper_1988 | Zilles_Rehkämper_1988 | 119 | **extra** underscore (two authors) |
| HerculanoHouzel_2015 | HerculanoHouzel__2015 | 56 | missing |
| Ashwell_2020 | Ashwell__2020 | 36 | missing |
| Brodmann_1913 | Brodmann__1913 | 23 | missing |
| Manger_2006 | Manger__2006 | 23 | missing |
| MedinaGonzalez_2026 | MedinaGonzalez__2026 | 21 | missing |
| Weaver_2001 | Weaver__2001 | 21 | missing |
| Matano_1992 | Matano__1992 | 7 | missing |
| Weaver_2005 | Weaver__2005 | 5 | missing |
| ManyPrimates_2022 | ManyPrimates__2022 | 2 | missing |
| MacLarnon_1996 | MacLarnon__1996 | 2 | missing |
| Granatosky_2018 | Granatosky__2018 | 1 | missing |

Note the direction: 15 of 16 are single-author folders that lost the empty author slot,
but **Zilles & Rehkämper is the opposite** — two authors wrongly given `__`. The folder and
its four main files were renamed to the correct single-underscore form; the script bodies,
the definitions file, and the entire restricted-side mirror were not.

## P1 — breaks execution now (3 strings, 2 files)

1. `Zilles_Rehkämper_1988/Zilles_Rehkämper_1988_Table12-2.R`
   - L48 `snapshot_file <- "Zilles__Rehkamper_1988_Table12-2_snapshot.xlsx"` — on disk it is
     `Zilles_Rehkämper_1988_Table12-2_snapshot.xlsx`. This is the logged failure
     (`path does not exist`, 2026-08-29 01:36).
   - L50 `output_file <- "Zilles__Rehkamper_1988_Table12-2.csv"` — would write a second,
     wrongly-named copy beside the correct one.
   - L1, L22, L23 headers carry the same wrong form (cosmetic).
   The script's mtime is 2026-06-28: the filenames were renamed, the contents never were.
2. `restricted_checks/Zilles__Rehkamper_1988/comparison/Zilles__Rehkamper_1988_Table12-2_compare_to_Zilles_1988_csv.R`
   - L42 `paper_dir <- file.path(repo, "Zilles__Rehkamper_1988")` and L50 snapshot path both
     point at the pre-rename names, so the QA comparison cannot open the public snapshot.
     Its own folder, filename and two output CSVs also still carry `__`.

## P2 — wrong label, no crash (writes bad provenance into products)

Hardcoded publication labels in R that then propagate into built columns:

| script | line | writes |
|---|---|---|
| `MacLeod__2000/MacLeod__2000_APPENDIXI.R` | 414 | `source = "MacLeod_2000"` |
| `Armstrong__1979/Armstrong__1979_Tables1-9.R` | 52, 84, 107 | filters on `source_group == "Armstrong_1979"` |
| `__merging_cerebral_metabolic_rate/cerebral_metabolic_rate_compiled.R` | 93, 109, 139 | `Compilation="Kaufman_2004"`, `"Karbowski_2007"`, `comp_priority` names |
| `__energetics_comparison/energetics_comparison.R` | 46 | `reference = "Kaufman_2004"` |
| `__merging_sleep/sleep_compiled.R` | 80 | `team = "HerculanoHouzel_2015"` |

`MacLeod__2000_APPENDIXI.R` L55-62 holds a fallback *vector* of candidate input filenames
containing both spellings; that is why it still runs. Harmless, but it is why this one never
showed up as a failure.

Hand-maintained key and registry files holding a non-canonical publication name:
`_keys/Stephan/anatomy_key.csv` (`reference`, x6 — documented as a token in
`Matano__1992.README.md` L108, so change both together), `_keys/glossary.csv`,
`_keys/collection_registry.csv`, `_keys/specimen_crosswalk/pongo_provenance_audit.csv`,
`_keys/specimen_crosswalk/specimen_source_registry.csv`,
`RES specimen_registry/cases/hylobates/gibbon_specimen_roster.csv`,
`RES .../RESTRICTED_disco_study_trace.csv`, `____Collections and Specimen notes/Disco_study_list_public.csv`.
The `MacLeod_2000` / `MacLeod__2000` key mismatch is already logged as an open item in
`_keys/specimen_crosswalk/IDENTIFIER_JOIN_PASS_METHOD.md` L61 — this audit confirms it is
still open and is the single string blocking those 57 identifier joins.

Per-paper `_definitions.csv` `Reference` columns (hand-authored, so fix in place):
`Ashwell__2020_definitions.csv` x17, `HerculanoHouzel_etal_2015_definitions.csv` x14,
`Brodmann__1913_Table1_definitions.csv` x12, `MedinaGonzalez_2026_definitions.csv` x8,
`Zilles__Rehkamper_1988_Table12-2_definitions.csv` x24.

**Frozen snapshot — decide before touching:** `Armstrong__1979_Tables1-9_snapshot.csv`
carries `source_group = Armstrong_1979` in 95 rows, and the build script *filters on that
string*. Snapshot value and script filter are one coupled pair: change both or neither.
The same value has already propagated into the four derived CSVs and the public TSV.

## P2 — filenames and folders still wrong (11)

    PUB  Zilles_Rehkämper_1988/reference_tables/Zilles__Rehkamper_1988_Table12-2_definitions.csv
    PUB  MedinaGonzalez__2026/MedinaGonzalez_2026.README.md
    PUB  MedinaGonzalez__2026/reference_tables/MedinaGonzalez_2026_definitions.csv
    PUB  Weaver__2005/Weaver_2005_NOTE.md
    PUB  Brodmann__1913/Brodmann_1913_Verhandlungen.pdf        NOT A DEFECT - source PDF, outside
                                                               the convention (see Scope above);
                                                               listed here in error, no action
    RES  restricted_checks/Zilles__Rehkamper_1988/                       (folder)
    RES  restricted_checks/Zilles__Rehkamper_1988/comparison/Zilles__Rehkamper_1988_Table12-2_compare_to_Zilles_1988_csv.R
    RES  restricted_checks/Zilles__Rehkamper_1988/comparison/Zilles__Rehkamper_1988_Table12-2_comparison_report_from_R.csv
    RES  restricted_checks/Zilles__Rehkamper_1988/comparison/Zilles__Rehkamper_1988_Table12-2_comparison_mismatches_from_R.csv

## P3 — rebuild, do not hand-edit (3,100 occurrences)

2,942 occurrences sit in merge and comparison products and 158 in generated check files.
They are downstream of the P2 labels; fixing the label and re-running the builder clears them.

- `__merging_cerebral_metabolic_rate/`: `cerebral_metabolic_rate_unfiltered.csv`
  (`Compilation`, 2,034), `_long.csv` (`Compilations`, 278), `_dedupe_report.csv`
  (`reported_by`/`kept`/`dropped`, 148), `_source_species_ids.csv` (26)
- `__energetics_comparison/`: `energetics_long.csv` (`reference`, 142),
  `energetics_merged_long.csv` (`Teams`, 142)
- `Armstrong__1979/` derived trio + `__Public/comparative-data/10.1002%2Fajpa.1330510308_Tables1-9.tsv`
  (`source_group`, 285 total)
- `MacLeod__2000_APPENDIXI.csv` (`source`, 47) + `__Public/comparative-data/NQ%3A61662_APPENDIXI.tsv`
- `__merging_sleep/sleep_long.csv` (`team`, 24)
- `_keys/variable_catalog.csv` (`item`, 31) and `_keys/variable_catalog_compatibility.csv`
  (`papers`, 31) — **blocked**, see below
- `_checks/folder_audit*.csv`, `csv_tsv_*.csv`, `r_script_data_file_associations.csv`,
  `packages_used.csv`, `registry_snapshot.csv`, `script_execution_log.csv`,
  `RES MIGRATED_INDEX.csv`, `RES _triage_comparison_inputs.csv` — stale by definition;
  they record the pre-rename state.

## P4 — prose (43) and R comments (13)

READMEs and notes quoting the old spelling. Four occurrences are *deliberate* — they
document the mismatch — and are excluded from the fix list:
`Weaver__2001_TableA-15.ReadMe.md` L11 (the folder-naming note),
`_keys/specimen_crosswalk/IDENTIFIER_JOIN_PASS_METHOD.md` L61,
`RES specimen_registry/derived/RESTRICTED_identifier_join_results.md` L92.

## The 11 logged script failures, triaged

Sweep window 2026-08-28 23:41 -> 2026-08-29 01:36; 308 SUCCESS, 11 FAILED, 10 SKIPPED.
Only one failure is an underscore problem.

| script | cause | underscore? |
|---|---|---|
| `Zilles_Rehkämper_1988_Table12-2.R` | reads `Zilles__Rehkamper_..._snapshot.xlsx` | **yes** |
| `_tools/file_list.R` | halts: "Non-canonical Sheet1 naming formula(s): K62" | no — see below |
| `Manger__2006/Manger_2006_Table1.R` | path not found; folder now holds `Manger__2006_Table1.R` and all four files are canonical | no — **stale log entry**, rerun |
| `deJager_etal_2022/deJager_etal_2022.R` | could not open `deJager_etal_2022_calibration.csv`; the file is present (mtime 2026-07-31) and reads fine now | no — transient (OneDrive materialisation), rerun |
| `_checks/check_item_name_resolution.R` | non-zero exit on 2 orphaned TSVs (`...figshare.c.3899422.v1_Dataset1.tsv`, `Barger_etal_2012_Table3.tsv`) — lost registry rows. All 182 item names referenced by the 14 merge scripts resolve | no |
| `_keys/build_variable_catalog.R` | `object 'domain' not found` — L65 transmutes `domain` from `_keys/anatomy_reference.csv`, which has no such column | no — blocks the variable-catalog rebuild |
| `_tools/__register_remaining_builds_20260824.R` | row-3 guard `expected Item name 'Armstrong__1979_Tables1-9'` compares registry column 12 against a hardcoded row map | no — dated one-off, obsolete |
| `_tools/__update_remaining_builds_20260815.R` | registry column "Data readable file, can use this" no longer exists in Sheet1 | no — dated one-off, obsolete |
| `____EvoM1_TraitTable/EvoM1_read_gait_excursion_medina.R` | missing `10.1002%2Fjez.70069_Data.tsv` (Medina-González source on HOLD) | no |
| `DosSantos_etal_2020_Table1_check.R` | wants `2020-PublishedDataMammalsMicroglia - cópia.xlsx` in the public folder; it lives in `RES unpublished_data/____Unpublished__DosSantos_microglia_2024/` | no — cross-repo path |
| `Heuer_etal_2023/source_data/load_data.R` | vendored upstream script, expects `../data/derived/...` | no — not ours |

## Two findings outside the underscore question

**`__ReadMe.xlsx` K62 is the `file_list.R` blocker.** The cell holds
`IF(P62="N", O62, "write file name")` and evaluates to the literal string
`write file name`, where K61/K63 hold the canonical TEXTJOIN formula. `file_list.R`
detects it, refuses to overwrite, and halts — so the AUTO TSV-match column cannot refresh
at all, for any row. Row 62 is `deSousa_etal_2010`, Item number `Sup Table 2`
(stage FINISHED); the canonical formula would give `deSousa_etal_2010_SupTable2`.
Fix K62 first — nothing else about the registry can be regenerated until it runs.

**One public TSV is structurally broken.** `__Public/comparative-data/NQ%3A61662_APPENDIXI.tsv`
was exported without quoting from a table containing embedded newlines: 47 logical rows
became 107 physical lines with 34/24/11/1 fields, so `source` values land in
`cause_of_death`. The sibling `MacLeod__2000_APPENDIXI.csv` is clean (48 x 34). Eight other
TSVs of 267 also have inconsistent field counts (several are only a short header row):
`10.1038%2Fs41467-020-14356-3_SupplementaryData3`, `10.1159%2F000319019_Table1`,
the three `10.1111%2Fj.1558-5646.2008.00392.x_sleep-data*`,
`10.1007%2Fs10329-026-01271-2_data`, `10.1016%2Fj.jhevol.2008.08.004_TableS3`,
`10.7554%2FeLife.77875_Supplementaryfile3`.

## Suggested order

1. Fix `__ReadMe.xlsx` K62 (unblocks `_tools/file_list.R`).
2. Fix the 3 P1 strings; rerun the two Zilles scripts.
3. Rename the 11 files/folders, including the restricted Zilles mirror.
4. Fix the 10 hardcoded labels in R; decide the Armstrong snapshot/filter pair.
5. Fix `_keys/anatomy_reference.csv`'s missing `domain` column, then rebuild the
   variable catalog.
6. Rebuild merge products, then rerun `_tools/file_list.R`, `_checks/registry_snapshot.R`,
   `_checks/find_csv_tsv_creators.R`, `audit_folders.py` so the generated checks stop
   reporting the old names.
7. Sweep the 43 prose mentions last, leaving the 4 deliberate ones.

## Not assessed

Nothing was edited or renamed by this audit. Case (`weaver_2005.pdf` vs `Weaver__2005`),
ASCII vs umlaut (`Zilles_Rehkämper_1988` on disk vs `Zilles_Rehkämper_1988` in Sheet1 rows
342-343 — both single-underscore, so out of scope here), and the nine folders with no Sheet1
row (`Changizi_He_2005`, `Deaner_etal_2007`, `Hutsler_etal_2005`, `Mota_etal_2015`,
`Reader_Laland_2002`, `Schultz_Dunbar_2010`, `VanEssen_Drury_1997`, `Weaver__2005`,
`Zilles_Rehkämper_1988`) are separate questions.

# Registry audit — 2026-09-30

Audit of `__ReadMe.xlsx` against the paper folders and `__Public/comparative-data/`,
plus a build pass on genuinely build-ready items. Run from a Claude Science session
with the `evom1-r` R 4.5.3 environment (R is now available in-sandbox; the old
"no R in the sandbox" constraint no longer applies).

## Overall health — GOOD

- **Registry:** 569 data rows (Sheet1), 3 sheets (Sheet1 / SOURCE_DISPOSITION / AUTO_Public_TSV_FileList).
- **Lost rows:** 0 (snapshot `registry_snapshot.csv` = 566 rows; current is 3 rows *ahead*:
  `Nudo_Masterton_1988_Table1`, `Nudo_Masterton_1990_III_Resultstext`, `Nudo_Masterton_1990_IV_Figure2A` — snapshot just needs a refresh).
- **Malformed keys:** 0 blank Item names, 0 trailing-`_`, 0 `xml:`/quote corruption.
- **Duplicate Item names:** 19 — all the legitimate multi-row (`#n`) convention; present in both snapshot and current.
- **Folder audit:** 294 folders, 263 clean on all three folder-side checks; item-convention audit: 177 folders fully clean on the 4-file convention.

## Findings by severity

### A. Public-TSV naming mismatches (7) — registry-hygiene, no data loss
Public TSVs on disk not matched by the AUTO column. All resolve to existing registry rows:
- **Stray space in name (2):** `10.1002%2Far.20829 _Table1`, `10.1007%2Fs00429-014-0792-y _Table1` — space before `_Table1` in both the TSV filename and the row's `Item encoded`.
- **Case mismatch (2):** disk `_ResultsText` vs registry `_Resultstext` — `10.1016%2FB978-012370880-9.00004-9` (Heffner & Heffner 2008), `10.1121%2F1.3284546` (Heffner et al. 2010).
- **Suffix mismatch (2):** `10.1037%2F0735-7036.102.2.99_Table1` vs registry `_Table1+Table3` (Owren 1988); `10.1121%2F1.1903415_Table1` vs registry `_TableI` (Schusterman 1974).
- **Encoding mismatch (1):** disk `10.1002%2Fajpa.1330380234_ResultsText` vs registry `PMID%3A4689764_ResultsText` (Gillette 1973, "BUILT — TSV upload pending"): the row is keyed by PMID, the TSV by DOI.
Fix: the registry is the naming authority — rename each TSV to match `Item encoded` (or fix the space-containing `Item encoded` cells), then rerun `file_list.R`.

### B. FINISHED but public TSV `notfound` (16) — needs `file_list.R` rerun and/or a build fix
`Boddy_etal_2012_brainbodydatabasev2.txt`, `Brodmann__1913_Tabelle1`, `Halley_Krubitzer_2019_Figure1`,
`Heffner_Heffner_2008_Resultstext`, `Heffner_etal_2010_Resultstext`, `Isler_etal_2008_Tree.nex`,
`Jorstad_etal_2023_TableS1..S4`, `Kruska__2014_Table2/Table3`, `Kruska_Rohrs_1974_Table2/Table3`,
`Pirlot_Kamiya_1982_Table1`, `Pirlot_Kamiya_1985_Table1`.
Several of these are the **convention gap** in section D, not a missing build.

**Correction (definitions placement) — RESOLVED this session.** `Kruska_Rohrs_1974`, `Kruska__2014`,
`Pirlot_Kamiya_1982`, `Pirlot_Kamiya_1985` originally had a `*_definitions.csv` at the **folder top level**,
but invariant 4 / `audit_dataset_item` require it in `reference_tables/*_definitions.csv` — so all four
had shown `definitions=MISSING` in `item_convention_audit_20260930.csv`. **Fixed:** the definitions file
was copied into each folder's `reference_tables/` (`reference_tables/` created where absent) and the
top-level originals were moved to Trash. A re-run of `audit_dataset_item` now reports
`definitions=PASS` for all four. Remaining blocker for these four is only the public TSV (section D
convention decision).

### C. Orphan `.tsv` inside paper folders (9 folders)
`audit_dataset_item` flags a non-snapshot `.tsv` sitting in the paper folder (public TSVs belong in `__Public/comparative-data/`):
`BarbeitoAndrés_etal_2019`, `Isler_etal_2008`, `McDowell_etal_2024`, `Siegel__2022`, and 5 others.
For `McDowell`/`Siegel` the in-folder `.tsv` is where an earlier build wrote it; move to `__Public/` (or let the corrected script write there).

### D. Build-script convention gap (systematic) — OWNER DECISION
A subset of build scripts end their public-TSV section with the comment
*"Public TSV mirror … written via the house file_list.R pipeline, not duplicated here."*
But `file_list.R` only **indexes** existing `.tsv` files in `__Public/comparative-data/` and rebuilds the
AUTO sheet + match formulas — **it never creates a TSV.** So these items' public TSVs are never produced:
- `Kaskan_etal_2005_TableS2`, `Kruska_Rohrs_1974_Tables2–3`, `Kruska__2014_Tables2–3`,
  `Pirlot_Kamiya_1982_Table1`, `Pirlot_Kamiya_1985_Table1`.
The older/canonical style (e.g. `Kaskan_TableS1`, `Burish_etal_2010`) self-emits the TSV correctly.
Decision needed: either (a) make these scripts self-emit like the canonical style, or (b) add a real
CSV→TSV mirror step to `file_list.R`. Not patched here (design choice + minimal-diff rule).

Additional structural note: `Kruska_Rohrs_1974` and `Kruska__2014` each have **two** registry rows
(`_Table2`, `_Table3`) but a **single combined** build (`_Tables2–3.R` → `_Tables2–3.csv`). The registry
keys and the built product disagree on split-vs-combined — resolve before their TSVs can match.

### E. `build_dataset_item()` tooling bug
`_tools/dataset_builder/build_dataset_item.R` sources each build script into
`new.env(parent = baseenv())`. Because the parent is `baseenv()` (not `globalenv()`), the sourced script
cannot see `utils::read.csv`, `readxl::read_excel`, or any attached package — every script that uses a
non-base reader fails with *"could not find function read.csv / read_excel"*. The scripts run fine when
invoked as designed (`Rscript <script>.R`, which sets `commandArgs('--file=')` for self-location).
Suggest changing the sourcing parent to `globalenv()` (or `sys.source(..., envir = globalenv())`).

## Actions taken this session

- Ran the folder audit (`_tools/audit_folders.py`) → refreshed `_checks/folder_audit.csv`.
- Ran an item-convention audit across all 294 folders → wrote `_checks/item_convention_audit_20260930.csv`.
- **Re-built 7 items by running their own scripts via `Rscript`** (deterministic, assertion-checked
  rebuilds from frozen snapshots; each overwrote a pre-existing identically-named public TSV):
  `Kaskan_etal_2005_TableS1`, `McDowell_etal_2024_Table1`, `Zilles_etal_1986_Table1`,
  `Zilles_etal_1986_Table2`, `Zilles_etal_2011_TableS1/TableS2/TableS3`.
  (Content is script-deterministic; owner should `git diff` before committing to confirm no unintended change.)
- **Relocated definitions files** for `Kruska_Rohrs_1974`, `Kruska__2014`, `Pirlot_Kamiya_1982`,
  `Pirlot_Kamiya_1985`: top-level `*_definitions.csv` → `reference_tables/` (created where absent),
  top-level originals Trashed; all four now pass `definitions`.
- **Generated `Hutsler_etal_2005_registry_rows.xlsx`** (4 paste-ready rows + HOW_TO_PASTE) for the only
  genuinely-missing-row folder with built data; saved in `Hutsler_etal_2005/`. Workbook not edited.
- **Did NOT edit `__ReadMe.xlsx`** (no `file_list.R` run, no registration) — the workbook may be open in
  Excel and the house process reserves those edits for the owner's RStudio session.

## Owner / RStudio to-do (workbook-touching, deferred by design)

1. Rerun `_tools/file_list.R` (rebuilds AUTO sheet + L-column matches; picks up the 7 rebuilt TSVs and the 3 Nudo rows).
2. Rerun `_tools/registry_snapshot.R` (snapshot is 3 rows behind).
3. Resolve the 7 name mismatches (section A) — rename TSVs to match `Item encoded`.
4. Decide the section-D convention (self-emit vs file_list mirror) and the Kruska split-vs-combined question. (The definitions-relocation for the four section-D folders was completed this session — see the Section B correction; no action needed there.)
5. Fix the `build_dataset_item()` sourcing-parent bug (section E).
6. Set Progress stage / register the blank-stage items now that products exist (Kaskan, McDowell, Zilles 1986/2011; `Zilles_etal_1986` already has a staged `__ReadMe_rows_to_add_*.csv`).

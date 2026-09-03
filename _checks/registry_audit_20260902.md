# Registry audit — 2026-09-02

Run: `_tools/audit_folders.py` + registry-side sweep (Python, no R). Previous audit:
`registry_audit_20260831.md`.

## Overall health

- **380 data rows** in `__ReadMe.xlsx` Sheet1 (no fully-empty formatting rows).
- **No lost rows.** Snapshot diff (373 keys, 14→7 rows stale) is clean: the single "missing"
  key `Heffner_Heffner_1992_TableI` is the folder rename to `Heffner_Heffner_1992_a` (row now
  `Heffner_Heffner_1992_a_TableI`), not a loss. 8 genuinely new rows since the snapshot:
  Heesy__2004_Table1, Jung_etal_2022 ×3, Kirk_Kay_2004 ×2, Heffner_etal_2020_Figure3 #2,
  Heffner rename. → rerun `_checks/registry_snapshot.R` in RStudio.
- **Zero trailing-`_` keys, zero blank Item numbers, zero XML-corrupted keys** — the
  `Young_etal_2013_xml:space…` corruption flagged 08-31 is repaired.
- **43 orphaned public TSVs** (on disk, not in the AUTO col) — dominated by the stale AUTO
  column: every 08-31→09-02 build (sensory set, Chaplin ResultsText, Demirci, VanEssen,
  Haarlem CFF, DNAonlyMCC…) shows here. → one `_tools/file_list.R` rerun clears most of it.
  Real defects inside the 43, still visible after the rerun unless fixed:
  - `10.1126%2Fsciadv.abn0954_ReportedResults.tsv` vs registry Item number `Reportedresults`
    — **case mismatch** (Jung 2022); align one side.
  - `10.1016%2Fj.neubiorev.2022.104550_acuityblind.csv.tsv` — double extension
    (`acuityblind.csv` as Item number); decide whether to keep or rename.
  - `10.6084%2Fm9.figshare.c.3899422.v1_Dataset1.tsv` — the **Olkowicz figshare/PNAS key
    mismatch**, still an owner decision (`script_repairs_20260829.md`).
- **16 FINISHED-but-notfound** rows — same file_list.R staleness, not data loss (incl. the
  duplicated `Upham_etal_2019_DNAonlyMCC` pair, known).
- **Duplicate Item names** (all the legitimate multi-row "#n" convention): Heffner_etal_2020
  ×2, Jacobs 2016 ×2, Johnson 2016 ×3, Peruffo 2019 ×3, Winkler & Bryant ×2, Young 2013 ×2,
  Young 2013b ×2, Zilles 2013 ×2.

## Folder audit (175 folders, 160 clean)

- **No registry row:** `Deaner_etal_2007`, `Hutsler_etal_2005` (built, 26 files — the known
  register-Hutsler-×4 queue item), `Reader_Laland_2002`, `Weaver__2005` (both known stubs).
- **Derived-without-frozen-source (invariant-1 risk):** `Fu_etal_2013`, `Rilling_Insel_1998`,
  `deJager_etal_2022` — each has xlsx/csv products but no snapshot/download marked frozen;
  worth a freeze pass. `Halley_Krubitzer_2019` is the documented skip (benign).
- **No paper PDF:** McGuire & Ratcliffe 2011, Shultz_Dunbar_2010 (URL-excused),
  Stephan 1991 / Upham 2019 (known-benign, supplements frozen).

## Work in flight

Sensory intake is the active program. `__merging_sensory/sensory_compiled.R` currently wires
Heffner & Heffner 1992a, Heffner et al. 2020, Koay et al. 1998, Kirk & Kay 2004 references,
Veilleux & Kirk 2014. **Built but not yet wired:** Heesy 2004 (folder complete, registry row
now present; snapshot 2nd review pending), Jung et al. 2022 (3 items). Non-sensory unwired
(unchanged from 08-31): Liu 2016 hand, Jacobs 2018 M1 morphology, Demirci 2023, Van Essen &
Drury 1997, Chaplin 2013 (all await the R rerun / wiring pass).

New-merge-group watch: `____Spinal_cord_etc/` staging (corticospinal + pyramidal tract PDFs,
`__ReadMe_SpinalCord.txt`) is the next candidate group; surface areas keep flowing to
`__merging_cortical_areas`, counts to `__merging_cellcounts`.

## Actions taken

- Rewrote `## Current order of work` in `PROJECT_SCOPE_AND_DATASET_ROADMAP.md`
  (refreshed 2026-09-02) and bumped the header date; second pass same day fixed stale claims
  (sensory merge status, NA.tsv/DNAonlyMCC resolution, Young 2013 split, Heuer 2023
  registration, Capellini wiring, app table count).
- `_checks/folder_audit.csv` rewritten by `audit_folders.py`.
- **Owner-approved fixes applied 2026-09-02** (workbook backed up to
  `_archive/__ReadMe.pre_vanessen_20260902.bak.xlsx`):
  - `__ReadMe.xlsx` row 357: removed artifact author "New Collective, A."; cached F/H/K now
    `VanEssen_Drury_1997` / `Drury` / `VanEssen_Drury_1997_Table1`; formulas untouched, 380
    data rows verified intact.
  - Jung 2022: folder products and public TSV renamed `ReportedResults` → `Reportedresults`
    (registry casing is authoritative); internal R references updated.
  - Todorov 2019: products renamed `_dimorphdata.*` → `_rspb20191712si001.*` (registry key
    kept); inner frozen `dimorphdata.csv` member untouched; R/README and
    `_keys/specimen_crosswalk/specimen_source_registry.csv` references updated.
- Still pending R-side: `file_list.R` (column M), `registry_snapshot.R`.

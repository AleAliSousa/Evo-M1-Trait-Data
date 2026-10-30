# Registry ↔ folder audit — 2026-08-25

`__ReadMe.xlsx` as of 2026-08-25 10:32 (124,687 B). 349 Sheet1 rows read; **334 real data rows**
(rows 335–349 are fully empty formatting rows). 163 paper folders scanned by
`_tools/audit_folders.py`; **143 clean on all three invariants**. Full per-folder table in
`folder_audit.csv` (this run overwrote it).

## Overall health

Good. **No rows lost since the last snapshot** (`registry_snapshot.csv`, 335 keys — every key still
present; the snapshot itself is now 14 rows stale and needs an R rerun of `registry_snapshot.R`).
Zero orphaned public TSVs: all 266 TSVs under `__Public/comparative-data/` have a registry
reference. The 2026-08-20 row-loss incident has not recurred.

## Findings, ordered by severity

1. **Built but unregistered (invisible to the registry):**
   - `Hutsler_etal_2005` — 4 finished products (Table1, Figure3, Figure6, ReportedValues) with
     snapshots, READMEs and `PROPOSED_species_key_rows.csv`; already named as a source in
     `__merging_cortical_layers/README__merging.md`. Looks like a merged RA contribution awaiting
     integration (registration, species-key rows, public TSVs).
   - `Todorov_etal_2019` — `dimorphdata` product built (R + CSV + README + frozen SI zip), no row.
2. **Blank `Item number` ⇒ malformed keys ending in `_`** (the `read_item()` failure fingerprint):
   `Shultz_Dunbar_2010_`, `Stephan_Pirlot_1970_`, `Weaver__2005_`. Shultz is additionally
   misspelled relative to its (empty) folder `Schultz_Dunbar_2010/`.
3. **Corrupted item name:** `Young_etal_2013_xml:space="preserve">b_Table1` — XML attribute text
   flattened into the key (same lineage as the known footnote-marker problem).
4. **Folder-name error:** `Deaner_et_2007/` (contains `deaner_etal_2007.pdf`) — should be
   `Deaner_etal_2007`, and has no registry row. Distinct from `Deaner_etal_2006/` (registered).
5. **No build, no row:** `Reader_Laland_2002/` (pdf + definitions only), `Schultz_Dunbar_2010/`
   (completely empty folder), `data_intermediate/` (empty, purpose unknown — created 2026-08-25).
6. **FINISHED but AUTO TSV column = notfound:** `DeCasien_Higham_2019_…SocialSystem` and
   `Upham_etal_2019_Completed100`. Both are expected to clear when `_tools/file_list.R` is rerun
   in R (the AUTO column is script-owned and stale, matching the pending Completed100 R run).
7. **Invariant-1 risk (derived data, no frozen source in folder):** Fu 2013, Halley & Krubitzer
   2019 (documented skip — audit CSVs only, acceptable), Rilling & Insel 1998, deJager 2022.
8. **No paper PDF:** Schultz_Dunbar_2010, Stephan_etal_1991, Upham_etal_2019 (tree source —
   supplement frozen, acceptable).
9. **59 rows with TSV = notfound** overall; 53 of these are blank-stage/candidate/NOT STARTED
   rows, i.e. the expected to-build queue, not errors.

## Duplicated item names (informational)

`Jacobs_etal_2016_Table1` ×2, `Johnson_etal_2016_Table1` ×3, `Peruffo_etal_2019_Table2` ×3,
`Winkler_Bryant_2021_Figure1` ×2, `Young_etal_2013_Table1` ×2, `Zilles_Rehkämper_1988_Table12-2`
×2, `Zilles_etal_2013_Table1` ×2 — consistent with the established multi-row "#n" convention;
not treated as defects here, but the Young/Zilles pairs share one TSV each and are worth a look
when fixing finding 3.

## Actions taken 2026-08-25

- Priority list refreshed: `PROJECT_SCOPE_AND_DATASET_ROADMAP.md` → "Current order of work
  (refreshed 2026-08-25)".
- No edits made to `__ReadMe.xlsx` in this pass (audit only).

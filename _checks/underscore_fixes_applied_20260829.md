# Underscore fixes applied — 2026-08-29

Companion to `_checks/underscore_naming_audit_20260829.md`. Scope applied: the P1 strings, the
P2 hardcoded R labels, the filename/folder renames, and the doc referrers that named a path
being renamed. Nothing was rebuilt (no R in this environment) and `__ReadMe.xlsx` was not touched.

Pre-edit copies of every file listed below: `pre_underscore_fix_backup_20260829.tar.gz`
(arcnames are `PUB/<relpath>` and `RES/<relpath>`).

## P1 — the two scripts that were halting

| file | change |
|---|---|
| `Zilles_Rehkamper_1988/Zilles_Rehkamper_1988_Table12-2.R` | `Zilles__Rehkamper_1988` -> `Zilles_Rehkamper_1988`, 5 occurrences (L1, 22, 23 headers; **L48** `snapshot_file`; **L50** `output_file`) |
| `RES restricted_checks/.../Zilles_Rehkamper_1988_Table12-2_compare_to_Zilles_1988_csv.R` | same token, 8 occurrences (L1, 15-17 headers; **L42** `paper_dir`; **L50** snapshot path; L53-54 output names) |

`snapshot_file` now resolves: `Zilles_Rehkamper_1988_Table12-2_snapshot.xlsx` is present in the
public folder, and the restricted script's `paper_dir` now points at the real folder name.

## P2 — hardcoded provenance labels in R

| file | line | before -> after |
|---|---|---|
| `MacLeod__2000/MacLeod__2000_APPENDIXI.R` | 414 | `source = "MacLeod_2000"` -> `"MacLeod__2000"` |
| `MacLeod__2000/MacLeod__2000_APPENDIXI.R` | 57, 58, 62 | three legacy single-underscore entries **removed** from `snapshot_candidates` (the canonical spellings were already in the vector at L59-61; the stale entries are what kept this script green and hid the mismatch) |
| `__merging_cerebral_metabolic_rate/cerebral_metabolic_rate_compiled.R` | 8, 93, 139 | `Kaufman_2004` -> `Kaufman__2004` (3) |
| `__merging_cerebral_metabolic_rate/cerebral_metabolic_rate_compiled.R` | 10, 109, 139 | `Karbowski_2007` -> `Karbowski__2007` (3) |
| `__energetics_comparison/energetics_comparison.R` | 46 | `reference = "Kaufman_2004"` -> `"Kaufman__2004"` |
| `__energetics_comparison/energetics_merged.R` | 5, 53, 137 | `Kaufman_2004` -> `Kaufman__2004` (3) |
| `__merging_sleep/sleep_compiled.R` | 19, 80 | `HerculanoHouzel_2015` -> `HerculanoHouzel__2015` (2) |

Both `comp_priority` names in `cerebral_metabolic_rate_compiled.R` L139 and the `Compilation`
values they are matched against moved together, so the dedupe keys stay consistent.
Comment lines in these same files were normalised at the same time, so no comment now
contradicts the code beside it.

**Held, deliberately:** `Armstrong__1979/Armstrong__1979_Tables1-9.R` L52, L84, L107 still filter
on `source_group == "Armstrong_1979"`. That string is the value stored in the frozen
`Armstrong__1979_Tables1-9_snapshot.csv` (95 rows). Changing the filter alone makes the script
return nothing; changing the snapshot means editing a frozen file. Snapshot + filter are one
decision and it is yours.

## Renames (8 filesystem operations kept; a 9th was reverted. The audit listed 11 path
## rows because the restricted folder component was counted once per child)

| repo | before -> after |
|---|---|
| PUB | `Zilles_Rehkamper_1988/reference_tables/Zilles__Rehkamper_1988_Table12-2_definitions.csv` -> `Zilles_Rehkamper_1988_Table12-2_definitions.csv` |
| PUB | `MedinaGonzalez__2026/MedinaGonzalez_2026.README.md` -> `MedinaGonzalez__2026.README.md` |
| PUB | `MedinaGonzalez__2026/reference_tables/MedinaGonzalez_2026_definitions.csv` -> `MedinaGonzalez__2026_definitions.csv` |
| PUB | `Weaver__2005/Weaver_2005_NOTE.md` -> `Weaver__2005_NOTE.md` |
| PUB | ~~`Brodmann_1913_Verhandlungen.pdf` -> `Brodmann__1913_Verhandlungen.pdf`~~ **REVERTED** - source PDF, outside the convention |
| RES | `restricted_checks/Zilles__Rehkamper_1988/` -> `restricted_checks/Zilles_Rehkamper_1988/` (folder) |
| RES | `.../comparison/Zilles__Rehkamper_1988_Table12-2_compare_to_Zilles_1988_csv.R` -> single underscore |
| RES | `.../comparison/Zilles__Rehkamper_1988_Table12-2_comparison_report_from_R.csv` -> single underscore |
| RES | `.../comparison/Zilles__Rehkamper_1988_Table12-2_comparison_mismatches_from_R.csv` -> single underscore |

No destination existed beforehand; nothing was overwritten. `Zilles_1988.csv` keeps its name — it
was only flagged because its parent folder was wrong, which the folder rename fixed.

## Referrer updates (docs that named a path being renamed, or an already-renamed one)

`Zilles_Rehkamper_1988_Table12-2.README.md` (7), `Matano_etal_1985_b_Table1.README.md` (2),
`Mota_etal_2015_TableS1.README.md` (1), `__COMPARISON_MOVED.md` (2),
`PROJECT_SCOPE_AND_DATASET_ROADMAP.md` (3: 1 Zilles, 2 `MedinaGonzalez_2026/`),
`MedinaGonzalez__2026.README.md` (1), `Weaver__2005_NOTE.md` (1),
`Brodmann__1913_Table1.README.md` (5).

## Verification after the edits

- Every quoted file reference in all 393 R/Rmd scripts was re-resolved against disk:
  **0 references now broken by underscore spelling** (was 5 in 3 scripts).
- Full re-scan of both repos: **0 filenames or folders** with a non-canonical publication name
  (was 11 path rows / 9 objects).
- Remaining in R code: the 3 held Armstrong filters, and 1 comment in
  `__merging_behaviour/behaviour_compiled.R` L10 (`ManyPrimates_2022`).
- Total occurrences 3,620 -> 3,547. The residue is what it was always going to be:
  2,940 in merge/comparison products and 149 in generated check files (both clear on rebuild),
  334 hand-authored data values, 95 in the Armstrong frozen snapshot, 21 prose, 4 deliberate.

`_checks/script_execution_log.csv` still shows the old FAILED rows — it can only be refreshed by
re-running the sweep in R. Expected on a rerun: the two Zilles scripts pass, `Manger__2006` and
`deJager_etal_2022` pass (both were stale entries), and the other 8 failures persist because
their causes are unrelated (K62, missing `domain` column, obsolete one-off tools, HOLD sources,
cross-repo path, vendored script).

## Still outstanding — not in this pass

1. `__ReadMe.xlsx` K62: `IF(P62="N", O62, "write file name")` -> the canonical TEXTJOIN formula.
   Blocks `_tools/file_list.R` for every row.
2. `__ReadMe.xlsx` Snapshot column (R), rows 342-343: still
   `Zilles__Rehkamper_1988_Table12-2_snapshot.xlsx`; the file is now single-underscore.
   Two more Snapshot-column rows do not match any file and look like fill errors rather than
   naming errors: row 42 `Bush_Allman_2004_b_TABLE1` names
   `Bush_Allman_2004_Table1_snapshot.csv` (actual: `Bush_Allman_2004_b_TABLE1_snapshot.csv`),
   and row 239 `Reader_etal_2011_Data` carries row 246's Schleifenbaum snapshot value verbatim.
3. Hand-authored `Reference` columns in five `_definitions.csv` files (Ashwell x17,
   HerculanoHouzel_etal_2015 x14, Brodmann x12, MedinaGonzalez x8, Zilles x24) and the key
   files (`_keys/Stephan/anatomy_key.csv` x6 - change with `Matano__1992.README.md` L108;
   `_keys/glossary.csv`, `_keys/collection_registry.csv`, `pongo_provenance_audit.csv`,
   `specimen_source_registry.csv`, and the restricted specimen roster / study trace).
   The `MacLeod_2000` -> `MacLeod__2000` crosswalk key is the one string that unblocks the
   57 identifier joins noted in `IDENTIFIER_JOIN_PASS_METHOD.md`.
4. The Armstrong snapshot/filter decision.
5. Rebuilds, in this order: `_keys/anatomy_reference.csv` `domain` column ->
   `build_variable_catalog.R`; then the cerebral-metabolic-rate, energetics, sleep and
   MacLeod builders; then `_tools/file_list.R`, `_checks/registry_snapshot.R`,
   `_checks/find_csv_tsv_creators.R`, `_tools/audit_folders.py`.
6. 21 prose mentions (4 deliberate ones excluded).


---

# Second pass — hand-authored definitions and key files (same day)

Applied after the code/rename pass. 76 occurrences in 13 files. Pre-edit copies:
`pre_keyfile_fix_backup_20260829.tar.gz`.

| repo | file | change | n |
|---|---|---|---|
| PUB | `Zilles_Rehkamper_1988/reference_tables/Zilles_Rehkamper_1988_Table12-2_definitions.csv` | `Reference`: `Zilles__Rehkamper_1988_Table12-2` -> single underscore | 24 |
| PUB | `Ashwell__2020/Ashwell__2020_definitions.csv` | `Reference`: `Ashwell_2020` -> `Ashwell__2020` | 17 |
| PUB | `Brodmann__1913/reference_tables/Brodmann__1913_Table1_definitions.csv` | `Reference`: `Brodmann_1913_Table1` -> `Brodmann__1913_Table1` | 12 |
| PUB | `MedinaGonzalez__2026/reference_tables/MedinaGonzalez__2026_definitions.csv` | `Reference`: `MedinaGonzalez_2026_Data` -> `MedinaGonzalez__2026_Data` | 8 |
| PUB | `_keys/Stephan/anatomy_key.csv` | `reference`: `Matano_1992` -> `Matano__1992` | 6 |
| PUB | `Matano__1992/Matano__1992.README.md` | L108 token mention, changed with the key above | 1 |
| RES | `specimen_registry/cases/hylobates/gibbon_specimen_roster.csv` | `registered_studies`: `MacLeod_2000` -> `MacLeod__2000` | 2 |
| RES | `specimen_registry/cases/hylobates/RESTRICTED_disco_study_trace.csv` | `study` | 1 |
| PUB | `____Collections and Specimen notes/Disco_study_list_public.csv` | `study` | 1 |
| PUB | `_keys/collection_registry.csv` | `evidence_note` prose | 1 |
| PUB | `_keys/specimen_crosswalk/pongo_provenance_audit.csv` | `item` | 1 |
| PUB | `_keys/specimen_crosswalk/specimen_source_registry.csv` | `repository_location`: `Weaver_2001/Weaver__2001_TableA-15.csv` -> `Weaver__2001/...` (verified the path now exists) | 1 |
| PUB | `_keys/glossary.csv` | `source` prose | 1 |

Every value was checked against the registry for a same-first-author, same-year collision before
being rewritten, so none of these silently repoints a row at a different publication.

## Resolved — the one value that was not an underscore error

`HerculanoHouzel_etal_2015/HerculanoHouzel_etal_2015_definitions.csv`, `Reference` column,
14 rows, held on the first pass and then confirmed: the value `HerculanoHouzel_2015` was missing
the `etal` token, not an underscore. Collapsing underscores makes it look like
`HerculanoHouzel__2015` (the single-author 2015 paper, which has its own folder), but every sibling
file in the folder is `HerculanoHouzel_etal_2015_*` and all four other `_definitions.csv` files in
the repo put the folder's **own** publication in `Reference`. Set to `HerculanoHouzel_etal_2015`
(14 occurrences) on your confirmation. Pre-edit copy: `pre_hh_fix_backup_20260829.tar.gz`.

Note the contrast with `__merging_sleep/sleep_compiled.R` L80, corrected earlier to
`HerculanoHouzel__2015`: there the label sat beside the item name `HerculanoHouzel__2015_Table1`,
so the single-author paper was unambiguous. Same string, two different publications, two
different corrections.

## The tree was rebuilt mid-pass

Merge and comparison products were regenerated in RStudio between 10:05 and 10:12 while this pass
was running, and they picked up the code fixes: `cerebral_metabolic_rate_unfiltered.csv` now carries
`Kaufman__2004` x1714 and `Karbowski__2007` (zero occurrences of either old form),
`energetics_merged_long.csv` `Kaufman__2004` x142, `sleep_long.csv` `HerculanoHouzel__2015` x24,
and `MacLeod__2000_APPENDIXI.csv` + its public TSV now write `source = MacLeod__2000`.
`_keys/variable_catalog.csv` did **not** rebuild - it is still blocked on the missing `domain`
column in `_keys/anatomy_reference.csv`.

The MacLeod public TSV is still structurally broken after that rebuild: the CSV parses cleanly
(48 rows x 34 columns) but `NQ%3A61662_APPENDIXI.tsv` is still 107 physical lines with field counts
34/24/11/9/3/1, so the exporter is still writing embedded newlines unquoted. That is reproducible,
not a leftover.

## Residue: 3,620 -> 540 occurrences

Buckets below are mutually exclusive and sum to 540 exactly.

| group | n | clears when |
|---|---|---|
| Armstrong cluster: frozen snapshot (95), 4 derived CSVs (190), public TSV (95), 3 script filters (3) | 383 | you decide the snapshot/filter pair, then rebuild |
| `_keys/variable_catalog.csv` (31) + `_compatibility.csv` (31) | 62 | `domain` column fixed -> `build_variable_catalog.R` rerun (its definitions inputs are now canonical) |
| generated check files: `MIGRATED_INDEX.csv` (18), `folder_audit_20260805.csv` (11), `folder_audit.csv` (9), `packages_used.csv` (9), `files_containing_rstudioapi.csv` (7), `registry_snapshot.csv` (2), RES `script_execution_log.csv` (2), `BUILD_STATUS_20260805.md` (1), `_triage_comparison_inputs.csv` (1) | 60 | regenerate (the two dated files - `folder_audit_20260805`, `BUILD_STATUS_20260805` - are historical and should be left as they are) |
| prose: `Manger__2006_Table1.ReadMe.md` (5), `SOURCE_DISPOSITION_REGISTER.md` (4), `MacLeod__2000_APPENDIXI.ReadMe.md` (4), `Disco_gibbon_specimen_note.md` (2), `Baker_etal_2025_HANDOFF.md` (2), `MacLarnon__1996_Table1.ReadMe.md` (2), `specimen_crosswalk/SCHEMA.md` (1), and 1 R comment in `__merging_behaviour/behaviour_compiled.R` L10 | 21 | text sweep |
| `specimen_crosswalk_combined_pre_split_2026-08-19.csv` | 8 | never - dated archive, left alone |
| deliberate mentions: `Weaver__2001_TableA-15.ReadMe.md` (2), `IDENTIFIER_JOIN_PASS_METHOD.md` (1), RES `RESTRICTED_identifier_join_results.md` (1) | 4 | never - they document the mismatch |
| **stragglers inside `__merging_*` / `__ShinyApp` that a rebuild will NOT clear** | **2** | **hand fix - see below** |

The last row is easy to lose, so it is spelled out: `__ShinyApp/data/glossary.csv` `source`
column still reads `Weaver_2001` (1), and `__merging_sleep/README__merging.md` L43 still reads
`HerculanoHouzel_2015` in its source table (1). Both sit under merge/app directories, so they look
like regenerated products, but the glossary row is carried through from `_keys/glossary.csv`
(already fixed, so it will clear on the next `__ShinyApp/build_data.R` run) and the README is
hand-written prose that no builder touches. Fix the README by hand.

No filenames, no folders, and no live R path references remain non-canonical in either repo.


---

# Scope correction (repo owner, 2026-08-29)

The convention always governs the **folder name**, the **builder script for the csv/tsv**, and the
**csv and tsv themselves**; **snapshots** follow it bar a couple of exceptions. It does **not**
govern the **source paper PDF**, **publisher-supplied source tables**, or **comparison inputs** —
those keep the name they arrived with and are entered by hand in each script.

Consequences, applied:

1. **Reverted** the one rename that was out of bounds:
   `Brodmann__1913/Brodmann__1913_Verhandlungen.pdf` is back to `Brodmann_1913_Verhandlungen.pdf`,
   and the single PDF mention in `Brodmann__1913_Table1.README.md` L40 was restored with it. The
   other four changes in that README (registry Item name, the `.R`, the `.csv`, the snapshot) are
   governed and stand. Nothing reads the PDF programmatically, so the revert is inert.
2. The checker now excludes non-governed objects and mentions of them: `.pdf`, publisher-named
   source tables in a paper folder, anything under a `comparison/` directory, and any filename
   token ending in a source extension without `snapshot` in it. This removed 1 flagged file and
   3 false-positive mentions (the PDF name quoted in a README and in two dated reports).
3. Confirmed no script derives a non-snapshot source filename from the publication token — all 28
   such paths are `paste0(<dir variable>, "<literal name>")`.
4. The two comparison outputs renamed on the restricted side
   (`..._comparison_report_from_R.csv`, `..._comparison_mismatches_from_R.csv`) and the compare
   script's own filename were **not** required to change by the convention. They are left at the
   single-underscore form because the script that writes them now uses those names, so the pair is
   self-consistent; the edits that *were* required there are the `paper_dir` and snapshot paths,
   which pointed at a public folder and file that do not exist under the old spelling. Say the word
   and I will put all three back to `Zilles__Rehkamper_1988_*`.

## Final residue: 537 in-scope occurrences, + 1 excluded

| group | n |
|---|---|
| Armstrong cluster (frozen snapshot 95, 4 derived CSVs 190, public TSV 95, 3 script filters) | 383 |
| `_keys/variable_catalog.csv` (31) + `_compatibility.csv` (31) | 62 |
| generated check files | 57 |
| prose (20) + 1 R comment | 21 |
| dated archive `specimen_crosswalk_combined_pre_split_2026-08-19.csv` | 8 |
| deliberate mentions | 4 |
| stragglers needing a hand fix: `__ShinyApp/data/glossary.csv` (1, clears on next `build_data.R`), `__merging_sleep/README__merging.md` L43 (1, hand-written prose) | 2 |
| **in-scope total** | **537** |
| excluded, no action: `Brodmann_1913_Verhandlungen.pdf` | 1 |

# Script repairs — 2026-09-27 (from the 2026-09-26 sweep: 15 failed)

The fixes were checked against the data files, the registry workbook and the source PDFs, but they have **not been run in R**, because R isn't available where the edits were made.

## Root causes
1. **Hyphenated second authors.** `__ReadMe.xlsx` column F now strips hyphens from the second author's name (the edit was made in Excel). That renamed two registry items:
   - `Mota_Herculano-Houzel_2015_TableS1` became `Mota_HerculanoHouzel_2015_TableS1`
   - `Schniter_Penaherrera-Aguirre_2026_data` became `Schniter_PenaherreraAguirre_2026_data`

   The scripts that used the old names, and `file_list.R`'s formula audit, were never updated.
2. **Sweep order.** Checks and merges ran before the registry tools and the per-paper builds, so each sweep checked the previous sweep's outputs.

## Fixes (14 files saved)
| Failing script | Cause | Fix |
|---|---|---|
| `_tools/file_list.R` | Its reference copy of the column-F formula still had the old version, so every F cell (F2 onwards) was reported as "non-canonical". | Its reference copy of the column-F formula and its R equivalent now match the workbook (hyphens stripped). The previous formula version is migrated if it is found. I checked that all 575 F cells now match, and that columns E and G–L also match. |
| `EvoM1_read_vocal_schniter.R` | Used the old Item name, so the lookup returned NA, the script read `NA.tsv`, and it failed with "differing number of rows: 0, 1". | Uses the new name, stops if the registry lookup fails, and checks the columns it expects. |
| `Schniter_PenaherreraAguirre_2026_data.R` | The snapshot file name was hard-coded to the pre-rename spelling. | The snapshot name is now built from the script's own name. |
| `cortical_areas_compiled.R` | Used the old Mota Item name. | The key is renamed in the script, in `standardized_term_cortical_areas.csv`, and in the Mota term file. |
| `brain_mass_compiled.R` | The Jacobs 2018 author and year were still blank, because `source_manifest.csv` had not been rebuilt yet. | Falls back to `__ReadMe.xlsx` for a missing author or year. |
| `Baron_etal_1996_Table32.R` | My earlier fix missed its second filter (on the Table 10 snapshot). | Same text-comparison fix applied to that filter. |
| `Heffner_etal_1969_ResultsText.R` | The snapshot's last field (`Results, Discussion and Summary (p. 13, 16, 17)`) contains commas but wasn't quoted, so the file read as 5 columns. | The field is now quoted in the snapshot CSV. The text is unchanged and the script is untouched. |
| `Ridgway__1990_Table1.R` | `skip = 2` read the printed header row as data (a "Category" group containing text), and `n_max = 33` cut off the last two rows. | The data block is now found by its header line. It expects 35 rows. |
| `Tschudin__1998_Table2.5.R` | Same header-read bug, which made every volume column text. | Same approach, 44 rows. The next check would have stopped on **HUM 5**: 949.00 + 281.00 = 1230.00, but 1230.40 is printed (the dissertation's own Table 2.5, p. 59). It is now listed next to BOT 9 as a known printed discrepancy and noted in the README. |
| `_keys/resolve_taxonomy.R` | TIMEOUT: about 215 species with up to 4 web lookups each won't finish in 300 s. | Now **skipped in the sweep** (it's an on-demand tool). It also finds its own folder, and keeps earlier values when a lookup fails. |
| `run_all_scripts_v2.R` | Ran consumers before producers. | New order: `restore_registry_rows` → `file_list` → paper builds → trait tables → `build_data` → merges → keys/tools → checks. |
| `Jacob_etal_2021_TABLE1/2/3.R` | Registry rows missing (in an earlier state). | **No change needed.** The rows are now in the registry (rows 554–556). The new run order builds the tables before the checks. |
| `check_item_name_resolution.R`, `check_trait_authority.R` | Correct checks reporting real problems. | See "Still for the owner" below. |

## Still for the owner
- **Registry, 2 cells: trailing spaces.** The citations in rows 151 (Hakeem 2009) and 363 (Raghanti 2015) end in a space. This gives Item encoded values `10.1002%2Far.20829 _Table1` and `10.1007%2Fs00429-014-0792-y _Table1`, so the cell-morphology merge reports "TSV not on disk". **Fixed later on 2026-09-27:** I removed the trailing space from both citations. Row 151 now resolves to `10.1002%2Far.20829_Table1`; row 363 received the same edit, but I could only read back the first 200 rows, so check it resolves to `10.1007%2Fs00429-014-0792-y_Table1`. Rerun `Hakeem_etal_2009_Table1.R` and `Raghanti_etal_2015_Table1.R` so their files are written. (The 4 de Sousa 2008 rows also end in a space, but that doesn't affect their names.)
- **Nimchinsky 1999: two files with a stray space.** `10.1073%2Fpnas.96.9.5268 _Table1.tsv` and `…_Table2.tsv` were written with the same kind of space in the name. The registry now resolves them without the space, so rerun `Nimchinsky_etal_1999_Table1.R` and `_Table2.R`, then delete the two versions with the space.
- **Delete from `__Public/comparative-data/`:** `NA.tsv`, `zz_DELETE_ME_test_upload_simplename.tsv`, `zz_DELETE_ME_test_upload2.tsv`.
- **Delete** the temporary folder `_checks/_tmp_copilot_reads_DELETE_ME` and the file `_checks/script_failures_only_20260927_read_copy.csv`. They hold read-only copies I made for reading.
- **Trait authority:** `trait_authority.csv` has a row for `Brain_Mass_from_volume_or_ecv (g)`, but the app no longer serves this label. Rerun `_keys/build_trait_authority.R` after the brain-mass merge succeeds. If the label still doesn't come back, remove the row deliberately.

# Script repairs — 2026-09-26 (from the 2026-09-25 sweep, `_checks/script_failures_only.csv`)

The fixes were checked against the data files and the PDFs, but they have **not been run in R**, because R isn't available where the edits were made. Re-run the sweep to confirm them.

## Run order (the registry must be repaired before most scripts will pass)
1. `Rscript _tools/restore_registry_rows.R` (restores 7 lost Sheet1 rows and repairs the `TEST_PROBE_VALUE` row in place)
2. `Rscript _tools/file_list.R`
3. Delete `__Public/comparative-data/NA.tsv` (a stale file; see Heffner 2008 below)
4. `Rscript Heffner_etal_2008/Heffner_etal_2008_Table1.R` (writes its real TSV)
5. `Rscript Jacob_etal_2021/Jacob_etal_2021_TABLE1.R` (and TABLE2, TABLE3)
6. `Rscript __ShinyApp/build_data.R` (fills in the manifest's author and year for the Jacobs 2018 TSVs)
7. `Rscript __merging_brain_mass/brain_mass_compiled.R`
8. `Rscript _checks/check_item_name_resolution.R` (should exit 0)

## Fixes
| Script(s) | Cause | Fix |
|---|---|---|
| Baron_etal_1996 Table8/10/13/16/19/22/25/28/30/32/36/39/42/45/48/51 | `read.csv()` reads an `is_header` column holding only "TRUE"/"" as logical values (TRUE/NA). That makes `is_header != "TRUE"` NA on every species row, and indexing with NA blanks those rows, so the check stopped with "Unexpected missing species". | `is_header` is now compared as text, and blank or NA counts as not-a-header. |
| Baron_etal_1996_Table5.R (not in the failure list) | Same bug, but it failed silently: the saved CSV was 342 empty rows. | Same fix, plus a check that stops if the row count isn't 342 named species. |
| Baron_etal_1996_extract_snapshots.R | The regression guard compared 272 extracted rows with a frozen snapshot of 309 rows (272 species + 37 section-header rows). The write-out step would also have overwritten the header-preserving snapshots. | The guard now compares only species rows. Snapshots that already have section headers are checked against the extraction and left untouched. |
| Jacob_etal_2021_TABLE1/2/3.R | Their Sheet1 rows are gone. | Rows added to `restore_registry_rows.R`. The scripts themselves are unchanged. |
| _checks/check_item_name_resolution.R | The check worked as intended: it found 7 orphaned TSVs (Jacob 2021 T1–T3, Jacobs 2018 T3 and T5, Jacobs 1997 T1 and T2), `NA.tsv`, and a `TEST_PROBE_VALUE` row. | Registry rows restored. The Heffner 2008 row's citation is written back into the existing row. |
| __merging_brain_mass/brain_mass_compiled.R | The Jacobs 2018 TSV has no registry row, so the manifest's author and year were blank. `read.csv` read those as NA, so the paper folder came back as NA. | Blank or NA is now treated as "", no folder is ever guessed from a blank author, and the error message now names the missing registry row. |
| __ShinyApp/build_data.R | "expected =" is an error from the workbook reader that doesn't say which file failed. The online copies of all six trait workbooks and the registry read cleanly, so this was probably a read of a file still being written or synced. | Each workbook read now retries 3 times, then stops with the workbook's name. |
| _keys/build_variable_definitions.R | `add()` got an NA code or definition, and `tolower(NA) == "nan"` is NA, which `if` can't handle. | NA and empty values are skipped (the `gx()` helper is also protected against NA). |
| deMagalhães_etal_2024_anagedata.txt.R | `source()` used a path relative to the working directory. The loader also located itself from the calling script. The validator was called with argument names it doesn't have. | Script finds its own folder and the repo root. `load_dataset_builder.R` now uses the innermost `source()` frame to find itself. The validator call uses the correct arguments, and the script refuses to write `NA.tsv`. |
| Kruska_Rohrs_1974_Tables2–3.R (+ README) | The tolerance was too tight: 1 mm³. The paper prints "limbic structures" 2 mm³ above Septum + Hippocampus + Schizocortex for Sd5 and Sd31 (confirmed in the PDF, Table 3). That is rounding in the source. The README's "exact for all 10" claim was wrong. | Tolerance set to (k+1)/2 mm³ for a sum of k rounded parts, and the rounding differences are reported. The README now gives the correct counts. |
| Heffner_etal_2008_Table1.R (not in the failure list) | This script created `NA.tsv`: when its registry row lost its item name, it wrote `paste0(NA, ".tsv")`. | It now refuses to write when there is no Item encoded value. |

## Still for the owner
- `Heffner_Heffner_1992_c_TableI` is listed as "ROW REMOVED" in `registry_snapshot_changes.csv`. It was not restored because its contents are not known.
- The Python twin (`build_brain_mass_merge.py`) handles blank author/year the same risky way.

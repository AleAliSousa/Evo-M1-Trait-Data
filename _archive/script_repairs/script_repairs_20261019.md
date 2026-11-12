# Script repairs — 2026-10-19 (from the 2026-10-19 `run_all_scripts_v3.py` sweep: 19 R scripts failed, 1 timed out)

Every fix below was **run in R 4.5.3** on a copy of the repo (no `.git`, no PDFs), not just edited.
Test copy limitation: `rJava`/`tabulapdf` were not installed there, so `Burish_etal_2010_SupplementaryTable1.R` could not be re-run; it is untouched.

## Fixed (script bugs)
| Script | Cause | Fix |
|---|---|---|
| `BallesterosYáñez_etal_2006_Figure3A/3B/3C/Table1.R` (4) | The folder/file name is **NFD** (decomposed á, ñ) on macOS; the registry text is **NFC**. `match(item_name, Item name)` returned NA, so `!is.na(item_encoded)` failed. | `match(nfc(item_name), nfc(Item name))`, the same `nfc()` helper `deMagalhães_etal_2024_anagedata.txt.R` already uses. Table1 re-run: passes. |
| `__merging_body_ecology/body_ecology_compiled.R` | `_keys/variable_catalog.csv` has `role = NA` for the body-mass rows of **Pirlot_Kamiya_1982** and **Ridgway__1990**. `role_ay[[k]] %\|\|% "secondary"` only defaults NULL, so the NA role made `any(d_role == "primary")` NA inside `pool_one()`. | A blank/NA catalog role is no longer recorded, so those sources take the script's existing default `"secondary"`. Re-run: passes; the new long/wide outputs gain the Pirlot_Kamiya and Ridgway body-mass rows the crash had been blocking. |
| `__merging_volumes/check_species_name_splits.R` | `volumes_source_species_ids.csv` has no `name_source` column (only the `_select` file does), so `g$name_source[1]` was NULL and `data.frame()` failed. | `name_source` is NA when the column is absent; the "curated vs not" comparison uses `%in%`. Re-run: exits 0 and lists **7 genuinely split labels** (Ateles sp., Avahi laniger, Callicebus sp., Cebus sp., Crocidura occidentalis, Rhynchocyon stuhlmanni, Tarsius syrichta) in `volumes_species_name_splits.csv`. These are a review list, not a gate. |

## Moved to the sweep skip list in `run_all_scripts_v2.R` (not builds)
| Script | Why |
|---|---|
| `__merging_volumes/volumes_sample_metadata_Pirlot__1981.R` | Function library with a CLI that needs `REPO_ROOT` and `NEW_PRIVATE_CSV` arguments. |
| `__Finder/app.R` | Shiny app; reads `data/` relative to its own folder. |
| `_checks/find_orphan_R_scripts.R` | Exhaustive scripts × data-files scan; hits the 300 s limit in every sweep that logged it (unchanged since 2026-08-20). Run it on its own. |
| `_tools/snapshot_freeze.R` | New library/CLI (below). |

## Not broken: deliberate guards waiting for an owner decision (left as they are)
- `Elston_etal_2005_a_Table3/4/5/6.R` — "swapped source location still needs an owner resolution" / "existing public TSV requires owner reconciliation".
- `Heffner_Heffner_1992_c_ResultsText.R`, `Schmidt_etal_1984_text.R` — "existing public TSV requires owner conflict review".
- `__merging_volumes/volumes_compiled_select_DeCasien.R` — source-review file needs one row per listed primary source (a source was added to the catalog without a review row).
- `__merging_brain_mass/brain_mass_compiled.R` — no measurement basis for `10.1007%2Fbf00518633_Table2.tsv / brain_weight_g` (**Kruska_Rohrs_1974**, a new untracked folder). Add it to `ASSIGN` in `_keys/build_brain_size_basis.py`, re-run that builder.
- `Stephan_etal_1991_Table71.R` — `Stephan_etal_1991_Table71_snapshot.csv` has never existed (not in git history); the reader is ahead of its snapshot.

## Reported checks (correct, reporting real findings)
- `_checks/check_item_name_resolution.R` (exit 1): 8 orphaned TSVs, i.e. files in `__Public/comparative-data/` that no registry row claims. Two carry a stray space in the name (`10.1002%2Far.20829 _Table1`, `10.1007%2Fs00429-014-0792-y _Table1`, the trailing-space citations already on the 2026-09-27 owner list). Five are `10.1002%2Fajpa.1330380234_ResultsText`, `10.1016%2FB978-012370880-9.00004-9_ResultsText`, `10.1037%2F0735-7036.102.2.99_Table1`, `10.1121%2F1.1903415_Table1`, `10.1121%2F1.3284546_ResultsText`. The eighth is `NA.tsv` (a Heffner rodent audiogram table written when an `item_encoded` lookup was NA). Deleting `NA.tsv` is already on the 2026-09-27 owner list; nothing was deleted here.
- `_tools/check_naming.py` (exit 1): VERDICT FAIL, 303 in-scope P1/P2 findings.

## New: snapshot freeze (`_tools/snapshot_freeze.R`)
See the header of that file. Short version: a dated stamp in `__ReadMe.xlsx` → "Human visual check of snapshot" freezes the item's `*_snapshot.*` files.
The sweep skips scripts that would rewrite them, re-hashes after every script and restores any change, and `EVOM1_UNFREEZE=<Item name>` releases an item on purpose.
**33 scripts in the repo write snapshots** (extract-and-build in one script); they are the ones a freeze will skip. Splitting them into `*_extract_snapshot.R` + a reader (the pattern `Nguyen_etal_2019`, `Seymour_etal_2017`, `deSousa__2008` already use) removes the conflict.

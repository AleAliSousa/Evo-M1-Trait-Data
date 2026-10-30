# Script repairs — 2026-09-18 (against the 2026-09-18 17:47–18:20 sweep: 6 FAILED, 1 TIMEOUT, 395 SUCCESS, 17 SKIPPED)

Static check first: all 419 `.R` files `parse()` cleanly and all 32 `.py` files byte-compile, so every
defect below is a runtime one. No `.R` script was executed in the authoring sandbox (house rule) —
every edit is static and was re-parsed; **re-run `run_all_scripts_v2.R` in RStudio to confirm.**

## Fixed (code)

1. **`__merging_brain_mass/brain_mass_compiled.R`** — `Error in man_by_file[[fn]]: subscript out of
   bounds`. `man_by_file` was a *named integer vector*; `[[` on an atomic vector errors for an absent
   name (only lists return `NULL`), so the first public TSV not yet in
   `__ShinyApp/data/source_manifest.csv` halted the build. Replaced with `match(fn, manifest$file)`
   + `is.na()` guard (the Python twin already used `dict.get`). Missing manifest rows now fall
   through to blank author/year as the code intended.

2. **`Nimchinsky_etal_1999/Nimchinsky_etal_1999_extract_snapshot.R`** — `table not found on the
   page: section#T1 table`. The live PMC page still carries `section#T1`/`#T2` (fetched and checked
   the same evening: 49 + 6 rows, bold on exactly Hominoidea/Pongidae/Hominidae and the five
   species, both tables identical to the frozen snapshots). PMC had served the unattended request a
   non-article page; `read_html(url)` hides the HTTP status so only the selector failed. Fetch now
   goes through `curl::curl_fetch_memory` with a status check, a Table-1 sanity check and one retry,
   and freezes the page as `Nimchinsky_etal_1999_PMC21853.html` on the first good fetch. That
   frozen copy is now in the folder (the script prefers it), so re-runs are offline. Both ReadMes
   note the frozen page.

3. **`_checks/find_csv_tsv_creators.R`** — TIMEOUT (>300 s). The inner loop re-read every script
   from the OneDrive mount once per data file (~1500 × ~420 ≈ 630 k `readLines()` calls). Scripts
   are now read once into memory and a whole-file `grepl()` on the stem pre-filters candidates
   before line-level matching. Same output columns and ranking. A standalone replica of the new
   search over the real tree ran in 24 s.

4. **`Walhovd_etal_2011/Walhovd_etal_2011.R`** — wrote its public TSV with a literal name
   `…neurobiolaging.2009.05.013_normative.tsv`, but the registry's Item number is "normative
   volumes" → key `…_normativevolumes`, so `check_item_name_resolution.R` listed the file as
   orphaned. Same class as the Barger 2012 fix (2026-08-29). Script now looks up `Item encoded`
   (Barger/Heffner pattern, warns and skips if absent); the on-disk TSV was renamed to
   `…_normativevolumes.tsv`; the folder ReadMe updated. Nothing in `__merging_*` or `_keys`
   referenced the old name (`__ShinyApp/data/source_manifest.csv` is a regenerated export and
   will pick up the new name on its next build).

5. **`__merging_volumes/compare_to_reference.R`** — `reference_csv not found: …/test_qc/…/
   Stephan_primates.csv`. The reference is an external, hand-assembled QC table outside the repo
   and no longer at that path. Path is now overridable via `EVOM1_REFERENCE_CSV`, the guard says
   what to do, and the script is skip-listed in the sweep (see 7) — same treatment as
   `combine_trees.R`.

6. **`vertebrate_opsin_explorer/setup_data.R`** — added the self-locating `setwd()` block (its
   inputs are relative to its own folder, so `Rscript` from the repo root could never find
   `raw_VPOD/vert_meta.tsv`). The `library(ggtree)` failure itself is an install matter
   (Bioconductor) on the running machine, not a script defect; see 7.

7. **`run_all_scripts_v2.R` SKIP_PATTERNS** — added `__merging_volumes/compare_to_reference.R`
   (external input; false FAILED otherwise) and `^vertebrate_opsin_explorer/` (contributed Shiny
   app: `app.R` ends in `shinyApp()` like `__ShinyApp/app.R`; `setup_data.R` needs ggtree/rtrees/
   piggyback and downloads from GitHub releases; its VPOD input `raw_VPOD/vert_meta.tsv` is not
   in the repo). Expected next sweep: 0 FAILED from these seven, provided PMC is reachable or the
   frozen page is present (it is).

## NOT fixed — registry/data items for the owner (the check that reports them is working correctly)

`_checks/check_item_name_resolution.R` exits 1 while any public TSV is claimed by no Sheet1 row.
Five were listed on 2026-09-18; Walhovd (above) is resolved. The remaining four are not script bugs:

- **`10.1073%2Fpnas.1911264116_ERABIS.tsv`** (Mackes 2020) — registry key is
  `…_ERABIS(cortical)` (Item number "ERABIS (cortical)"); the sibling `…_subcortical.tsv` matches.
  No build script exists in `Mackes_etal_2020/` any more (the `_analysis.R` that
  `csv_tsv_candidate_creators.csv` names is gone). Fix either side: Item number → "ERABIS", or
  rename the file to the key.
- **`10.1093%2Fcercor%2Fbhr033_authordata.tsv`** (Karlsen & Pakkenberg 2011) — registry key
  `…_authordata(groupmeans)`; no writer script (`Table2.R` and `reported_values.R` write the other
  two TSVs, with literal names that happen to match). Same choice as above.
- **`10.1159%2F000121494_TableI.tsv`** (Heffner & Masterton 1983) — the folder is fully built
  (script, CSV, snapshot, ReadMe) and its script looks up `Item encoded` correctly, so a Sheet1
  row *existed* when the TSV was written (11 Sep). There is **no Heffner & Masterton 1983 row in
  Sheet1 now**, and none in `_checks/registry_snapshot.csv` either — a row added after the last
  snapshot and since lost, or a merged fork contribution never registered. Needs a row (then
  `_tools/file_list.R`); add it to `_tools/restore_registry_rows.R`'s ROWS list if restoring.
- **`10.6084%2Fm9.figshare.c.3899422.v1_Dataset1.tsv`** (Olkowicz 2016) — the 2026-08-29 report's
  option (b) has evidently been taken: the PNAS-keyed `10.1073%2Fpnas.1517131113_DatasetS1.tsv`
  now exists (18 Sep) and matches the registry. The figshare-named file is a stale duplicate, but
  `__merging_body_ecology/*.csv` and `__ShinyApp/data/body_ecology_long.csv` still cite it by
  name. Finish (b): rebuild `__merging_body_ecology` (and the app export), then retire the
  figshare file.

## Portability debt (passes on the owner's machine; fails on any clone)

39 scripts hard-code `~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data`
or `/Users/crossmodal/...` (`setwd()`, `repo <-`, `here <-`, or direct `read_excel()` paths):
`Barger_etal_2014`, `Granatosky__2018`, `Karbowski__2007`, `Lewitus_etal_2013`,
`MedinaGonzález__2026` (×3), `Upham_etal_2019`, `Wilman_etal_2014`, `Wimberly_etal_2021`,
18 readers in `____EvoM1_TraitTable/`, `__merging_cellcounts` (×2), `__merging_cerebral_metabolic_rate/
standardized_term.R`, `__merging_sensory` (×2), `__merging_trees` (×2), `__merging_volumes/
standardized_term.R`, `_keys/build_variable_catalog.R`, `_keys/resolve_taxonomy.R`
(`compare_to_reference.R` is handled above). The house replacement is the self-locating root
finder already used by `run_all_scripts_v2.R` (`--file=` → rstudioapi → walk up to
`__ReadMe.xlsx`). Left as-is in this pass because they are not failing and the change touches 39
files; worth a dedicated pass before the next RA fork is merged.

# Script repairs — 2026-08-29 (against the 2026-08-29 19:11 sweep, 9 FAILED)

All four "needs your call" items from the 2026-07-31 triage now pass (behaviour, DeCasien,
Barger Table3 parse, Seymour officer). This pass addressed the CURRENT failures. No R in the
authoring sandbox — every edit is static; **re-run the sweep in RStudio to confirm.**

## Fixed (code)
1. **`Barger_etal_2012/Barger_etal_2012_Table3.R`** — wrote its public TSV as
   `Barger_etal_2012_Table3.tsv` (plain item name) instead of the registry's DOI-coded
   `10.1002%2Fcne.23118_Table3.tsv`. This is what check_item_name_resolution reported as an
   "orphaned TSV / lost row" — the row (15) was never lost; the FILE was mis-named. Script now
   looks up 'Item encoded' (Olkowicz-script pattern); the on-disk TSV was renamed to the
   DOI-coded name (grep confirmed nothing referenced the old name).
2. **`deJager_etal_2022/deJager_etal_2022.R`** — read its CSVs relative to the caller's cwd;
   added the house self-locating block.
3. **`DosSantos_etal_2020/DosSantos_etal_2020_Table1_check.R`** — read the unpublished
   microglia xlsx from its own folder; the file lives in the private repo. Now resolved via
   `_helpers/restricted_data.R` (graceful, actionable stop when the private repo is absent).
4. **`____EvoM1_TraitTable/EvoM1_read_gait_excursion_medina.R`** — hardcoded absolute setwd
   replaced with the self-locating block, plus an explicit guard: stops with the
   Zenodo-restricted explanation instead of a bare file() error. Also skip-listed (below).
5. **`_keys/build_variable_catalog.R`** — `__ShinyApp/data/variable_definitions.csv` (an app
   EXPORT carrying its own `domain` column) was being swept up as a paper definitions file and
   collided with `anatomy_reference.csv`'s `domain` in the join → "object 'domain' not found".
   `__ShinyApp/` and `__Public/` excluded from the definitions glob.
6. **`_checks/check_item_name_resolution.R`** — its orphan message asserted "a registry row was
   lost"; both of today's orphans were actually mis-named/re-keyed FILES. Message now lists the
   three possible causes instead of asserting one.
7. **`run_all_scripts_v2.R` SKIP_PATTERNS** — added: the two dated one-shot registry editors
   (`__register_remaining_builds_20260824`, `__update_remaining_builds_20260815`; guards
   intentionally fail after application — same class as the already-skipped 20260815
   cortical-layer one-shot), `source_data/` (frozen author code, e.g. Heuer 2023's
   `load_data.R` — never run someone else's shipped analysis in a sweep), and the Medina reader
   (externally blocked).

## Fixed (workbook — backups `__ReadMe.pre_K62fix_20260829.bak.xlsx`, `__ReadMe.pre_finlayflag2_20260829.bak.xlsx`)
8. **K62 canonicalized** — the deSousa 2010 Sup Table 2 row's Item-name cell held a legacy
   `IF(P62="N", O62, "write file name")` formula evaluating to the literal "write file name",
   which made `_tools/file_list.R` refuse to run ("Non-canonical Sheet1 naming formula(s): K62").
   Replaced with the canonical TEXTJOIN formula; cached value now `deSousa_etal_2010_SupTable2`.
   file_list.R is unblocked (re-run it — the AUTO TSV column is stale).
9. **Finlay whole-paper flag re-applied** (now cell AD80). The first application was lost when a
   newer workbook version (Todorov registration + in-progress Chaplin/Veilleux rows) synced over
   it — see "concurrency" below.

## NOT fixed — needs the owner
- **Olkowicz TSV key mismatch.** Registry row 232 derives `10.1073%2Fpnas.1517131113_DatasetS1`
  (col C is now empty, so the J-formula falls back to the citation's PNAS DOI), but the built
  TSV — and every `body_ecology` source string citing it — uses
  `10.6084%2Fm9.figshare.c.3899422.v1_Dataset1.tsv` (figshare DOI *and* "Dataset1" vs
  "DatasetS1"). At build time col C evidently held the figshare DOI and was cleared later.
  Two consistent fixes, pick one: (a) restore col C = the figshare DOI and set Item number to
  match "Dataset 1" (registry re-joins the existing file and the body_ecology references), or
  (b) keep the PNAS key, rename the TSV, and regenerate `__merging_body_ecology` +
  `__ShinyApp/data/body_ecology_long.csv` (filename-keyed consumers!). Do in Excel/R, not by
  XML surgery — cached formula values must recalc.
- **Two in-progress registry rows** (`Chaplin_etal_2013_`, `Veilleux_Kirk_2014_`) have blank
  Item numbers → trailing-underscore keys, the known `read_item()` failure fingerprint. Fine
  while mid-entry; they need Item numbers before any build refers to them.

## Concurrency lesson
The workbook changed between my first flag edit and this pass (a newer version synced in,
without the flag; columns also shifted — "Flags active (skips)" moved AE→AD). When Claude and
Excel edit `__ReadMe.xlsx` in the same period, whoever saves last wins silently. Rule of thumb:
close Excel before asking for a workbook edit, and re-verify any recent registry edit after a
sync (this file's §8–9 were verified against the current version).

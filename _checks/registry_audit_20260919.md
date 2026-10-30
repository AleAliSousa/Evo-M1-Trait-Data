# Script repairs & Frahm re-verification — 2026-09-19

Bounded follow-up to `_checks/script_repairs_20260918.md`, which explicitly disclosed it
never ran a single R script (house rule at the time: static edits only, re-verify in
RStudio). This pass actually ran everything, which is why several of yesterday's fixes
needed a second round: a fix that only *looks* right against the code can still be wrong
against the data.

## 1. Frahm_etal_1984 Table 1 footnote (prior session) — re-verified

`former_name_stephan1981` (species-name synonymy vs Stephan et al. 1981, per the printed
Table 1 footnote) is wired into `Frahm_etal_1984_Table1.R`, confirmed against the six
Stephan_etal_1981 table files, and flows correctly downstream: re-ran
`__merging_volumes/volumes_compiled.R` end to end and confirmed 158 Frahm_etal_1984_Table1
rows land in `volumes_long.csv` under the `Stephan_collection` tier with a resolving
citation in `volumes_source_citations.csv`.

## 2. The 7 scripts flagged FAILED/TIMEOUT in the 2026-09-18 sweep — all resolved

| script | 2026-09-18 status | now | notes |
|---|---|---|---|
| `__merging_brain_mass/brain_mass_compiled.R` | FAILED | SUCCESS | see §3 |
| `__merging_volumes/compare_to_reference.R` | FAILED | SKIPPED (by design) | optional QC differ; external reference CSV, not a repo file |
| `_checks/check_item_name_resolution.R` | FAILED | FAILED (intentional) | see §4 — real findings, not a crash |
| `_checks/find_csv_tsv_creators.R` | TIMEOUT | SUCCESS | see §5 |
| `Nimchinsky_etal_1999/Nimchinsky_etal_1999_extract_snapshot.R` | FAILED | SUCCESS | see §6 |
| `vertebrate_opsin_explorer/app.R` | FAILED | SKIPPED (by design) | contributed Shiny app; needs ggtree/rtrees/piggyback |
| `vertebrate_opsin_explorer/setup_data.R` | FAILED | SKIPPED (by design) | same |

## 3. `brain_mass_compiled.R` — three basis-key gaps behind the crash fix

Yesterday's crash fix (`man_by_file[[fn]]` subscript-out-of-bounds -> `match()` + `is.na()`
guard) was correct but, once actually run, surfaced three separate gaps in
`_keys/build_brain_size_basis.py`'s `ASSIGN` table that had been silently blocking the
merge one at a time:

- **Butti_etal_2009** `brain_mass_mg` had no basis entry at all. Its own definitions file
  states the values are secondary, compiled from Marino et al. (2004) and Hof et al.
  (2005) — added as `mass_compilation_unspecified`.
- **Manger__2006**: the `ASSIGN` key was stale (`brain_mass_g`), but the harvested/current
  column is `brain_mass_mg` (the project-unit column; the source is printed in g and
  ×1000'd for storage). The old key never matched, so this source's basis silently never
  fired. Fixed both occurrences to the correct key.
- **Zilles_Rehkämper_1988** Table 12-1 `Brain_weight_g` had no basis entry (only Table
  12-2 has a definitions file). Added as `mass_compilation_unspecified`, per the folder's
  own README, which quotes the chapter's explicit caution about unstated fixation state.
  This entry also needed the folder's on-disk Unicode NORMALIZATION FORM (decomposed
  "a" + combining diaeresis, not the composed "ä"), or the key silently never matches —
  worth remembering for any future key referencing an accented paper folder name.

Re-ran `_keys/build_brain_size_basis.py` then `brain_mass_compiled.R`: now attributes all
2613/2613 merge rows and completes (1942 pooled cells, 1691 species).

## 4. `check_item_name_resolution.R` — real findings, not a bug

This script's non-zero exit *is* its designed behavior when it finds orphaned TSVs; it is
not a crash. Started at 5 orphaned TSVs (1 already resolved before this session started).

**Fixed one** — `10.6084%2Fm9.figshare.c.3899422.v1_Dataset1.tsv` was NOT an Olkowicz file
(despite superficially reading that way from nearby PNAS DOI numbers in the earlier
diagnosis): it is a byte-identical, stale duplicate of **Powell_etal_2017**'s correctly
registry-keyed `10.1098%2Frspb.2017.1765_Dataset1.tsv`, confirmed by diff and by Powell's
own README (which documents the figshare DOI as an old naming convention, superseded by
the paper's journal DOI). No script referenced it by name, but
`__merging_body_ecology/body_ecology_compiled.R` scans the whole `comparative-data` folder
by extension, so it was silently double-counting Powell's 289 species rows under two
source labels. Deleted (moved to Trash, user-approved) and rebuilt the body-ecology merge.

**3 remaining — registry-side, need an owner decision, left unfixed:**

- `Mackes_etal_2020_ERABIS(cortical)` and `Karlsen_Pakkenberg_2011_authordata(groupmeans)`:
  both registry rows already show `"notfound"` in their own TSV column — a known gap. The
  actual built files on disk (`..._ERABIS.tsv`, `..._authordata.tsv`) are missing the
  parenthetical suffix the registry's Item-encoded key carries. Likely a
  parenthesis-stripping step in whatever wrote the TSV filename. Needs a registry-side
  decision (rename the file to match, or update the registry key) — did not touch
  `__ReadMe.xlsx`.
- `Heffner_Masterton_1983_TableI` (DOI `10.1159/000121494`): a fully built paper folder
  (script, snapshot, csv, README all present, 21 species) with **no registry row at all**.
  Needs `_tools/restore_registry_rows.R` (add the row) then `_tools/file_list.R`, per the
  checker's own guidance — an owner call, not made here.

## 5. `find_csv_tsv_creators.R` — timeout, then a second bug once it could finish

Yesterday's O(files × scripts) -> read-once-per-script performance fix was correct, but had
never been run either. Running it surfaced a locale bug: `grepl()`/`grep()` on
regex-escaped filenames containing non-ASCII characters (e.g. `BarbeitoAndrés_...`) throw
"invalid regular expression" under the sandbox's default C locale. Fixed with
`useBytes = TRUE` on the three affected calls. Now completes in ~26s (well under the 300s
timeout).

## 6. `Nimchinsky_etal_1999_extract_snapshot.R` — three more bugs behind the scrape fix

Yesterday's frozen-page + retry fetch was correct, but running the parser for the first
time surfaced three bugs, all now fixed with both tables verified to match their frozen
snapshots exactly:

- The sandbox's C locale made `gsub()` error on the script's literal non-breaking-space
  character, and made `[[:space:]]` fail to recognize Unicode whitespace (EM SPACE table
  indentation, THIN SPACE around "±"). Fixed with an `LC_CTYPE` guard (tries
  `en_US.UTF-8`/`en_GB.UTF-8`/`C.UTF-8`/`UTF-8`) at the top of the script.
- Confirmed against the actual committed frozen snapshot that taxonomy-tree indentation is
  fully collapsed away, not preserved — an assumption I made and then had to walk back
  once I checked the real committed file instead of reasoning from the live page alone.
- I introduced and then reverted an incorrect `nzchar(NA)` -> `is.na()` change based on a
  flawed manual reproduction of `read_tbl()`; the real function pads short rows with `""`,
  not `NA`, so the original `nzchar()` check was already correct.

## 7. The sweep runner itself was silently truncating every run

Re-running `run_all_scripts_v2.R` for real (not just the 7 targeted scripts) uncovered a
bug in the runner, not in any individual paper script: `system2()` cannot translate a
`shQuote()`'d path containing a non-ASCII filename (`BarbeitoAndrés_etal_2019`) to UTF-8
under the C locale, and the *entire sweep* halts there — meaning no script past #9 of 419
had ever actually been exercised in this environment, regardless of what the log said.
Fixed with the same locale guard, applied both via `Sys.setlocale()` (this process) and
`Sys.setenv(LANG=, LC_ALL=)` (so every child `Rscript` the runner spawns inherits it too —
`Sys.setlocale()` alone does not propagate to child processes).

The now-complete 419-script sweep found 22 FAILED beyond the 7 above (21 new +
`check_item_name_resolution.R`'s intentional one). All 21 new ones trace to this sandbox's
R environment lacking packages the scripts need (`rJava`, `taxizedb`, `zoo`, `docxtractr`,
`officer`, `rentrez`), one hardcoded absolute path unique to the owner's machine
(`EvoM1Gen_NoEstimates.R`), and one blocked network fetch (`Raghanti_etal_2015` ->
springer.com) — not code or repo defects. The original 2026-09-18 sweep (run on the
owner's own machine) reported 395/402 SUCCESS, consistent with those packages being
installed there. **Explicitly out of scope for this pass** (package installs across a
shared R environment weren't part of the approved bounded task) — listed here so the
owner can decide whether to install them or leave these scripts as manual/occasional runs.

## Files touched

- `_keys/build_brain_size_basis.py` — 3 ASSIGN entries added/fixed (§3)
- `__merging_brain_mass/brain_mass_compiled.R` — unchanged this pass (fix already applied
  2026-09-18); `_keys/brain_size_basis.csv` regenerated
- `Nimchinsky_etal_1999/Nimchinsky_etal_1999_extract_snapshot.R` — locale guard (§6)
- `_checks/find_csv_tsv_creators.R` — `useBytes = TRUE` on 3 calls (§5)
- `__merging_volumes/source_citations.R` — `useBytes = TRUE` on `norm()` (needed for
  Frahm re-verification to complete; hit the same locale bug on an unrelated source name)
- `run_all_scripts_v2.R` — locale guard, process + child env (§7)
- `__Public/comparative-data/10.6084%2Fm9.figshare.c.3899422.v1_Dataset1.tsv` — deleted
  (stale Powell duplicate, §4)
- `__merging_body_ecology/*` — rebuilt after the deletion above
- `__merging_volumes/volumes_long.csv`, `volumes_wide.csv`, and related outputs — rebuilt
- `_checks/script_execution_log.csv`, `_checks/script_failures_only.csv` — refreshed from
  the full 419-script sweep

## Not done (explicitly out of the approved bounded scope)

- The 57 built-but-unwired paper folders identified in the initial audit — untouched, as
  agreed before starting.
- The 21 sandbox-environment package/path/network failures in §7 — reported, not fixed.
- `Zilles_Rehkämper_1988_Table12-2` — flagged by `volumes_compiled.R` as having no
  `__ReadMe.xlsx` citation (a different table from the Table 12-1 fixed in §3) — a
  pre-existing registry gap, noted here for the priority list.
- The 3 remaining orphaned-TSV registry gaps in §4 — need an owner decision on
  `__ReadMe.xlsx`, which this task's convention says not to edit unilaterally.

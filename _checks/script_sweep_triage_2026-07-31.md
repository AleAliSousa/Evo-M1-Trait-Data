# Script sweep triage — 2026-07-31

Source: `_checks/script_execution_log.csv`, written by `run_all_scripts_v2.R`.
The sweep covered 275 of 277 `.R` files before being interrupted.

| Status | Count |
|---|---|
| SUCCESS | 249 |
| FAILED | 14 |
| never reached (logged as `NA`) | 11 |
| in flight when killed (`RUNNING`) | 1 — `update_shinyapp.R` |

The 11 unreached scripts are simply the tail of the alphabetical list (Weaver → Zilles);
nothing is known about them either way. `update_shinyapp.R` is what stalled the sweep —
it publishes to shinyapps.io and never returns. It is no longer present in the tree.

## The rstudioapi problem is already solved

The earlier handoff listed ~10 scripts failing with "RStudio not running". That is fixed.
All 211 scripts that reference `rstudioapi` now wrap it in
`requireNamespace(...) && rstudioapi::isAvailable()` behind the portable
`commandArgs` → `sys.frames()[[1]]$ofile` → rstudioapi ladder. A repo-wide check for
`getActiveDocumentContext` without an `isAvailable()` guard returns nothing.
Two of the four "code bugs" from that handoff (`Baron_etal_1990_Table1.R` `:=` /
data.table, and `predates_1988` in the Zilles provenance check) also now pass.

---

## Fixed in this pass

| Script | Root cause | Fix |
|---|---|---|
| `__ShinyApp/app.R` | **Parse error.** Lines 187–188 had `tax_order <- if (...) setNames(...)` with `else` on the next line at top level. R closes the expression at the newline, then hits a bare `else`. The whole app was unsourceable. | Braced the `if`/`else`. |
| `__flow_comparison/Seymour_Boyer_flow_combined.R` | `deframe()` called; `tibble` never attached (readr/dplyr/tidyr/stringr only). | Added `library(tibble)`. |
| `_checks/check_Zilles_Rehkämper_1988_provenance.R` | `replace_na()` called; `tidyr` never attached. | Added `library(tidyr)`. |
| `Heffner_Masterton_1983/Heffner_Masterton_1983_TableI.R` | `replace_na()` called; `tidyr` never attached. | Added `library(tidyr)`. |
| `__merging_body_ecology/body_ecology_compiled.R` | `dirname(sys.frame(1)$ofile)` — no frames exist under `Rscript`, so this errors ("not that many frames on the stack"). It also used `%||%` one line *before* defining it. | Replaced with the house self-locating block, then ascend to the folder containing `__Public`. |
| `__merging_brain_mass/brain_mass_compiled.R` | `repo <- if (dir.exists("__Public")) "." else ".."` — cwd-dependent, so `Rscript` from anywhere else failed on `../__ShinyApp/data/source_manifest.csv`. | Same self-locating block. |
| `Kochiyama_etal_2018/Kochiyama_etal_2018_reconcile_relative_volumes.R` | Reads `Kochiyama_etal_2018_Figure3.csv`, which no longer exists — Figure 3 was split into separate 3A / 3B items (`Kochiyama_etal_2018_ReadMe_split.md`). The `NT_rel`/`EH_rel`/`MH_rel` columns it needs moved to Figure3A, byte-identical in value. | Point at `Kochiyama_etal_2018_Figure3A.csv`. |

`run_all_scripts_v2.R` was also hardened:

- **Skip list.** `deploy_shiny.R`, `update_shinyapp.R`, `__ShinyApp/app.R` (ends in
  `shinyApp()`, which blocks forever under `Rscript`) and `_tools/__edit_all_directories.R`
  (mass rename/find-replace utility) are never executed. Each logs as `SKIPPED` with its reason.
- **`NOT_RUN` instead of `NA`** as the pre-filled status, so an interrupted sweep is
  unambiguous in the log rather than indistinguishable from a missing value.
- **`TIMEOUT`** recorded separately from `FAILED` (exit 124 at the 300 s limit).
- **`EVOM1_ONLY`** environment variable takes a regex and runs only matching paths, e.g.
  `EVOM1_ONLY='merging_volumes' Rscript run_all_scripts_v2.R`.

Verification: R is not installable in the sandbox this pass was done in (no R, no root,
no CRAN reachability), so nothing here was executed. Every modified file was checked
statically for brace/paren/string balance and top-level dangling `else` — 278 files,
0 issues — and the skip-list regexes were simulated against the real path list
(matches exactly the 4 intended files).

---

## Not fixed — needs your call

### 1. `__merging_behaviour/behaviour_compiled.R` — `group_modify()` rejects `Measure`

```
Error in `group_modify()`: The returned data frame cannot contain the original
grouping variables: Measure.
```

Line 138 groups by `Species, Measure`; `resolve_one()` (line 122) returns a tibble that
includes a `Measure` column of its own. `group_modify()` forbids that, because the
grouping keys are re-attached from `.y`.

Three ways out, in increasing invasiveness:

- drop it from the returned tibble — delete `Measure = measure,` from the `tibble(...)` call
  and let `group_modify` supply it, then confirm `relocate(Species)` still yields the
  intended column order;
- keep `resolve_one()` untouched and group by `Species` only, passing measure through `.x`;
- switch to `reframe()`, which has no such restriction.

The first is smallest but changes column order in `behaviour_long.csv`; worth checking
against the committed copy before you accept it.

### 2. `__merging_volumes/volumes_compiled_DeCasien.R` — term-map key mismatch

```
Error: paper_long('Stephan_etal_1970_Tables1-6'): no measured columns matched the term map.
df cols: Species, body_weight_g, brain_weight_mg, total_brain_net_mm3, medulla_oblongata_mm3, ...
```

Line 66 registers the item as `Stephan_etal_1970_Tables1-6` and line 92 points it at the
combined TSV `ISBN%3A0390672505_Tables1-6`. But `standardized_term_volumes.csv` is keyed
per table — `Stephan_etal_1970_Table1`, `_Table2`, … (rows 214+) — so the lookup for the
combined item finds nothing and `paper_long()` stops at line 303.

The mappings themselves already exist and cover the columns in the error message
(`total_brain_net_mm3` → `Total_brain_net_volume_Vol.mm3`, etc.). So this is a key
problem, not a missing-data problem: either add `Stephan_etal_1970_Tables1-6` rows as the
union of Table1–6, or give the lookup a fallback that unions the per-table keys when the
combined key is absent. This sits inside the DeCasien merge, so the
`decasien-volume-merge-update` skill is the right vehicle — it knows the
no-double-counting rules and regenerates the comparison outputs.

### 3. `Barger_etal_2012/Barger_etal_2012_Table3.R` — row-count mismatch

```
Error in `[[<-.data.frame`(...): replacement has 5 rows, data has 7
```

Line 64 assigns `round(ms[, 1] * 1e6)` into a 7-row `out`, but `ms` has 5 rows. `ms` comes
from parsing `"13.27 (3.7)"`-style mean/SD strings; two of the seven rows evidently don't
match the pattern (blank, dash, or "n.a."), and the parse drops them rather than emitting
`NA`. Fix is to make the mean/SD extraction row-preserving — return `NA_real_` for
non-matching cells so `nrow(ms) == nrow(out)` always. Check the published Table 3 for which
two nuclei are blank before deciding whether `NA` is the right value.

### 4. `__imputing_cellcounts/cellcounts_imputations_diagnostic.R` — all-NA density

```
Error in density.default(x = c(NA_real_, NA_real_, ...)): need at least 2 points to
select a bandwidth automatically
```

A diagnostic `densityplot` is called on a variable with fewer than 2 non-missing values.
Guard the plotting loop with `sum(!is.na(x)) >= 2` and report the skipped variables
instead. Diagnostic-only — no effect on imputed values.

### 5. `Seymour_etal_2017/Seymour_etal_2017_TableS1_snapshot_extract.R` — missing package

`library(officer)` fails: the package isn't installed. Environment, not code —
`install.packages("officer")`. Worth converting to the pattern already used in
`DeCasien_Higham_2019_references_braindata.R`, which does `requireNamespace()` and stops
with an actionable message naming the install command.

### Failing by design — leave alone

- `_keys/combine_trees.R` — stops with `Need _keys/phylo_placental.* and _keys/phylo_marsupial.*
  (see PHYLO_SETUP.md)`. The trees aren't in the repo; the script is telling you so correctly.
- `_keys/extend_phylo.R` — stops with `extend_phylo.R is deprecated: use a published source
  tree, not imputation`. A deliberate tombstone.

Both will always appear as `FAILED` in a sweep. If that noise is unwanted, they are
candidates for the `SKIP_PATTERNS` list rather than for repair.

---

## Separate observation — 20 scripts hardcode an absolute `setwd()`

Not a current failure (they pass on this machine) but they break on any clone:

```
setwd("/Users/crossmodal/.../Evo-M1-Trait-Data/<folder>")
```

Almost all are `*/comparison/*_compare_to_*.R` QA scripts, plus `_keys/resolve_taxonomy.R`,
`_keys/build_variable_catalog.R`, and `_checks/check_Zilles_Rehkämper_1988_provenance.R`.
The repo already has the portable replacement in 211 other files, and
`_tools/__edit_all_directories.R` (dry-run by default) is the tool for applying it in bulk.
Relevant if RAs are contributing via forks.

---

## Re-running

```sh
cd "/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
Rscript run_all_scripts_v2.R
```

To confirm just this pass's fixes without a full sweep:

```sh
EVOM1_ONLY='app\.R|Seymour_Boyer_flow_combined|check_Zilles_Rehkämper_1988_provenance|Heffner_Masterton_1983_TableI|body_ecology_compiled|brain_mass_compiled|reconcile_relative_volumes' \
  Rscript run_all_scripts_v2.R
```

Note that `app.R` is on the skip list, so it will report `SKIPPED` rather than run. To
check the parse fix alone: `Rscript -e 'invisible(parse("__ShinyApp/app.R"))'` — silence
means it parses.

Before the sweep, be aware the working tree currently holds ~53 uncommitted regenerated
outputs (CSV / XLSX / `__ReadMe.xlsx` / the log itself) from the previous run. Commit or
stash them first if you want a clean diff of what the next sweep changes.

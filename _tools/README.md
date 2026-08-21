# `_tools/` — things that change something

**The rule: a tool acts. If it only looks and reports, it belongs in
[`_checks/`](../_checks/README.md).**

The two folders drifted together because a check and a tool both end up writing a
file. The distinction is *what* they write: a check writes its own report, a tool
writes the repo — `__ReadMe.xlsx`, a paper folder, a `__Public/` TSV, a merge
output.

Neither folder uses the `__` prefix. That prefix marks things in the repo **root**,
to separate them from the paper folders; inside a subfolder it means nothing. Two
dated one-offs still carry it for historical reasons.

Sourced libraries used to live here too. They now have their own folder,
[`_helpers/`](../_helpers/README.md), because they are neither checks nor tools:
nothing in here is `source()`d by anything else, and nothing in `_helpers/` is
meant to be run.

## Action scripts — run deliberately

| Script | Does | In the sweep? |
|---|---|---|
| `file_list.R` | fills Sheet1's generated `E:M` columns and their cached values; rebuilds the `AUTO_Public_TSV_FileList` sheet from the TSV directory; reports orphan TSVs | yes — idempotent |
| `restore_registry_rows.R` | puts back registry rows that have gone missing, and clears a stranded value in column C | yes — idempotent, skips rows already present |
| `build_cortical_layer_definitions.R` | regenerates the cortical-layer definition tables | yes |
| `__update_remaining_builds_20260815.R` | one-off registration; finds its rows with `match()` on Item name, so re-running is safe | yes |
| `__edit_all_directories.R` | mass find/replace and rename across the repo | **no** — skipped; run deliberately |
| `__register_cortical_layer_builds_20260815.R` | one-off registration of three cortical-layer builds | **no** — skipped; see the warning below |

A tool that stays in the sweep must be **idempotent**: running it twice must do
nothing the second time. Two here are not, and are in `run_all_scripts_v2.R`'s
`SKIP_PATTERNS` with the reason recorded next to the pattern.

## Never address a Sheet1 row by number

`__ReadMe.xlsx` Sheet1 **re-sorts itself**. A hard-coded row number is therefore a
time bomb, and one went off:

`__register_cortical_layer_builds_20260815.R` writes Jacobs, Johnson and Peruffo
into rows **299, 300 and 301** by number, and it used to run on every sweep. After
a re-sort those numbers addressed different sources, so it overwrote them. It also
writes only the fields in its own list, so a column it never names — notably C,
"DOI if different" — kept the *overwritten* row's value. That is how the Zilles &
Rehkämper 1988 ISBN ended up stranded on the Johnson et al. 2016 row, sending
Johnson to a TSV that does not exist while its real one sat unused on disk. It is
also why rows 302 and 303 are duplicate Johnson and Peruffo entries whose Team and
Method still read `Stephan`, `Stephan, Zilles`, `Zilles`, `review` — leftovers of
the rows they replaced.

Find rows with `match()` on Item name, as `__update_remaining_builds_20260815.R`
does. Append with the last populated row computed at run time, as
`restore_registry_rows.R` does.

## Division of labour on `__ReadMe.xlsx`

Only `file_list.R` writes columns `E:M`. It validates every formula against the
canonical family and **stops** rather than overwrite a non-canonical one, so
anything else that adds a row writes only `A:D` plus the descriptive columns and
then defers to it:

```
Rscript _tools/restore_registry_rows.R         # or any script that adds a row
Rscript _tools/file_list.R                     # fills E:M, refreshes caches
Rscript _checks/check_item_name_resolution.R   # confirm, expect exit 0
```

Until `file_list.R` runs, a newly added row has no Item name and no merge can see
it. `check_item_name_resolution.R` reports exactly that.

## One thing to decide

`restore_registry_rows.R` runs in the sweep, which makes it a safety net — a lost
row is put back automatically. It also means a **deliberately** deleted row will
be resurrected on the next sweep. If that is not wanted, add it to
`SKIP_PATTERNS`; by the letter of the rule above ("run deliberately") it arguably
belongs there already.

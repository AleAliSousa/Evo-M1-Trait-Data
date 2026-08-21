# `_checks/` — passive reporting

**The rule: a check reads and reports. It never changes the repo.**

Writing its own report into this folder is not "changing the repo" — that is the
output. What a check must not do is touch `__ReadMe.xlsx`, a paper folder, a
`__Public/` TSV, or a merge output. If you find yourself wanting to fix something
from in here, the fix belongs in [`_tools/`](../_tools/README.md) and the check
should name the tool in its output instead.

Consequences of the rule, and why it is worth keeping:

- **Safe to run at any time**, in any order, without a backup.
- **Runs in the sweep.** `run_all_scripts_v2.R` picks up every `.R` here, so a
  check is exercised on every full run without anyone remembering it exists.
- **Exit status is the signal.** Non-zero means "something is wrong", which puts
  the check in `script_failures_only.csv` where it will be seen.

## What is here

| Script | Reports on |
|---|---|
| `check_item_name_resolution.R` | every item name a merge asks for resolves to a TSV that exists; orphaned TSVs; rows added without running `_tools/file_list.R` |
| `check_laterality_doubling.R` | doubled brain-volume values are marked as provenance, never as a veto, and nothing is doubled twice |
| `registry_snapshot.R` | writes a plain-text copy of `__ReadMe.xlsx` Sheet1 and names any row that has vanished since the last run |
| `find_csv_tsv_creators.R` | which script creates each CSV/TSV, and which data files have no creator |
| `find_orphan_R_scripts.R` | scripts with no data input or output |
| `parity_R_vs_py.R` | **temporary.** Diffs `check_laterality_doubling.R` against its retired `.py` twin. Delete both once they agree. Skipped by the sweep because it shells out to `Rscript` and `python3`. |

Committed outputs worth knowing about:

- `registry_snapshot.csv` — Sheet1 as text, sorted by Item name. This is the
  point of the whole exercise: `__ReadMe.xlsx` is binary, so a lost row shows up
  in git as "file changed". Here it shows up as a deleted line. Commit it.
- `registry_snapshot_changes.csv` — what moved on the last run.
- `script_execution_log.csv`, `script_failures_only.csv` — written by
  `run_all_scripts_v2.R` at the repo root, not by anything in here.
- `R_vs_python_builders.{md,csv}` — the record of the 2026-08-07 decision to
  retire the Python builders, kept because it states the rule that a `.py` goes
  only once its R twin is proven equal. The script that generated it is in
  `_archive/`.

## Known duplication, deliberately not fixed yet

Nine places in the merge and check layer implement "resolve an item name to a
TSV", and **they do not agree**. The three `__merging_volumes` scripts match
case-insensitively with `enc_override` fallbacks; `__merging_gyrification` and
`__merging_cortical_areas` match exactly with none; `__merging_sleep` warns and
skips where the others stop. So the same registry drift breaks some merges and
not others, which is how a lost row went unnoticed until it happened to hit a
script with strict matching.

The right fix is one sourced helper in `_tools/`. It is not done because it
touches six merge scripts, and the reason it is written down here is so the next
person does not add a tenth implementation by copy-paste.

Note that the ~220 *paper* build scripts also each resolve their own encoding.
That duplication is deliberate — it is what lets one folder be run on its own,
which the RA fork workflow depends on. Leave it alone.

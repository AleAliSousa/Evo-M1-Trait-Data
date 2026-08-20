# Where the comparison/ folders went

> **This is a migration record, not a rule book.** For where a new file belongs — check, source,
> staging, unpublished data — see **[`REPO_BOUNDARY.md`](REPO_BOUNDARY.md)**, which is the canonical
> definition of the public/private split. If this file and that one disagree, that one wins.

**2026-08-19.** Every `<Paper>/comparison/` folder was moved out of this repository into the private
companion repo **`Evo-M1-Traits-Data-restricted`** — note the plural *Traits*; on this machine it sits
at `…/OneDrive-AllenInstitute/Evo-M1-Traits-Data-restricted`, one level above this repo's `Species/`
parent — under `restricted_checks/<Paper>/comparison/`. 43 folders, 214 files.

**Why.** This repository is public. The comparison folders held working QA material that was never
meant to be published: hand-digitised copies of other people's printed tables, author-supplied
spreadsheets, and in a few cases unpublished data belonging to other researchers.

**What this repo keeps.** The build chain is complete: frozen source → `.R` → analysis CSV →
DOI-coded public TSV → `definitions.csv` → README. Each paper's README still states what its audit
found (for example "verified against the comparison CSV: 0 value mismatches"); the script and report
that produced that statement now live in the private repo.

The post-migration dependency audit found three aggregate/check scripts that had treated comparison copies
as build inputs. They now read the equivalent canonical public tables instead:
`__flow_comparison/Seymour_Boyer_flow_combined.R` reads
`Boyer_Harrington_2019/Boyer_Harrington_2019_SOMTableS6.csv`, and
`__energetics_comparison/energetics_comparison.R` reads
`Kaufman__2004/Kaufman__2004_TableA15.csv`. In addition,
`__energetics_comparison/heiss_wholebrain_check.R` now reads the published whole-brain benchmark
directly from `Karbowski__2007/Karbowski__2007_TableS2.csv`. The two output-producing scripts were
run after the change and reproduced their prior outputs byte-for-byte; the console-only Heiss check
reproduced the same 0.31 µmol/g/min and 428.55 µmol/min benchmark values. Remaining mentions of the
old paths are historical README/code comments or private-audit pointers, not public build reads.

**Where to look for the evidence.** `Evo-M1-Traits-Data-restricted/README__comparison_migration.md`
explains how the audits run now (`_paths.R`, `EVOM1_REPO`), and `MIGRATED_INDEX.csv` there lists all
214 moved files with their SHA-256.

**History.** 195 of the 216 files had already been committed here, so they remain reachable in this
repository's git history; the move only keeps them out of future commits. Whether to rewrite history
is an open decision, recorded in the private repo's migration README.

Two repository-level leftovers were found outside the paper `comparison/` folders. The obsolete
`_tools/mirror_new_comparisons.py` sandbox mirror was removed because its canonical R checks are in
the private repo. `_checks/check_Zilles_Rehkamper_1988_provenance.R` and its generated report depend
on the restricted comparison CSVs; they moved together to
`restricted_checks/_cross_table/Zilles_Rehkamper_1988_provenance/` and were removed here.

**Restricted *source* files, not just checks.** A few sources cannot live here either — data another
researcher supplied privately. Those sit in the private repo under `unpublished_data/`, and the build
that needs one reaches it through **`_tools/restricted_data.R`** (`evom1_restricted_file(...)`), which
resolves the private repo from `EVOM1_RESTRICTED` or the default layout and stops with an explanatory
message if it is not mounted. Current cases: Carol MacLeod's neocortex workbooks, and the Dos Santos
et al. 2020 authors' corrected microglia spreadsheet (`DosSantos_etal_2020_unpublished.R` reads it
from there; the audit that used it moved to the private repo's `restricted_checks/_cross_table/`).

**If you are adding a new source:** follow `__HOWTO_build_a_dataset_file.md` as before, and place its
check by the rules in [`REPO_BOUNDARY.md`](REPO_BOUNDARY.md) §3 — which for most sources means
creating the comparison folder in the private repo rather than here.

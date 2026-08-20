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

**What this repo keeps.** The build chain is unchanged and complete: frozen source → `.R` →
analysis CSV → DOI-coded public TSV → `definitions.csv` → README. Each paper's README still states
what its audit found (for example "verified against the comparison CSV: 0 value mismatches"); the
script and the report that produced that statement now live in the private repo. **No build reads a
`comparison/` path**, so nothing here broke — that was verified before the move, and the remaining
mentions of `comparison/` in scripts and READMEs are comments and prose.

**Where to look for the evidence.** `Evo-M1-Traits-Data-restricted/README__comparison_migration.md`
explains how the audits run now (`_paths.R`, `EVOM1_REPO`), and `MIGRATED_INDEX.csv` there lists all
214 moved files with their SHA-256.

**History.** 195 of the 216 files had already been committed here, so they remain reachable in this
repository's git history; the move only keeps them out of future commits. Whether to rewrite history
is an open decision, recorded in the private repo's migration README.

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

# The public/private boundary

**Canonical definition of what belongs in which of the two repositories, updated 2026-09-05.**
Section 7 (here) and `README__comparison_migration.md` (private) record *how* the split
happened on 2026-08-19; sections 1–6 define *where things go from now on*. Where they disagree,
sections 1–6 win.

**2026-09-05 rule change: every check now lives in the restricted repo, regardless of whether its
inputs are public.** The earlier rule sent an all-public-input check beside what it audits, in the
public repo; that distinction is gone. No check/comparison folder belongs in the public repo any
more, full stop — see section 3's placement table. This moved `__cerebellum_protocol_comparison`,
`__energetics_comparison`, `__flow_comparison`, and five sensory-paper `comparison/` folders
(`Heffner_Heffner_1992_a`, `Heffner_etal_2020`, `Koay_etal_1998`, `Kirk_Kay_2004`,
`Veilleux_Kirk_2014`) into `restricted_checks/`, and retroactively resolves open question 1 below:
the "six publishable audits" question is moot, because publishability of the inputs no longer
decides where a check lives.

---

## 1. The two repositories

The names differ by one letter. That is the single most common source of a broken path, so both are
spelled out here and nowhere else should be trusted from memory.

| | public | private |
|---|---|---|
| folder | `Evo-M1-Trait-Data` — **Trait**, singular | `Evo-M1-Trait-Data-restricted` — **Trait**, singular |
| remote | `github.com/AleAliSousa/Evo-M1-Trait-Data` (public) | `github.com/AleAliSousa/Evo-M1-Trait-Data-restricted` (private) |
| on this machine | `…/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data` | `…/OneDrive-AllenInstitute/Evo-M1-Trait-Data-restricted` |
| recognised by | `__ReadMe.xlsx` at its root | `_paths.R` at its root |
| found from the other side by | `_paths.R` → `evom1_repo()`, override `EVOM1_REPO` | `_helpers/restricted_data.R` → `evom1_restricted()`, override `EVOM1_RESTRICTED` |
| sweep runner | `run_all_scripts_v2.R` | `run_all_restricted_checks.R` |

The two are **not** side by side: the public repo sits one level deeper, inside `Species/`. Both
resolvers already allow for that, but if your layout differs, set both variables in `~/.Renviron`
rather than editing either resolver:

```
EVOM1_REPO=/Users/<you>/…/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data
EVOM1_RESTRICTED=/Users/<you>/…/OneDrive-AllenInstitute/Evo-M1-Trait-Data-restricted
```

## 2. What each repository is for

**Public — the build.** Every step from a frozen source snapshot to a citable public table, plus the
registry and keys that name them. Its contents are, by construction, publishable: a reader can follow
any value from the public TSV back to the printed table it came from.

**Private — the evidence that cannot be published.** Two kinds: checks whose inputs are not public,
and source data that is not ours to release. Nothing here is needed to *rebuild* the public data; it
is needed to *trust* it.

### The one test

> Could this file be pushed to a public GitHub repository today, without asking anyone's permission?

**Yes** → public repo. **No** → private repo. **Not sure** → private repo, and record the open
question as a row in `_triage_comparison_inputs.csv` so the doubt is visible rather than forgotten.

Note what the test is *not* about: file size, tidiness, or whether the work is finished. A messy
half-built public table belongs in the public repo. A beautifully finished audit of someone's
unpublished spreadsheet does not.

## 3. Placement, by kind of artefact

| artefact | repo | path |
|---|---|---|
| frozen snapshot of a published source table | public | `<Paper>/` |
| reader / build script | public | `<Paper>/<Paper>_<Item>.R` |
| analysis CSV | public | `<Paper>/<Paper>_<Item>.csv` |
| DOI-coded public TSV | public | `__Public/comparative-data/<encoded>_<item>.tsv` |
| `definitions.csv`, source README | public | `<Paper>/` |
| registry row (citation → item → filename) | public | `__ReadMe.xlsx` `Sheet1` |
| merge and its outputs | public | `__merging_<domain>/` |
| decision to skip, supersede, or exclude a source | public | `SOURCE_DISPOSITION_REGISTER.md` |
| species / specimen / taxonomy keys | public | `_keys/` |
| **check, single-paper** (any input, public or not) | private | `restricted_checks/<Paper>/comparison/` |
| **check, cross-publication** (any input, public or not) | private | `restricted_checks/_cross_table/<a>_vs_<b>/` |
| source data that cannot be published | private | `unpublished_data/____Unpublished__<Set>/` |
| material being cleaned up before promotion | private | `_<name>_staging/` |
| sweep log, folder audit, cleanup manifest | either | `_checks/` of that repo |

A check's *result* is public even when the check is not: the paper's README in the public repo states
what the audit found ("verified against the comparison CSV: 0 value mismatches"), and the script and
report that produced it live privately. That asymmetry is deliberate — the claim is citable, the
working material stays where it is allowed to be.

## 4. Four invariants

**I1 — A check goes where its most restricted input is.** One unpublishable input makes the whole
comparison unpublishable, however published the other inputs are. This is the rule that decides the
hard cases; the placement table above is just its consequences.

**I2 — Exactly one read crosses the boundary.** A public build may read
`unpublished_data/`, and only through `_helpers/restricted_data.R` (`evom1_restricted_file(...)`), never
a hardcoded path. No public script may read anything under `restricted_checks/`. Currently one build
crosses: `DosSantos_etal_2020/DosSantos_etal_2020_unpublished.R`.

**I3 — Nothing private writes into the public repo.** Private checks read the public data and write
their reports next to themselves. A private script that needs to change a public file is a request for
a public commit, not a write.

**I4 — The shared folder names are names, not content.** 42 paper folders exist in both repos under
the same name. The public `<Paper>/` holds the build and never a `comparison/` folder; the private
`restricted_checks/<Paper>/` holds checks and their inputs and never a build artefact. If the same
CSV appears on both sides, one of them is wrong.

**I5 — A derivative of a restricted source is not automatically publishable.** Each restricted source
carries a ReadMe in the private repo stating the conditions it was shared under. Read it before
publishing anything built from it. This is a permission question, not a technical one.

## 5. The repo root is not a scratch directory

The root of either repository holds only what this document and its README list. Anything else is an
accident, and accidents at the root get committed.

They arrive one of two ways. A script that writes to a **relative** path writes into the *runner's*
working directory, not its own — which is why both sweep runners now run each script with its own
folder as `cwd`, and print any new root-level entry when they finish. And an unrelated R session
whose `cwd` happens to be a repo root will leave its own debris there: on 2026-08-19,
`tools::testInstalledBasic()` / `testInstalledPackages()` deposited **74 files** (`reg-tests-*.pdf`,
`PS-*.ps`, `pdf-*.pdf`, `multicore*.Rout.fail`, `utils.tar*`, `pkg.utf8/`, …) in the private repo's
root, and they reached its first commit. Inventory in
`Evo-M1-Trait-Data-restricted/_checks/junk_removed_20260819.csv`, and the resolution in
`_checks/PUSH_NOTE_20260819.md`.

Both `.gitignore` files now carry root-anchored patterns for that family of names, but note what that
does and does not do: **`.gitignore` has no effect on a file git already tracks.** It stops the next
accident; it does not clean up this one. Removing already-committed debris takes a `git rm` plus,
if it should never have been in the history at all, a rewrite of the commits that carry it.

If you run a package or R-installation check, `setwd()` to `/tmp` first. Neither repo root is a
working directory.

## 6. Open questions this boundary does not yet settle

These are live ambiguities, not rules. Each needs a decision; none should be resolved by guessing.

1. **RESOLVED (moot) 2026-09-05 — the six publishable audits.** Publishability of a check's inputs
   no longer decides where it lives (see the 2026-09-05 rule change at the top of this file); every
   check stays in `restricted_checks/`, so `Baron_etal_1996`, `Kazu_etal_2015`, `Lewitus_etal_2014`,
   `Smaers_etal_2011`, `Turner_etal_2016`, `deSousa_etal_2009` are correctly where they already sat
   and there is nothing to move. **New open item found while applying that rule:**
   `Baron_etal_1996_overlap_taxonomy_audit.R` still sits in the public `Baron_etal_1996/` folder (not
   a `comparison/` folder, so it wasn't caught by the 2026-09-05 sweep) and does double duty: it
   writes `Baron_etal_1996_taxonomy_crosswalk.csv` (a build input the merge may consume) alongside
   `Baron_etal_1996_overlap_audit.csv`/`_species_overlap_audit.csv` (audit reports, all-public-input,
   which under the new rule belong in `restricted_checks/Baron_etal_1996/`). Needs a human decision
   on whether to split the script (crosswalk stays public, audit output moves) or move it whole and
   have the merge read the crosswalk across the boundary via `_helpers/restricted_data.R`.

2. **`__merging_<domain>/checks/` does not exist.** Both migration READMEs name it as the home for
   public cross-source checks, but no such folder is present; in practice the DeCasien comparisons sit
   directly in `__merging_volumes/` and the energetics checks in `__energetics_comparison/`. Either
   create the folders or amend the rule to "beside the merge".

3. **`output/` in the private repo is undefined.** Its one occupant,
   `output/bush_allman_v1_comparison/`, tests Bush & Allman 2004b Table 1 against the unpublished
   Wisconsin workbook and Frahm 1984 — by I1 and the cross-publication rule that is
   `restricted_checks/_cross_table/BushAllman_2004b_vs_Wisconsin_unpublished/`. It landed at
   `output/` because the script was pasted into a session whose `cwd` was the repo root. Move it and
   `output/` stops existing as a concept.

4. **`checks/` and `_checks/` both exist in the public repo**, one letter apart. `checks/` holds two
   empty directories and is untracked; `_checks/` is the real one. Fold and delete.

5. **`SFI dataset/` in the private repo** (OCR QC pages, strips, and reviewer JSON) predates the
   split and is unrelated to it. It needs the one test applied and a home named.

### Resolved since the migration

- **Specimen registry boundary (resolved 2026-08-20).** Public, citable specimen identity and
  taxonomy now live in `_keys/specimen_crosswalk/`; restricted collection records, source material,
  full notes, and the pre-split archive live in the private repo's `specimen_registry/`. The public
  `SPECIMEN_INFORMATION_BOUNDARY.md` and `split_manifest_2026-08-19.csv` record the per-file split.

## 7. History of the split

*A migration record, not a rule book. Sections 1–6 define where a new file belongs; where this
section disagrees with them, they win. This section was the standalone file
`__COMPARISON_MOVED.md` until it was merged here on 2026-10-08; its git history is under that name.*

**2026-08-19.** Every `<Paper>/comparison/` folder was moved out of this repository into the private
companion repo **`Evo-M1-Trait-Data-restricted`** — note the singular *Trait*; on this machine it sits
at `…/OneDrive-AllenInstitute/Evo-M1-Trait-Data-restricted`, one level above this repo's `Species/`
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

**Where to look for the evidence.** `Evo-M1-Trait-Data-restricted/README__comparison_migration.md`
explains how the audits run now (`_paths.R`, `EVOM1_REPO`), and `MIGRATED_INDEX.csv` there lists all
214 moved files with their SHA-256.

**History.** 195 of the 216 files had already been committed here, so they remain reachable in this
repository's git history; the move only keeps them out of future commits. Whether to rewrite history
is an open decision, recorded in the private repo's migration README.

Two repository-level leftovers were found outside the paper `comparison/` folders. The obsolete
`_tools/mirror_new_comparisons.py` sandbox mirror was removed because its canonical R checks are in
the private repo. `_checks/check_Zilles_Rehkämper_1988_provenance.R` and its generated report depend
on the restricted comparison CSVs; they moved together to
`restricted_checks/_cross_table/Zilles_Rehkämper_1988_provenance/` and were removed here.
*(Retired in the private repo on 2026-08-20. What the audit established — that a `Pongo` value in a
pre-1988 formatted CSV traces back to Zilles & Rehkämper 1988 — now lives in
`Zilles_Rehkämper_1988/Zilles_Rehkämper_1988_Table12-2.README.md`, so no paper README points at
the deleted report.)*

**Restricted *source* files, not just checks.** A few sources cannot live here either — data another
researcher supplied privately. Those sit in the private repo under `unpublished_data/`, and the build
that needs one reaches it through **`_helpers/restricted_data.R`** (`evom1_restricted_file(...)`), which
resolves the private repo from `EVOM1_RESTRICTED` or the default layout and stops with an explanatory
message if it is not mounted. Current cases: Carol MacLeod's neocortex workbooks, and the Dos Santos
et al. 2020 authors' corrected microglia spreadsheet (`DosSantos_etal_2020_unpublished.R` reads it
from there; the audit that used it moved to the private repo's `restricted_checks/_cross_table/`).

### 2026-09-05 addendum: repair after a manual move, and a boundary-rule change

The standalone record `__COMPARISON_MOVED.md` (now this section), `____TODO/`, the four public
specimen notes under `_keys/specimen_crosswalk/`, and three top-level cross-publication checks
(`__cerebellum_protocol_comparison`, `__energetics_comparison`, `__flow_comparison`) were moved by
hand into `Evo-M1-Trait-Data-restricted`, alongside a correct move/rename of
`____Sensory_audiovisual` to `unpublished_data/____Unpublished__Sensory_audiovisual/`. That record,
`____TODO/`, and the public specimen notes have been moved back here, since none of them are checks.
Separately, the user changed the check-placement rule: **every check now lives in the restricted
repo regardless of whether its inputs are public** (see the rule-change note at the top of this file
and section 3). Under that rule the three cross-publication checks above stay in the restricted repo
(their path resolution was broken by the move and has been fixed there), and five more public
`comparison/` folders — `Heffner_Heffner_1992_a`, `Heffner_etal_2020`, `Koay_etal_1998`,
`Kirk_Kay_2004`, `Veilleux_Kirk_2014` — moved into `restricted_checks/` alongside them. Two of those
needed live-code fixes rather than a plain move: `Heffner_Heffner_1992_a`'s comparison script was
rewired to resolve the public repo via `_paths.R` and the restricted input via its new
`unpublished_data/____Unpublished__Sensory_audiovisual/` path; `Heffner_etal_2020_Figure3_mirror.py`
had its restricted-input check extracted into a new standalone script in the restricted repo,
leaving only the public build behind. A genuine data-loss bug was also found and fixed in passing:
12 real (non-placeholder) files were left behind under a stale
`unpublished_data/____Sensory_audiovisual/` during the rename to
`____Unpublished__Sensory_audiovisual/`; they were recovered and moved into the correctly-named
tree. One further boundary item was flagged but not resolved:
`Baron_etal_1996_overlap_taxonomy_audit.R` (public repo) writes both a build-relevant crosswalk CSV
and an audit-report CSV from one script — see section 6, item 1.

---

## Where to look next

- Section 7 above — what moved on 2026-08-19, and the git-history caveat
- `_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md` — the per-folder build procedure
- `SOURCE_DISPOSITION_REGISTER.md` — which sources are skipped, superseded, or excluded, and why
- `_helpers/restricted_data.R` — the only sanctioned read across the boundary
- private `README__comparison_migration.md` — the migration record and the triage table
- private `_triage_comparison_inputs.csv` — publishable vs restricted, per folder

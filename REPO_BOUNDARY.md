# The public/private boundary

**Canonical definition of what belongs in which of the two repositories, updated 2026-08-20.**
`__COMPARISON_MOVED.md` (here) and `README__comparison_migration.md` (private) record *how* the split
happened on 2026-08-19; this file defines *where things go from now on*. Where they disagree, this
file wins.

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
| **check whose every input is already public** | public | beside what it audits — the paper folder, or the merge that pools the data |
| **check with any non-public input** | private | `restricted_checks/<Paper>/comparison/` |
| **cross-publication check with any non-public input** | private | `restricted_checks/_cross_table/<a>_vs_<b>/` |
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

1. **The six publishable audits.** `_triage_comparison_inputs.csv` finds 6 of 42 check folders whose
   inputs are all public (`Baron_etal_1996`, `Kazu_etal_2015`, `Lewitus_etal_2014`,
   `Smaers_etal_2011`, `Turner_etal_2016`, `deSousa_etal_2009`). By I1 they belong in the public
   repo. Direction of travel is private → public; the trigger is human confirmation, not the
   classifier, which errs toward "restricted" by design. On moving one: restore its `../` paths and
   flip its row to `PUBLISHABLE — moved <date>`. Until then a reader cannot tell whether a folder is
   private because it must be or because nobody has looked. The separate Baron overlap/taxonomy
   audit already remains public beside its source tables because all its inputs are public; only the
   migrated Table 32-vs-Table 10 check is part of this open review.

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

---

## Where to look next

- `__COMPARISON_MOVED.md` — what moved on 2026-08-19, and the git-history caveat
- `__HOWTO_build_a_dataset_file.md` — the per-folder build procedure
- `SOURCE_DISPOSITION_REGISTER.md` — which sources are skipped, superseded, or excluded, and why
- `_helpers/restricted_data.R` — the only sanctioned read across the boundary
- private `README__comparison_migration.md` — the migration record and the triage table
- private `_triage_comparison_inputs.csv` — publishable vs restricted, per folder

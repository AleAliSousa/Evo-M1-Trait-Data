# One route per trait — plan to retire the `__merging_*` folders and separate the source files

Written 22 Nov 2026, at Michael's request. Status: PLAN ONLY — nothing here is
authorised yet; each phase needs its own go-ahead, following the repo's
established pattern (build in a replica → cell-level diff → PR → verify →
delete last).

---

## 1. Where things stand (verified 22 Nov 2026)

A trait can currently reach the app by **three routes**:

1. **A `__merging_*` folder** — ~26 folders, each with its own compiled.R and
   its own long/wide/unfiltered outputs. The app loads each one through an
   explicit entry in app.R's GH table.
2. **The EvoM1 trait table** — `__ShinyApp/data/evom1_traits_long.csv`, melted
   from the `____EvoM1_TraitTable/*.xlsx` workbooks by `build_data.R`. No
   merge, no reconciliation: the app's "EvoM1 traits" dataset.
3. **`__Public/comparative-data/`** — the per-publication TSVs, fetched raw
   into the app's source-tables view.

The same underlying datum can therefore exist **three times**: once in a
per-publication TSV, once as a trait-table column, once in a merge output.
The only thing stopping the compiled database from showing the trait-table
and merge copies side by side is a hand-maintained patch file,
`_keys/variable_canonical.csv` — **64 rows** mapping trait-table variables
onto merge labels (48 of them name a merging folder as the winner). It only
covers the duplicates somebody has already noticed, it only relabels/drops
trait-table rows (it cannot touch anything inside a merge), and every new
duplicate needs a new row.

The definitions have the same shape in miniature: ~978 per-folder
`*_definitions.csv` sources feeding one built `_keys/variable_definitions.csv`
— that layer at least has a single builder and a recorded provenance column.

The pilot (`__measurements/` + `__metadata/`) was an attempt at this problem,
but it has two competing registration systems and interprets every cell
twice. Michael's verdict stands: *it needs to be simple.* This plan replaces
the pilot's approach rather than extending it.

## 2. Principles (Michael's standing rules, applied)

- **One route per trait.** Every app label is produced by exactly one build
  path. A second copy of a trait anywhere in the app feed is a bug, not a
  feature.
- **Where more than one source reports a trait, reconcile — don't
  duplicate.** Reconciliation means the established rules: primaries before
  compilations; a compilation that largely re-reports a primary already in
  the data is a cross-check and gap-filler only, never pooled wholesale;
  pooling is by explicit precedence, never by averaging across sources;
  fossil values are different variables from extant ones (except ECV).
- **Provenance at the data-point level.** Every value keeps its source item;
  reconciliation chooses among sources, it never blends them into anonymity.
- **One editable table drives the build.** The replacement for both
  `__ReadMe.xlsx`-as-build-command and the per-merge scripts is a single
  mapping table a human can read and edit: one row per (trait, source) with
  its precedence, unit conversion and label. File-level registration only
  where it earns its keep.
- **R only** for build scripts that live in the repo.
- **The app reads GitHub at runtime.** Data moves are live on push; loader
  changes need a redeploy. Every phase ends verified live before the next
  begins, and nothing is deleted until its replacement is verified
  (the body_ecology split pattern, PRs #95–#100).

## 3. Target design

```
Layer 1  SOURCES     per-publication built tables (TSVs) — unchanged in
                     content; PDFs and publisher source files moved out
                     (Part B below).
Layer 2  ONE BUILD   a single R pipeline driven by the mapping table:
                     sources → per-trait reconciliation by precedence →
                     one long table (+ wide, unfiltered, species
                     resolution) in ONE output folder.
Layer 3  CATALOGUE   _keys/variable_domain.csv + the definitions builder —
                     unchanged in role; variable_canonical.csv retired
                     (nothing left for it to patch).
APP                  GH table collapses to the single Layer-2 output plus
                     the source tables. No trait-table feed.
```

The working model for Layer 2 already exists inside the repo: the
supplementary merge is mapping-driven (a sources CSV with a precedence
column, dual mapping for pooled labels, provenance spanning all
contributors). Layer 2 generalises that one pattern to every trait, instead
of 26 hand-written scripts each inventing their own.

The trait table stops being an app feed. Its traits that no merge covers
today (dexterity, corticospinal tract, locomotion, gait, handedness, V1
synapse measures, …) become mapping rows whose source is the trait table
itself, treated as what it is: a compilation, ranked below any primary that
reports the same trait.

## 4. Phases

### Phase 0 — Route audit (no repo changes)
- Enumerate every app label and its route(s): merge folder / trait table /
  public-only. Output: the triplication list — every trait arriving by more
  than one route, with species counts per route and value-agreement stats
  where routes overlap.
- For every multi-source trait, a proposed precedence applying §2's rules,
  as a decision table for Michael (the format used for the Nov 20 audit:
  POOL BY PRECEDENCE / KEEP SEPARATE / ALREADY HANDLED, with evidence).
- Also inventory everything that *reads* the merging folders or the trait
  table: app.R loaders, `_keys/build_species_taxonomy.py` (reads every
  `__merging_*/*_long.csv`), the definitions builder's globs,
  `__shinyapp_update.R`'s staging list, TraitExplorer (separate repo — must
  be checked before anything moves).

### Phase 1 — Stop the trait-table feed duplicating merges
- Add mapping rows for every trait-table-only trait (source = trait table).
- Shrink `variable_canonical.csv` to zero rows as each duplicate is
  reconciled at the source instead of patched at load time.
- App change: drop the `traits` GH entry once the pipeline (Phase 2) or the
  interim mapping covers its labels. (Interim option: keep the feed but
  with the canonical file empty and a startup check that fails loudly on
  any duplicate label across datasets.)

### Phase 2 — Build the single pipeline in parallel
- New folder (working name `__compiled/`) with: the mapping table, one
  R build script, the outputs. Built in a replica against live inputs.
- Acceptance test: reproduce the app's current compiled database
  cell-for-cell, with every difference itemised and explained (the standard
  set by the Nov 21–22 rebase reports). Differences are expected exactly
  where Phase 0 found unreconciled duplicates — those are decided, not
  discovered, at this point.
- Per-trait precedence from the Phase 0 decision table is encoded in the
  mapping; guards for known source misprints (the §3.4 family) become
  mapping-level annotations with the guard values recorded, not code
  scattered across 26 scripts.

### Phase 3 — Switch the app
- Loader re-point (the PR #99 pattern): GH table → the single output;
  dataset names in the picker preserved where they are meaningful, or
  deliberately renamed with Michael's agreement.
- Redeploy (Alexandra runs the updater), then the spot-check list:
  picker contents, per-dataset species counts against the Phase 2
  acceptance table, the known sentinel values (elephant cortex O.n
  150,150,000,000; rabbit cerebellum O/N 0.314; *Leontocebus fuscicollis*
  Cathemeral; Gestation coverage).
- TraitExplorer verified against the new output before Phase 4.

### Phase 4 — Retire the merging folders
- Delete `__merging_*` folders in batches (data first verified live under
  the new route), with the registry and the updater's staging list updated
  in the same PRs.
- Retire `variable_canonical.csv`, the pilot folders (`__measurements/`,
  `__metadata/`) if Michael confirms the pilot is superseded, and the
  trait-table app feed machinery in `build_data.R`.
- Heuer 2019 is the test case that proves the design: a single-source
  "merge" becomes one mapping row (or a decision not to surface it) — no
  folder theatre required to keep it separate from Zilles; separateness
  is a property of the mapping, not of the directory tree.

### Part B — Move the publications' PDFs and source files out (independent of Phases 0–4)
- **Scope, defined precisely:** PDFs, publisher/source captures
  (`fulltext.html`) and any publisher-supplied files, wherever they sit
  (paper folders today). NOT in scope: built TSVs/CSVs, snapshot CSVs,
  builder scripts, READMEs — builds read those where they are.
- **Destination options:**
  - **B1 (recommended first step):** one in-repo area, e.g. `__sources/`,
    mirroring the paper-folder names. Keeps every raw URL and local path
    one edit away; reversible; repo stays one clone.
  - **B2:** a separate repository. Cleaner separation and a smaller
    working repo, but every reference becomes cross-repo, the app and
    builders must never need the files at runtime, and access control
    diverges (the current repo is public; some source files may not be
    redistributable — cf. the restricted repo's unpublished material).
- **Ripple effects to handle in the same move:** `__ReadMe.xlsx` snapshot
  filenames (registry tools only, never hand-edited), paper-folder builder
  scripts that read their own PDF/fulltext, the registry's
  human-verification workflow, and any README links. The app does not
  read PDFs (it fetches TSVs from `__Public/`), so the app is untouched.
- Sequencing: Part B can run before, during or after Phases 0–4, but the
  Phase 0 reader-inventory should land first so the move doesn't break a
  reader nobody knew about.

## 5. Risks and guards

- **Live-app breakage** — mitigated by parallel build + acceptance diff +
  delete-last, exactly as in the split. The app fails loudly (by design)
  when a file it expects is missing, so deletions never precede the
  re-point + redeploy + spot checks.
- **Silent value changes** — the acceptance test is cell-level against the
  current app data; every delta must trace to a Phase 0 decision.
- **Registry churn** — `__ReadMe.xlsx` is a shared file: sync to live main
  and diff before and after every change (the shared-repo-files rule).
- **Scope creep into curation** — reconciliation *choices* (which source
  wins) are Michael's; the plan only makes them explicit and singular.
  Known open curation items stay open (e.g. the Blarina whole-brain guard)
  until he decides them; the pipeline carries them as flagged annotations.
- **Effort shape** — Phase 0 is analysis (days, mostly agent time).
  Phase 2 is the big build. Phases 1, 3, 4 are mechanical once 0 and 2
  are right. Part B is mechanical once its inventory exists.

## 6. Decisions Michael needs to make

1. **Target:** the single mapping-driven pipeline (§3), or a lesser step —
   keep per-domain merges but generate them all from the one mapping table?
2. **Trait table:** archive the workbooks as a source (recommended), or
   keep them as a living input someone still edits?
3. **PDFs/source files:** B1 in-repo `__sources/` (recommended first), or
   B2 separate repo — and if B2, public or private?
4. **Pilot:** confirm `__measurements/` + `__metadata/` are superseded by
   this plan and can be retired in Phase 4.
5. **Dataset names in the app:** keep the current picker names as labels
   over the single output, or take the chance to rename?

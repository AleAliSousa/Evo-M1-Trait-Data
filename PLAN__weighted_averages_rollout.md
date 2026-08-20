# Plan — de-average at source, carry N, weight the means: rollout across all `__merging_*` datasets

Status: **plan, plus the first two sources done.** Written 2026-08-19.
Companion to `__merging_volumes/PLAN__hierarchical_curation.md`, which covers the volumes merge in
detail. This document is the cross-domain view: which of the 13 datasets can adopt the same workflow,
in what order, and where it cannot go because the sample sizes are not recoverable.

Tables that go with this plan:

- **`weighted_average_readiness.csv`** — per-domain verdict, 13 rows
- **`sample_size_open_questions.csv`** — every N question the rollout runs into, 17 rows, marked
  answerable / not answerable / moot

---

## The workflow, in one paragraph

A published species value is usually a mean over animals. Three things have to be true before a merge
may pool such values: the individual observations must still exist (so N is known), the sources must be
measuring the same thing (so pooling is legitimate), and the pooling must weight by N (so a 1-brain
study does not outvote a 12-brain study). The repo currently fails the first at extraction — several
source scripts average individuals into a species mean before the merge ever sees them — and fails the
third everywhere: **there is no weighted mean anywhere in any of the 13 merges.** The workflow is
therefore: (1) stop averaging in the source script, keep one row per specimen; (2) carry N and the
specimen identifier through to the merge; (3) keep the paper's own printed mean/SD as a reconciliation
file, never as data; (4) pool in the merge, weighted where N is complete for that cell, unweighted and
flagged where it is not.

Step (3) is what makes (1) safe. If the recomputed mean reproduces the published one, the individual
rows are demonstrably the sample behind the published value, and moving the averaging downstream
changes nothing except that N becomes visible.

---

## Done so far

| Source | What changed | Numerical effect |
|---|---|---|
| `Ashwell__2020_SupplementaryTable` | 150 → **154 rows**; the 6 monotreme specimen rows preserved instead of collapsed to 2 means; printed mean/SD rows moved to `Ashwell__2020_published_mean_reconciliation.csv`; added `species_as_published`, `specimen_number`, `row_type`, `n_specimen_rows` | **none** — 26/26 monotreme values identical, 148 other species byte-identical |
| `Bauernfeind_etal_2013_Table1` | footnote markers split off the specimen ID into `footnote_ref`, `measurement_software`, `left_hemisphere_unavailable`; added `individual_as_published` | **none** — no value touched; `Individual` strings corrected |

Both verified against the paper's own summary table. Ashwell: all 26 printed means reproduce (3 differ
in the last digit by ≤0.3%, his rounding). Bauernfeind: **60 of 60** published `n` reproduce exactly,
max mean deviation 11.1% and that is his rounding of a 36 mm³ value to 40.

### Bauernfeind was more interesting than expected

Table 1 was *already* one row per individual — 43 individuals, 30 species — so the de-averaging is a
merge-side job here, not an extraction one. What was wrong at the source was the specimen ID. Every one
of the 43 printed labels carries a trailing footnote marker, and the markers are not decoration:

| marker | meaning | n |
|---|---|---|
| `a` | Volumes estimated using **StereoInvestigator** software | 22 |
| `b` | Volumes estimated using **ImageJ** software | 21 |
| `c` | The left hemisphere was unavailable | 1 (*Pongo pygmaeus* "Sabtu") |

Glued onto the ID they made it wrong — `Nambob` for Nambo, `Sabtub,c` for Sabtu — and, worse,
unjoinable: **Table 2 prints the same animals without markers**, so the left and right hemispheres of
one brain were two different strings. After the split, **all 15 Table 2 individuals match a Table 1
individual exactly.**

Two things follow that were not previously available:

1. **14 of the 43 brains were measured on both sides** (5 *Homo*, 3 *Pan paniscus*, 2 *Pan
   troglodytes*, 2 *Gorilla*, 1 *Pongo abelii*, 1 *Pongo pygmaeus*). For those, a whole-insula volume
   is a *measurement*, not the merge's current 2 × left estimate. Left−right asymmetry runs −4.4% to
   +10.7% of the total, left larger in 8 of 14 — so 2 × left is a fair approximation but not a free
   one. Written to `Bauernfeind_etal_2013_bilateral_individuals.csv`.
2. **Two measurement softwares inside one table.** That is method heterogeneity within a single source
   — a `definition_compatibility` fact in the sense of the volumes plan §5.3, and one that only became
   visible because the footnote was treated as data rather than noise.

Still to do for Bauernfeind, all merge-side and all deliberately deferred to the phased plan because
they change numbers: stop collapsing the 43 individuals at `volumes_compiled.R:272`; drop the
*Pongo pygmaeus* + *Pongo abelii* lump (Bauernfeind separates them and Table 3 confirms the split, so
no lump is needed); fix the `Brain_Mass.mg` unit defect, where the reshape divides by 1000 and stores
grams under an mg label.

---

## Where the rollout can go

Full detail in `weighted_average_readiness.csv`. Summary, in the order I would do them:

### Tier A — turn it on with local edits

**`cortical_layers`** — the schema is already complete and is the template the other domains lack:
`specimen_id`, `observation_level`, `n_specimens`, `uncertainty_type`, `uncertainty_value`,
`n_sampling_locations`, `value_basis`, all propagating into the long and wide outputs. The only
obstacle is a policy line: `cortical_layers_compiled.R:78-79` marks Peruffo's 6 individual sheep
non-default and prefers the printed species mean, while `:209` asserts that the printed mean differs
from the arithmetic mean of those six. That is the Ashwell decision in miniature and it should go the
same way. There is no cross-source pooling step in this domain yet, so building one is greenfield.

**`cerebral_metabolic_rate`** — the closest to ready. Kaufman's 14 tables carry `n` filled on 98.6% of
1,436 rows, it already survives into `cerebral_metabolic_rate_unfiltered.csv`, and the domain is
already deduped on the cited *primary study* rather than a team label (`comp_priority` at `:139-145`) —
which is `republishes` by another name. Two `summarise()` calls at `:157` and `:159` are all that stand
between it and a weighted mean. Two caveats: Karbowski's 23 tables and Heiss publish no `n`, so mixed
cells stay unweighted; and `Kaufman__2004_TableA15.csv` — Kaufman's own weighted summary, with explicit
`weighting`, `N` and `CV` columns — is sitting unread because the loader regex stops at `TableA14`.
Compare his weighting to ours before choosing.

### Tier B — the N exists in the files and is thrown away at a known line

Four chokepoints, each a small edit, each unlocking partial weighting:

| domain | chokepoint | what it discards |
|---|---|---|
| `body_ecology` | `:116` filter + `blk()` at `:147-154` has no N slot | n from 17 of 52 sources |
| `brain_mass` | `:67`, identical filter; `uf` at `:118-120` has no N column | n from 7 of 39 sources |
| `cellcounts` | `:530-534` greps `_n$`, `_S.n$`, `_SD$` into `variables_to_move`, removed at `:546`, parked at `:549` | 3 sample-size columns **and 55 SD columns** |
| `cortical_areas` | `standardized_term_cortical_areas.csv` maps only 2 of Young's columns | `n_hemispheres` + 10 `*_sd` |

`cellcounts` is the sharpest case: the columns are found, named, moved and shelved. Nothing is missing.

Note also that `cortical_areas:75` already does a within-specimen hemisphere average for Turner — the
only specimen-aware reduction anywhere in the repo besides the new Bauernfeind file. The pattern exists;
it just has not been generalised.

### Tier C — will not weight, and that is the right answer

**`behaviour`** and **`gyrification`** refuse to average across sources on citation-dependency grounds,
and the refusals are documented and correct (`behaviour_compiled.R:9-14`;
`gyrification_compiled.R:13-16`; `__merging_volumes/README__merging.md:49-51`). Weighting a mean you
never take is not a task. Where sources trace to the same underlying data, prefer one — which is what
both scripts already do.

**`fossil_brain_glucose`** pools across three *estimation methods* for one fossil, not across animals.
Every row is n=1 by construction, so N-weighting is vacuous. The right weight there is estimator
precision, which is not published — a genuinely different open question, logged as such.

**`cerebellar_folding`** and **`sleep`** have no multi-source pool to weight yet. Sleep is pre-wired
(`team` and `dependency_group` columns already exist, `:22-25` states the intent), so it will fall out
when a second source of the same trait arrives.

---

## Sequencing

1. **Finish the volumes sources.** Ashwell and Bauernfeind are done. Remaining collapsers in the
   step-3 reshape: MacLeod T1/T2, de Sousa 2010 T1, Smaers 2011 SuppT1/T2, Barger 2007. All five have
   specimen identifiers; all five are collapsed at `volumes_compiled.R:272-333`. Do them the same way,
   each with a reconciliation file against the paper's own species means.
2. **Build the shared helper** (`_tools/curation.R`, designed in the volumes plan §8) with
   `attach_N()` and `pool_values(weighted = "if_complete")`. Do this before Tier B, so the four
   chokepoint fixes have something to hand N to.
3. **Tier A**: `cortical_layers`, then `cerebral_metabolic_rate`.
4. **Tier B**: `cellcounts`, `cortical_areas`, then `body_ecology` and `brain_mass` together — they
   share the same filter line and the same `pool_one()` shape.
5. **Fix the gyrification registry defect first regardless of tier** — `Zilles_etal_2013_Table1` has no
   `Item name` / `Item encoded` row in `__ReadMe.xlsx`, so `enc()` returns `NA`, the script reads
   `NA.tsv`, and the domain cannot run at all. `gyrification_long.csv` still holds 181 Zilles rows from
   an earlier build, which is how it has gone unnoticed. The real TSV is
   `__Public/comparative-data/10.1016%2Fj.tins.2013.01.006_Table1.tsv`.

Each step: back up outputs to a dated `_prerun_backup_*`, assert byte-identical values where the change
is meant to be provenance-only, and write the reconciliation file before touching the pooling.

---

## Weighting rule (unchanged from the volumes plan)

Weighted mean **only where every contributor to that cell has a known N**; unweighted otherwise; a
per-cell `N_rule` column records which fired (`weighted` / `unweighted_N_incomplete` / `single_source` /
`recency`). No `N = 1` defaults — a source that reports 12 brains without stating N must not be
outvoted by a single-specimen study on the strength of an assumption.

Expect this to look inconsistent in print: two cells in the same column will have been computed by
different arithmetic. `N_rule` makes it auditable, and the methods section has to say so plainly.

Two distinctions worth keeping straight in the N column itself:

- **printed N** vs **counted N** (rows in a per-specimen table) vs **as-published single row** (one
  printed row, the paper never says whether it is one brain). Ashwell's 148 single-row species are the
  third kind and must not be laundered into the first.
- **row counts are not sample sizes.** `n_obs` (`volumes_compiled_select.R:666`), `n_rows_in_source`,
  `n_sources`, `n_teams`, gyrification's `n = n()` at `:78`, and Ashwell's new `n_specimen_rows` are all
  counts of *rows or sources*, not animals. Use `N_specimens` for animals and nothing else.

---

## Sample-size questions that cannot be answered

The user instruction was to stop where a sample-size question has no answer and record it rather than
guess. Full list in **`sample_size_open_questions.csv`** (17 rows). Of those:

- **9 are genuinely unanswerable from anything in the repo** — the paper simply does not publish n.
  They are concentrated in `gyrification` (all 3 sources), `cerebral_metabolic_rate` (Karbowski's 23
  tables, Heiss), `cellcounts` (7 items), `cortical_areas` (3 items) and `body_ecology` (35 of 52
  sources). In every case the consequence is the same and is acceptable: those cells stay unweighted
  and say so.
- **4 are not questions at all but defects** — the N is in the file and the script throws it away
  (`body_ecology:116`, `brain_mass:67`, `cellcounts:530-534`, the `cortical_areas` term map). Plus a
  fifth one hop upstream: Baker's `Individuals` and Caspar's `N` are dropped by the
  `____EvoM1_TraitTable/EvoM1_read_*.R` readers before `behaviour` ever sees them.
- **1 is answerable by reading one methods section** — whether HerculanoHouzel et al. 2015's
  `Whole brain n` (Table 5) applies to Tables 1–3. Likely yes, not stated in the tables.
- **1 is an open decision, not a missing fact** — whether to use Kaufman's own weighted summary
  (`TableA15`, with its `weighting` and `CV` columns) instead of computing our own.
- **1 is a different question wearing N's clothes** — `fossil_brain_glucose` needs estimator precision,
  not sample size.

Nothing in the two completed sources is blocked: Ashwell's N is countable for the two monotremes and
`as_published_single_row` for the rest, and Bauernfeind's N reconciles 60/60 against the paper's own
Table 3.

**The one place I would stop and ask before proceeding** is `gyrification`. Its N is unrecoverable, its
two teams are citation-dependent so the merge refuses to average them anyway, and its main source is
currently unregistered so the script cannot run. Weighting is the wrong thing to spend effort on there;
fixing the registry row and deciding whether Zilles should be de-averaged by its `Ref` column is the
real work, and that is a judgement call rather than a data question.

---

## Files this plan adds or changes

New: `weighted_average_readiness.csv` · `sample_size_open_questions.csv` ·
`Bauernfeind_etal_2013/Bauernfeind_etal_2013_reconcile_to_Table3.R` (+ `.py` mirror) ·
`Bauernfeind_etal_2013/Bauernfeind_etal_2013_Table3_reconciliation.csv` ·
`Bauernfeind_etal_2013/Bauernfeind_etal_2013_bilateral_individuals.csv` ·
`Ashwell__2020/Ashwell__2020_published_mean_reconciliation.csv`

Changed: `Ashwell__2020/Ashwell__2020_SupplementaryTable.R` + `.csv` + definitions + public TSV ·
`Bauernfeind_etal_2013/Bauernfeind_etal_2013_Table1.R` + `.csv` + public TSV

Backups: `Ashwell__2020/_prerun_backup_2026-08-19/` · `Bauernfeind_etal_2013/_prerun_backup_2026-08-19/`

# Wiring plan — regional (per-area) cell counts into the cell-count layer

**Written 2026-08-25.** This file was already referenced by a comment in `cell_counts_isotropic_fractionator_compiled.R`
(§ the HH 2013 Table1-a item) but did not exist. It records the design problem and the queue, so
the sources stay visible.

**Status, 2026-11-23.** The owner decided how per-area sources enter this merge and how
one-hemisphere values are served. One source is wired under those decisions: Seelke, Dooley &
Krubitzer 2014 (opossum), below. The five sources in the queue further down are **not** wired yet;
the decisions cover them, and what each still needs is listed with the queue.

## Owner decisions, 2026-11-23

Recorded as review `RV-2026-012` in `_keys/cell_count_methods/expert_reviews.csv`.

- **Per-area values are variables of this merge**, in its own `<Structure>_<code>` form
  (`V1_N.n`, `S1_Mass.g`, `A1_N.p.mg`), served under the dataset `Cell counts`. This is option (a)
  of "The problem" below. **It also applies to the queued Herculano-Houzel et al. 2013 and
  Kaas-lab sources** (owner, 2026-11-23): no separate regional product.
- **Whole neocortex** is the structure `Neocortex` (not `CerebralCortex`), taken from the
  intact-hemisphere row ("Whole neocortex"). The "Σ neocortex" row is the same quantity measured
  less directly (the other hemisphere, dissected, pieces summed) and is not served.
- **V1, S1 and A1** are served as their own regions. **"Rem Ctx"** (remaining cortex) is not a
  structure of the database: held, not served.
- **Hemisphere — the merge's rule.** *"Serve both hemisphere in the comparison but make it clear it
  is doubled; and also offer single. There are many cases where a hemisphere is doubled, we should
  just always do it the same way unless there is a specific note that it is a different kind of
  value."* So: a weight or a number of cells measured in one hemisphere is served as the
  both-hemisphere estimate (2 × the printed value, doubled by this merge) under the plain label,
  marked in `cell_counts_isotropic_fractionator_flags.csv`, **and** as measured under
  `<Structure>_unilateral_<code>`. Densities, percentages and ratios are never doubled. The
  one-hemisphere columns are listed in `laterality_known.csv`; the merge stops if a term and the
  register disagree. Same format, flags and wording as `__merging_volumes`. The full rule is in
  `README__merging.md`, section **Hemispheres**.
- **Units.** Counts printed in millions are served as counts; densities printed in millions per
  gram are served per milligram, under the merge's codes. One code is new, `C.p.mg` (cells per
  mg): no earlier source prints a total-cell density. The glossary codes `C.p.g`, `N.p.g`,
  `O.p.g` stay as the record of the printed unit.
- **Derived ratio.** `_O.p.N` (non-neuronal cells per neuron), which the merge derives from the
  two counts (step 3.7), is served (owner, 2026-11-23).
- **Dispersion.** Values are group means of 5 animals. The printed ± is carried as `_pm`
  (annexed, in the unfiltered table), not as `_SD`: the tables do not label it, the figure
  captions say SEM.
- **Team.** A new team, `Krubitzer` (name confirmed by the owner, 2026-11-23), resolved on its
  own. The merge stops if this team ever holds a species × variable that another team also holds,
  so it cannot change or be averaged with a value already served.

## Wired

| Source | What is served | Held (in the public TSV, not in the merge) | Team |
|---|---|---|---|
| `Seelke_etal_2014_Table3` | `Neocortex_`, `V1_`, `S1_`, `A1_` × `Mass.g` (2 × estimate) and `_unilateral_Mass.g` (as measured) | Σ neocortex and Rem Ctx rows; the "% of Σ neocortex" weight share (no code fits) | Krubitzer |
| `Seelke_etal_2014_Table4` | the same four structures × `C.n`, `N.n`, `O.n` (2 × estimate) and `_unilateral_C.n`, `_N.n`, `_O.n` (as measured); `p.C.N`; `O.p.N` is derived by step 3.7 | Σ neocortex and Rem Ctx rows | Krubitzer |
| `Seelke_etal_2014_Table5` | the same four structures × `C.p.mg`, `N.p.mg`, `O.p.mg` (never doubled) | Σ neocortex and Rem Ctx rows | Krubitzer |

One species, *Monodelphis domestica*; 52 served values: 16 both-hemisphere estimates, the same 16
as measured, and 20 densities, percentages and ratios. Where each piece lives in
`cell_counts_isotropic_fractionator_compiled.R`: item list (step 1), reshape and held rows (1.7,
guarded on the six printed areas), hemisphere register guard (2), unit conversion (3.4n, guarded),
doubling (3.5), `_pm` annexed (6), team (7, 8.1–8.3.S), no `_unilateral_` derivations (9.1),
no-overlap guard (9.2), flags file (9.3). Keys: three files in `standardized_term_by_reference/`;
`laterality_known.csv` (16 rows); `cell_counts_isotropic_fractionator_label_definitions.csv` (one
definition per label, stating the hemisphere basis); 53 rows in `_keys/variable_domain.csv`;
`C.p.mg` in `_keys/glossary.csv`; the Seelke rows of `_keys/cell_count_methods/source_methods.csv`.

**Three things a later per-area source must respect.** (1) The plain labels `Neocortex_`, `V1_`,
`S1_`, `A1_` × `Mass.g`, `C.n`, `N.n`, `O.n` are **both-hemisphere** values. A source that
measured one hemisphere goes through `laterality_known.csv` (`doubling = none`, `_unilateral_`
terms); one whose authors already doubled is registered `by_source`; neither is typed in by hand
under the plain label. (2) The 9.2 guard stops a second team that would hold the same species ×
variable as team Krubitzer; inside one team nothing stops it. (3) `Neocortex_Mass.g` here is not
joined to the `Neocortex_Mass (g)` of `__merging_weights` (no `_keys/variable_canonical.csv` row).
Open item: it is now a both-hemisphere estimate, so the join is possible once the estimate flag
can follow the value into the joined label; the tissue was also weighed after perfusion fixation.

## The problem
`cell_counts_isotropic_fractionator_compiled.R` is organized as species × whole-structure variables (whole brain, cerebral
cortex, cerebellum, RoB …) with team-based within-team resolution (§8.2, most-recent-wins). The
built-but-unwired sources below are **per cortical AREA** (V1, V2, M1, S1 …) — a third axis. Wiring
them needs a decision: (a) reshape long→wide into per-area column families
(`V1_N.n`, `M1_N.p.mm2`, …), or (b) a separate `__merging_regional_cell_counts_isotropic_fractionator` product that stays
long. Option (b) avoids exploding the wide schema and mirrors how regional surfaces are kept as
separate `trait_class = regional` terms in `__merging_cortical_areas`. **Owner decision required
before any build.** *(2026-11-23: decided — option (a), for Seelke et al. 2014 and for the queued
Herculano-Houzel et al. 2013 and Kaas-lab sources. What stays open for the queue is not the form
but the content: per-piece rather than per-area data, shared specimens, values per unit of
cortical surface, and each table's hemisphere basis, which has to be read from the paper and
entered in `laterality_known.csv`.)*

## Ready and waiting — not wired (all built, registered, public TSVs on disk)
| Source | What it holds | Team |
|---|---|---|
| `HerculanoHouzel_etal_2013_Table1-a` | mouse, 18 cortical areas (already commented in the item list) | HH |
| `Collins_etal_2010_DatasetS1` | 4 primates, per-PIECE counts/densities across the flattened cortex — would need piece→area assignment or cortex-level aggregation | Kaas |
| `Collins_etal_2016_Table1` | chimp: cortex, V1, V2, M1, S1-block, premotor-block, PFC counts + densities | Kaas |
| `Young_etal_2013_Table1` | 10 species, M1 cell/neuron densities (per g and per mm²) | Kaas |
| `Young_etal_2013_b_Table1` | baboon V1/S1/M1 + cortex counts — **excluded from merges** (epileptics + Collins-duplicate; only case 11-31 usable). Respect the folder README. | Kaas |

## Constraints to carry into the design
- **Specimen web:** the Kaas tables share specimens (chimp KAAS-PAN-11_38 in Collins 2016 = Young
  2013; baboon 09-27 in Collins 2010 = Young 2013b = Turner). Specimen-level dedupe must come from
  `_keys/specimen_crosswalk/`, not per-source hacks.
- **Teams:** these are Kaas-lab flow-fractionator data — a **new team** alongside HH and Kverkova
  in the §8 resolution logic (or in the separate regional product).
- **Doubling:** these counts are reported per one hemisphere (to be confirmed per table when it is
  wired). They follow the merge's hemisphere rule (README, **Hemispheres**): register the column
  in `laterality_known.csv`, map it to `<Structure>_unilateral_<code>`, and the merge serves the
  measured value and the marked 2 × estimate. Never doubled by hand, never doubled twice. Seelke
  et al. 2014 is the worked example.
- **Whole-cortex values:** Collins 2016 / Young 2013b whole-cortex counts LOOK like they fit the
  existing `CerebralCortex_N.n` columns, but they are single-hemisphere and largely
  specimen-duplicated — do not shortcut them in ahead of the design.
- Mota 2019's `N` (cortical neurons) stays out — it re-reports HH-team counts already merged.

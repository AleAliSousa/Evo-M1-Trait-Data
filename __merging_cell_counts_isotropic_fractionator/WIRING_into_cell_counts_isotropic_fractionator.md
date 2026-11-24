# Wiring plan — regional (per-area) cell counts into the cell-count layer

**Written 2026-08-25.** This file was already referenced by a comment in `cell_counts_isotropic_fractionator_compiled.R`
(§ the HH 2013 Table1-a item) but did not exist. It records the design problem and the queue, so
the sources stay visible.

**Status, 2026-11-24.** The owner decided how per-area sources enter this merge and how
one-hemisphere values are served (2026-11-23), and that those decisions cover the queued
Herculano-Houzel 2013 and Kaas-lab sources. Wired: Seelke, Dooley & Krubitzer 2014 (2026-11-23);
Herculano-Houzel, Watson & Paxinos 2013 Table 1-a, Young, Collins & Kaas 2013 Table 1 and Collins
et al. 2016 (2026-11-24). Not wired: Collins et al. 2010 Dataset S1 and the excluded Young 2013b.
Each wired source stops where it needs the owner: see **Decisions needed**.

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

| `HerculanoHouzel_etal_2013_Table1-a` | 18 mouse areas × `N.n`, `O.n`, `C.n` (2 × estimate) and `_unilateral_N.n`, `_O.n`, `_C.n` (as measured; `C.n` is the sum of the two printed means); `O.p.N` and `p.C.N` derived by step 3.7 | neurons per mm² and per mm³, thickness, the three % columns, the Total row | Herculano-Houzel |
| `Young_etal_2013_a_Table1` | `M1_Mass.g` (2 × estimate), `M1_unilateral_Mass.g`, `M1_C.p.mg`, `M1_N.p.mg`, `M1_p.C.N`; five species | the two baboon rows; cells and neurons per mm²; M1 area; % of total mass, % of total area, % neuron difference | Kaas |
| `Collins_etal_2016_Table1` | `Neocortex_`, `V1_`, `V2_` × `C.n`, `N.n` (2 × estimate) and `_right_C.n`, `_right_N.n`; `p.C.N`; `C.p.mg`, `N.p.mg` (V1, V2) | M1 (superseded by Young 2013, same chimpanzee); somatosensory, premotor and prefrontal blocks; left V1 volume; cells and neurons per cm²; surface area | Kaas |

Served values: *Monodelphis domestica* 52 (Seelke); *Mus musculus* 144 (Herculano-Houzel 2013);
five primates 25 (Young 2013); *Pan troglodytes* 19 (Collins 2016). Where each piece lives in
`cell_counts_isotropic_fractionator_compiled.R`: item list (step 1), reshapes and held rows
(1.7 Seelke, 1.8 Herculano-Houzel 2013, 1.9 Young, 1.10 Collins; each guarded on the printed
rows), hemisphere register guard (2), unit conversions (3.4n, 3.4p, guarded), bat guard (3.4o),
doubling (3.5), `_pm` / `_SD` / `_SEM` / `_n` annexed (6), teams (7, 8.1–8.3.S Krubitzer, 8.1–8.3.Y
Kaas), no `_unilateral_` derivations (9.1), no-overlap guards (9.2), flags file (9.3). Keys: term
files in `standardized_term_by_reference/`; `laterality_known.csv` (81 rows) and
`laterality_known_exceptions.csv`; `cell_counts_isotropic_fractionator_label_definitions.csv` (205
definitions; one per label, naming every source); rows in `_keys/variable_domain.csv`; `C.p.mg`
in `_keys/glossary.csv`; `_keys/cell_count_methods/source_methods.csv` and reviews `RV-2026-012`
to `RV-2026-016`.

## Structure names (per-area labels)

Rule (owner, 2026-11-23, as applied on 2026-11-24): a database label where one exists, otherwise
the paper's own area name.

| Label | Existing or new | What it is in each source |
|---|---|---|
| `Neocortex` | existing | Seelke 2014: intact neocortical hemisphere. Collins 2016: flattened neocortex of the right hemisphere ("cerebral cortex" total) |
| `V1` | existing | Seelke 2014: myelin-dense field. Herculano-Houzel 2013: atlas V1, V1M, V1B. Collins 2016: V1 of the flattened hemisphere |
| `S1`, `A1` | existing | Seelke 2014 only |
| `M1` | existing (cortical areas, cell morphology) | Young 2013: M1 dissected from the flattened hemisphere |
| `V2` | existing (cortical areas, cell morphology) | Collins 2016: the paper's estimate of V2 |
| `S2` | existing (cortical areas) | Herculano-Houzel 2013: atlas S2 |
| `Insula` | existing (volumes) | Herculano-Houzel 2013: AI, GI, DI, AIP, AID, AIV |
| `EntorhinalCortex` | existing (this merge) | Herculano-Houzel 2013 "Entorhinal": DLEnt, DIEnt, MEnt, VIEnt |
| `Infralimbic` | **new** | Herculano-Houzel 2013: PrL, IL, DP |
| `Cingulate` | **new** | Cg1, Cg2 |
| `Retrosplenial` | **new** | RSD, RSGa-c |
| `Parietal` | **new** | LptA, MptA, PTPR (mouse atlas areas, not the parietal lobe) |
| `Motor` | **new** | M1, M2 (so it is **not** `M1`) |
| `Frontal` | **new** | FrA, Fr3 (mouse atlas areas, not the frontal lobe) |
| `V2M` | **new** | V2ML, V2MM |
| `V2L` | **new** | V2L |
| `S1limb` | **new** | the paper's "S1-limb": S1FL, S1HL, S1Sh, S1Tr |
| `S1face` | **new** | the paper's "S1-face": S1J, S1Ulp, S1DZ, S1BF |
| `Auditory` | **new** | AuD, AuI, TeA, AuV (so it is **not** `A1`) |
| `Orbital` | **new** | LO, MO, VO |
| `Ectorhinal` | **new** | EcT, PRh |
| `Piriform` | **new** | Pir, CxA, Apis, BLP |

Atlas abbreviations are as printed in the paper's Table 1 (Franklin & Paxinos 2007).

## Decisions needed

1. **Herculano-Houzel 2020, brain mass.** The bats' neuron numbers are marked as doubled by the
   authors. Is `MBRAIN` (brain mass) also 2 × the one hemisphere? The paper does not say. Not
   marked.
2. **Herculano-Houzel 2013, area names.** Are the 14 new names acceptable as database structures,
   in particular `Motor`, `Frontal`, `Parietal` and `Auditory`, which read like broader regions?
3. **Herculano-Houzel 2013, S1.** The paper splits S1 into "S1-limb" and "S1-face" and prints no
   S1 total. Serve `S1` as their sum (our aggregation; no SEM)? Not served.
4. **Densities per unit of cortical surface or volume.** No measure code exists. Proposed:
   `N.p.mm2`, `C.p.mm2` (neurons, cells under 1 mm² of cortical surface) and `N.p.mm3`. Held in
   all three sources (and in Herculano-Houzel 2013 the denominators are atlas values).
5. **Young 2013, the two baboons.** Cases 09-27 and 11-31 both resolve to *Papio anubis*. Serve
   their mean (n = 2), or one case? Not served.
6. **Collins 2016, M1.** Held as superseded by Young 2013 (same chimpanzee), following the
   2026-08-25 decision for cortical areas. The alternative is to serve the Collins M1 cell and
   neuron numbers, which Young does not print, beside Young's densities.
7. **Collins 2010 Dataset S1.** See the queue below.

**Three things a later per-area source must respect.** (1) The plain per-area labels × `Mass.g`,
`C.n`, `N.n`, `O.n` are **both-hemisphere** values. A source that
measured one hemisphere goes through `laterality_known.csv` (`doubling = none`, `_unilateral_`
terms); one whose authors already doubled is registered `by_source`; neither is typed in by hand
under the plain label. (2) The 9.2 guard stops a second team that would hold the same species ×
variable as team Krubitzer or team Kaas; inside one team nothing stops it. (3) `Neocortex_Mass.g` here is not
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

## The queue (all built, registered, public TSVs on disk)
| Source | What it holds | Team | Status |
|---|---|---|---|
| `HerculanoHouzel_etal_2013_Table1-a` | mouse, 18 cortical areas | HH | **wired 2026-11-24** |
| `Young_etal_2013_a_Table1` | 6 primate species (7 rows), M1 mass and cell/neuron densities (per g and per mm²) | Kaas | **wired 2026-11-24**, baboon rows held |
| `Collins_etal_2016_Table1` | chimp: cortex, V1, V2, M1, S1-block, premotor-block, PFC counts + densities | Kaas | **wired 2026-11-24**: cortex, V1, V2 |
| `Collins_etal_2010_DatasetS1` | 5 cases of 4 primates, 244 tissue PIECES | Kaas | **not wired** — below |
| `Young_etal_2013_b_Table1` | baboon V1/S1/M1 + cortex counts — **excluded from merges** (epileptics + Collins-duplicate; only case 11-31 usable). Respect the folder README. | Kaas | excluded |

**Collins 2010 Dataset S1 — why it is not wired, and what would unblock it.** The supplement is
one row per tissue piece and has no totals of its own.
- *Per area.* Two of the five cases were dissected by the authors into named areas — galago 08-07
  (right hemisphere) and owl monkey 07-78 (left): V1, V2, dV3, vV3, S1, M1, A1, MT, premotor, DL,
  "Remain Ctx", "Surr Ctx". These need no piece-to-area assignment by us. The other three cases
  (galago 07-104, macaque 08-59, baboon 09-27) are numbered grids and would.
- *Whole cortex.* The per-hemisphere totals are approximate figures in the running text, not a
  table. The pieces sum to the text figure for three cases (galago 08-07: 242.5 million cells
  against "243 million"; owl monkey: 553.2 against "more than 553 million"; baboon: 4.674 billion
  against "4.67 billion"). They do not for the other two: macaque 3.41 billion against "nearly 3.5
  billion", and galago 07-104, whose 36 pieces sum to 239 million cells against "≈326 million".
- *Decisions needed first.* (a) Specimens: owl monkey 07-78 is probably Young 2013's owl monkey,
  and galago 08-07 is one of Young's three galagos, so M1 for those species would come from two
  tables of the same team for the same animals — which serves? This file's own rule is that
  specimen dedupe comes from `_keys/specimen_crosswalk/`. (b) The two galago cases are two rows
  for one species (the same question as the baboons). (c) One column would hold a right
  hemisphere for one species and a left for another; the register is per column. (d) Whole-cortex
  totals: sum the pieces, or register the text figures as an item of their own?

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

# Wiring plan — regional (per-area) cell counts into the cell-count layer

**Written 2026-08-25.** This file was already referenced by a comment in `cell_counts_isotropic_fractionator_compiled.R`
(§ the HH 2013 Table1-a item) but did not exist. It records the design problem and the queue, so
the sources stay visible.

**Status, 2026-11-24.** The owner decided how per-area sources enter this merge and how
one-hemisphere values are served (2026-11-23), and that those decisions cover the queued
Herculano-Houzel 2013 and Kaas-lab sources. Wired: Seelke, Dooley & Krubitzer 2014 (2026-11-23);
Herculano-Houzel, Watson & Paxinos 2013 Table 1-a, Young, Collins & Kaas 2013 Table 1, Collins
et al. 2016 and Collins et al. 2010 Dataset S1 (2026-11-24). Not wired: the excluded Young 2013b.
The owner's decisions of 2026-11-24 on the seven questions the wiring raised are in **Owner
decisions, 2026-11-24**; what is still open is in **Decisions still needed**.

## Owner decisions, 2026-11-23

Recorded as review `RV-2026-012` in `_keys/cell_count_methods/expert_reviews.csv`.

- **Per-area values are variables of this merge**, in its own `<Structure>_<code>` form
  (`V1_N.n`, `S1_Mass.g`, `A1_N.p.mg`), served under the dataset `Cell counts`. This is option (a)
  of "The problem" below. **It also applies to the queued Herculano-Houzel et al. 2013 and
  Kaas-lab sources** (owner, 2026-11-23): no separate regional product.
- **Whole neocortex** is the structure `Neocortex` (not `CerebralCortex`), taken from the
  intact-hemisphere row ("Whole neocortex"). The "Σ neocortex" row is a second measurement of the
  same quantity (the other hemisphere of the same animals, dissected, pieces summed) and is not
  served (`not_served.csv`: `second_measurement`).
- **V1, S1 and A1** are served as their own regions. **"Rem Ctx"** (remaining cortex) is not a
  structure of the database and is not served (`not_served.csv`: `not_a_database_structure`).
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
  own. The merge stops if this team ever gives a species × variable that another team also gives,
  so it cannot change or be averaged with a value already served.

## Owner decisions, 2026-11-24

Recorded as reviews `RV-2026-017` to `RV-2026-022` (and `RV-2026-013`). How each is built is in
`README__merging.md`, **Step 7b** and **Step 7c**.

- **Mouse area names** (Herculano-Houzel 2013). *"the table gives definition to what is included
  under the umbrella terms Motor, Frontal, Parietal and Auditory"*: the names stand.
- **Mouse S1.** *"i think the 'S1-limb' and 'S1-face' example shows they sampls those regions but
  not the whole S1"*: no whole-S1 value is built for the mouse, now or later.
- **Densities per surface and per volume.** *"Proposed: C.p.mm2, N.p.mm2 (cells, neurons under 1
  mm² of cortical surface) and N.p.mm3 is good and can be converted easily"*: three new codes; the
  density columns of Young 2013, Collins 2016, Collins 2010 and Herculano-Houzel 2013 are served.
- **The two baboons** (Young 2013). *"if 'Papio cynocephalus anubis' (case 09-27) and 'Papio
  hamadryas anubis' (case 11-31) are the same species we can average them for the merging"*: one
  row, the mean of the two cases; the merge checks that both names are one NCBI taxon.
- **No "hold".** *"i do not really understand the concept of hold. We should register, and just
  indicate they are the same data when it is registered, so that it never double counts. Like a
  code for different data poinst which are actually the same data."* The code is the specimen
  identifier of `_keys/specimen_crosswalk/`; `specimen_key.csv` points at it; rows that share an
  identifier and give the same measure are counted once. Everything else that is not served has a
  status and a reason in `not_served.csv`.
- **Collins 2016, M1; Collins 2010.** *"wire it as I said. we can see they are the same data and
  just register that to avoid double counting."* Both wired.
- **Herculano-Houzel 2020, brain mass** — answered on 2026-11-24 by the internal check the owner
  asked for: `MBRAIN` is the sum of the dissected structures, on the same basis as the neuron
  numbers (`HerculanoHouzel_etal_2020/internal_checks/`). Registered `by_source`. *"the
  hemisphere rule applies to all bats of course"* (2026-11-24): review `RV-2026-013` is
  `accepted`, and the three regional masses this merge computes from the bats' doubled neuron
  numbers (`CerebralCortex_`, `Cerebellum_`, `RoB_Mass.g`; 36 values) are flagged
  `published_bilateral_estimate` as well.
- **Collins 2010, macaque 08-59 and galago 07-104** (*"I agree"*, 2026-11-24; `RV-2026-022`).
  The whole-neocortex cells and neurons of both cases are served from the sum of the supplement's
  samples. Macaque: the weight too. Galago: the species' cells and neurons are the mean of cases
  08-07 and 07-104 (one hemisphere, a right and a left: `Neocortex_unilateral_`); the weight of
  07-104 is not served and no density is derived from it (its area and weight are about 0.6 of
  the other galago hemispheres'), so the species' weight and neurons per mg stay case 08-07. The
  text figures that disagree with the supplement are registered. Whether a case's sum is served
  is now a recorded decision per case (`Collins_etal_2010_case_decisions.csv`), not the 1 % rule.
  Evidence: `Collins_etal_2010/internal_checks/Collins_etal_2010_DatasetS1_internal_check.csv`.

## Wired

| Source | What is served | Not served (status and reason per row or column in `not_served.csv`) | Team |
|---|---|---|---|
| `Seelke_etal_2014_Table3` | `Neocortex_`, `V1_`, `S1_`, `A1_` × `Mass.g` (2 × estimate) and `_unilateral_Mass.g` (as measured) | Σ neocortex row (`second_measurement`); Rem Ctx row (`not_a_database_structure`); the "% of Σ neocortex" weight share (`no_measure_code`) | Krubitzer |
| `Seelke_etal_2014_Table4` | the same four structures × `C.n`, `N.n`, `O.n` (2 × estimate) and `_unilateral_C.n`, `_N.n`, `_O.n` (as measured); `p.C.N`; `O.p.N` is derived by step 3.7 | Σ neocortex and Rem Ctx rows | Krubitzer |
| `Seelke_etal_2014_Table5` | the same four structures × `C.p.mg`, `N.p.mg`, `O.p.mg` (never doubled) | Σ neocortex and Rem Ctx rows | Krubitzer |
| `HerculanoHouzel_etal_2013_Table1-a` | 18 mouse areas × `N.n`, `O.n`, `C.n` (2 × estimate) and `_unilateral_N.n`, `_O.n`, `_C.n` (as measured; `C.n` is the sum of the two printed means); `N.p.mm2`, `N.p.mm3` (as printed; atlas denominators); `O.p.N` and `p.C.N` derived by step 3.7 | thickness and two % columns (`no_measure_code`); % of cortical neurons (`derived_from_registered`); the Total row is not in the TSV | Herculano-Houzel |
| `Young_etal_2013_a_Table1` | `M1_Mass.g` (2 × estimate), `M1_unilateral_Mass.g`, `M1_C.p.mg`, `M1_N.p.mg`, `M1_p.C.N`, `M1_C.p.mm2`, `M1_N.p.mm2`; six species, the baboon as the mean of two cases | M1 area (`other_merge`); % of total mass, % of total area, % neuron difference (`no_measure_code`) | Kaas |
| `Collins_etal_2016_Table1` | `Neocortex_`, `V1_`, `V2_`, `M1_` × `C.n`, `N.n` (2 × estimate) and `_right_C.n`, `_right_N.n`; `p.C.N`; `C.p.mg`, `N.p.mg`, `C.p.mm2`, `N.p.mm2` (V1, V2; for M1 these five are the same data as Young's and are counted once) | somatosensory, premotor and prefrontal blocks (`not_a_database_structure`); left V1 volume (`no_measure_code`); surface area, brain and body mass (`other_merge`) | Kaas |
| `Collins_etal_2010_DatasetS1` | galago 08-07 and owl monkey 07-78: `V1_`, `V2_`, `dV3_`, `vV3_`, `S1_`, `M1_`, `A1_`, `MT_`, `DL_` × `Mass.g`, `C.n`, `N.n` (2 × estimate) and `_right_` / `_left_` (as measured), `p.C.N`, `C.p.mg`, `N.p.mg`, `C.p.mm2`, `N.p.mm2` (for M1 the measures Young also gives are the same data and are counted once); `Neocortex_` × `Mass.g`, `C.n`, `N.n` as the sum of the pieces of each case (all five cases, by the decisions in `Collins_etal_2010_case_decisions.csv`; the galago's cells and neurons are the mean of cases 08-07 and 07-104, served as `Neocortex_unilateral_` and 2 × it; the weight of 07-104 is not served), with `N.p.mg` and `p.C.N` derived | premotor, remaining and surrounding pieces, single grid pieces (`not_a_database_structure`); the weight of galago 07-104 (`excluded`); the text's whole-hemisphere figures for galago 07-104 and macaque 08-59 (`disagrees_with_text`); surface area (`other_merge`) | Kaas |

Served values: *Monodelphis domestica* 52 (Seelke); *Mus musculus* 180 (Herculano-Houzel 2013);
six primates 40 (Young 2013); *Pan troglodytes* 27 (Collins 2016); four primates 216 (Collins
2010). Where each piece lives in `cell_counts_isotropic_fractionator_compiled.R`: item list
(step 1), the not-served register (1.6b), reshapes (1.7 Seelke, 1.8 Herculano-Houzel 2013, 1.9
Young, 1.10 Collins 2016, 1.11 Collins 2010; each guarded on the printed rows and checked against
`not_served.csv`), hemisphere register guard (2), unit conversions (3.4n, 3.4p, guarded), bat
guard (3.4o), doubling (3.5), specimen identifiers (4.3b), `_pm` / `_SD` / `_SEM` / `_n` /
`Specimen` annexed (6), the specimen rule (6b), teams (7, 8.1–8.3.S Krubitzer, 8.1–8.3.Y Kaas), no
`_unilateral_` derivations (9.1), no-overlap guards (8.Y, 9.2), source details (9.2), flags file
(9.3). Keys: term files in `standardized_term_by_reference/`; `laterality_known.csv` (146 rows),
`laterality_known_exceptions.csv`, `laterality_case_side.csv`; `specimen_key.csv`;
`not_served.csv`; `Collins_etal_2010_text_totals.csv`; `Collins_etal_2010_case_decisions.csv`;
`cell_counts_isotropic_fractionator_label_definitions.csv` (337 definitions; one per label, naming
every source); rows in `_keys/variable_domain.csv`; `C.p.mg`, `C.p.mm2`, `N.p.mm2`, `N.p.mm3` in
`_keys/glossary.csv`; `_keys/cell_count_methods/source_methods.csv` and reviews `RV-2026-012` to
`RV-2026-022`.

## Structure names (per-area labels)

Rule (owner, 2026-11-23, as applied on 2026-11-24): a database label where one exists, otherwise
the paper's own area name.

| Label | Existing or new | What it is in each source |
|---|---|---|
| `Neocortex` | existing | Seelke 2014: intact neocortical hemisphere. Collins 2016: flattened neocortex of the right hemisphere ("cerebral cortex" total). Collins 2010: the flattened cortical sheet of one hemisphere ("cortex"), as the sum of the supplement's pieces |
| `V1` | existing | Seelke 2014: myelin-dense field. Herculano-Houzel 2013: atlas V1, V1M, V1B. Collins 2016: V1 of the flattened hemisphere. Collins 2010: one sample cut along the V1/V2 border |
| `S1`, `A1` | existing | Seelke 2014: myelin-dense fields. Collins 2010: the myelin-dense fields of the flattened cortex (S1 = area 3b) |
| `M1` | existing (cortical areas, cell morphology) | Young 2013: M1 dissected from the flattened hemisphere. Collins 2016: the block "designated as motor", which "likely contains most of M1". Collins 2010: location estimated from earlier descriptions; includes area 3a |
| `V2` | existing (cortical areas, cell morphology) | Collins 2016: the paper's estimate of V2. Collins 2010: a strip of approximated width along the V1/V2 border |
| `MT` | existing (cortical areas) | Collins 2010: the myelin-dense middle temporal area |
| `DL` | existing (cortical areas) | Collins 2010: visual cortex between MT and V3, "largely corresponding to the dorsolateral visual area (DL or V4)" |
| `dV3` | **new** (2026-11-24) | Collins 2010: dorsal portion of the third visual area (the paper's V3d), width approximated from the V1/V2 border |
| `vV3` | **new** (2026-11-24) | Collins 2010: ventral portion of the third visual area (the paper's V3v) |
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

## Decisions still needed

1. *(Decided 2026-11-24, see above: Collins 2010, macaque 08-59 and galago 07-104 are served from
   the supplement's sums; `RV-2026-022`.)* The internal check does not support the earlier reading
   that the supplement lacks pieces of galago 07-104: the paper says its 46 pieces were "processed
   as 36 samples", and the supplement has 36.
2. **Which table serves a measure two tables give for the same animal.** Built: Young et al. 2013
   for M1 (`serve_rank` in `specimen_key.csv`), following the 2026-08-25 cortical-areas decision.
   For the owl monkey the two tables print the same numbers (Young rounds them); for the
   chimpanzee and the galago they differ (the M1 pieces differ in extent; for the galago Young's
   value is a three-animal mean).
3. **M1 numbers next to M1 densities from another dissection.** `M1_C.n` and `M1_N.n` (Collins)
   are served beside `M1_Mass.g` and the densities (Young) for the same animals, as decided. They
   do not multiply up (chimpanzee: 625 million cells against 73.01 million per g × 7.52 g = 549
   million). The definitions say so; say if the numbers should carry a visible mark as well.
4. **Collins 2010 choices made in the wiring.** The label `Neocortex` for the paper's "cortex"; the
   1 % tolerance above which a text figure is registered as disagreeing; the side of baboon 09-27 (right, from the Fig. 3 legend and Young et al.
   2013b; not in the supplement); the premotor pieces not served (in the owl monkey the piece is
   "dorsal premotor plus prefrontal cortex").
5. **The baboon name.** The mean row is served as *Papio cynocephalus anubis* (the name printed
   for case 09-27 and by Collins 2010). Young et al. 2013b and Turner et al. 2016 describe case
   09-27 as an anubis × cynocephalus hybrid.
6. **`_keys/specimen_crosswalk/kaas_young_collins_provenance_audit.csv`** says of Young's 09-27
   row "exclude duplicate when Collins 2010 is present". Under the owner's rule of 2026-11-24 it
   is not excluded: Collins 2010 gives no M1 value for that animal, so nothing is counted twice.
   The audit file was not edited.
7. **Young et al. 2013b** stays excluded as a table. Its two normal cases print V1, S1 and M1 cell
   and neuron numbers that no wired table gives.

**Three things a later per-area source must respect.** (1) The plain per-area labels × `Mass.g`,
`C.n`, `N.n`, `O.n` are **both-hemisphere** values. A source that
measured one hemisphere goes through `laterality_known.csv` (`doubling = none`, `_unilateral_`
terms); one whose authors already doubled is registered `by_source`; neither is typed in by hand
under the plain label. (2) The 9.2 guard stops a second team that would give the same species ×
variable as team Krubitzer or team Kaas, and the 8.Y guard stops two Kaas-lab tables that do; if
the cause is a shared animal, register it in `specimen_key.csv` (from `_keys/specimen_crosswalk/`)
and the specimen rule counts it once. Every row or column a new table does not serve needs a row
in `not_served.csv`. (3) `Neocortex_Mass.g` here is not
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
| Source | What it contains | Team | Status |
|---|---|---|---|
| `HerculanoHouzel_etal_2013_Table1-a` | mouse, 18 cortical areas | HH | **wired 2026-11-24** |
| `Young_etal_2013_a_Table1` | 6 primate species (7 rows), M1 mass and cell/neuron densities (per g and per mm²) | Kaas | **wired 2026-11-24** (the two baboon cases as their mean) |
| `Collins_etal_2016_Table1` | chimp: cortex, V1, V2, M1, S1-block, premotor-block, PFC counts + densities | Kaas | **wired 2026-11-24**: cortex, V1, V2, M1 |
| `Collins_etal_2010_DatasetS1` | 5 cases of 4 primates, 244 tissue PIECES | Kaas | **wired 2026-11-24** — below |
| `Young_etal_2013_b_Table1` | baboon V1/S1/M1 + cortex counts — **excluded from merges** (epileptics + Collins-duplicate; only case 11-31 usable). Respect the folder README. | Kaas | excluded |

**Collins 2010 Dataset S1 — how it is wired (2026-11-24).** The supplement is one row per tissue
piece and has no totals of its own.
- *Per area.* Two of the five cases were dissected by the authors into named areas — galago 08-07
  (right hemisphere) and owl monkey 07-78 (left): V1, V2, dV3, vV3, S1, M1, A1, MT, premotor, DL,
  "Remain Ctx", "Surr Ctx". Nine are served as structures; the premotor, remaining and
  surrounding pieces are counted only inside the whole-neocortex sum. The other three cases
  (galago 07-104, macaque 08-59, baboon 09-27) are numbered grids: no per-area values.
- *Whole neocortex.* The sum of a case's pieces, made by this project, for every case, by a
  recorded decision per case (`Collins_etal_2010_case_decisions.csv`). It agrees with the
  whole-hemisphere figures of the paper's text for galago 08-07 (242.5 million cells against "243
  million"), owl monkey (553.2 against "more than 553 million") and baboon (4.674 billion against
  "4.67 billion"). It does not for macaque 08-59 (3.41 billion against "nearly 3.5 billion") and
  galago 07-104 (239 million against "≈326 million"): the sum is served, the text figures are
  registered as disagreeing. The weight of galago 07-104 is not served.
- *Specimens.* Owl monkey 07-78, galago 08-07 and baboon 09-27 are animals of Young 2013:
  `specimen_key.csv` and the specimen rule.
- *Sides.* Right for 08-07 and 09-27, left for 07-78: side-specific columns, one register row each.
Details: `README__merging.md`, **Step 7b**.

## Constraints to carry into the design
- **Specimen web:** the Kaas tables share specimens (chimp KAAS-PAN-11_38 in Collins 2016 = Young
  2013; baboon 09-27 in Collins 2010 = Young 2013b = Turner). Specimen-level dedupe must come from
  `_keys/specimen_crosswalk/`, not per-source hacks. *(Done 2026-11-24: `specimen_key.csv` and the
  specimen rule, step 6b.)*
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

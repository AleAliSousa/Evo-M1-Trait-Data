# Merging cell-counts data

Pipeline for compiling the comparative brain cell-count dataset.

## Steps

1. **Standardized term list** — `standardized_term.R`
   - Input: one term file per table in `standardized_term_by_reference/`
     (`<Reference>_standardized_terms.csv`, columns `Original_Term, Reference, Standardized_Term`).
   - Output: `standardized_term_cell_counts_isotropic_fractionator.csv` (all per-reference files stacked).

2. **Compile cell counts** — `cell_counts_isotropic_fractionator_compiled.R`
   - Merges, filters, and calculates variables across datasets.
   - Inputs: `__Public/comparative-data/*.tsv`, `__ReadMe.xlsx`, `standardized_term_cell_counts_isotropic_fractionator.csv`.
   - Outputs: `cell_counts_isotropic_fractionator_long.csv`, `cell_counts_isotropic_fractionator_wide.csv`.
   - Checks: `cell_counts_isotropic_fractionator_unfiltered.csv`; `cell_counts_isotropic_fractionator_conflictcheck.R`.
   - Species names: `cell_counts_isotropic_fractionator_source_species_ids.csv`.
   - Flagged datasets: `*_metadata_flags.csv`.

3. **Imputations** — `cell_counts_isotropic_fractionator_imputations_diagnostic.R` → `imp30x10.RData`.

## Adding a paper

1. Create `standardized_term_by_reference/<Reference>_standardized_terms.csv` (its terms → standardized terms).
2. Register it in `__ReadMe.xlsx` (Item name → Item encoded) and add it to the `item_name` vector in `cell_counts_isotropic_fractionator_compiled.R`.
3. Put its DOI-coded table in `__Public/comparative-data/<Item encoded>.tsv`.
4. Re-run `standardized_term.R`, then `cell_counts_isotropic_fractionator_compiled.R`.

Most recent addition: `AvelinodeSouza_etal_2025_TABLE1` (*Balaenoptera acutorostrata*, the minke whale).

## Corrections

- **2026-09 — Jardim-Messeder et al. 2017 Table 1, *Procyon lotor* hippocampus mass: laterality-basis
  fix, step 3.4c.** `MHP` is doubled, 0.477 g → 0.954 g. The published raccoon row is internally
  inconsistent by exactly a factor of two: printed `DNHP` (16,076 /mg) is half of `NHP`/`MHP`
  (15.34×10⁶ / 477 mg = 32,159 /mg). Printed `O/NHP` (4.564) equals `OHP`/`NHP`, tying the two
  counts to each other, so only two readings are coherent — a halved mass, or both counts doubled.
  **A density is basis-invariant** (N/M is the same for one side as for both), so `DNHP` cannot be
  corrupted by a side error, and the evidence isolates `MHP` as the single printed error — the mass
  of ONE hippocampus printed against bilateral counts:
  - Of the 42 checkable `N.p.mg` cells in this table, 41 agree with `NHP`/`MHP` to within 0.4%.
    This is the only 2× cell, so it is not a table-wide convention.
  - *Felis catus* has almost the same brain mass (34.86 g vs 34.19 g); its hippocampus is 2.51% of
    brain and the dog's 2.32%. The printed raccoon value is 1.40%, and doubled it is 2.79%.
  - `OHP`/`MHP` as printed is 146,751 /mg, the highest in the table by 1.65×; on the doubled mass it
    is 73,375 /mg, between cat (63,870) and ferret (89,088).
  - Printed `NHP` is 0.71% of `NBR`, in line with ferret 0.79% and cat 0.66%; halving the counts
    instead would drop it to 0.36%. So the counts look right.
  - **Direct confirmation — same species, same method (2026-09-06).** Jacob et al. 2021
    (*J Comp Neurol* 529:3375, DOI 10.1002/cne.25197; Herculano-Houzel a co-author of both papers)
    reports raccoon hippocampus mass **and** hippocampal nuclei counts by isotropic fractionation
    for **one hemisphere** (Methods §2.3–2.4), pooled n-weighted over its three problem-solving
    groups: mass 474.01 mg (n = 18), total nuclei 42.60×10⁶ (n = 18), nonneuronal 36.88×10⁶
    (n = 17). Against the Jardim-Messeder row: the printed **mass matches Jacob's one-hemisphere
    mass to 0.6%** (477 vs 474.01), the printed **total cell count is twice Jacob's
    one-hemisphere count to 0.3%** (85.34×10⁶ vs 2 × 42.60×10⁶), and on the doubled mass the
    total-cell density agrees with Jacob to **0.5%** (89,455 vs 89,874 /mg) where on the printed
    mass it is off by exactly 2×. So the printed mass is unilateral and the printed counts are
    bilateral. Check: `restricted_checks/_cross_table/JardimMesseder_2017_vs_Jacob_2021_raccoon/`
    in the restricted repo. **Caveat:** the neuronal/nonneuronal split does *not* agree — 18.0%
    neurons here against 13.4% implied by Jacob — but Jacob's neuronal count is a difference of
    means over non-identical samples (n = 18 vs 17) from different animals, so it is recorded, not
    used as evidence.
  - **Congener cross-check.** Reep et al. 2007 gives the congener *Procyon cancrivorus*
    `Hippocampus_Vol.mm3` = 1,025.76 at a comparable brain size (36,858 mm³ summed, against 34,100
    mm³ for *P. lotor*), and `__merging_volumes/laterality_known.csv` records Reep values as already
    bilateral. Across size-comparable congeneric pairs, this table's mass ÷ Reep volume runs
    0.72–1.14 (*Canis* 0.904, *Panthera leo* 0.788, *P. leo* vs *pardus* 1.135, *Ursus* 0.717). The
    raccoon sits at 0.451; doubled it is 0.902. The *Mustela* pair is excluded — ferret against the
    much smaller weasel is not size-matched.

  **Effect (2 cells).** `Hippocampus_Mass.g` 0.477 → 0.954 and `Hippocampus_O.p.mg` 146,750.52 →
  73,375.26 /mg. The reported `Hippocampus_N.p.mg` (16,076) is correct and untouched, as are `_C.n`
  and `_p.C.N`. The cell now passes the density-basis check: densities imply O/N = 4.5643 against
  the paper's printed 4.564.

  The frozen source snapshot is deliberately **not** edited — it is the record of what the paper
  printed, and 0.477 is confirmed verbatim from the PDF (Table 1, p. 6). Step 3.4c carries a guard
  that stops the run if the printed value is no longer 0.477 or the row is missing.
  **Cross-confirmed against Jacob et al. 2021 (same species, same method), not author-confirmed.**
  The Jardim-Messeder team has not been asked; revise if they supply the underlying mass or confirm
  the hemisphere basis. **Separately unresolved:** this raccoon's `CerebralCortex` fails the same density
  check by 3.4%, which this correction does not explain. Four other cells fail it by 2–7%
  (*Mustela putorius furo* WholeBrain, and SpinalCord for *Macaca radiata*, *M. mulatta*,
  *Aotus trivirgatus*) and look like printed-precision effects rather than basis errors.

- **2026-09 — cellular ratios and densities are now derived, not only harvested (steps 3.6, 3.7, 6, 9.1).**
  `WholeBrain_N.p.mg` had exactly **one** value in `cell_counts_isotropic_fractionator_long` (*Balaenoptera acutorostrata*,
  `AvelinodeSouza_etal_2025_TABLE1`). That was not a peculiarity of how the minke-whale table was
  compiled. Isotropic fractionation measures a density in each **dissected piece**, so the
  Herculano-Houzel-team tables print densities per structure (cortex, cerebellum, rest of brain)
  and print whole-brain **totals** — but never a whole-brain density, because the whole brain is
  not a dissected piece. Avelino de Souza et al. 2025 is the only table that tabulates a
  whole-brain density row. Meanwhile `WholeBrain_N.n` and `WholeBrain_Mass.g` were present in
  **seven** sources: the ratio was never missing from the data, it was simply never computed.
  Four changes:
  1. **Step 3.6 bug (regional `_C.n` never derived).** `prefixes` was computed once, outside the
     loop, from whatever dataframe the variable `df` was left holding by step 3.4b (Burish et al.
     2010 — WholeBrain / SpinalCord / Body only), so those were the only structures the step ever
     tried. **195** species × structure cells of `_C.n` were silently skipped (Cerebellum 50,
     CerebralCortex 49, RoB 49, OlfactoryBulb 31, Hippocampus 9, plus 7 single-species structures:
     Amygdala, CerebralCortexGrey, CerebralCortexWhite, DiencephalonStriatum, Medulla,
     Mesencephalon, Pons). `prefixes` is now rebuilt per dataframe, and the `!any(is.na(...))` test — which
     gated a whole column on one blank species — is now row-wise.
  2. **New step 3.7: within-source derivation.** `_N.p.mg`, `_O.p.mg`, `_I.p.mg`, `_O.p.N`,
     `_I.p.C`, `_p.C.N` and `_I.n` are filled from each source's own `_N.n` / `_O.n` / `_C.n` /
     `_Mass.g`, so a species × structure ratio stays tied to one paper's specimens and competes in
     the section 8 within-team resolution exactly as a reported value would.
  3. **Step 6: the cellular ratios are no longer annexed.** `_p.C.N` joined `_N.p.mg`, `_O.p.mg`
     and `_O.p.N` in the merge. `_p.C.Brain` stays annexed deliberately — it is a structure
     fraction, and `_keys/glossary.csv` defines it as a volume fraction while the masses and counts
     carried here would give a mass or neuron fraction; its basis needs pinning to the source
     table first.
  4. **Step 9.1 implemented (was commented out).** Ratios still empty after filtering are derived
     from primaries that survived for the same species and structure within the same team, across
     tables, with the two contributing sources joined in `Source`. This is the only route to
     microglia numbers: `DosSantos_etal_2020_unpublished` reports only the microglia/cell ratio
     `_I.p.C`, while `_C.n` and `_Mass.g` for those species come from other HH-team tables, so
     `_I.n = _I.p.C * _C.n` and `_I.p.mg = _I.n / (_Mass.g * 1000)`.

  **Policy: fill-only.** A ratio a source reports is never overwritten. For isotropic-fractionation
  data the density is the measured quantity and the count is density × mass, so a printed density
  carries the authors' precision while a back-calculation from a rounded printed count does not.
  Where both exist they agree to a median |difference| of 0.02–0.24%; the 85 species-cells above 2%
  (worst *Procyon lotor* `Hippocampus_N.p.mg` at 100%, i.e. a factor of two, plausibly a
  one-versus-both-hemispheres basis) are **source-table inconsistencies to inspect**, not values to
  overwrite.

  **Effect.** `cell_counts_isotropic_fractionator_long` 2,465 → 3,259 cells; no cell lost. `WholeBrain_N.p.mg` 1 → 70
  species, `WholeBrain_O.p.mg` 1 → 48, `WholeBrain_O.p.N` 23 → 57, `WholeBrain_p.C.N` 0 → 48,
  `_I.n` and `_I.p.mg` 0 → 70 cells across 5 structures. Five values changed, all
  `WholeBrain_O.p.N` for the five Kazu artiodactyls and all by ≤0.02%: HH 2015 Table 5 now supplies
  a full-precision derived value and, per the documented date-then-species-count tie-break,
  outranks Kazu's 4-significant-figure printed value. Verified against a pre-patch run that
  reproduced the committed `cell_counts_isotropic_fractionator_long/wide/unfiltered` bit-for-bit.

  **Known, not caused by this change:** 18 rows in `cell_counts_isotropic_fractionator_long` carry `NA` values because
  five Kazu text/metadata columns (`Species_Kazu2015`, `body_mass_approximate`,
  `consistency_flags`, `parse_flags`, `source_printing`) are not annexed in step 6 and are coerced
  by `as.numeric` in 9.2 — the source of the "NAs introduced by coercion" warning. Present
  identically before this change.

- **2026-06 — HH-2020 Table 2 derived masses (unit fix), step 3.4.**
  Regional masses not reported in Herculano-Houzel et al. 2020 Table 2
  (`CerebralCortex_Mass.g`, `Cerebellum_Mass.g`, `RoB_Mass.g`) are back-calculated
  from neuron count ÷ neuronal density. Because `_N.p.mg` is neurons per **mg**,
  `_N.n / _N.p.mg` is a mass in **mg** and must be divided by 1000 to get grams.
  The code previously **multiplied** by 1000, inflating those masses by **10⁶** for
  the ~13 African bats in that table (whole-brain masses, reported directly, were
  unaffected). Corrected to `(_N.n / _N.p.mg) / 1000`. Re-run the pipeline to
  propagate the fix.

- **2026-06 — Burish et al. 2010 (two fixes).**
  (a) *Brain = whole brain*: Burish's "Brain" (`MBR`, `NBR`) is the whole brain, so it is now
  mapped to `WholeBrain_Mass.g` / `WholeBrain_N.n` in its standardized-terms file (rather than a
  separate `Brain_*` measure that duplicated WholeBrain). The `Brain_*` measure no longer exists.
  (b) *Units*: Burish tabulated cell COUNTS in **millions** (e.g. *Macaca mulatta* brain "6380" =
  6.38×10⁹ neurons; spinal-cord neuron/other counts likewise). Step 3.4b in `cell_counts_isotropic_fractionator_compiled.R`
  now multiplies `WholeBrain_N.n`, `SpinalCord_N.n(_SD)`, `SpinalCord_O.n(_SD)` by 1e6. Masses (g),
  densities (per mg) and percentages were already absolute and are unchanged. A density sanity scan
  (neurons / (mass×1000) should be ~50–3,000,000 /mg) flagged only Burish; JardimMesseder et al. 2017
  and the other datasets were within range. Re-run `standardized_term.R` then `cell_counts_isotropic_fractionator_compiled.R`.

- **Dos Santos et al. 2020 — published Table 1 excluded; authors' unpublished data used instead.**
  The published Table 1 (main PDF) contains transcription/typographical errors in several cell-count
  values, some physically impossible (neurons or microglia exceeding total cells; e.g. *Tragelaphus
  strepsiceros* whole-brain cells = 21,751,929, ~1000× too small — the unpublished value is
  21,751,929,128). The authors supplied an updated **unpublished** spreadsheet
  (`2020-PublishedDataMammalsMicroglia - cópia.xlsx`; received 22 Mar 2024 via O. S. Todorov from the
  authors' team). Independent checks (`DosSantos_etal_2020/DosSantos_etal_2020_Table1_check.R`; summary
  `DosSantos_etal_2020_comparison_summary.md`) show the unpublished data is internally consistent and
  agrees with older publications (Herculano-Houzel et al. 2015). Therefore `item_name` uses
  `DosSantos_etal_2020_unpublished` (commented out `DosSantos_etal_2020_Table1`). The unpublished file
  contributes the microglia/cell ratio (`*_I.p.C`); cell **numbers** for these species come from older
  primary sources. The published Table 1 is kept only as a reference snapshot.

## Within-team resolution: most recent wins (worked example, Kazu 2015)

`cell_counts_isotropic_fractionator_compiled.R` §8.2 builds a `worth_dataframe` per team, sorting sources by **date
descending, then number of species descending**, and assigns `priority` = row number. §8.3 then
marks every row `WORSE` whose priority is above the minimum for that **species × variable**, and
drops it. So a newer table from the same team supersedes an older one automatically, per
species × variable — there is no manual column filtering and no per-source exclusion list to
maintain.

`Kazu_etal_2015_TABLE1` (added 2026-08-06) is the worked example, and it is instructive because
the date *ties*:

- Kazu is Herculano-Houzel–team work, so it is resolved in §8.2.H alongside `HerculanoHouzel_etal_2015`
  Tables 1–5. Both are dated **2015**.
- The tie-break on species count hands the shared variables to HH (≈40 species against 5).
- Simulated against the published TSVs before wiring: of the five Kazu species,
  **80 species × variable pairs are held by both → HH wins**; **87 pairs are sub-structure values
  only Kazu has** (hippocampus 20, pons + medulla 20, diencephalon + basal ganglia 16,
  mesencephalon 16, cortical grey matter 15); **21 more are whole-structure values HH happens to
  lack for those species**. Kazu contributes 108 values and duplicates none.
- Of the 80 overlapping pairs, **none differ by more than 2%** — HH 2015's full-precision values
  already are the corrigendum's, so which source wins does not change the data. That is the check
  worth repeating whenever a same-team, same-year source is added: if the overlap *disagreed*, the
  priority rule would be silently choosing between two different measurements rather than two
  printings of one.

The older printing, `Kazu_etal_2014_Table1`, is not in `item_name` and should never be: the
corrigendum changed 71 of the 184 cells present in both, and the 2014 values fail
`N_BR = N_CXT + N_CB + N_RoB` by up to −22%. Even if it were listed, its 2014 date would put it
below both — but leaving it out keeps the intent explicit.


## Renamed 4 Nov 2026

Former names: `__merging_cellcounts` and `__merging_cell_counts` (renamed by `_tools/__rename_cell_counts_20261104.R`, owner decisions RV-2026-004 and RV-2026-011). Inside this folder the term became `cell_counts_isotropic_fractionator` (file names, R object names, notes). It holds isotropic- and flow-fractionator counts only; counts made in tissue sections go to `__merging_cell_counts_histology`. Each source's counting method, treatment and flags: `_keys/cell_count_methods/source_methods.csv`.

# Combined encephalic blood-flow table — Seymour 2015 + Boyer & Harrington 2019

First concrete step toward estimating brain glucose metabolic rate in fossil hominins
from primate scaling. This merges the two cranial-canal blood-flow datasets in the repo
into one row per species, on accepted names, with a consistent total-flow column and an
overlap cross-check. **This is a flow table, not a glucose table** — see "Next step".

## Inputs
- **Seymour et al. (2015)** *Scaling of cerebral blood perfusion in primates and
  marsupials.* J Exp Biol 218:2631-2640. `Seymour_etal_2015/Seymour_etal_2015_TableS1.csv`.
  Provides `Total_QICA_cm3_s` — flow through the **internal carotid arteries only** (ICA).
  60 species (primates + diprotodont marsupial outgroup).
- **Boyer & Harrington (2019)** *New estimates of blood flow rates in the vertebral
  artery of euarchontans...* J Hum Evol.
  `Boyer_Harrington_2019/Boyer_Harrington_2019_SOMTableS6.csv` (= SOM Table S6).
  Provides `QICA`, `QVA`, and `QTOT = QICA + QVA` — carotid **plus vertebral** arteries.
  53 species (euarchontans + rodent/lagomorph outgroups).

Both derive flow from the same physics: lumen radius = bony-canal radius / 1.4, a
wall-shear-stress allometry (tau = a*BM^b), and Poiseuille flow. Units are mL/s in both.
That shared method is what makes them combinable.

## Taxonomy
Names resolved to the project's accepted names. Seymour names go through
`_keys/Stephan/species_key.csv` (token `Seymour2015`); Boyer names follow the same
project convention (`Gorilla gorilla -> Gorilla sp.`, `Pongo pygmaeus -> Pongo sp.`).
Boyer has no key token yet — recommend adding one (`Boyer2019`) if this becomes a
permanent merge input.

## Files
- `Seymour_Boyer_flow_combined.csv` — 96 species (union). Columns:
  `accepted_species, suborder, in_Seymour2015, in_Boyer2019, overlap,
  BM_g_Seymour, BM_g_Boyer, ECV_ml_Seymour, ECV_ml_Boyer,
  Sey_QICA_mLs, Boy_QICA_mLs, Boy_QVA_mLs, Boy_QTOT_mLs,
  QICA_ratio_Sey_over_Boy, QTOT_best_mLs, QTOT_source, notes`
- `Seymour_Boyer_QICA_crosscheck.csv` — the 17 overlap species only.
- `Seymour_Boyer_flow_combined.R` — reproducible build (house style; run in R).

## The consistent total-flow column (`QTOT_best_mLs`)
Total encephalic flow requires the vertebral contribution, which **only Boyer supplies**.
So `QTOT_best_mLs` takes Boyer's `QTOT` where available (53 species, `QTOT_source =
Boyer2019_QTOT(ICA+VA)`); for Seymour-only species it is left blank
(`Seymour2015_ICA_only(no_VA;QTOT_unavailable)`) rather than silently using ICA as if it
were the total. Do not substitute Seymour `QICA` into a QTOT analysis — see below for why.

## Overlap cross-check (17 shared species)
- The two methods measure the **same underlying quantity**: Pearson r of log(QICA) = **0.977**.
- But Seymour's ICA-only flow runs systematically **higher**: median Sey/Boy QICA ratio
  **1.67** (geometric mean 1.71), range 0.58-7.93. The largest ratios are strepsirrhines,
  where the ICA is tiny and near-zero absolute values inflate the ratio.
- **Vertebral arteries dominate exactly where Seymour omits them.** Median VA share of
  total flow: **0.98 in strepsirrhines** vs **0.52 in haplorhines**. In *Lemur catta*,
  *Nycticebus*, *Loris*, ICA carries almost none of the encephalic supply — so an ICA-only
  estimate is not a scaled-down total, it is a different variable in those clades.

**Practical rule:** for a total-flow scaling relationship, use `QTOT_best_mLs` (Boyer);
treat `Sey_QICA_mLs` as an ICA-specific quantity, not interchangeable with QTOT. The two
QICA columns can be pooled/averaged for the 17 overlaps if you want a carotid-only series.

## Caveats
- Body-mass source differs (Seymour: Smith & Jungers; Boyer: own compilation), which feeds
  the BM^b shear term. Columns are kept separate (`BM_g_Seymour`, `BM_g_Boyer`) — pick one
  per species before regressing.
- `Sciurus carolinensis` (Boyer) has NA ICA/QICA (cranial-foramen specimen of unknown
  species; flagged in `notes`); its QTOT reflects VA only.
- Seymour's 19 diprotodont marsupials are retained as a non-primate outgroup (`suborder =
  Diprotodontia`); drop them for a primate-only scaling fit.
- Overlap species must be de-duplicated (not treated as independent points) in any pooled
  regression.

## Next step (not in this table)
Neither source measures glucose. To reach CMR_glc you must calibrate flow against
*measured* brain glucose uptake in the species where both exist — the repo has that in
`__energetics_comparison/energetics_merged_long.csv` (Kaufman 2004, Heiss 2004). The
`QTOT_best_mLs` column here is the intended input to that calibration, which is then
applied to fossil-hominin canal measurements (Seymour 2017/2019).

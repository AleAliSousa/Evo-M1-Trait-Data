# Smaers et al. 2017 — frontal-lobe data: source and the prefrontal + frontal-motor question

Scope: the frontal-lobe-related columns carried into `Stephan_primates` from the "Smaers
dataset" — `Prefrontal.Gray`, `Prefrontal.White`, `Frontal.motor.Gray`, `Frontal.motor`
(=frontal motor white). Reference: Smaers JB, Gómez-Robles A, Parks AN, Sherwood CC (2017),
*Current Biology* 27:714–720, "Exceptional Evolutionary Expansion of Prefrontal Cortex in Great
Apes and Humans" (paper PDF + supplement `mmc1.pdf` in this folder).

## 1. Where the frontal-lobe data comes from (paper + supplement)

The values themselves appear **only in the supplement** (Table S1, "Smaers data" block); the
main text just names "the Smaers dataset." The supplement's *Supplemental Experimental
Procedures → Data* states verbatim:

> "Prefrontal and frontal motor data was taken from Smaers et al. [S1, S2] and Brodmann [S3]
> (Table S1)."

So Smaers 2017 did **not** newly measure these; it compiled them from:

- **[S1] Smaers et al. 2010**, *PLoS ONE* — "Frontal white matter volume is associated with brain
  enlargement…" (frontal delineation / 20-section method).
- **[S2] Smaers et al. 2011**, *Brain Behav. Evol.* 77:67–78 — "Primate Prefrontal Cortex
  Evolution…" (the volumetric data; raw tables held locally in `../../Smaers_etal_2011/`).
- **[S3] Brodmann 1909** — used only for the separate **surface-area** sub-table of Table S1, not
  for the volumes.

The volume block (prefrontal/frontal-motor gray & white) is the Smaers 2010/2011 material; the
primary visual column is de Sousa et al. 2010 [S6]; "other" brain data is Stephan et al. 1981
[S7]. All from the same Vogt-Institute specimens.

**Verified against the primary source.** The prefrontal values in Smaers 2017 Table S1 are
exactly Smaers 2011's *Supplementary Table 2* ("volumes … up to the 5th section of the anterior
frontal"), summed across hemispheres (human = mean of 8 individuals): **17 / 17 shared species
match within 2%** (essentially exact). See `frontal_lobe_partition_check.csv`.

## 2. Is (prefrontal + frontal motor) = the entire frontal lobe?  **No.**

**Method (Smaers 2011, *Frontal/Prefrontal Delineation Procedure*).** The frontal lobe is defined
as all neocortex anterior to the area 4 / area 3 border (primary-motor / somatosensory), and its
volume is computed from **20 equidistant coronal sections**. To locate prefrontal vs frontal-motor
cortex without species-by-species cytoarchitecture, they take **cumulative volumes from each end**:

- **Prefrontal** = cumulative volume of the **anterior** sections (frontal-pole end). Smaers 2017
  uses the **5th interval** → the anterior 5 of 20 sections.
- **Frontal motor** = cumulative volume of the **posterior** sections (the end adjacent to the
  area 3/4 border) → the posterior 5 of 20 sections.

These are the **two opposite ends** of the frontal lobe. The ~10 middle sections belong to
neither. Smaers 2011 is explicit: *"This procedure does not provide a single volumetric measure of
either prefrontal or frontal motor areas, but investigates allometric trends at different positions
along the anterior and posterior ends of the frontal lobe."* The measures were built for an
**end-to-end allometric contrast** (anterior prefrontal vs posterior motor), not to partition the
lobe.

**Empirical confirmation.** Adding the Smaers 2017 columns and comparing to Smaers 2011's total
frontal-lobe volume (Supp. Table 1), per species:

> (prefrontal + frontal motor) = **36.5 %** of total frontal lobe on average
> (range **31.5 – 46.9 %**, n = 17; gray matter). The remaining ~63 % is the middle frontal
> cortex captured by neither column.

Example (gray, cm³): *Homo sapiens* prefrontal 46.3 + frontal motor 29.0 = **75.3**, vs total
frontal lobe **204.2** (37 %). *Cercopithecus mitis* 1.38 + 1.85 = **3.23** vs **10.19** (32 %).

**So the two columns cannot be summed to recover frontal-lobe volume.** If a whole-frontal-lobe
figure is needed, use Smaers 2011 Supp. Table 1 (`frontal_grey_total_cm3` + `frontal_white_total_cm3`)
directly. Note also that in the 2017 supplement, "other cortical association areas = neocortex −
**frontal lobe** − primary visual" — there "frontal lobe" means the *full* lobe (Table 1), not the
prefrontal + motor proxy.

### Two caveats worth flagging in the dataset

1. **Frontal motor is not independently reproducible from the public record.** Smaers 2011's
   supplement published only the *anterior* section-5 (prefrontal, Table 2). The *posterior*
   section-5 (frontal motor) was never printed, so the Smaers 2017 frontal-motor column traces to
   the underlying 2010/2011 dataset but **cannot be checked against any published table** (only
   prefrontal can — and it matches exactly).
2. **The split is a biased proxy** (per the authors). Because it uses the area 3/4 border rather
   than the true prefrontal/premotor border, prefrontal is **under**estimated and frontal motor
   **over**estimated in great apes and humans (Smaers 2017, Fig. S2 caption + Data section). The
   *sum's* shortfall from the whole lobe, however, is the excluded middle sections, not this bias.

## Files
- `frontal_lobe_partition_check.csv` — per-species: prefrontal & frontal-motor (2017), their sum,
  the matched Smaers-2011 anterior section-5 and total frontal lobe, and sum-as-%-of-total.
- Source tables: `../../Smaers_etal_2011/Smaers_etal_2011_SupplementaryTable1_snapshot.csv` (total
  frontal), `..._SupplementaryTable2_snapshot.csv` (anterior section-5 = prefrontal).

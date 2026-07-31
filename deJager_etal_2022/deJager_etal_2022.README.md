# de Jager et al. 2022 — transverse foramen ↔ vertebral artery calibration

**Status: DATA STAGED AND VERIFIED — not yet wired into any merge.** The paper's two
tables are transcribed and internally cross-checked. Nothing in the repo reads this
folder yet. **Read the caveats below before wiring it in — one of them invalidates the
originally planned fossil pathway.**

de Jager E, Prigge L, Amod N, Oettlé A, Beaudet A (2022) *Exploring the relationship
between soft and hard tissues: the example of vertebral arteries and transverse
foramina.* **J. Anat.** 241(4), 447–452. doi:10.1111/joa.13681 (open access, CC BY-NC).

## Why this paper is here

The fossil brain-glucose merge (`../__merging_fossil_brain_glucose/`) estimates
whole-brain glucose use from **arterial canal size**, and both existing arterial teams
calibrate that relationship on **extant** animals and then apply it to fossil foramina:

- `Seymour_flow` — carotid **foramen** → ICA flow (extant primate calibration,
  `../Seymour_etal_2015/`).
- `Boyer_ACA_scaled` / `Boyer_ACA_ecvpred` — total arterial canal area (carotid +
  **vertebral**) → BGU (extant euarchontan calibration, `../Boyer_Harrington_2018/`).

Boyer's vertebral contribution for fossils is currently **predicted from ECV** (the
`Boyer_ACA_ecvpred` upper-bound team), not measured. de Jager et al. 2022 supplies the
missing **extant-human calibration for the vertebral artery**: cross-sectional area of
the cervical **transverse foramen** → cross-sectional area of the **vertebral artery**,
measured in the same living individuals by contrast CT, C1–C6. Same logic as
Seymour/Boyer: **calibrate on living animals**, **apply to a fossil**.

## What the paper actually provides

**Sample.** 16 living humans (5 F, 11 M), 21–75 y, South African, post-contrast CT of
the neck (Philips 128 Ingenuity / GE Optima 660), 0.5–1 mm slices. Cross-sectional areas
segmented in Avizo v9.0 on a best-fit plane through each foramen. Inter/intra-observer
error < 5%. The authors call it a *pilot study*.

**Model form.** Areas were log10-transformed (Shapiro–Wilk rejected normality), so:

```
log10(VA_area_mm2) = slope · log10(TF_area_mm2) + intercept
```

Back-transform with `10^(...)`. **No smearing / retransformation correction is given.**

**Two files staged here:**

| File | Content |
|---|---|
| `deJager_etal_2022_calibration.csv` | Table 2 — slope, intercept, Pearson r, per level × side. **C2–C6 only, 15 rows.** |
| `deJager_etal_2022_Table1.csv` | Table 1 — mean and min–max foramen and artery areas, C1–C6, both sides. Descriptive reference distribution. |

Foramen areas span 13.40–71.25 mm²; artery areas 4.53–29.40 mm². Foramen area is large
at C1–C2, dips at C3–C4, and rises again to C6; **artery area stays nearly constant**
(mean 10.6–12.8 mm²) all the way up. That flatness is why the foramen is only a moderate
predictor.

### C1 is excluded on purpose

Table 2 prints C1 coefficients, but the correlation is **not significant** there
(r = 0.38 right, 0.41 left, 0.23 both) and Table S1 reports much worse RMSE/MAE/R².
The atlas foramen is large relative to the artery passing through it, plausibly because
of C1's pivotal biomechanical role. The printed C1 rows are recorded here **for the
record only** and are deliberately kept out of the machine-readable calibration so
nothing downstream can pick them up:

| Level | Side | r | Intercept | Slope |
|---|---|---|---|---|
| C1 | Right | 0.38 (n.s.) | 0.4104 | 0.3854 |
| C1 | Left | 0.41 (n.s.) | −0.1194 | 0.7142 |
| C1 | Both | 0.23 (n.s.) | 0.5013 | 0.3236 |

### `side = "both"` means means, not pooling

Per the Table 2 caption, the combined equation is fitted on the **per-individual mean of
left and right**, not on left and right stacked as separate observations. **n stays 16,
it is not 32.** The authors offer it because their t-test found no significant
left–right asymmetry.

## Verification performed

Raw per-individual data are **not obtainable** — the authors state the CT scans cannot be
released, and supplementary Table S1 holds leave-one-out cross-validation metrics
(RMSE/MAE/R²), not areas. The house refit-and-verify policy used for Boyer/Seymour is
therefore impossible. The transcription is instead checked four ways by
`deJager_etal_2022.R`, all passing:

1. **Text vs table.** The three C2 equations quoted in the running text (p. 450)
   reproduce the C2 rows of Table 2 exactly.
2. **Prediction at the mean.** Each level's mean foramen area (Table 1) pushed through
   its own equation lands within **5.8%** of that level's mean artery area, and almost
   always slightly low — the expected direction for a back-transformed log–log fit.
3. **Range coherence.** The `side = "both"` foramen ranges are the outer envelope of the
   printed right and left ranges.
4. **Independent reproduction of a published summary.** The paper states arteries occupy
   ~35% of foramen area. Recomputing from the transcribed Table 1 over C1–C6 gives
   **35.2%** — an independent confirmation that Table 1 was transcribed correctly.

Output: `deJager_etal_2022_calibration_check.csv`.

> **Transcription note.** The Discussion says the 35% figure was "computed using the
> measurements for C1-C2". C1–C2 alone actually gives 29.8%; C1–C6 gives 35.2%. The
> printed range is almost certainly a typo for C1–C6, consistent with the Results
> section's "Overall … approximately 35%". Recorded, not corrected.

## ⚠ Caveats — read before wiring this into the merge

**1. The planned fossil specimen is the wrong vertebra.** The integration plan pointed at
Beaudet et al. (2020), *The **atlas** of StW 573* — an atlas is **C1**, the one level
where de Jager's calibration does not work. **de Jager 2022 × StW 573 is not a viable
pathway.** Using it needs a fossil **C2–C6** with a preserved transverse foramen. Candidates
cited by the paper itself: Sima de los Huesos (Gómez-Olivencia et al. 2007), Hadar A.L. 333
(Lovejoy et al. 1982), plus the usual Neanderthal cervical material.

**2. The authors restrict the equations to fossil *humans*.** Verbatim: "*Because our study
is restricted to extant humans, at this stage we recommend that our equations are applied
to fossil humans only.*" Applying them to an australopith is an extrapolation the paper
does not endorse. Sima de los Huesos sits comfortably inside the authors' scope;
StW 573 does not — a second reason that pathway is weak.

**3. Three incompatible bone→lumen assumptions would collide.** The fraction of foramen
area occupied by the artery is assumed differently in each component:

| Source | VA lumen area as % of canal area | Basis |
|---|---|---|
| de Jager et al. 2022 | **~35%** | measured, contrast CT, 16 humans |
| `../__flow_comparison/` (`lumen radius = canal radius / 1.4`) | **~51%** | geometric rule of thumb |
| Boyer & Harrington 2019, *Homo sapiens* | **63%** | their own estimate |

Feeding a de Jager VA area into Boyer's BGU regression mixes a measured 35% with a fitted
63% and will bias the result **downward** relative to the existing `Boyer_ACA_*` teams.
This has to be a deliberate, documented choice, not a silent one. Note also that de Jager
gives the VA **area directly**, so the `/1.4` lumen approximation is not needed for the
vertebral artery at all.

**4. Small, clinical, single-population sample.** n = 16 from one South African hospital,
scans collected for clinical indications, ages 21–75. The authors call the data
preliminary. Per-row n is not printed; 16 is taken from the Methods and is consistent with
which correlations are flagged significant.

**5. Log–log retransformation bias.** Uncorrected back-transformation gives a
geometric-mean-like prediction, biased low. Visible as the systematically negative
deviations in the check file.

## Revised integration plan

Superseding the scaffold's original plan (which assumed StW 573):

1. ~~Refit from raw areas~~ — impossible; coefficients transcribed and verified instead. **Done.**
2. **Pick a usable fossil.** Stage a source folder for a hominin **C2–C6** with a measured
   transverse-foramen area, preferably fossil *Homo*. Sima de los Huesos is the best fit to
   the authors' stated scope.
3. Fossil transverse-foramen area → **VA area directly** (this calibration). No `/1.4` step.
4. VA area → lumen radius → VA flow via the wall-shear-stress allometry and Poiseuille
   physics already in `../__flow_comparison/`.
5. Add VA flow to carotid flow → total encephalic flow → Boyer's BGU regression, **with
   caveat 3 documented in the merge README**.
6. New team in `../__merging_fossil_brain_glucose/build_fossil_brain_glucose_merge.py`,
   **filtered only where a measured fossil foramen exists**; keep ECV-predicted VA in
   `*_unfiltered.csv` exactly as `Boyer_ACA_ecvpred` is handled today.
7. Regenerate `fossil_brain_glucose_long/wide/unfiltered.csv`; update that merge's
   references and caveats.

## Files in this folder

| File | Status | Purpose |
|---|---|---|
| `deJager_etal_2022.README.md` | this file | scope, verification, caveats |
| `de Jager-2022-Exploring the relationship betwe.pdf` | staged | the paper |
| `deJager_etal_2022_calibration.csv` | **done** | Table 2 coefficients, C2–C6 × 3 sides |
| `deJager_etal_2022_Table1.csv` | **done** | Table 1 descriptive areas, C1–C6 |
| `deJager_etal_2022_calibration_check.csv` | generated | internal-consistency report |
| `deJager_etal_2022.R` | **runs** | validation + `estimate_VA_area()` accessor |
| `reference_tables/deJager_etal_2022_definitions.csv` | **done** | column definitions |
| _(supplementary Table S1)_ | not staged | LOOCV metrics only; no raw areas, nothing to ingest |

There is no `_snapshot.xlsx` here: this is a digital-native transcription from the PDF
with no upstream spreadsheet to snapshot.

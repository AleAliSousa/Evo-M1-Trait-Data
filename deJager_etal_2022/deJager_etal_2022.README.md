# de Jager et al. 2022 — transverse foramen ↔ vertebral artery calibration

**Status: SCAFFOLD ONLY — no data yet.** This folder is staged and waiting for the
paper's tables. The `*.TEMPLATE.csv` files are empty schemas, not data. Nothing in
the repo reads this folder yet; wiring into `__merging_fossil_brain_glucose/` happens
only after the numbers are in and reproduce.

de Jager E, Prigge L, Amod N, Oettlé A, Beaudet A (2022) *Exploring the relationship
between soft and hard tissues: the example of vertebral arteries and transverse
foramina.* **J. Anat.** 241(4). doi:10.1111/joa.13681.

## Why this paper is here

The fossil brain-glucose merge (`../__merging_fossil_brain_glucose/`) estimates
whole-brain glucose use from **arterial canal size**, and both existing arterial
teams calibrate that relationship on **extant** animals and then apply it to fossil
foramina:

- `Seymour_flow` — carotid **foramen** → ICA flow (extant primate calibration,
  `../Seymour_etal_2015/`).
- `Boyer_ACA_scaled` / `Boyer_ACA_ecvpred` — total arterial canal area (carotid +
  **vertebral**) → BGU (extant euarchontan calibration, `../Boyer_Harrington_2018/`).

Boyer's vertebral contribution for fossils is currently **predicted from ECV**
(the `Boyer_ACA_ecvpred` upper-bound team), not measured — because no fossil
transverse-foramen data were staged. de Jager et al. 2022 supplies the missing
**extant human calibration for the vertebral artery**: cross-sectional area of the
cervical **transverse foramen** → cross-sectional area of the **vertebral artery**,
measured in the same living individuals by contrast CT, C1–C6. That lets a *measured*
fossil transverse foramen replace an ECV-predicted VA.

Same logic as Seymour/Boyer: **calibrate on living animals** (where both the bony
canal and the soft-tissue lumen are visible), **apply to a fossil** (where only the
bone survives).

## What we know from the paper so far (from abstract / search; VERIFY against PDF)

- Transverse-foramen areas ≈ **13.40–71.25 mm²**; vertebral-artery areas ≈
  **4.53–29.40 mm²**.
- Foramen and artery areas are **significantly correlated at C2–C6 but NOT at C1**
  → do **not** use the atlas (C1) transverse foramen to estimate VA size.
- Regression equations are given per vertebral level, explicitly intended for
  estimating VA size in fossils.
- Small extant human sample (~16 individuals; confirm n and whether left/right are
  pooled or separate).

Everything above needs confirming against the actual tables before use.

---

# 👉 WHERE TO ADD FILES

Drop these into **this folder** (`deJager_etal_2022/`). Suggested names mirror the
other source folders (`Seymour_etal_2015/`, `Boyer_Harrington_2018/`).

1. **The PDF** →
   `deJager_etal_2022/deJager-2022-Exploring the relationship betwee.pdf`
   (Author-Year-truncated-title, same as `Seymour-2015-Scaling of cerebral blood perfusi.pdf`.)

2. **Any supplementary tables / spreadsheet** (raw per-individual areas, regression
   output) → drop the original file here as-is, e.g.
   `deJager_etal_2022/joa13681-sup-0001.xlsx` (keep the publisher's name).

3. **Fill the two templates** (rename to drop `.TEMPLATE` once populated):
   - `deJager_etal_2022_calibration.TEMPLATE.csv` → `deJager_etal_2022_calibration.csv`
     — the C2–C6 regression coefficients. **This is the minimum needed to build a team.**
   - `deJager_etal_2022_raw_areas.TEMPLATE.csv` → `deJager_etal_2022_raw_areas.csv`
     — per-individual, per-level foramen & VA areas, **if** a supplementary table
     provides them. Optional but preferred: lets the builder **refit** the regression
     in house style rather than trusting transcribed coefficients (same policy as the
     Boyer/Seymour refits in `__merging_fossil_brain_glucose/`).

4. **Column definitions** → fill `reference_tables/deJager_etal_2022_definitions.csv`
   (a scaffold is already there, matching the `Seymour_etal_2015` definitions layout).

## What is still needed BEYOND this paper to produce a fossil estimate

de Jager et al. 2022 is a **calibration only**. To turn it into a fossil BGU number
you also need a **fossil transverse-foramen measurement** to feed the equation. The
obvious source is a fossil cervical vertebra, e.g.:

> Beaudet A, et al. (2020) *The atlas of StW 573 and the late emergence of human-like
> head mobility and brain metabolism.* **Sci. Rep.** 10:4285. doi:10.1038/s41598-020-60837-2.

If you want that pulled in, it would get its own source folder (`Beaudet_etal_2020/`)
holding the StW 573 atlas transverse-foramen area; this folder stays the *calibration*,
that one supplies the *specimen*. Initially this pathway adds VA data for **one early
fossil** (StW 573, *Australopithecus*), not the 30-specimen Seymour set.

## Planned integration (after data is in — NOT built yet)

1. Refit/record VA-area = f(transverse-foramen area) per level from the staged data.
2. Fossil transverse-foramen area → VA lumen radius → VA flow via the **same physics
   already used** in `../__flow_comparison/` (lumen radius = canal radius / 1.4,
   wall-shear-stress allometry τ = a·BM^b, Poiseuille Q = τ·π·r³ / 4η).
3. Add VA flow to carotid flow → total encephalic flow → feed Boyer's BGU regression.
4. Add as a **new team** in `../__merging_fossil_brain_glucose/build_fossil_brain_glucose_merge.py`,
   **filtered only where a measured fossil foramen exists**; keep ECV-predicted VA in
   `*_unfiltered.csv` exactly as `Boyer_ACA_ecvpred` is handled today.
5. Regenerate `fossil_brain_glucose_long/wide/unfiltered.csv`; update that merge's
   README references + caveats.

## Files in this folder

| File | Status | Purpose |
|---|---|---|
| `deJager_etal_2022.README.md` | this file | scope + drop instructions |
| `deJager_etal_2022_calibration.TEMPLATE.csv` | **TODO** | C2–C6 regression coefficients |
| `deJager_etal_2022_raw_areas.TEMPLATE.csv` | **TODO** | per-individual raw areas (optional, for refit) |
| `reference_tables/deJager_etal_2022_definitions.csv` | **TODO** | column definitions (scaffold present) |
| `deJager_etal_2022.R` | skeleton | house-style extractor/refit (waits on data) |
| _(the PDF)_ | **TODO** | drop here |
| _(supplementary table)_ | **TODO** | drop here if it exists |

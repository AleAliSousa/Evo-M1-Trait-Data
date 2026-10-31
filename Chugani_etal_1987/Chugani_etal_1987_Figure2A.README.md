# Chugani et al. (1987) — Figure 2A (digitised), lCMRGlc vs age

Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). *Positron emission tomography study of
human brain functional development.* Annals of Neurology, 22(4), 487-497.
https://doi.org/10.1002/ana.410220408

**Item:** `Chugani_etal_1987_Figure2A` · **Item encoded:** `10.1002%2Fana.410220408_Figure2A` ·
**Public TSV:** `__Public/comparative-data/10.1002%2Fana.410220408_Figure2A.tsv`

**FIG 2, panel A** (p. 492). Absolute lCMRGlc for four regions of cerebral cortex plotted against
age: filled square = **Frontal cortex**, filled circle = **Parietal cortex**, open circle =
**Temporal cortex**, filled triangle = **Occipital cortex**.

Caption (p. 493): in the infants and children each point is **one individual patient** — one of the
29 listed in Table 1; the rightmost point of each series is the **mean of 7 normal adults aged
19–30 years**, plotted with the symbol size equal to its SEM. Each plotted series therefore carries
**30 points**.

## ⚠️ Digitised data

Every value in `Chugani_etal_1987_Figure2A.csv` was read off the plotted figure. The paper prints only
the **group means** (Table 2); the individual patient values appear nowhere else in the paper.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded grey page bitmaps (2400 × 3449 px)**
  at native resolution — never a re-render — by `Chugani_etal_1987_Figure2_extract.py`
  (conda env `python`; pymupdf, numpy, scipy), run 2026‑10‑31; a second run reports
  "snapshot unchanged". The ordinate is calibrated two‑point (the x‑axis row = 0, the top of the
  y‑axis line = 72 µmol/min/100 g, matching the printed 0…72 ladder in steps of 6 with a minor tick
  every 3). The abscissa is a least‑squares fit on the regular 1‑year ticks (≈ 66.8–67.1 px/year by
  panel), with age 0 on the y‑axis column. The plotting glyphs (filled square, filled circle, open
  circle, filled triangle) were matched by normalised cross‑correlation against templates cut from
  clean isolated markers, with background weighted −1.0 so that neighbouring ink is penalised.
- **Slot constraint.** The abscissa of every point is known in advance, because **Table 1 prints the
  age of all 29 patients**. Detection is therefore constrained: each (patient age, glyph) pair is one
  slot and receives at most one detection, with the adult means sharing a wide slot to the right of
  the 16‑year tick. `subject_slot` is an identification against Table 1, not a free measurement;
  `age_years_from_abscissa` carries the glyph's own pixel‑implied age as a check.
- **Estimated error in the figure's own units: ± 0.3 µmol/min/100 g.** The 13 adult group means
  across all four panels are isolated, uncrowded markers whose true values are printed in Table 2;
  they reproduce it to a mean of +0.03 and a maximum of 0.26 µmol/min/100 g. For this item the
  largest adult deviation is 0.22 µmol/min/100 g.
- **Points contained vs resolved: the figure contains 120 plotted points and 101 were
  individually resolved.** The 19 unresolved points are **absent from the snapshot and the
  CSV — none was inferred or interpolated.** They lie where glyphs overprint: the birth‑to‑1‑year
  cluster (7 patients spanning 0.014–0.63 y ≈ 41 px, with 15 px glyphs) and the 6.7–7.5 y cluster
  (6 patients across ≈ 53 px). Low `ncc_score` marks a crowded glyph.
- **Overprinting can also mis-assign a resolved point.** Where two glyphs touch, the match can land
  on the wrong series. That is visible in the cross‑check below as bins whose points were *all*
  resolved yet whose mean still departs from Table 2.

## Cross-check against Table 2 of the same paper (actual R run, 2026‑10‑31)

Table 2 prints the mean lCMRGlc of the very same patients, by the same four age bins
(n = 7 / 4 / 12 / 6) plus the adult group, for every series plotted here. `table_checks` recomputes
each bin mean from the resolved points: **20 checks, 13 pass, 7 mismatch.**
Tolerance is 0.3 µmol/min/100 g (the isolated‑marker error) widened in proportion to the fraction of
that bin's points that could *not* be resolved.

Where the figure is legible the agreement is close: over the 3–8 y and 9–15 y bins the mean absolute
difference from Table 2 is **0.34 µmol/min/100 g** (maximum 0.68), and the adult points
agree to ≤ 0.22.

Bins that did not pass:

| series | age bin | points resolved | digitised mean | Table 2 | difference | tolerance |
|---|---|---|---|---|---|---|
| Parietal cortex | 1-2 years | 3 / 4 | 30.69 | 28.76 | 1.93 | 1.05 |
| Temporal cortex | 1-2 years | 4 / 4 | 27.56 | 28.64 | -1.09 | 0.3 |
| Parietal cortex | 3-8 years | 11 / 12 | 54.62 | 53.98 | 0.64 | 0.55 |
| Occipital cortex | 9-15 years | 6 / 6 | 45.12 | 45.66 | -0.53 | 0.3 |
| Occipital cortex | Birth-1 year | 5 / 7 | 21.97 | 20.54 | 1.43 | 1.16 |
| Parietal cortex | Birth-1 year | 4 / 7 | 17.23 | 20.23 | -3.0 | 1.59 |
| Temporal cortex | Birth-1 year | 5 / 7 | 21.48 | 20.0 | 1.48 | 1.16 |

These are **reported, not reconciled**: neither the digitisation nor Table 2 was adjusted. A
disagreement here means the plotted glyphs in that bin could not be separated cleanly, not that the
printed table is wrong.


## Pipeline

| file | role |
|---|---|
| `Chugani_etal_1987_Figure2_extract.py` | reproducible bitmap digitisation → the frozen snapshots of both Figure 2 items (one script, because the four panels share one calibration and one glyph set) |
| `Chugani_etal_1987_Figure2A_snapshot.csv` | constructed snapshot: the digitisation as captured, in the figure's own axis units, with the printed series label |
| `Chugani_etal_1987_Figure2A.R` | snapshot → analysis CSV + public TSV; `table_checks` against Table 2 |
| `Chugani_etal_1987_Figure2A.csv` | analysis data, 101 rows |
| `reference_tables/Chugani_etal_1987_Figure2A_definitions.csv` | data dictionary |
| `reference_tables/Chugani_etal_1987_errata.csv` | errata (Table 2) |
| public TSV | `__Public/comparative-data/10.1002%2Fana.410220408_Figure2A.tsv` |

## Observation level and data role

**primary** — this paper's own PET measurements, but `value_origin = digitised_from_figure` on every
row. One row per **resolved plotted point**: `observation_level` distinguishes the individual
patients from the adult group mean; do not pool them. `species_as_published = "human"` (the figure
prints no species name), resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Chugani_etal_1987`).

<!-- errata:begin -->
<!-- errata:end -->

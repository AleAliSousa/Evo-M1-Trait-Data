# Chugani et al. (1987) — Figure 2B–D (digitised), lCMRGlc vs age

Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). *Positron emission tomography study of
human brain functional development.* Annals of Neurology, 22(4), 487-497.
https://doi.org/10.1002/ana.410220408

**Item:** `Chugani_etal_1987_Figure2B-D` · **Item encoded:** `10.1002%2Fana.410220408_Figure2B-D` ·
**Public TSV:** `__Public/comparative-data/10.1002%2Fana.410220408_Figure2B-D.tsv`

**FIG 2, panels B, C and D**. Absolute lCMRGlc plotted against age for nine further regions:
**panel B** (p. 492) Calcarine cortex (filled square), Sensorimotor cortex (filled circle), Anterior
cingulate cortex (open circle) and Transverse temporal cortex (filled triangle); **panel C** (p. 492)
Caudate (head) (filled square), Lenticular nuclei (filled circle) and Thalamus (filled triangle);
**panel D** (p. 493) Cerebellar cortex (filled square) and Brainstem (filled circle).

Caption (p. 493): in the infants and children each point is **one individual patient** — one of the
29 listed in Table 1; the rightmost point of each series is the **mean of 7 normal adults aged
19–30 years**, plotted with the symbol size equal to its SEM. Each plotted series therefore carries
**30 points**.

## ⚠️ Digitised data

Every value in `Chugani_etal_1987_Figure2B-D.csv` was read off the plotted figure. The paper prints only
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
  largest adult deviation is 0.26 µmol/min/100 g.
- **Points contained vs resolved: the figure contains 270 plotted points and 226 were
  individually resolved.** The 44 unresolved points are **absent from the snapshot and the
  CSV — none was inferred or interpolated.** They lie where glyphs overprint: the birth‑to‑1‑year
  cluster (7 patients spanning 0.014–0.63 y ≈ 41 px, with 15 px glyphs) and the 6.7–7.5 y cluster
  (6 patients across ≈ 53 px). Low `ncc_score` marks a crowded glyph.
- **Overprinting can also mis-assign a resolved point.** Where two glyphs touch, the match can land
  on the wrong series. That is visible in the cross‑check below as bins whose points were *all*
  resolved yet whose mean still departs from Table 2.

## Cross-check against Table 2 of the same paper (actual R run, 2026‑10‑31)

Table 2 prints the mean lCMRGlc of the very same patients, by the same four age bins
(n = 7 / 4 / 12 / 6) plus the adult group, for every series plotted here. `table_checks` recomputes
each bin mean from the resolved points: **45 checks, 34 pass, 11 mismatch.**
Tolerance is 0.3 µmol/min/100 g (the isolated‑marker error) widened in proportion to the fraction of
that bin's points that could *not* be resolved.

Where the figure is legible the agreement is close: over the 3–8 y and 9–15 y bins the mean absolute
difference from Table 2 is **0.68 µmol/min/100 g** (maximum 2.95), and the adult points
agree to ≤ 0.26.

Bins that did not pass:

| series | age bin | points resolved | digitised mean | Table 2 | difference | tolerance |
|---|---|---|---|---|---|---|
| Calcarine cortex | 1-2 years | 3 / 4 | 34.81 | 32.39 | 2.42 | 1.05 |
| Sensorimotor cortex | 1-2 years | 4 / 4 | 28.38 | 29.73 | -1.34 | 0.3 |
| Anterior cingulate cortex | 3-8 years | 10 / 12 | 53.61 | 55.08 | -1.47 | 0.8 |
| Calcarine cortex | 3-8 years | 11 / 12 | 61.7 | 61.01 | 0.69 | 0.55 |
| Sensorimotor cortex | 3-8 years | 11 / 12 | 55.8 | 52.85 | 2.95 | 0.55 |
| Transverse temporal cortex | 3-8 years | 11 / 12 | 56.07 | 57.25 | -1.18 | 0.55 |
| Transverse temporal cortex | 9-15 years | 5 / 6 | 47.88 | 47.0 | 0.88 | 0.8 |
| Brainstem | Birth-1 year | 5 / 7 | 20.7 | 18.63 | 2.07 | 1.16 |
| Sensorimotor cortex | Birth-1 year | 5 / 7 | 23.52 | 22.17 | 1.35 | 1.16 |
| Thalamus | Birth-1 year | 7 / 7 | 28.25 | 27.15 | 1.1 | 0.3 |
| Transverse temporal cortex | Birth-1 year | 5 / 7 | 28.22 | 25.47 | 2.75 | 1.16 |

These are **reported, not reconciled**: neither the digitisation nor Table 2 was adjusted. A
disagreement here means the plotted glyphs in that bin could not be separated cleanly, not that the
printed table is wrong.

### Per-panel resolution

| panel | regions | points plotted | resolved |
|---|---|---|---|
| B | Calcarine, Sensorimotor, Anterior cingulate, Transverse temporal cortex | 120 | 103 |
| C | Caudate (head), Lenticular nuclei, Thalamus | 90 | 80 |
| D | Cerebellar cortex, Brainstem | 60 | 43 |

Panel D is the weakest: with only two series the birth‑to‑1‑year points sit almost exactly on top of
one another, and 17 of its 60 points could not be separated.

## Pipeline

| file | role |
|---|---|
| `Chugani_etal_1987_Figure2_extract.py` | reproducible bitmap digitisation → the frozen snapshots of both Figure 2 items (one script, because the four panels share one calibration and one glyph set) |
| `Chugani_etal_1987_Figure2B-D_snapshot.csv` | constructed snapshot: the digitisation as captured, in the figure's own axis units, with the printed series label |
| `Chugani_etal_1987_Figure2B-D.R` | snapshot → analysis CSV + public TSV; `table_checks` against Table 2 |
| `Chugani_etal_1987_Figure2B-D.csv` | analysis data, 226 rows |
| `reference_tables/Chugani_etal_1987_Figure2B-D_definitions.csv` | data dictionary |
| `reference_tables/Chugani_etal_1987_errata.csv` | errata (Table 2) |
| public TSV | `__Public/comparative-data/10.1002%2Fana.410220408_Figure2B-D.tsv` |

## Observation level and data role

**primary** — this paper's own PET measurements, but `value_origin = digitised_from_figure` on every
row. One row per **resolved plotted point**: `observation_level` distinguishes the individual
patients from the adult group mean; do not pool them. `species_as_published = "human"` (the figure
prints no species name), resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Chugani_etal_1987`).

<!-- errata:begin -->
<!-- errata:end -->

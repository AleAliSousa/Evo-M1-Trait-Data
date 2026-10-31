# Heffner et al. (2007) — Figure 4 (digitised), retinal isodensity contours

Heffner, R. S., Koay, G., & Heffner, H. E. (2007). *Sound-localization acuity and its relation to
vision in large and small fruit-eating bats: I. Echolocating species, Phyllostomus hastatus and
Carollia perspicillata.* Hearing Research 234, 1–9. https://doi.org/10.1016/j.heares.2007.06.001

**Item:** `Heffner_etal_2007_Figure4` · **Item encoded:** `10.1016%2Fj.heares.2007.06.001_Figure4` ·
**Public TSV:** `__Public/comparative-data/10.1016%2Fj.heares.2007.06.001_Figure4.tsv`

**Fig. 4** (p. 6). Retinal ganglion-cell isodensity contours for *P. hastatus* (left panel) and
*C. perspicillata* (right panel), shaded at ≥25%, ≥50% and ≥75% of maximum density, each with a
1 mm scale bar and the optic disc marked.

## What "digitising" means for a figure with no axes

This figure plots no variable against another: it is a map. Its quantitative content is **areal**,
and it is the only place the sizes of these two retinae and of their density zones appear. The
item is therefore a **scale-bar planimetry** — retinal outline area, the area of each isodensity
zone, and the nasotemporal / superoinferior extents, all in mm. The *angular* width of the field of
best vision (51° and 110°) is **not** measured here: the paper states it in §3.2 and the sibling
item `Heffner_etal_2007_Figure6` is the source of record for those two numbers; they enter this
item only as the constants that convert the digitised ≥75% extent into degrees per mm.

## Method, precision, and what was resolved

- **Digitisation method:** planimetry of the **embedded 444 × 906 px bitmap** at native resolution
  by `Heffner_etal_2007_Figure4_extract.py` (conda env `python`), run 2026-10-31; a second run
  reports "snapshot unchanged". The two printed 1 mm scale bars measure **75 px** (left panel) and
  **124 px** (right panel) — the panels are at different magnifications, which is why each is
  calibrated separately. The retina is the largest non-white connected component of the panel with
  its interior filled; grey levels partition it into the three zones; the ≥75% field is the black
  component lying strictly inside the retina (erosion by 7 px removes the outline stroke) and larger
  than 300 px, which also excludes the black "25%"/"50%"/"OD" lettering.
- **Estimated error in the figure's own units: about ±3% on areas** (one pixel of contour edge taken
  around the outline) and **±0.027 mm (*P. hastatus*) / ±0.016 mm (*C. perspicillata*)** on linear
  extents (two pixels).
- **Points contained vs resolved: the figure contains two panels — two retinal outlines each with
  three nested contours — and all of them were fully resolved** (one ≥75% component per panel).
  **Nothing was inferred.**

## Cross-checks against this paper's own printed numbers (actual R run 2026-10-31)

| check | observed | printed | status |
|---|---|---|---|
| *P. hastatus* nasotemporal extent | 4.573 mm | "was 4.6 mm in diameter" (§3.2) | pass |
| *C. perspicillata* nasotemporal extent | 2.702 mm | "approximately 2.6 mm in diameter" (§3.2) | pass |
| *P. hastatus* deg/mm from 51° over the ≥75% extent | 42.97 | 39.1 (180° of arc over 4.6 mm, §3.2) | pass |
| deg/mm ratio (Cp / Ph) vs inverse ratio of retinal extents | 1.707 | 1.692 | pass |

The last row is the internal consistency test: the two retinae differ ~1.7-fold in linear size, and
the degrees-per-mm implied independently by their printed fields of best vision differ by the same
factor to **0.8%** — so the digitised ≥75% extents are proportionate to the paper's own angular
statements.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_2007_Figure4_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_2007_Figure4_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_2007_Figure4.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_2007_Figure4.csv` | analysis data |
| `reference_tables/Heffner_etal_2007_Figure4_definitions.csv` | data dictionary |
| `Heffner_etal_2007_Figure4_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1016%2Fj.heares.2007.06.001_Figure4.tsv` |

## Data role
**primary** — this paper's own retinal material, but `value_origin = digitised_from_figure
(scale-bar planimetry)` on both rows.

<!-- errata:begin -->
<!-- errata:end -->

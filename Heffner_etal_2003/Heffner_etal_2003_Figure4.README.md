# Heffner et al. (2003) — Figure 4 (digitised), three phyllostomid audiograms

Heffner, R. S., Koay, G., & Heffner, H. E. (2003). *Hearing in American leaf-nosed bats. III:
Artibeus jamaicensis.* Hearing Research 184, 113–122.
https://doi.org/10.1016/s0378-5955(03)00233-8

**Item:** `Heffner_etal_2003_Figure4` · **Item encoded:** `10.1016%2Fs0378-5955(03)00233-8_Figure4` ·
**Public TSV:** `__Public/comparative-data/10.1016%2Fs0378-5955(03)00233-8_Figure4.tsv`

**Fig. 4** (p. 117). Audiograms for three species of Phyllostomidae, drawn as three line styles
with the functional interaural distance printed after each species name.

## Curve identity

Fixed by the three printed arrows, which run from the stacked labels to the right-hand end of each
curve: **thick grey = *Carollia perspicillata* (47 µs)**, **thin black = *Artibeus jamaicensis*
(96 µs)**, **dotted = *Phyllostomus hastatus* (108 µs)**. This ordering is corroborated by the
physiology the paper argues for (smallest functional interaural distance → highest high-frequency
limit) and by the independent agreement of the *A. jamaicensis* curve with the Results text below.

## ⚠️ Digitised data, not printed values

The paper prints only the summary values for *A. jamaicensis* (see `Heffner_etal_2003_ResultsText`);
the three full audiograms appear only as plotted curves.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded 617 × 945 px bitmap** at native
  resolution by `Heffner_etal_2003_Figure4_extract.py` (conda env `python`), run 2026-10-31; a
  second run reports "snapshot unchanged". Axis ticks were found by scanning offsets outside the
  axis lines for the band yielding exactly the printed tick count (14 abscissa, 10 ordinate). The
  three curves were separated by grey level and connectivity (grey band 130–175 with components
  > 200 px; the single largest < 110 component; all remaining < 110 components ≤ 120 px, with the
  in-panel italic labels and the 60-dB reference line removed by position). Each curve was traced
  as the centre of the longest dark run per column and simplified to polyline vertices by
  Douglas–Peucker (2.0 px black, 2.5 px grey, 3.0 px dotted), merging vertices closer than 4 px.
- **Estimated error in the figure's own units: ±0.2 dB** for the thin black curve and **±0.45 dB**
  for the thick grey and dotted curves (rms of the fitted polyline against the traced pixels:
  1.07, 2.45 and 2.61 px at 0.178 dB/px); **±0.9% in frequency** (log-fit residuals on the 14
  printed ticks, −0.89% to +0.76%).
- **Points contained vs resolved: the figure contains three curves and all three were resolved end
  to end** (49 vertices: 19 grey, 13 black, 17 dotted). **No vertex was inferred.** But note the
  caveat that matters more than the error bar: **the paper does not mark the tested frequencies**,
  so the vertices are the digitiser's breakpoints, reported as extracted and **not snapped** to a
  nominal test series — a vertex is not guaranteed to be a tested frequency, and a tested frequency
  lying on a straight run may produce no vertex. The dotted curve additionally has ink gaps, so its
  vertex count is the least reliable of the three.

## Cross-checks against this paper's own printed numbers (actual R run 2026-10-31)

| check (*A. jamaicensis*, the curve the paper quantifies) | observed | printed | status |
|---|---|---|---|
| low 60-dB limit | 2.83 kHz | 2.8 kHz | pass |
| high 60-dB limit | 130.8 kHz | 131 kHz | pass |
| lowest threshold | 8.77 dB SPL | 8.5 dB SPL | pass |
| frequency of best hearing | 15.75 kHz | 16 kHz | pass |

For reference, the other two curves imply 60-dB ranges of ≈5.1–150 kHz (*C. perspicillata*) and
≈1.8–106 kHz (*P. hastatus*); this paper prints no numbers to check those against.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_2003_Figure4_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_2003_Figure4_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_2003_Figure4.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_2003_Figure4.csv` | analysis data |
| `reference_tables/Heffner_etal_2003_Figure4_references.csv` | per-curve source (Koay et al. 2002 / 2003; A. jamaicensis is this paper) |
| `reference_tables/Heffner_etal_2003_Figure4_definitions.csv` | data dictionary |
| `Heffner_etal_2003_Figure4_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1016%2Fs0378-5955(03)00233-8_Figure4.tsv` |

## Data role
**both** — *A. jamaicensis* is this paper's own audiogram (`primary`); the other two curves are
reproduced from Koay et al. (2002, 2003) (`secondary`).

<!-- errata:begin -->
<!-- errata:end -->

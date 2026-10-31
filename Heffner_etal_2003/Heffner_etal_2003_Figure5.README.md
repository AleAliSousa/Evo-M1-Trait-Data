# Heffner et al. (2003) — Figure 5 (digitised), interaural distance vs high-frequency hearing

Heffner, R. S., Koay, G., & Heffner, H. E. (2003). *Hearing in American leaf-nosed bats. III:
Artibeus jamaicensis.* Hearing Research 184, 113–122.
https://doi.org/10.1016/s0378-5955(03)00233-8

**Item:** `Heffner_etal_2003_Figure5` · **Item encoded:** `10.1016%2Fs0378-5955(03)00233-8_Figure5` ·
**Public TSV:** `__Public/comparative-data/10.1016%2Fs0378-5955(03)00233-8_Figure5.tsv`

**Fig. 5** (p. 119). Log–log scatter of highest audible frequency at 60 dB SPL against functional
interaural distance for mammals; printed statistics *r* = −0.792, *p* ≤ .0001, **n = 67**, plus
three subterranean species drawn as open triangles and excluded from the correlation.

## ⚠️ Digitised data, not printed values — and incomplete by construction

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded 755 × 945 px bitmap** at native
  resolution by `Heffner_etal_2003_Figure5_extract.py` (conda env `python`), run 2026-10-31; a
  second run reports "snapshot unchanged". Ticks were read just outside the axis lines and matched
  to the printed decade labels. Markers were found by normalised cross-correlation with three
  templates cut from the figure itself — an open-circle ring, a filled disc (the eight bat species
  the caption keys) and an open triangle — at peak thresholds (0.40 / 0.50 / 0.60 of the map
  maximum) chosen so that no text glyph is accepted; centres were then refined on the marker's own
  ink (ring annulus or disc centroid).
- **Estimated error in the figure's own units: ±0.9% on both axes** (log-fit residuals on the
  printed ticks: −0.51% to +0.75% on *x*, −0.81% to +0.91% on *y*), plus roughly 0.3% per pixel of
  marker centring.
- **Points contained vs resolved: the figure contains 70 plotted points — the caption's 67 circles
  plus 3 subterranean open triangles — and 62 were individually resolved** (51 open circles,
  8 filled circles, 3 triangles). **8 circles could not be separated from an overlapping neighbour
  and are absent from this item**; this dataset therefore *undercounts* the figure. **No point was
  inferred**: every row in the CSV is a marker found in the ink, and nothing was placed by
  assumption.
- **Identity:** only **21 of the 62 resolved markers carry a printed label**; the other 41 are
  unlabelled comparison points and keep `Species = NA`. Label-to-marker assignment was a separate
  visual step recorded in `reference_tables/Heffner_etal_2003_Figure5_label_assignment.csv`
  (20 `high`, 1 `medium` — "rhesus", whose leader line crosses a crowded cluster).

## Cross-checks against numbers printed in this paper (actual R run 2026-10-31)

| check | observed | printed | status |
|---|---|---|---|
| pocket gopher 60-dB limit | 8.70 kHz | 8.7 kHz (§4.2.3) | pass |
| naked mole rat 60-dB limit | 11.31 kHz | 11.5 kHz (§4.2.3) | pass |
| blind mole rat 60-dB limit | 5.95 kHz | 5.9 kHz (§4.2.3) | pass |
| *A. jamaicensis* 60-dB limit | 137.0 kHz | 131 kHz (Results p. 116) | pass |
| *A. jamaicensis* interaural distance | 92.4 µs | 96 µs (Fig. 4 label) | pass |
| *C. perspicillata* interaural distance | 45.1 µs | 47 µs (Fig. 4 label) | pass |
| *P. hastatus* interaural distance | 102.9 µs | 108 µs (Fig. 4 label) | pass |
| markers resolved of the 70 plotted | 62 | 62 | pass |
| resolved markers carrying a label | 21 | 21 | pass |

The three subterranean triangles reproduce the three numbers §4.2.3 prints to 0.0–1.7%, which is
the strongest evidence that the ordinate calibration is right. The three bat abscissa values sit
2–5% below their printed labels — within the plotting precision of the figure itself, since several
unlabelled points (elephant 3370 µs / 10.4 kHz; human 879 µs / 17.5 kHz; chinchilla 227 µs /
33.0 kHz; cat 260 µs / 78.9 kHz) land on their literature values to ≈1%.

## Source traceability (secondary data)

`reference_tables/Heffner_etal_2003_Figure5_references.csv` resolves **every key the caption
prints** (Aj, Cp, Ef, Ml, Nl, Ph, Ra, Rf) to the full bibliography entry, and adds the three
subterranean triangles from §4.2.3. The ten labels the caption calls "some familiar species …
labeled for comparison" (porpoise, wild mouse, dolphin, harp seal, hooded rat, cat, chinchilla,
rhesus, human, elephant) carry **no citation anywhere in the paper** and are recorded as
`UNRESOLVED`; the 41 unlabelled markers cannot be traced at all.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_2003_Figure5_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_2003_Figure5_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_2003_Figure5.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_2003_Figure5.csv` | analysis data |
| `Heffner_etal_2003_Figure5_digitisation_check.png` | overlay check: detected markers and values drawn on the bitmap |
| `reference_tables/Heffner_etal_2003_Figure5_label_assignment.csv` | marker → printed label (visual step) |
| `reference_tables/Heffner_etal_2003_Figure5_references.csv` | per-point sources, with the unresolved labels declared |
| `reference_tables/Heffner_etal_2003_Figure5_definitions.csv` | data dictionary |
| `Heffner_etal_2003_Figure5_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1016%2Fs0378-5955(03)00233-8_Figure5.tsv` |

## Data role
**secondary** — a Heffner-lab compilation. The one point this paper measured itself (Aj) is carried
as primary by `Heffner_etal_2003_ResultsText`.

<!-- errata:begin -->
<!-- errata:end -->

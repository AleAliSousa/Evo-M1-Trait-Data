# Huttenlocher (1979) — Figure 3, synaptic density (digitised)

Huttenlocher, P. R. (1979). *Synaptic density in human frontal cortex: developmental changes and
effects of aging.* Brain Research, 163(2), 195–205. https://doi.org/10.1016/0006-8993(79)90349-4

**Item:** `Huttenlocher__1979_Figure3` · **Item encoded:** `10.1016%2F0006-8993(79)90349-4_Figure3` ·
**Public TSV:** `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure3.tsv`

**Fig. 3** (p. 199). Synapse counts in layer 3 of the middle frontal gyrus plotted as a function of
age, as filled circles, for 22 postmortem brains from newborn to about 90 years. A hand-drawn trend
line runs through them (dashed where the data are sparse).

## ⚠️ Digitised data — the paper publishes no table

This paper contains **no data table at all**: every value it reports lives in a figure. Everything in
`Huttenlocher__1979_Figure3.csv` was read off the plotted figure.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded grey page bitmap (1950 × 3000 px)** at
  native resolution — never a re-render — by `Huttenlocher__1979_Figures3-6_extract.py` (conda env
  `python`; pymupdf, numpy, scipy), run 2026‑10‑31; a second run reports "snapshot unchanged". One
  script builds all four figure snapshots, because the four figures share one calibration routine and
  one marker-detection routine. Open markers are found as the white region each outline encloses;
  filled markers by eroding the dark mask with a disk, which removes the fitted curve and the error
  bars and leaves one blob per marker.
- **The abscissa is broken and piecewise linear.** Figure 3 prints `NB 0.5 1 // 5 10 15 20 // 40 60 80 100` — three linear segments at three
  different scales, separated by two printed break glyphs.
  Age is interpolated **within** the printed segment a marker falls in (`abscissa_segment` names it).
  A marker lying inside an axis-break gap has its age **extrapolated from the nearer segment** and is
  flagged `age_in_axis_break = yes`; such an age is not an exact reading. 

- **Points contained vs resolved: the figure contains 22 plotted points and 22 were
  individually resolved.** None was inferred and none was interpolated. The paper prints no point
  count for any figure, so 22 is what the detectors find, not a published total.
- **Estimated error in the figure's own units: ± 0.2 ×10⁸ synapses/mm³.** Two independent detectors —
  matched filtering with a circle template, and morphological erosion — return the **same 22 markers
  to within 1 px**, and the adult group mean reproduces the paper's printed 11 ×10⁸ exactly (below).
- **Cross-check against a later replot.** Feinberg et al. (1990) Fig. 1(a) replots 12 of these brains
  (those from birth to about 30 years; N = 12 in their Table 2). Built here as
  `Feinberg_etal_1990_Figure1(a)`, the two independent digitisations agree to a **mean of 0.084 and a
  maximum of 0.159 ×10⁸ synapses/mm³**.

## Table checks (actual R run, 2026‑10‑31)

| check | observed | printed | status |
|---|---|---|---|
| markers resolved | 22 | — (no printed count) | pass |
| brains aged 6 months–7 years | 7 | "n = 7" (p. 199) | pass |
| mean synaptic density, that group | 15.57 ×10⁸ | 14.8 ×10⁸ (p. 199) | **mismatch** (+0.77) |
| lowest value in that group | 13.38 ×10⁸ | "range of 13.5" | pass |
| highest value in that group | 17.04 ×10⁸ | "to 16.5 ×10⁸" | **mismatch** (+0.54) |
| **mean, adult 16–72 years** | **11.00 ×10⁸** | **11 ×10⁸ (p. 201)** | **pass (exact)** |
| brains above age 74 years | 4 | "4 brains above age 74 years" (p. 201) | pass |
| 7‑year value as % above the adult mean | 47.0% | "36% above the adult mean" (p. 202) | **mismatch** (+11) |

The adult check is the strong one: the eight brains aged 16–72 years digitise to a mean of **11.00**
against the **11 ×10⁸** the text prints, which fixes the ordinate calibration to better than
0.1 ×10⁸. Against that, the childhood group mean and the 36% statement do not reproduce from the
plotted points.

Mismatches are **reported, not reconciled**: no value was adjusted on either side.

## Pipeline

| file | role |
|---|---|
| `Huttenlocher__1979_Figures3-6_extract.py` | reproducible bitmap digitisation → the frozen snapshots of all four figure items |
| `Huttenlocher__1979_Figure3_snapshot.csv` | constructed snapshot: the digitisation as captured, in the figure's own axis units |
| `Huttenlocher__1979_Figure3.R` | snapshot → analysis CSV + public TSV; `table_checks` |
| `Huttenlocher__1979_Figure3.csv` | analysis data, 22 rows |
| `reference_tables/Huttenlocher__1979_Figure3_definitions.csv` | data dictionary |
| `reference_tables/Huttenlocher__1979_errata.csv` | errata |
| public TSV | `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure3.tsv` |

## Observation level and data role

**primary** — this paper's own electron-microscope counts, but `value_origin = digitised_from_figure`
on every row. One row per **brain**.

`species_as_published = "human"` on every row (the figure prints no species name; the title and
Methods state human), resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Huttenlocher__1979`).

<!-- errata:begin -->
<!-- errata:end -->

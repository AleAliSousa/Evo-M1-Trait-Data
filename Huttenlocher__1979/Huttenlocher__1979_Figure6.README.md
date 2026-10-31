# Huttenlocher (1979) — Figure 6, brain weights (digitised)

Huttenlocher, P. R. (1979). *Synaptic density in human frontal cortex: developmental changes and
effects of aging.* Brain Research, 163(2), 195–205. https://doi.org/10.1016/0006-8993(79)90349-4

**Item:** `Huttenlocher__1979_Figure6` · **Item encoded:** `10.1016%2F0006-8993(79)90349-4_Figure6` ·
**Public TSV:** `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure6.tsv`

**Fig. 6** (p. 203). Total weights of the brains the study's data were obtained from, against age, as
open circles with ± 1 S.D. confidence limits.

## ⚠️ Digitised data — the paper publishes no table

This paper contains **no data table at all**: every value it reports lives in a figure. Everything in
`Huttenlocher__1979_Figure6.csv` was read off the plotted figure.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded grey page bitmap (1950 × 3000 px)** at
  native resolution — never a re-render — by `Huttenlocher__1979_Figures3-6_extract.py` (conda env
  `python`; pymupdf, numpy, scipy), run 2026‑10‑31; a second run reports "snapshot unchanged". One
  script builds all four figure snapshots, because the four figures share one calibration routine and
  one marker-detection routine. Open markers are found as the white region each outline encloses;
  filled markers by eroding the dark mask with a disk, which removes the fitted curve and the error
  bars and leaves one blob per marker.
- **The abscissa is broken and piecewise linear.** Figures 4, 5 and 6 print `NB 0.5 1 2 // 5 10 // Adult Aged(74-90)`.
  Age is interpolated **within** the printed segment a marker falls in (`abscissa_segment` names it).
  A marker lying inside an axis-break gap has its age **extrapolated from the nearer segment** and is
  flagged `age_in_axis_break = yes`; such an age is not an exact reading. `Adult` and `Aged (74-90)` are **categorical columns, not numeric ages**: `age_years` is NA for them.

- **Points contained vs resolved: the figure contains 10 plotted points and 10 were
  individually resolved.** None was inferred and none was interpolated. The paper prints no point
  count for any figure, so 10 is what the detectors find, not a published total.
- **Estimated error in the figure's own units: ± 10 g** (ordinate fitted on all seven printed ticks).
- **Unit conversion:** the figure prints grams; the analysis CSV carries the project unit for brain
  mass, **mg** (g × 1000), done in the R script.

## Table checks (actual R run, 2026‑10‑31)

| check | observed | printed | status |
|---|---|---|---|
| open circles resolved | 10 | — (no printed count) | pass |
| adult as % above the 2‑year value | 7.2% | "about 20% between ages 2 years and maturity" (p. 202) | **mismatch** (−12.8) |
| adult brain weight | 1233 g | range check only (1350 ± 250 g) | pass |
| newborn brain weight | 332 g | range check only (375 ± 125 g) | pass |

The paper prints **no brain-weight value anywhere**, so there is nothing in the text to check an
individual weight against; the last two rows are range checks, not comparisons with a printed number.
The 20% statement does not reproduce from the plotted points — reported, not reconciled.

Mismatches are **reported, not reconciled**: no value was adjusted on either side.

## Pipeline

| file | role |
|---|---|
| `Huttenlocher__1979_Figures3-6_extract.py` | reproducible bitmap digitisation → the frozen snapshots of all four figure items |
| `Huttenlocher__1979_Figure6_snapshot.csv` | constructed snapshot: the digitisation as captured, in the figure's own axis units |
| `Huttenlocher__1979_Figure6.R` | snapshot → analysis CSV + public TSV; `table_checks` |
| `Huttenlocher__1979_Figure6.csv` | analysis data, 10 rows |
| `reference_tables/Huttenlocher__1979_Figure6_definitions.csv` | data dictionary |
| `reference_tables/Huttenlocher__1979_errata.csv` | errata |
| public TSV | `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure6.tsv` |

## Observation level and data role

**primary** — the weights of this study's own specimens. One row per **brain** for the eight
age-resolved circles; the `Adult` and `Aged (74-90)` circles are **group means**.

`species_as_published = "human"` on every row (the figure prints no species name; the title and
Methods state human), resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Huttenlocher__1979`).

<!-- errata:begin -->
<!-- errata:end -->

# Huttenlocher (1979) — Figure 4, neuronal density (digitised)

Huttenlocher, P. R. (1979). *Synaptic density in human frontal cortex: developmental changes and
effects of aging.* Brain Research, 163(2), 195–205. https://doi.org/10.1016/0006-8993(79)90349-4

**Item:** `Huttenlocher__1979_Figure4` · **Item encoded:** `10.1016%2F0006-8993(79)90349-4_Figure4` ·
**Public TSV:** `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure4.tsv`

**Fig. 4** (p. 200). Neuronal density in layer 3 of the middle frontal gyrus against age, with ± 1 S.D.
confidence limits on the two group points. **Open circles are this study; closed circles are data
obtained by Schade and Van Groenigen (reference 18).**

## ⚠️ Digitised data — the paper publishes no table

This paper contains **no data table at all**: every value it reports lives in a figure. Everything in
`Huttenlocher__1979_Figure4.csv` was read off the plotted figure.

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

- **Points contained vs resolved: the figure contains 14 plotted points and 14 were
  individually resolved.** None was inferred and none was interpolated. The paper prints no point
  count for any figure, so 14 is what the detectors find, not a published total.
- **Estimated error in the figure's own units: ± 0.05 ×10⁴ neurons/mm³** (ordinate fitted on all six
  printed ticks, maximum residual 0.04 ×10⁴).
- **Mixed provenance — this is why the registry role is `both`.** The caption reads "Open circles =
  data derived from the present study. Closed circles = data obtained by Schade and Van Groenigen¹⁸."
  `data_role` is set **per row** from `plot_symbol`: the 10 open circles are `primary`, the 4 filled
  circles are `secondary`. **Filter on `plot_symbol == "open_circle"` before using this item as
  evidence for this paper.**

## Table checks (actual R run, 2026‑10‑31)

| check | observed | printed | status |
|---|---|---|---|
| open circles (this study) | 10 | — (no printed count) | pass |
| filled circles (Schade & Van Groenigen) | 4 | — (no printed count) | pass |
| adult neuronal density | 1.11 ×10⁴ | 1.32 ×10⁴ ± 0.04 S.E.M. (p. 200) | **mismatch** (−0.21) |
| 2‑year value as % above the adult mean | 52.2% | "about 55%" (p. 200) | pass |
| 7‑year value as % above the adult mean | 24.1% | "about 10%" (p. 200) | **mismatch** (+14.1) |
| newborn density, order of magnitude | 10^5.0 | "about 10⁵ neurons/cu.mm" (p. 200) | pass |

The figure is internally consistent with the "55%" statement (the plotted 2‑year and adult circles
stand in a ratio of 1.52) but not with the printed adult value of 1.32 ×10⁴, from which the 2‑year
value would have to be 2.05 ×10⁴. Recorded as erratum `Huttenlocher__1979-E001`
(publication_ambiguity); nothing was adjusted.

Mismatches are **reported, not reconciled**: no value was adjusted on either side.

## Pipeline

| file | role |
|---|---|
| `Huttenlocher__1979_Figures3-6_extract.py` | reproducible bitmap digitisation → the frozen snapshots of all four figure items |
| `Huttenlocher__1979_Figure4_snapshot.csv` | constructed snapshot: the digitisation as captured, in the figure's own axis units |
| `Huttenlocher__1979_Figure4.R` | snapshot → analysis CSV + public TSV; `table_checks` |
| `Huttenlocher__1979_Figure4.csv` | analysis data, 14 rows |
| `reference_tables/Huttenlocher__1979_Figure4_definitions.csv` | data dictionary |
| `reference_tables/Huttenlocher__1979_Figure4_references.csv` | the secondary source of the 4 filled circles (ref. 18, Schade & van Groenigen 1961), verbatim from the bibliography (p. 205) |
| `reference_tables/Huttenlocher__1979_errata.csv` | errata |
| public TSV | `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure4.tsv` |

## Observation level and data role

**both** — 10 open circles are this paper's own counts (`primary`) and 4 filled circles are Schade
and Van Groenigen's values replotted (`secondary`); `data_role` carries this per row. One row per
**brain** for the age-resolved circles; the `Adult` and `Aged (74-90)` circles are **group means**.

`species_as_published = "human"` on every row (the figure prints no species name; the title and
Methods state human), resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Huttenlocher__1979`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Huttenlocher__1979_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Huttenlocher__1979-E001 | Neuronal_density.neurons_mm3 | Fig. 4, p. 200, the 'Adult' open circle, against the running text on the same page | 1.32 x 10^4 +/- 0.04 S.E.M. | 1.11 x 10^4 | publication_ambiguity |  | proposed | The text on p. 200 states 'Density of neurons in layer 3 at age 2 years was about 55% above the adult mean of 1.32 x 10^4 +/- 0.04 S.E.M.'. The adult open circle of Fig. 4 digitises to 1.11 x 10^4 (ordinate calibrated on all six printed ticks, max residual 0.04 x 10^4). The figure is internally consistent with the 55% statement - the 2-year open circle digitises to 1.68 x 10^4, i.e. 52% above the plotted adult value - but not with the printed adult value of 1.32, from which the 2-year value would have to be 2.05 x 10^4. The same page says the 7-year brain was 'about 10% above the adult mean'; the figure gives 24%. | The CSV keeps the digitised figure value. This is a text-versus-figure discrepancy inside the publication, not a transcription error; neither side was adjusted. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

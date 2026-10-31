# Huttenlocher (1979) — Figure 5, synapses per neuron (digitised)

Huttenlocher, P. R. (1979). *Synaptic density in human frontal cortex: developmental changes and
effects of aging.* Brain Research, 163(2), 195–205. https://doi.org/10.1016/0006-8993(79)90349-4

**Item:** `Huttenlocher__1979_Figure5` · **Item encoded:** `10.1016%2F0006-8993(79)90349-4_Figure5` ·
**Public TSV:** `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure5.tsv`

**Fig. 5** (p. 203). Mean number of synapses per neuron in layer 3 of the middle frontal gyrus against
age, as open triangles with ± 1 S.D. confidence limits.

## ⚠️ Digitised data — the paper publishes no table

This paper contains **no data table at all**: every value it reports lives in a figure. Everything in
`Huttenlocher__1979_Figure5.csv` was read off the plotted figure.

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
- **Estimated error in the figure's own units: ± 0.05 ×10⁴ synapses/neuron.**
- ### ⚠️ This figure is derived, not measured

  Its caption reads "Mean number of synapses per neuron, **derived from data of the present study**, as
  a function of age", and p. 202 states that the value was calculated from packing density together
  with synaptic density. **Figure 5 = Figure 3 ÷ Figure 4.** The build verifies the arithmetic (below).
  **Do not treat this item as evidence independent of `Huttenlocher__1979_Figure3` and
  `Huttenlocher__1979_Figure4`** — using all three together double-counts the same measurements. The
  10 triangles correspond one for one to the 10 open circles of Fig. 4.

## Table checks (actual R run, 2026‑10‑31)

| check | observed | printed | status |
|---|---|---|---|
| triangles resolved | 10 | — (no printed count) | pass |
| **max \|Fig5 × Fig4 − nearest Fig3 value\|** | **1.01 ×10⁸** | 0 if Fig. 5 = Fig. 3 / Fig. 4 | pass (tol 1.1) |
| mean \|Fig5 × Fig4 − nearest Fig3 value\| | 0.24 ×10⁸ | 0 | pass (tol 0.4) |
| synapses per neuron at birth | ~7,500 | "about 10,000 at birth" (p. 202) | pass |
| synapses per neuron at age one year | ~97,000 | "to 100,000 at age one year" (p. 202) | pass |

The derivation test multiplies each triangle by the neuronal density plotted at the same abscissa in
Fig. 4 and asks whether the product is one of the 22 synaptic densities plotted in Fig. 3. It is, to a
mean of 0.24 ×10⁸. The single large deviation is the `Aged (74-90)` column, where Fig. 5 plots one
mean but Fig. 3 plots four separate brains.

Mismatches are **reported, not reconciled**: no value was adjusted on either side.

## Pipeline

| file | role |
|---|---|
| `Huttenlocher__1979_Figures3-6_extract.py` | reproducible bitmap digitisation → the frozen snapshots of all four figure items |
| `Huttenlocher__1979_Figure5_snapshot.csv` | constructed snapshot: the digitisation as captured, in the figure's own axis units |
| `Huttenlocher__1979_Figure5.R` | snapshot → analysis CSV + public TSV; `table_checks` |
| `Huttenlocher__1979_Figure5.csv` | analysis data, 10 rows |
| `reference_tables/Huttenlocher__1979_Figure5_definitions.csv` | data dictionary |
| `reference_tables/Huttenlocher__1979_errata.csv` | errata |
| public TSV | `__Public/comparative-data/10.1016%2F0006-8993(79)90349-4_Figure5.tsv` |

## Observation level and data role

**primary** in the registry, but the values are **derived from two other items of the same paper** —
see the warning above. One row per **brain** for the eight age-resolved triangles; the `Adult` and
`Aged (74-90)` triangles are **group means**.

`species_as_published = "human"` on every row (the figure prints no species name; the title and
Methods state human), resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Huttenlocher__1979`).

<!-- errata:begin -->
<!-- errata:end -->

# Feinberg et al. (1990) — Figure 1(a) (digitised), synaptic density

Feinberg, I., Thode, H. C., Jr., Chugani, H. T., & March, J. D. (1990). *Gamma distribution model
describes maturational curves for delta wave amplitude, cortical metabolic rate and synaptic density.*
Journal of Theoretical Biology, 142, 149–161. https://doi.org/10.1016/S0022-5193(05)80218-8

**Item:** `Feinberg_etal_1990_Figure1(a)` · **Item encoded:** `10.1016%2FS0022-5193(05)80218-8_Figure1(a)` ·
**Public TSV:** `__Public/comparative-data/10.1016%2FS0022-5193(05)80218-8_Figure1(a).tsv`

**FIG. 1(a)** (p. 152). The raw synaptic-density observations the authors fitted their gamma
distribution model to, as open circles, with the fitted curve.

## ⚠️ Secondary data — these are Huttenlocher's measurements

**Feinberg et al. measured nothing in this panel.** The 12 plotted observations are
**Huttenlocher (1979)**, as this paper's own Table 2 states (N = 12 for synaptic density) and its
text says at p. 150. `data_role = secondary` on every row, `primary_source_ref_key` carries the key,
and `reference_tables/Feinberg_etal_1990_Figure1(a)_references.csv` carries the verbatim citation
taken from this paper's bibliography (p. 160).

**For the measurements themselves, use `Huttenlocher__1979_Figure3` — not this item.** What this
panel adds is the **ages**: Feinberg's abscissa is a single linear 0–35 year axis, whereas
Huttenlocher's Fig. 3 abscissa is broken into three linear segments at three different scales, so
where the two disagree on an age this panel is the better reading.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded grey page bitmap (1890 × 2850 px,
  PDF p. 4)** at native resolution — never a re-render — by `Feinberg_etal_1990_Figure1_extract.py`
  (conda env `python`; pymupdf, numpy, scipy), run 2026‑10‑31; a second run reports "snapshot
  unchanged". One script builds both panels' snapshots. **Both axes are single linear axes** (0–35
  years on the abscissa), calibrated on the eight printed 5‑year ticks and on the row centres of the
  printed ordinate labels; the ordinate rule is slightly skewed on this scan, so a fixed-column tick
  scan misses some ticks. Circles are found two ways and merged — the white region each ring
  encloses, and normalised cross-correlation against a ring template cut from an isolated circle,
  which recovers rings the fitted gamma curve has broken. `marker_detection` records which found
  each point. The `(a)` / `(c)` panel-letter box is excluded, because those letters enclose holes too.
- **Estimated error in the figure's own units: ± 0.2 ×10⁸ synapses/mm³ and ± 0.2 y.**
- **Points contained vs resolved: the panel contains 12 plotted points and all 12 were individually
  resolved.** None was inferred.

## Cross-check against the primary source (actual R run, 2026‑10‑31)

`Huttenlocher__1979_Figure3` is built in this repo from Huttenlocher's own figure. It plots 22
brains; Feinberg used "only data from birth to 30 years of age" (p. 152), which is 12 of them — the N
its Table 2 prints. The two sets are paired by sorted value (no common key exists).

| check | observed | expected | tolerance | status |
|---|---|---|---|---|
| points in Fig. 1(a) | 12 | 12 (Table 2, N) | 0 | pass |
| Huttenlocher Fig. 3 brains ≤ 32 y | 12 | 12 | 0 | pass |
| **mean \|value difference\|** | **0.084 ×10⁸** | 0 | 0.2 | **pass** |
| **max \|value difference\|** | **0.159 ×10⁸** | 0 | 0.3 | **pass** |
| max \|age difference\|, source points not in an axis break (n = 10) | 0.85 y | 0 | 1.0 | pass |
| max \|age difference\|, all 12 points | 1.44 y | 0 | 1.0 | **mismatch** |

**The values agree.** Two independent digitisations, of two different figures in two different
papers, reproduce the same 12 synaptic densities to a mean of 0.084 and a worst case of 0.159 ×10⁸
synapses/mm³ — inside the summed digitisation error of the two figures.

**The ages do not fully agree, and the disagreement is explained.** The two largest age differences
(1.44 y and 0.88 y) are exactly the two Huttenlocher points that fall **inside an axis-break gap** of
his Fig. 3, where an age cannot be read between two ticks and has to be extrapolated. A third pair
differs by 0.85 y (Huttenlocher 5.14 y, Feinberg 5.99 y) for a point sitting on his "5" tick. This is
**reported, not reconciled**: neither digitisation was adjusted to the other.

## Pipeline

| file | role |
|---|---|
| `Feinberg_etal_1990_Figure1_extract.py` | reproducible bitmap digitisation → the frozen snapshots of both Figure 1 items |
| `Feinberg_etal_1990_Figure1(a)_snapshot.csv` | constructed snapshot, in the figure's own axis units |
| `Feinberg_etal_1990_Figure1(a).R` | snapshot → analysis CSV + public TSV; `table_checks` against the primary source |
| `Feinberg_etal_1990_Figure1(a).csv` | analysis data, 12 rows |
| `reference_tables/Feinberg_etal_1990_Figure1(a)_references.csv` | the primary citation for every plotted point |
| `reference_tables/Feinberg_etal_1990_Figure1(a)_definitions.csv` | data dictionary |
| public TSV | `__Public/comparative-data/10.1016%2FS0022-5193(05)80218-8_Figure1(a).tsv` |

## Observation level and data role

**secondary** — one row per plotted observation = one postmortem brain measured by Huttenlocher
(1979). **Never merge this item as primary evidence**; it is a provenance record and an age source.
`species_as_published = "human"`, resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Feinberg_etal_1990`).

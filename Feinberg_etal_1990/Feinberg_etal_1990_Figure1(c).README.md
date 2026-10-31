# Feinberg et al. (1990) — Figure 1(c) (digitised), cerebral metabolic rate

Feinberg, I., Thode, H. C., Jr., Chugani, H. T., & March, J. D. (1990). *Gamma distribution model
describes maturational curves for delta wave amplitude, cortical metabolic rate and synaptic density.*
Journal of Theoretical Biology, 142, 149–161. https://doi.org/10.1016/S0022-5193(05)80218-8

**Item:** `Feinberg_etal_1990_Figure1(c)` · **Item encoded:** `10.1016%2FS0022-5193(05)80218-8_Figure1(c)` ·
**Public TSV:** `__Public/comparative-data/10.1016%2FS0022-5193(05)80218-8_Figure1(c).tsv`

**FIG. 1(c)** (p. 152). The raw cerebral metabolic-rate observations the authors fitted their gamma
distribution model to, as open circles, with the fitted curve.

## ⚠️ Secondary data — these are Chugani's measurements

**Feinberg et al. measured nothing in this panel.** The 29 plotted observations are the **frontal
cortex lCMRGlc values of Chugani, Phelps & Mazziotta (1987)**, as this paper's Table 2 states (N = 29
for CMR) and its text says at p. 150 — the same 29 patients Chugani's Table 1 lists.
`data_role = secondary` on every row, `primary_source_ref_key` carries the key, and
`reference_tables/Feinberg_etal_1990_Figure1(c)_references.csv` carries the verbatim citation taken
from this paper's bibliography (p. 160).

**For the measurements themselves, use `Chugani_etal_1987_Figure2A` (individual values) or
`Chugani_etal_1987_Table2` (group means) — not this item.**

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
- **Estimated error in the figure's own units: ± 0.5 µmol/min/100 g and ± 0.2 y.**
- **Points contained vs resolved: the panel contains 29 plotted points and 28 were individually
  resolved.** The 29th could not be separated from its neighbour in the 3–8 year cluster; it is
  **absent, not inferred**.

## Cross-check against the primary source (actual R run, 2026‑10‑31)

Chugani's Table 2 prints the frontal-cortex mean lCMRGlc of the very same patients in four age bins
of n = 7 / 4 / 12 / 6. Bin membership is fixed by the patients' printed ages, so the resolved points
are assigned to bins **by age rank**, not by Feinberg's own abscissa reading (which places Chugani's
1.0‑year patient just below 1 y); the one unresolved point is taken out of the 3–8 y bin, which is
where it lies.

| check | observed | Chugani Table 2 | tolerance | status |
|---|---|---|---|---|
| points resolved | 28 | 29 | 0 | **mismatch** (one not separable) |
| mean, Birth–1 year (n = 7) | 20.53 | 19.68 | 1.0 | pass (+0.85) |
| mean, 1–2 years (n = 4) | 29.89 | 29.65 | 1.0 | pass (+0.24) |
| **mean, 3–8 years (11 of 12)** | **54.06** | **54.01** | 1.0 | **pass (+0.05)** |
| mean, 9–15 years (n = 6) | 45.36 | 44.59 | 1.0 | pass (+0.77) |
| lowest plotted value | 15.1 | 14.8 (Chugani Fig. 2A, digitised) | 2.0 | pass |
| highest plotted value | 60.3 | 59.7 (Chugani Fig. 2A, digitised) | 2.0 | pass |

**The agreement is close**: all four bin means reproduce Chugani's printed frontal-cortex means to
within 0.85 µmol/min/100 g, and the best-resolved bin to 0.05. A **point-by-point** comparison is
**not possible**: neither figure resolves all 29 points (28 here, 25 in the Chugani Fig. 2A
digitisation) and there is no key to pair individual points on.

## Pipeline

| file | role |
|---|---|
| `Feinberg_etal_1990_Figure1_extract.py` | reproducible bitmap digitisation → the frozen snapshots of both Figure 1 items |
| `Feinberg_etal_1990_Figure1(c)_snapshot.csv` | constructed snapshot, in the figure's own axis units |
| `Feinberg_etal_1990_Figure1(c).R` | snapshot → analysis CSV + public TSV; `table_checks` against the primary source |
| `Feinberg_etal_1990_Figure1(c).csv` | analysis data, 28 rows |
| `reference_tables/Feinberg_etal_1990_Figure1(c)_references.csv` | the primary citation for every plotted point |
| `reference_tables/Feinberg_etal_1990_Figure1(c)_definitions.csv` | data dictionary |
| public TSV | `__Public/comparative-data/10.1016%2FS0022-5193(05)80218-8_Figure1(c).tsv` |

## Observation level and data role

**secondary** — one row per plotted observation = one patient of Chugani et al. (1987) Table 1.
**Never merge this item as primary evidence**; it is a provenance record.
`species_as_published = "human"`, resolved to *Homo sapiens* through `_keys/General/species_key.csv`
(`source_publication = Feinberg_etal_1990`).

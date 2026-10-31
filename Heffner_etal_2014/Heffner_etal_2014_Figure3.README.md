# Heffner et al. (2014) — Figure 3 (digitised), alpaca audiogram

Heffner, R. S., Koay, G., & Heffner, H. E. (2014). *Hearing in alpacas (Vicugna pacos):
Audiogram, localization acuity, and use of binaural locus cues.* J. Acoust. Soc. Am.
135, 778–788. https://doi.org/10.1121/1.4861344

**Item:** `Heffner_etal_2014_Figure3` · **Item encoded:** `10.1121%2F1.4861344_Figure3` ·
**Public TSV:** `__Public/comparative-data/10.1121%2F1.4861344_Figure3.tsv`

**FIG. 3** (p. 782). Auditory detection thresholds for three alpacas; the plotted symbols are the
letters **A**, **B** and **C**, one per individual, and the solid line is their mean. Arrows mark
the frequencies audible at 60 dB SPL.

## ⚠️ Digitised data, not printed values

Every threshold in `Heffner_etal_2014_Figure3.csv` was read off the plotted figure. The paper
prints only six summary numbers (the Results text); the 42 individual thresholds appear nowhere
else. Use `Heffner_etal_2014_ResultsText` for the headline values.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded 682 × 1015 px bitmap** at native
  resolution (never a re-render) by `Heffner_etal_2014_Figure3_extract.py` (conda env `python`;
  pymupdf, numpy, scipy), run 2026-10-31; a second run reports "snapshot unchanged".
  Axis lines were found as the longest fully dark column/row, ticks as the dark runs just outside
  them, giving nine ordinate ticks (80…0 dB SPL, linear fit, residuals ≤ 0.24 dB) and 14 abscissa
  ticks (log fit). Letter glyphs were segmented as connected components inside the plot frame
  (splitting components taller than 24 px or wider than 22 px into two) and identified as A, B or C
  by normalised cross-correlation against exemplars cut from the uncrowded 1 kHz cluster.
- **Estimated error in the figure's own units: ±0.4 dB.** The mean of the three digitised letters
  reproduces the three means the Results text prints — 70.5 dB at 25 Hz, −0.5 dB at 8 kHz,
  79 dB at 40 kHz — to −0.29, −0.40 and −0.23 dB respectively. Frequencies are the printed tick
  labels, not digitised.
- **Points contained vs resolved: the figure contains 42 plotted points (14 frequencies × 3
  animals) and all 42 were individually resolved.** Ten of the 42 were printed as a merged glyph
  pair; those were split at the nominal glyph size (17 × 15 px) rather than measured separately and
  are flagged `marker_glyphs_overlapped = yes`. **No point was inferred** — every one of the 42
  letters is present in the ink.

## Cross-checks against this paper's own printed numbers (actual R run 2026-10-31)

| check | observed | printed | status |
|---|---|---|---|
| mean threshold at 0.025 kHz | 70.21 dB SPL | 70.5 | pass |
| lowest mean threshold | −0.90 dB SPL | −0.5 | pass |
| frequency of best hearing | 8 kHz | 8 | pass |
| mean threshold at 40 kHz | 78.77 dB SPL | 79 | pass |
| largest inter-individual range | 9.14 dB | "up to 9 dB" | pass |
| mean at the tick printed "20" | 23.52 dB SPL | ≤ 25 dB SPL to 22.5 kHz | pass |

The 60-dB arrows digitise to 0.039 kHz and 33.6 kHz against the text's 40 Hz and 32.8 kHz.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_2014_Figure3_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_2014_Figure3_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_2014_Figure3.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_2014_Figure3.csv` | analysis data |
| `Heffner_etal_2014_Figure3_digitisation_check.png` | overlay check: detected markers and values drawn on the bitmap |
| `reference_tables/Heffner_etal_2014_Figure3_definitions.csv` | data dictionary |
| `Heffner_etal_2014_Figure3_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1121%2F1.4861344_Figure3.tsv` |

## Data role
**primary** — this paper's own behavioural measurements, but `value_origin = digitised_from_figure`
on every row.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Heffner_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Heffner_etal_2014-E001 | frequency_kHz | FIG. 3, p. 782, abscissa tick printed “20” (second from the right-hand end) | 20 | 20 | publication_ambiguity | 22.5 | proposed | The 14 abscissa ticks were located in the embedded bitmap. Fitting log10(frequency) to pixel column over the other 13 printed labels leaves a residual of +10.4% at this tick if its value is 20 kHz, but +0.07% if it is 22.5 kHz (all other residuals then <= 0.9%). The Results text (p. 781) names 22.5 kHz as a test frequency: "Thresholds remained at 25 dB SPL or better up to 22.5 kHz". | The CSV keeps the printed label 20 in frequency_kHz; the position-implied 22.5 kHz is carried alongside in frequency_kHz_from_tick_position. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

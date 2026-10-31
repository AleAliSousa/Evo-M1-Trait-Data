# Heffner et al. (2014) — Figures 10 and 11 (digitised), one vs both binaural locus cues

Heffner, R. S., Koay, G., & Heffner, H. E. (2014). *Hearing in alpacas (Vicugna pacos):
Audiogram, localization acuity, and use of binaural locus cues.* J. Acoust. Soc. Am.
135, 778–788. https://doi.org/10.1121/1.4861344

**Item:** `Heffner_etal_2014_Figures10-11` · **Item encoded:** `10.1121%2F1.4861344_Figures10-11` ·
**Public TSV:** `__Public/comparative-data/10.1121%2F1.4861344_Figures10-11.tsv`

## Why the two figures are one item

The registry's `Item number` is **"Figures 10-11"** and its `Item full original title` is
*"Sound-localization acuity and functional interaural distance among species using one vs both
binaural locus cues"* — i.e. the item is defined as the pair. The figures carry the **same species
roster** and the **same left/right cue-use grouping**; FIG. 10 (p. 786) puts sound-localization
threshold on a **linear 0–35°** scale and FIG. 11 (p. 787) functional interaural distance on a
**logarithmic 40–4000 µs** scale. They are therefore joined into **one row per species with both
measures**, which is also what makes the item useful (the two figures exist to be read together).

## ⚠️ Digitised data, not printed values

No value in either figure is printed as a number anywhere in the paper.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded 1273 × 754 px (Fig. 10) and
  1280 × 754 px (Fig. 11) bitmaps** at native resolution by
  `Heffner_etal_2014_Figures10-11_extract.py` (conda env `python`), run 2026-10-31; a second run
  reports "snapshot unchanged". Same geometry as Fig. 9: grey bar located by its black border
  columns, calibration from the numeric labels printed inside the bar, species leader lines as the
  connected components touching a border from outside and wider than 30 px.
- **Estimated error in each figure's own units:** Fig. 10 **±0.04°** (the linear fit to the eight
  printed ticks 35…0 leaves residuals of −0.031 to +0.039°); Fig. 11 **±0.35%** (the log fit to the
  nine printed ticks 4000…40 leaves residuals of −0.34% to +0.19%). Add roughly one pixel of
  leader-line placement (≈0.03° and ≈0.4%).
- **Points contained vs resolved: Fig. 10 contains 24 plotted ticks and Fig. 11 contains 24; all 48
  were individually resolved**, and together they carry **25 species**.
- **Inferred (shared-marker) points — four species, flagged in `shares_tick_Fig10` /
  `shares_tick_Fig11`:** in Fig. 11 the leader lines of *Egyptian fruit bat* and *prairie dog*
  converge on one tick (134.6 µs), and those of *kangaroo rat* and *Jamaican fruit bat* converge on
  another (90.3 µs). In Fig. 10 the label "kangaroo rat, gerbil" is one tick for two species, and in
  Fig. 11 "\*goat, horse" likewise. For those species the individual value is **inferred from a
  shared marker, not independently resolved**.
- **Binaural cue use** comes from the printed type style, which the captions define (roman on the
  left = both cues; bold italic on the right = only time cues; bold upright on the right = only
  intensity cues; `*` = elephants and goats also use intensity cues, but only at low frequencies).
  The style was read visually and frozen in
  `reference_tables/Heffner_etal_2014_Figures10-11_label_typography.csv`.

## Cross-checks (actual R run 2026-10-31)

| check | observed | expected | status |
|---|---|---|---|
| alpaca threshold, Fig. 10 | 22.96° | 23° (Results III.B) | pass |
| largest Fig. 10 − Fig. 9 threshold difference, 21 shared species | 0.51° | ≤ 0.6° | pass |
| species common to Figs. 9 and 10 | 21 | 21 | pass |
| short-tailed fruit bat interaural distance | 47.3 µs | 47 µs (Heffner et al. 2003, Fig. 4) | pass |
| greater spear-nosed bat interaural distance | 107.5 µs | 108 µs (Koay et al. 2002) | pass |
| **Jamaican fruit bat interaural distance** | **90.3 µs** | **96 µs (Heffner et al. 2003)** | **mismatch** |
| species in the item | 25 | 25 | pass |

The independent agreement between Fig. 10 and Fig. 9 (two different scales in the same paper,
digitised independently, 21 species in common, worst case 0.51°) is the main evidence that the
method is sound. The Jamaican fruit bat mismatch is recorded as
`Heffner_etal_2014-E002` (`cross_source_disagreement`): that point shares its Fig. 11 tick with the
kangaroo rat, so the figure cannot place the two separately. Prefer the printed 96 µs.

## Source traceability (secondary data)

Neither caption keys a per-species source. The only citation either prints is **Heffner and Heffner
(1982)** for the asterisked species; the roster's thresholds are sourced only collectively, through
the Fig. 9 caption of the same paper. All three works, and that limitation, are recorded in
`reference_tables/Heffner_etal_2014_Figures10-11_references.csv`.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_2014_Figures10-11_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_2014_Figures10-11_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_2014_Figures10-11.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_2014_Figures10-11.csv` | analysis data |
| `reference_tables/Heffner_etal_2014_Figures10-11_label_typography.csv` | printed type style → binaural cue use (visual reading) |
| `reference_tables/Heffner_etal_2014_Figures10-11_references.csv` | the sources either caption names |
| `reference_tables/Heffner_etal_2014_Figures10-11_definitions.csv` | data dictionary |
| `Heffner_etal_2014_Figures10-11_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1121%2F1.4861344_Figures10-11.tsv` |

## Data role
**secondary** — a Heffner-lab compilation replotted here.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Heffner_etal_2014_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Heffner_etal_2014-E002 | functional_interaural_distance_us | FIG. 11, p. 787, label “Jamaican fruit bat” (left of scale) | n/a (plotted position only) | 90.344 | cross_source_disagreement |  | proposed | The Fig. 11 leader lines for "kangaroo rat" and "Jamaican fruit bat" converge on a single tick at pixel row 955.5, which calibrates to 90.3 us (calibration spread 0.35%). Heffner, Koay & Heffner (2003) Hear. Res. 184:113-122 prints 96 us for Artibeus jamaicensis in the Fig. 4 label and in its Results, and the repo item Heffner_etal_2003_ResultsText carries 96 us. The same Fig. 11 reads 107.5 us for P. hastatus (printed 108) and 47.3 us for C. perspicillata (printed 47), so the 5.9% shortfall is specific to this point. | The two species share one plotted tick, so the figure cannot place them separately; prefer the printed 96 us from Heffner et al. (2003) over this reading. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

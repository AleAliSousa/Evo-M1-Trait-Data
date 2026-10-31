# Heffner et al. (2014) — Figure 9 (digitised), mammalian sound-localization thresholds

Heffner, R. S., Koay, G., & Heffner, H. E. (2014). *Hearing in alpacas (Vicugna pacos):
Audiogram, localization acuity, and use of binaural locus cues.* J. Acoust. Soc. Am.
135, 778–788. https://doi.org/10.1121/1.4861344

**Item:** `Heffner_etal_2014_Figure9` · **Item encoded:** `10.1121%2F1.4861344_Figure9` ·
**Public TSV:** `__Public/comparative-data/10.1121%2F1.4861344_Figure9.tsv`

**FIG. 9** (p. 785). Behaviourally determined sound-localization thresholds for mammals on a
one-dimensional logarithmic scale from 1° to 180°; each printed common name is joined to the scale
by a leader line whose meeting point with the bar is the datum. Rodents, bats and other species are
listed on the left, hoofed mammals, carnivores and primates on the right.

## ⚠️ Digitised data, not printed values

No value in this figure is printed as a number anywhere in the paper.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the **embedded 1535 × 754 px bitmap** at native
  resolution by `Heffner_etal_2014_Figure9_extract.py` (conda env `python`), run 2026-10-31;
  a second run reports "snapshot unchanged". The grey value bar was located by its two black border
  columns; the scale ticks are the dark runs projecting inward from each border, and the seven
  printed labels (180, 100, 50, 20, 10, 5, 1°) were matched to them. A species leader line is a
  connected component touching a border from outside and wider than 30 px; the row where it meets
  the bar is the value, the row of its far end identifies which printed label it serves.
- **Estimated error in the figure's own units: ±0.5% in degrees.** A single least-squares log fit to
  the seven printed ticks leaves residuals of −0.31% to +0.44%, and the largest difference between
  the piecewise and single-fit calibrations over the 34 points (`calibration_spread_pct`) is 0.41%.
  Add roughly 0.2% per pixel of leader-line placement. The independent check is the alpaca point:
  22.98° against the 23° this paper's own Results state.
- **Points contained vs resolved: the figure contains 34 plotted ticks, carrying 38 species, and all
  34 were individually resolved** (19 on the left, 15 on the right; the component count was asserted
  against the printed label count in the extract script). **No point was inferred.**
- **Shared markers:** four printed labels name two species each — "blind mole rat, gopher",
  "kangaroo rat, gerbil", "hedgehog, hamster", "big brown bat, fox squirrel". Those species are
  split to separate rows but necessarily receive the *same* value and are flagged
  `shares_tick_with`; their individual thresholds are not separable in this figure.

## Cross-checks (actual R run 2026-10-31)

| check | observed | expected | status |
|---|---|---|---|
| alpaca threshold | 22.98° | 23° (Results III.B) | pass |
| blind mole rat / gopher | 180.0° | top of the printed scale | pass |
| species resolved from 34 leader lines | 38 | 38 | pass |
| largest calibration spread | 0.41% | ≤ 1% | pass |

## Source traceability (secondary data)

The caption says only *"For specific citations, see Heffner and Heffner, 2003, and Heffner et al.,
2007."* **The figure keys no per-species source**, so an individual plotted species cannot be traced
to its primary study from this figure alone; both collective reviews are recorded in
`reference_tables/Heffner_etal_2014_Figure9_references.csv` with that statement in `note`.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_2014_Figure9_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_2014_Figure9_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_2014_Figure9.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_2014_Figure9.csv` | analysis data |
| `reference_tables/Heffner_etal_2014_Figure9_references.csv` | the two collective sources the caption names |
| `reference_tables/Heffner_etal_2014_Figure9_definitions.csv` | data dictionary |
| `Heffner_etal_2014_Figure9_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1121%2F1.4861344_Figure9.tsv` |

## Data role
**secondary** — a Heffner-lab compilation replotted here. Prefer any printed table or text value for
the same species.

<!-- errata:begin -->
<!-- errata:end -->

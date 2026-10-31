# Heffner et al. (1994c) — Figure 7 (digitised), interaural distance vs localization acuity

Heffner, R. S., Heffner, H. E., Kearns, D., Vogel, J., & Koay, G. (1994). *Sound localization in
chinchillas. I: Left/right discriminations.* Hearing Research 80, 247–257.
https://doi.org/10.1016/0378-5955(94)90116-3

**Item:** `Heffner_etal_1994_c_Figure7` · **Item encoded:** `10.1016%2F0378-5955(94)90116-3_Figure7` ·
**Public TSV:** `__Public/comparative-data/10.1016%2F0378-5955(94)90116-3_Figure7.tsv`

**Fig. 7** (p. 254). Two panels. The **left** panel — the only one digitised — plots
sound-localization threshold (deg) against interaural distance (µs) for **29 mammals** on log–log
axes. The **right** panel plots the same relation after partialling out the width of the field of
best vision; those are *residuals*, a derived quantity, and were deliberately not digitised.

## ⚠️ The lowest-confidence item in this folder. Read this before using it.

In this figure **the two-letter species codes are the plotted symbols**: a round dot is drawn only
where a code had to be displaced to avoid a collision, and is then joined to its code by a leader
line. The page is also a **200-ppi bilevel scan**, and its abscissa ticks are not evenly log-spaced.
Both facts limit what can be read out, and both are quantified below.

## Method, precision, and what was resolved

- **Digitisation method:** pixel digitisation of the page scan (1700 × 2200 px, cropped to rows
  1230–1720 / columns 200–1460) by `Heffner_etal_1994_c_Figure7_extract.py` (conda env `python`),
  run 2026-10-31; a second run reports "snapshot unchanged". Dot markers were isolated by binary
  erosion (which removes the 2–3 px letter strokes and leader lines) and matched to the detected
  ink; code positions are the ink centroid inside a hand-read bounding box, so the *coordinate* is
  always machine-measured and only the *region* is human-specified.
- **Estimated error in the figure's own units — two components, both large:**
  1. **Calibration.** A single log fit to the five printed abscissa ticks (50, 100, 300, 1000,
     3000 µs) leaves residuals of **−10.9% to +10.5%**; the ordinate fits to −1.9% to +1.5%.
     Primary values therefore use piecewise log interpolation between adjacent printed ticks, with
     the single-fit values carried as `*_globalfit` and the difference as
     `calibration_spread_pct_x` / `_y`.
  2. **Code displacement.** A displaced code can sit up to about one character from its datum.
     Checked against this paper's own Table 1 (11 species in both), the **six dot-anchored species
     agree to within 2.7%**, while the **five code-anchored species scatter from −40.9% to +11.6%**
     — *Sp* (spiny mouse) reads 11.2° here against the 19.0° Table 1 prints.
- **Points contained vs resolved: the panel contains 29 plotted species.** **13 of them sit on 8
  printed dots** and **16 are located only by their printed code**. Of the 13 dot-anchored species,
  **8 are inferred from a shared marker**: the dots for *Gr/K*, *C/Op*, *Mk/P* and *SI/D* each serve
  two species, which therefore receive identical coordinates (`shares_marker_with`). Every row
  carries its `position_basis`.

## Cross-check against this paper's own Table 1 (actual R run 2026-10-31)

| code | Table 1 species | Table 1 (deg) | digitised (deg) | diff | basis |
|---|---|---|---|---|---|
| Gm | Grasshopper mouse | 19.3 | 18.78 | −2.7% | dot |
| Gr | Gerbil | 27.0 | 27.30 | +1.1% | dot |
| K | Kangaroo rat | 27.0 | 27.30 | +1.1% | dot |
| Mb | Blind mole rat | 180.0 | 180.09 | 0.0% | dot |
| Rd | Norway rat (domestic) | 11.1 | 11.18 | +0.7% | dot |
| Rw | Norway rat (wild) | 12.8 | 12.51 | −2.3% | dot |
| Ch | Chinchilla | 15.6 | 17.41 | +11.6% | code |
| Gh | Groundhog | 27.8 | 26.57 | −4.4% | code |
| N | Naked mole rat | 63.0 | 60.39 | −4.1% | code |
| Wr | Wood rat | 19.0 | 18.23 | −4.1% | code |
| **Sp** | **Spiny mouse** | **19.0** | **11.23** | **−40.9%** | **code** |

`table_checks` records the dot-anchored maximum (2.7%, pass) and the code-anchored maximum
(40.9%, **mismatch by design** — the check exists to quantify label displacement, not to pass).

## Source traceability (secondary data)

`reference_tables/Heffner_etal_1994_c_Figure7_references.csv` resolves each of the 29 codes to a
full bibliography entry, taking the citation key from the Fig. 7 legend where it gives one and
otherwise from the Table 1 Source column (the legend explicitly directs the reader there for
"remaining citations"). **Five codes are unresolved and say so in `note`: D (dog), H (horse),
M (man), Mk (macaque) and W (least weasel)** — neither the legend nor Table 1 keys a source for
them, and they are not guessed. The legend's common names are frozen verbatim (including its own
"domestic Nmway rat") in `reference_tables/Heffner_etal_1994_c_Figure7_legend_codes.csv`.

## Pipeline

| file | role |
|---|---|
| `Heffner_etal_1994_c_Figure7_extract.py` | reproducible bitmap digitisation -> frozen snapshot (Python: pymupdf, numpy, scipy, pandas, pillow) |
| `Heffner_etal_1994_c_Figure7_snapshot.csv` | constructed snapshot (the digitisation as captured, in the figure's own units) |
| `Heffner_etal_1994_c_Figure7.R` | snapshot -> analysis CSV + public TSV; `table_checks` |
| `Heffner_etal_1994_c_Figure7.csv` | analysis data |
| `Heffner_etal_1994_c_Figure7_digitisation_check.png` | overlay check: detected markers and values drawn on the bitmap |
| `reference_tables/Heffner_etal_1994_c_Figure7_legend_codes.csv` | code → common name as printed in the legend |
| `reference_tables/Heffner_etal_1994_c_Figure7_references.csv` | per-code sources, with the five unresolved codes declared |
| `reference_tables/Heffner_etal_1994_c_Figure7_definitions.csv` | data dictionary |
| `Heffner_etal_1994_c_Figure7_registry_row.xlsx` | paste-ready registry update |
| public TSV | `__Public/comparative-data/10.1016%2F0378-5955(94)90116-3_Figure7.tsv` |

## Data role
**secondary** — a Heffner-lab compilation. **Prefer `Heffner_etal_1994_c_Table1` and the other
registered Heffner items wherever they cover the same species**; this item's value is as a roster
of which 29 species the relationship was built on, and as the only source for the *interaural
distance* axis.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Heffner_etal_1994_c_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Heffner_etal_1994_c-E002 | source_ref_key | Fig. 7, p. 254, species code "Wr" (wood rat); the legend directs the reader to the Table 1 Source column for the remaining citations | Heffner and Heffner, 1988a | Heffner and Heffner, 1988a | publication_ambiguity |  | proposed | Table 1 (p. 253) cites "Heffner and Heffner, 1988a" for BOTH the wood rat (19.0 deg) and the grasshopper mouse (19.3 deg). The reference list (p. 256) gives 1988a as "Sound localization in a predatory rodent, the northern grasshopper mouse (Onychomys leucogaster). J. Comp. Psychol. 102, 66-71", a paper whose title names only Onychomys leucogaster. No separate wood-rat source appears anywhere in this paper. | The repo keeps the printed citation key. A wood-rat (Neotoma floridana) localization threshold may be reported within the 1988a paper alongside the grasshopper mouse, or the key may be a typesetting slip for a different Heffner & Heffner 1988 letter; not resolvable from this PDF. Do not treat the 1988a citation as verified provenance for the wood-rat value. Raised on the Table 1 cell as Heffner_etal_1994_c-E001; recorded here because the Figure 7 item joins to the same printed key. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->

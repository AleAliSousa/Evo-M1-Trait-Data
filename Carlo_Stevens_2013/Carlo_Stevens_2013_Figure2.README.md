# Carlo_Stevens_2013_Figure2

## Source
Carlo, C. N., & Stevens, C. F. (2013). Structural uniformity of neocortex, revisited.
*PNAS*, 110(4), 1488–1493. https://doi.org/10.1073/pnas.1221398110 — Fig. 2 (p. 1489): number of
cells (A), neurons (B) and glia (C) under 1 mm² of cortical surface vs cortical thickness, for
mouse, rat, cat and monkey (M1, S1, parietal, temporal).

## Constructed snapshot (figure digitization)
No values are printed; the figure is an embedded 1-bit raster (2043 × 4275 px). The snapshot
`Carlo_Stevens_2013_Figure2_snapshot.csv` is produced by
`Carlo_Stevens_2013_Figure2_extract_snapshot.py` (AI assistant, 2026-10-28):
- **Calibration:** tick marks detected per panel (y 0–200 thousand, x 0–3 mm), linear fit;
  ~0.2 thousand cells and ~0.002 mm per pixel.
- **Markers:** normalised cross-correlation with the legend markers (circle = mouse, square = rat,
  triangle = cat, diamond = monkey); panels linked by identical abscissa.
- **Occlusions (flagged in `occluded_in`):** at 1.12 mm a mouse circle and a monkey diamond are
  concentric in all panels — the hidden marker takes the visible one's coordinates; two panel-B
  monkey markers on the regression lines (1.75, 1.78 mm) were found by a local template search.
- The script re-derives every value from the PDF; it refuses to overwrite a differing snapshot.

Validation (actual R run 2026-10-28, `table_checks`): 24 points = 8 mouse + 4 rat + 4 cat +
8 monkey, matching Table S1 (non-frontal specimen × area entries); max |A − (B + C)| = 0.9
thousand (A = neurons + glia, tolerance 1.5); regression slope/intercept A 18.3 / 120.8 (printed
18.8 / 121), C 21.1 / 22.8 (printed 21.1 / 23), B slope −3.0 (printed −2.7); mean ± SD neurons
93.8 ± 10.7 thousand (Results text: 94.0 ± 10.7). One mismatch: **panel B intercept** 98.2 vs
printed 94 — the printed intercept equals the printed mean, whereas a −2.7 slope through these
data implies ~98; panel B also shows both a solid and a dashed line. Reported, not corrected.

## Pipeline
| file | role |
|---|---|
| `Carlo_Stevens_2013_Figure2_extract_snapshot.py` | digitizer (Python: pymupdf, numpy, scipy) |
| `Carlo_Stevens_2013_Figure2_snapshot.csv` | constructed snapshot (per point: marker, thickness, A, B, C, A−(B+C), NCC scores, occlusion) |
| `Carlo_Stevens_2013_Figure2.R` | snapshot → CSV + public TSV; `table_checks` |
| `Carlo_Stevens_2013_Figure2.csv` | 24 rows, counts per mm² (thousands × 1000) |
| `reference_tables/Carlo_Stevens_2013_Figure2_definitions.csv` | data dictionary |
| `Carlo_Stevens_2013_Figure2_registry_row.xlsx` | registry row |
| public TSV | `__Public/comparative-data/10.1073%2Fpnas.1221398110_Figure2.tsv` |

## Data role
primary — but values are **digitized approximations** (`value_type`), not printed numbers. The
figure does not say which cortical area or specimen a point is; only species is known.

## Species
Legend labels kept (`species_as_published` = mouse/rat/cat/monkey); binomials from Table S1 via
`_keys/General/species_key.csv` (Mus sp., Rattus sp., Felis catus, Macaca mulatta).

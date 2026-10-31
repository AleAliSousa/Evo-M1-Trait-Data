# Heffner_etal_2013_Figure2

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2013). Hearing in American leaf-nosed bats. IV: the Common vampire bat, *Desmodus rotundus*. *Hearing Research*, 296, 42-50. doi:10.1016/j.heares.2012.09.011. Public copy: `Heffner_etal_2013/Heffner_etal_2013.pdf` (born-digital).

Registry Item **Figure 2 (p. 45, PDF page 4)**.

## Why this item exists
The full mean pure-tone audiogram of *D. rotundus* (29 frequencies). The Results text (item `Heffner_etal_2013_ResultsText`) gives only the summary (716 Hz-113 kHz at 60 dB; best −5 dB SPL at 20 kHz). Note: the text layer drops that minus sign (encoded as a control byte); erratum Heffner_etal_2013-E001 (proposed) flags `best_sensitivity_dB = 5` in the ResultsText item.

## Snapshot and extraction method
The figure is born-digital vector art. `Heffner_etal_2013_Figure2_extract.py` (PyMuPDF 1.28) reads the drawing commands on PDF page 4: the black 0.97-pt polyline (pure tones, 29 vertices, each with a filled marker at the same position) and the grey 1.16-pt polyline (noise bands, 9 vertices), plus the axis tick segments. Calibration by least squares: x = log10(kHz) on the 11 labelled ticks (.5, 1, 2, 4, 8, 10, 20, 40, 80, 100, 116 kHz; max residual 0.13 pt, ~0.3% in frequency); y = dB SPL on the 18 ticks −5…80 (max residual 0.11 dB). Estimated error: ±0.2 dB, ±0.5% frequency. Rows: legend order (Pure Tone, then Noiseband), then increasing frequency. Pixel/pt coordinates are kept. `Heffner_etal_2013_Figure2_digitisation_check.png` overlays every extracted vertex on a 300-dpi render (checked by eye: all 38 sit on the printed markers).

## Build
`Heffner_etal_2013_Figure2.R` reads the snapshot, labels stimulus, n (3 animals for the mean pure-tone curve), `source_ref_key`, `data_role`, harmonises the caption name 'D. rotundus' via `_keys/General/species_key.csv`.

Run clean 2026-10-30 with `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Heffner_etal_2013/Heffner_etal_2013_Figure2.R` (R 4.5.3, conda env `evom1-r`) from the repo root. Reader: an AI assistant (Claude) for A. de Sousa, 2026-10-30.

## Checks
Fatal checks in the script against the text (p. 45): 60-dB SPL crossings of the pure-tone curve = 0.712 kHz (text 716 Hz; Discussion 710 Hz) and 113.3 kHz (text 113 kHz), both within 2%; minimum = −5.0 dB at 19.9 kHz (text '−5 dB at 20 kHz'); Results point values 72 dB at 500 Hz, 20 dB at 63 kHz, 1 dB at 71 kHz, 74.5 dB at 116 kHz reproduced as 71.9, 20.0, 0.6, 74.3 dB.

## Secondary data / sources
The 'Noiseband Thresholds' series is Gröger & Wiegrebe (2006), cited in the caption: `reference_tables/Heffner_etal_2013_Figure2_references.csv` (bibliography entry p. 49; DOI kept as the text layer gives it and noted). Join on `source_ref_key`.

## Data role
both: pure-tone series primary (mean of 3 animals); noiseband series secondary.

## Observation level
Group mean (3 individuals) per frequency; secondary series as plotted by the source.

## Units
kHz; dB SPL.

## Flags (kept as printed)
- Frequencies are kept as extracted (3 s.f.), not snapped to nominal test frequencies.

## Files
| file | role |
|---|---|
| `Heffner_etal_2013_Figure2_snapshot.csv` | constructed/frozen snapshot (read as text, never edited) |
| `Heffner_etal_2013_Figure2_extract.py` | vector extraction script that wrote the snapshot |
| `Heffner_etal_2013_Figure2_digitisation_check.png` | overlay check image |
| `Heffner_etal_2013_Figure2.R` | snapshot -> analysis CSV + public TSV |
| `Heffner_etal_2013_Figure2.csv` | analysis CSV |
| `reference_tables/Heffner_etal_2013_Figure2_definitions.csv` | data dictionary |
| `reference_tables/Heffner_etal_2013_Figure2_references.csv` | cited sources, join on ref_key |
| `Heffner_etal_2013_Figure2_registry_row.xlsx` | registry row proposal (live 34-col Sheet1 header) |
| `__Public/comparative-data/10.1016%2Fj.heares.2012.09.011_Figure2.tsv` | public TSV (repo-level) |

Human visual check of the snapshot: pending (record `DDMMYYYY_initials` in `__ReadMe.xlsx` column AH).

# Koay, Bitter, Heffner & Heffner (2002) — Figure 3

**Source paper.** Koay, G., Bitter, K. S., Heffner, H. E., & Heffner, R. S. (2002). Hearing in American leaf-nosed bats. I: *Phyllostomus hastatus*. *Hearing Research*, 171, 96–102. https://doi.org/10.1016/s0378-5955(02)00458-6

**The item is a figure, not a table.** Figure 3 (journal p. 101) carries **two series on one pair of axes**: the paper's own **behavioural audiogram** of *Phyllostomus hastatus* (mean 50 % detection thresholds, drawn as a thick line) and **multi-unit inferior-colliculus thresholds** (thin line with markers). Neither series is tabulated in the paper.

## ⚠️ The behavioural curve has no markers

The behavioural audiogram is printed as a **thick line with no plotting symbols**, so its data points cannot be read directly. They are recovered as the **vertices of the traced polyline** (Douglas–Peucker, tolerance 3.5 px, vertices within 0.025 decade merged) and are labelled `polyline_vertex_inferred` in both the snapshot and the CSV: **14 inferred points**, against **12 printed markers** for the inferior-colliculus series, which were all individually resolved. A vertex is an estimate of a tested frequency, not a printed one.

## Method

1. Embedded figure image (xref 83, 1975 × 1318 px) read directly from the PDF.
2. Axes calibrated on the printed ticks — x against log₁₀(kHz) over 1–110 kHz, y against dB SPL over 0–90 — by least squares; residuals **2.8 px on x (0.004 decade)** and **2.6 px on y (0.22 dB)**. With the curve-tracing error, values carry roughly **±1 dB** and a few per cent in frequency.
3. Behavioural curve traced by continuity: at each column, the dark run at least 6 px thick whose centre is nearest the previous centre.
4. Inferior-colliculus markers found as distance-transform peaks of radius ≥ 10 px (the lines and axes give 5–6 px and are excluded).

**Anchors.** The paper's own Results text (built here as `Koay_etal_2002_ResultsText`) gives **best sensitivity 1 dB at 20 kHz** and a **60 dB SPL range of 1.8–105 kHz**. This digitisation reads **0.9 dB at 19.9 kHz** and crosses 60 dB at about **1.9 and 103 kHz**.

## Data role: both, not primary

The registry has this item as **primary**, which is right for the behavioural series. The second series is **not this paper's data**: Section 4.3 states that the multi-unit inferior-colliculus thresholds come from **Grinnell (1970)**, so those 12 points are secondary. The item is therefore **both**, `data_role` carries it per row, and `reference_tables/Koay_etal_2002_Figure3_references.csv` resolves `value_source`. Note that the **figure caption itself names no source** — the attribution comes from the Results text.

## Files in this folder

| file | what it is |
| --- | --- |
| `Koay_etal_2002_Figure3_extract_snapshot.py` | the digitiser; measures every coordinate at run time |
| `Koay_etal_2002_Figure3_snapshot.csv` | **frozen digitisation**: 26 points (14 behavioural vertices + 12 markers), both axes as read, pixel coordinates |
| `Koay_etal_2002_Figure3.R` | snapshot → CSV + public TSV |
| `Koay_etal_2002_Figure3.csv` | analysis-ready, one row per point (26 rows) |
| `reference_tables/…_references.csv` | the two sources behind the two series |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |

Public TSV: `__Public/comparative-data/10.1016%2Fs0378-5955(02)00458-6_Figure3.tsv`.

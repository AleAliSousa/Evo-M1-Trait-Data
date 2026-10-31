# Wenstrup (1984) — Figure 8

**Source paper.** Wenstrup, J. J. (1984). Auditory sensitivity in the fish-catching bat, *Noctilio leporinus*. *Journal of Comparative Physiology A*, 155, 91–101. https://doi.org/10.1007/BF00610934

**The item is a figure, not a table.** Figure 8 (journal p. 99) stacks **three behavioural audiograms** on one shared logarithmic frequency axis: *Rhinolophus ferrumequinum*, *Eptesicus fuscus* and *Noctilio leporinus*. None of the three is tabulated in the paper. The **caption names no sources**; the attributions below come from the Results text on the same page ("Behavioral audiograms of other bats").

## ⚠️ Digitised, and most points are inferred vertices

The solid curves carry small filled dots, but **most are no thicker than the line joining them**, so the plotted points are recovered as the **vertices of the traced polyline** and marked `polyline_vertex_inferred`. An independent dot detector was run as a check and the result is carried per point in `printed_dot_confirmed`:

| panel | series | points | confirmed by a distinct printed dot |
| --- | --- | --- | --- |
| *Rhinolophus ferrumequinum* | solid, filled dots | 23 | 7 |
| *Eptesicus fuscus* | solid, filled dots | 17 | 9 |
| *Eptesicus fuscus* | **dashed, open circles** | 7 | 7 (all are printed symbols) |
| *Noctilio leporinus* | solid, filled dots | 17 | 9 |

**64 points in total.** The leftmost open circle of the Eptesicus dashed series sits on the y-axis and is **bisected by it**; its centre was measured on the frame and the row is flagged. The horizontal bars at the top of each panel mark the echolocation band, not data, and are removed before tracing.

## Method

1. Page scan read directly from the PDF (xref 269, 2490 × 3270 px, 300 dpi). The page is **slightly skewed**, so the left frame is fitted as x = f(y) and the bottom frame as y = g(x) before any tick is sought.
2. **Frequency**: inward ticks on the bottom frame fitted against log₁₀(kHz) over 1–150 kHz; max residual **3.1 px = 0.011 decade (≈ 2.6 %)**.
3. **Intensity**: each panel has its own five inward ticks (0, 20, 40, 60, 80 dB SPL), giving 2.84, 2.78 and 2.81 px/dB — about **0.4 dB per pixel**, so values carry roughly **±1 dB**.
4. Curves traced by continuity, then Douglas–Peucker at 2.6 px with vertices within 0.02 decade merged. Open circles found with a ring template at radii 5–7 px, using an 80th-percentile ring test so the gap where the dashed line enters does not reject the ring.

**Check.** The paper's Results text gives NL 21 a high-frequency limit of **115 kHz** and a low-frequency limit averaging **7 kHz** (built as `Wenstrup__1984_Figures3-5`); the digitised *Noctilio* curve crosses 60 dB at about **120 kHz** and about **5–6 kHz**.

## Errata

`reference_tables/Wenstrup__1984_errata.csv` carries one confirmed row, **Wenstrup__1984-E001** (`publication_ambiguity`): the paper states maximum sensitivity for the CF region as a band, 56–59 kHz (56–58 in the summary), and never gives one best frequency. **Figure 8 raises no new discrepancy and does not resolve that one.** The digitised *Noctilio* curve has its two lowest thresholds at ≈ 32 kHz (−0.4 dB) and ≈ 60 kHz (−0.9 dB), consistent with best sensitivity in the CF region but, at ±1 dB, not able to single out a best frequency within the printed band. No erratum row was added and no value was altered.

## Data role

Registered **secondary**, which holds for the two replotted panels. The ***Noctilio leporinus* panel is this paper's own audiogram** (individual NL 21), so the item is strictly **both**; `authors_own` and `data_role` carry it per row and the proposed registry row says so. The *Eptesicus* panel is a **composite of two sources** and the figure does not say which points come from which, so both citations are carried on every Eptesicus row, separated by `"; "`.

## Files in this folder

| file | what it is |
| --- | --- |
| `Wenstrup__1984_Figure8_extract_snapshot.py` | the digitiser; measures every coordinate at run time |
| `Wenstrup__1984_Figure8_snapshot.csv` | **frozen digitisation**: 64 points, panel and series as printed, both axes as read, pixel coordinates, dot-confirmation flag |
| `Wenstrup__1984_Figure8.R` | snapshot → CSV + public TSV |
| `Wenstrup__1984_Figure8.csv` | analysis-ready, one row per point (64 rows) |
| `reference_tables/…_references.csv` | the four sources behind the three panels |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |
| `reference_tables/Wenstrup__1984_errata.csv` | the paper's errata file (shared with `Figures3-5`) |

Public TSV: `__Public/comparative-data/10.1007%2FBf00610934_Figure8.tsv`.

# Babushina_etal_1991_Figure2

## Source
Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and
underwater hearing characteristics of the northern fur seal: audiograms,
frequency and differential thresholds. *Biophysics*, 36(5), 909-913
(translated from *Biofizika* 36(5), 904-907). No DOI; registry alternate
identifier `Biophysics:36:909-913`.

Registry Item **Figure 2**, printed p. 911 (PDF page 4). Caption as printed:
"Fig. 2. Air audiograms of: *1*, the northern fur seal; *2*, the common seal
[5]; *3*, the Californian sea lion [8]; *4*, humans [17]." Axes as printed:
"P, dB (rel. 0,0002 dyne/cm²)" (inner scale, 20-80), "P, dB (rel. 1 µbar)"
(outer scale, 0 to -80) and "lg f [kHz]". Public copy:
`Babushina_etal_1991/Babushina1991.pdf` (library scan with an OCR text layer).

## Why this item exists
The text (item `Babushina_etal_1991_Text`) gives only summary ranges for air:
sounds "perceived ... in the range of frequencies studied 0·1–25 kHz with the
highest sensitivity at the frequencies 2–16 kHz (11–20 dB relative to 0·0002
dyne/cm²)". Heffner et al. (2006, *Hear. Res.* 221: 17-25, Fig. 6, footnote 1,
bin F "161–250 Hz") place the northern fur seal, "tested in air", by its lowest
frequency audible at 60 dB SPL and cite this paper. That limit is not stated in
the text, so it can only come from this figure. This item captures the fur seal
air audiogram so the build can compute it.

## What was digitised
Curve *1* only (northern fur seal; filled circles, solid line): 11 points, P01-P11,
in `Babushina_etal_1991_Figure2_snapshot.csv`. Not digitised: curves *2*-*4*
(common seal [5], Californian sea lion [8], humans [17] are cited data from other
papers; use their primary sources) and the smooth line drawn through curve *1*
from about 5 kHz upwards (a drawn fit that does not pass through every point, e.g.
P09). Near lg f = 0.3 an open rectangular marker on the dashed line sits under P06.

## Digitisation method
- **Image:** the embedded 300-ppi page scan of PDF page 4, extracted without
  resampling (2269 x 3196 px). Pixel coordinates in the snapshot are on that image.
- **Markers:** dark filled blobs were found automatically; each one was classified
  by eye on zoomed crops (circle = curve 1, triangle = curve 2, square = curve 3),
  and each circle centre was fitted with a disc template of 8.5 px radius. Two
  circles overlap other markers (P06, P08); their centres were fitted on the
  visible round part and checked by eye.
- **Tool:** Python (NumPy, Pillow), run by Microsoft Copilot (AI assistant) for
  A. de Sousa on 26 Oct 2026. WebPlotDigitizer was not used.
- **Check image:** `Babushina_etal_1991_Figure2_digitisation_check.png` shows every
  digitised point (red), the ticks used for calibration (blue) and the 60 dB SPL
  line (green) on the scan.

## Calibration
All three axes are linear in the plotted units (frequency is plotted as lg f, the
log10 of frequency in kHz). Lines were fitted by least squares to the printed tick
marks (tick centres located on the scan, intensity-weighted).

Inner scale, dB re 0,0002 dyne/cm² (used for the values): 6.236 px per dB.

| dB | tick y (px) | residual (px) |
|---|---|---|
| 80 | 1342.2 | +1.1 |
| 70 | 1402.8 | -0.7 |
| 60 | 1466.1 | +0.3 |
| 50 | 1526.8 | -1.4 |
| 40 | 1589.8 | -0.8 |
| 30 | 1654.5 | +1.6 |
| 20 | 1715.4 | +0.1 |
| 10 | 1777.5 | -0.2 |

Outer scale, dB re 1 µbar (cross-check only): 6.278 px per dB.

| dB | tick y (px) | residual (px) |
|---|---|---|
| 0 | 1379.1 | +0.8 |
| -10 | 1442.3 | +1.2 |
| -20 | 1502.3 | -1.5 |
| -30 | 1565.0 | -1.7 |
| -40 | 1629.1 | -0.3 |
| -50 | 1693.2 | +1.0 |
| -60 | 1755.5 | +0.5 |

Frequency axis, lg f [kHz]: 516.4 px per decade.

| lg f | tick x (px) | residual (px) |
|---|---|---|
| -1 | 576.1 | +0.3 |
| 0 | 1091.5 | -0.7 |
| 1 | 1608.9 | +0.3 |

The two printed level scales agree: the outer 0 dB (re 1 µbar) tick reads
73.91 dB on the inner scale, against the 73.98 dB expected for 1 µbar
(0.1 Pa) re 0,0002 dyne/cm² (20 µPa). The outer -70 tick (faint) and -80 tick
(below the frequency axis) sit 3.5 and 7.5 px above where the regular spacing puts
them, so they were left out of the fit; the outer scale is only a cross-check.

## Precision
Calibration residuals are at most 1.7 px (about 0.3 dB) and 0.7 px (about 0.001
decade). Marker size (about 18 px across, about 3 dB) and drafting accuracy
dominate: treat values as about ±1 dB and ±0.01 decade (about ±2% in frequency).
The digitised frequencies lie within 0.016 decade of plausible test frequencies
(0.1, 0.2, 0.25, 0.5, 1, 2, 5, 10, 16, 20 and 25 kHz). They are kept as read, not
snapped; any snapping is a build decision to record in the R script.

## Checks against the text
- Range: the first point is at 100 Hz and the last at
  24.6 kHz, matching "the range of frequencies studied 0·1–25 kHz"
  (Results, p. 910).
- Best region: the points between 2 and 16 kHz read P06 2.0 kHz = 20.3 dB, P07 4.9 kHz = 11.4 dB, P08 9.7 kHz = 15.1 dB, P09 16.1 kHz = 17.0 dB, matching
  "highest sensitivity at the frequencies 2–16 kHz (11–20 dB relative to 0·0002
  dyne/cm²)" within reading precision.

## Cross-check with Figure 3
Fig. 3 (curve *2*) replots these air points as intensity, dB re 1 µW/cm².
Converted with I = p²/(ρc) and ρc = 415 Pa·s/m for air (offset -100.2 dB;
ρc is not stated in the paper), all 11 points pair with Fig. 3 and agree:
Fig. 3 minus converted Fig. 2 has median -0.5 dB, range -1.0 to +0.4 dB.
This supports the readings here, including P01 and P02, which set the 60 dB
low-frequency limit. Files: `Babushina_etal_1991_Figures1-3_crosscheck.csv` /
`.png` / `.R` (R NOT RUN; the CSV and PNG come from a line-for-line Python port).

## Derived values (for the build; not in the snapshot)
Computed in Python from the snapshot values; the R build should recompute them.
- **Lowest frequency audible at 60 dB SPL: about 190 Hz**, by linear
  interpolation in lg f between P01 (100 Hz, 71.6 dB) and
  P02 (198 Hz, 59.2 dB). If either point is misread by
  ±1 dB, the limit moves between 180 and 201 Hz. It falls inside Heffner et al.'s
  (2006) bin F, 161-250 Hz.
- **High-frequency 60 dB limit: not reached in the tested range.** The last point
  (P11, 24.6 kHz) is at 47.6 dB. The text puts the
  upper boundary of hearing in air "between 20 and 25 kHz" from the sharp rise in
  the frequency differential thresholds (f.d.t.), not from these thresholds.
- **Lowest threshold:** 11.4 dB at about 4.9 kHz (P07).

## Data role
Primary: this study's own measurements on one animal.

## Observation level
One northern fur seal (*Callorhinus ursinus*), "adult 8–9-year-old male"
(p. 910). Thresholds at "the 75% level of positive reactions" to tonal pulses of
100 msec at 5 pulse/sec, presented for 1 sec; head above water, loudspeaker 0·5 m
above the water surface and 3·8 m away (Methods, p. 910).

## Units
Levels in dB re 0,0002 dyne/cm² (equal to dB re 20 µPa, i.e. dB SPL) as plotted,
with the outer-scale reading in dB re 1 µbar kept as a cross-check. Frequency as
plotted, lg f with f in kHz; the build converts it to Hz (f = 1000 x 10^lg f).

## Status
| file | status |
|---|---|
| `Babushina_etal_1991_Figure2_snapshot.csv` | done: digitised points, as read |
| `Babushina_etal_1991_Figure2_digitisation_check.png` | done: visual check aid |
| `Babushina_etal_1991_Figures1-3_crosscheck.R` / `.csv` / `.png` | done: cross-figure check (R NOT RUN) |
| `Babushina_etal_1991_Figure2.R`, `.csv`, public TSV, `reference_tables/..._definitions.csv` | not built yet |

Human visual check of the snapshot: pending. The digitisation was done and
checked by an AI assistant only; record the person and date in `__ReadMe.xlsx`
when checked.

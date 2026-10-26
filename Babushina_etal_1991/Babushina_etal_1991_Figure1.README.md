# Babushina_etal_1991_Figure1

## Source
Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and
underwater hearing characteristics of the northern fur seal: audiograms,
frequency and differential thresholds. *Biophysics*, 36(5), 909-913
(translated from *Biofizika* 36(5), 904-907). No DOI; registry alternate
identifier `Biophysics:36:909-913`.

Registry Item **Figure 1**, printed p. 911 (PDF page 4). Caption as printed:
"Fig. 1. Underwater audiograms of: *1*, the northern fur seal; *2*, the common
seal [5]; *3*, the Californian sea lion [10]." Axes as printed: "P, dB (rel. 1
µbar)" (labelled -40 to 40) and "lg f [kHz]" (labelled 0, 1, 2). Public copy:
`Babushina_etal_1991/Babushina1991.pdf` (library scan with an OCR text layer).

## Why this item exists
The text (item `Babushina_etal_1991_Text`) gives only the underwater range
studied, "0·5–40 kHz", and the best region, "5–17 kHz (−41 . . −45 dB relative
to 1 µbar)". This figure holds the full underwater audiogram. Companion items:
`Babushina_etal_1991_Figure2` (air) and `Babushina_etal_1991_Figure3` (both
media in intensity units, which replots these points).

## What was digitised
Curve *1* only (northern fur seal; filled circles): 12 points, P01-P12, in
`Babushina_etal_1991_Figure1_snapshot.csv`. Not digitised: curves *2* and *3* (common seal [5],
Californian sea lion [10]: cited data from other papers) and the smooth line drawn
through curve *1* (a drawn fit; several points lie off it). Fig. 3 shows one more
water point, at about 30 kHz, with no circle here (see Cross-check).

## Digitisation method
- **Image:** the embedded 300-ppi page scan of PDF page 4, extracted without
  resampling (2269 x 3196 px). Pixel coordinates in the snapshot are on that image.
- **Markers:** dark markers were found automatically and classified by eye on
  zoomed crops (circle = curve 1, triangle = curve 2, square = curve 3). Filled circles were centred with a disc template
  (8.3 px radius). Every point was checked by eye on zoomed crops.
- **Tool:** Python (NumPy, Pillow), run by Microsoft Copilot (AI assistant) for
  A. de Sousa on 26 Oct 2026. WebPlotDigitizer was not used.
- **Check image:** `Babushina_etal_1991_Figure1_digitisation_check.png` shows every digitised point and
  the ticks used for calibration on the scan.

## Calibration
Axes are linear in the plotted units (lg f is the log10 of frequency in kHz).
Lines were fitted by least squares to the printed ticks.

Level, dB re 1 µbar: 6.272 px per dB. The drawn tick spacing is
uneven (60 to 68 px per 10 dB), hence the larger residuals than in Figure 2.

| dB | tick y (px) | residual (px) |
|---|---|---|
| 50 | 363.8 | +2.1 |
| 40 | 426.5 | +2.0 |
| 30 | 488.0 | +0.8 |
| 20 | 547.9 | -2.0 |
| 10 | 611.5 | -1.1 |
| 0 | 671.5 | -3.8 |
| -10 | 736.4 | -1.7 |
| -20 | 800.0 | -0.8 |
| -30 | 863.0 | -0.5 |
| -40 | 931.4 | +5.2 |

Frequency, lg f [kHz]: 506.3 px per decade.

| lg f | tick x (px) | residual (px) |
|---|---|---|
| 0 | 730.6 | -1.5 |
| 1 | 1241.3 | +3.0 |
| 2 | 1743.2 | -1.5 |

## Precision
Calibration residuals reach 5.2 px (about 0.8 dB) and 3.0 px (about 0.006
decade). With marker size and drafting, treat values as about ±1 dB and ±0.01
decade (about ±2% in frequency); the first point reads 469 Hz against the 0·5 kHz
start of the range studied (0.03 decade low). Values are kept as read, not snapped.

## Checks against the text
- Range: the first point is at 469 Hz and the last at
  38.7 kHz, against "the range of frequencies studied,
  0·5–40 kHz" (Results, p. 910).
- Best region: the points between about 5 and 17 kHz read
  P06 4.9 kHz = -45.7 dB; P07 10.0 kHz = -41.4 dB; P08 14.3 kHz = -35.0 dB; P09 17.0 kHz = -42.3 dB. Three are within about 1 dB of
  "5–17 kHz (−41 . . −45 dB relative to 1 µbar)"; P08 (14.3 kHz, -35.0 dB) is
  6 dB above that range. Fig. 3 shows the same point at an equivalent level, so it
  is not a reading error.

## Cross-check with Figure 3
Fig. 3 replots these points as intensity. Converted with I = p²/(ρc) and
ρc = 1.54 x 10⁶ Pa·s/m for sea water (offset -61.9 dB; ρc is not stated
in the paper), 12 points pair with Fig. 3. Fig. 3 minus converted Fig. 1: median
+0.3 dB, range -1.3 to +3.3 dB; 11 of 12 within 2 dB. The exception is the
top point (P12 vs W13, about 40 kHz, +3.3 dB), on the steepest part of the curve.

Fig. 3's point W11 (about 30 kHz, -74.8 dB re 1 µW/cm², i.e. about
-12.9 dB re 1 µbar) has no circle here. At that spot Fig. 1 shows the sea lion's
filled square (about -15 dB re 1 µbar) with the fur seal's line passing behind it,
so the circle may be hidden under the square, or was left out. Files:
`Babushina_etal_1991_Figures1-3_crosscheck.csv` / `.png` / `.R`.

## Derived values (for the build; not in the snapshot)
- Lowest threshold: -45.7 dB re 1 µbar at about 4.9 kHz (P06).
- For dB re 1 µPa (the modern underwater reference), add 100 dB (1 µbar = 0.1 Pa).
- No 60 dB SPL limit applies: that measure is defined for airborne sound.

## Data role
Primary: this study's own measurements on one animal.

## Observation level
One northern fur seal (*Callorhinus ursinus*), "adult 8–9-year-old male"
(p. 910), tested "in the horizontal (under the water near the surface)" with the
emitter "at a depth of 1 m and a distance of 2·6 m" (Methods, p. 910). Thresholds
at "the 75% level of positive reactions" to tonal pulses of 100 msec at 5
pulse/sec, presented for 1 sec.

## Units
Levels in dB re 1 µbar as plotted. Frequency as plotted, lg f with f in kHz; the
build converts it to Hz (f = 1000 x 10^lg f).

## Status
| file | status |
|---|---|
| `Babushina_etal_1991_Figure1_snapshot.csv` | done: digitised points, as read |
| `Babushina_etal_1991_Figure1_digitisation_check.png` | done: visual check aid |
| `Babushina_etal_1991_Figures1-3_crosscheck.R` / `.csv` / `.png` | done: cross-figure check (R NOT RUN; the CSV and PNG come from a line-for-line Python port) |
| `Babushina_etal_1991_Figure1.R`, `.csv`, public TSV, `reference_tables/..._definitions.csv` | not built yet |

Human visual check of the snapshot: pending. The digitisation was done and
checked by an AI assistant only; record the person and date in `__ReadMe.xlsx`
when checked.

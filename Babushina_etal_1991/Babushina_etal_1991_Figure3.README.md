# Babushina_etal_1991_Figure3

## Source
Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and
underwater hearing characteristics of the northern fur seal: audiograms,
frequency and differential thresholds. *Biophysics*, 36(5), 909-913
(translated from *Biofizika* 36(5), 904-907). No DOI; registry alternate
identifier `Biophysics:36:909-913`.

Registry Item **Figure 3**, printed p. 912 (PDF page 5). Caption as printed:
"Fig. 3. Sensitivity of hearing of the northern fur seal in water (*1*) and air
(*2*)." Axes as printed: "I, dB (rel. 1 µW/cm²)" (labelled -40 to -100) and
"lg f [kHz]" (labelled -1, 0, 1). Public copy: `Babushina_etal_1991/Babushina1991.pdf`.

## Why this item exists
This is the paper's own like-for-like comparison of the two media: "Figure 3
presents the underwater and air audiograms of the northern fur seal in
intensity–frequency coordinates" (Results, p. 911), from which "the sensitivity of
hearing of the northern fur seal in water is 15–20 dB (in the main frequency range
of auditory perception) better than in air". It replots the thresholds of
Figs 1 (water) and 2 (air), so it also checks both of those digitisations.

## What was digitised
Both curves, both the fur seal: curve *1*, water, 13 filled circles (W01-W13);
curve *2*, air, 11 open circles (A01-A11), in `Babushina_etal_1991_Figure3_snapshot.csv`. The drawn
lines (fits) were not digitised.

## Digitisation method
- **Image:** the embedded 300-ppi page scan of PDF page 5, extracted without
  resampling (2302 x 3237 px). Pixel coordinates in the snapshot are on that image.
- **Markers:** dark markers were found automatically and classified by eye on
  zoomed crops (filled circle = water, open circle = air). Filled circles were centred with a disc template
  (8.5 px radius); open circles were found with a ring template and centred on the open middle of the ring. Every point was checked by eye on zoomed crops.
- **Tool:** Python (NumPy, Pillow), run by Microsoft Copilot (AI assistant) for
  A. de Sousa on 26 Oct 2026. WebPlotDigitizer was not used.
- **Check image:** `Babushina_etal_1991_Figure3_digitisation_check.png` shows every digitised point and
  the ticks used for calibration on the scan.

## Calibration
Axes are linear in the plotted units. Lines were fitted by least squares to the
printed ticks.

Intensity, dB re 1 µW/cm²: 6.100 px per dB.

| dB | tick y (px) | residual (px) |
|---|---|---|
| -30 | 568.0 | -1.4 |
| -40 | 631.0 | +0.6 |
| -50 | 693.4 | +2.0 |
| -60 | 752.9 | +0.6 |
| -70 | 812.0 | -1.3 |
| -80 | 874.9 | +0.6 |
| -90 | 932.7 | -2.7 |
| -100 | 996.7 | +0.4 |
| -110 | 1058.5 | +1.2 |

Frequency, lg f [kHz]: 500.7 px per decade.

| lg f | tick x (px) | residual (px) |
|---|---|---|
| -1 | 590.9 | +1.1 |
| 0 | 1088.3 | -2.2 |
| 1 | 1592.2 | +1.1 |

## Precision
Calibration residuals are at most 2.7 px (about 0.4 dB) and 2.2 px (about 0.004
decade). Treat values as about ±1 dB and ±0.01 decade. Values are kept as read.

## Checks against the text
Where both curves have a point at the same frequency (within 0.02 decade), the
air threshold minus the water threshold (positive = more sensitive in water) is:
0.5 kHz: -8.0 dB; 0.9 kHz: -19.3 dB; 1.9 kHz: +6.2 dB; 4.9 kHz: +17.2 dB; 10.1 kHz: +17.9 dB; 20.3 kHz: +26.7 dB. At 4.9 and 10 kHz the
difference (17-18 dB) matches the text's "15–20 dB (in the main frequency range of
auditory perception)"; below 1 kHz the fur seal is more sensitive in air.

## Cross-check with Figures 1 and 2
Converted with I = p²/(ρc); ρc is not stated in the paper, so standard values
were assumed: 415 Pa·s/m for air (offset -100.2 dB from dB re 0,0002
dyne/cm²) and 1.54 x 10⁶ Pa·s/m for sea water (offset -61.9 dB from dB
re 1 µbar; fresh water would shift it by 0.2 dB).
- **Air (vs Figure 2):** 11 of 11 points agree; Fig. 3 minus converted Fig. 2 has
  median -0.5 dB, range -1.0 to +0.4 dB.
- **Water (vs Figure 1):** 12 pairs, median +0.3 dB, range -1.3 to +3.3 dB;
  11 within 2 dB. W13 (about 40 kHz, +3.3 dB) is flagged; it sits on the
  steepest part of the curve. W11 (about 30 kHz) has no circle in Fig. 1 (see the
  Figure 1 README).
- The agreement in both media supports the readings of all three figures and the
  assumed conversion. Files: `Babushina_etal_1991_Figures1-3_crosscheck.csv` /
  `.png` / `.R`.

## Derived values (for the build; not in the snapshot)
- Lowest threshold in water: -107.0 dB re 1 µW/cm² at about 4.9 kHz (W06).
- Lowest threshold in air: -89.8 dB re 1 µW/cm² at about 4.8 kHz (A07).

## Data role
Primary: this study's own measurements on one animal, replotted from Figs 1 and 2
as intensity (plus the 30-kHz water point not visible in Fig. 1).

## Observation level
One northern fur seal (*Callorhinus ursinus*), "adult 8–9-year-old male"
(p. 910); water and air test set-ups as in Figs 1 and 2 (Methods, p. 910).

## Units
Intensity in dB re 1 µW/cm² as plotted (an intensity scale, not sound pressure).
Frequency as plotted, lg f with f in kHz.

## Status
| file | status |
|---|---|
| `Babushina_etal_1991_Figure3_snapshot.csv` | done: digitised points, as read |
| `Babushina_etal_1991_Figure3_digitisation_check.png` | done: visual check aid |
| `Babushina_etal_1991_Figures1-3_crosscheck.R` / `.csv` / `.png` | done: cross-figure check (R NOT RUN; the CSV and PNG come from a line-for-line Python port) |
| `Babushina_etal_1991_Figure3.R`, `.csv`, public TSV, `reference_tables/..._definitions.csv` | not built yet |

Human visual check of the snapshot: pending. The digitisation was done and
checked by an AI assistant only; record the person and date in `__ReadMe.xlsx`
when checked.

# Koay_etal_2002_Resultstext

## Source
Koay, G., Bitter, K. S., Heffner, H. E., & Heffner, R. S. (2002). Hearing in
American leaf-nosed bats. I: *Phyllostomus hastatus*. *Hearing Research*,
171(1-2), 96-102. doi:10.1016/S0378-5955(02)00458-6

Registry Item **Results text**, printed p. 98. Public copy:
`Koay_etal_2002/Koay_etal_2002.pdf`.

## Why this item exists
First paper in the Heffner-lab Phyllostomidae (American leaf-nosed bat)
audiogram series, reporting the greater spear-nosed bat's hearing using a
conditioned suppression/avoidance procedure (n=2 females). The Results
section states the headline audiogram numbers explicitly in text, so those
sentences are transcribed directly rather than digitizing Fig. 2 (the
audiogram curve) or Fig. 3 (comparison with electrophysiological
thresholds).

## Pipeline
Results text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Koay_etal_2002_Resultstext_snapshot.csv` | frozen source, one row per stated trait |
| `Koay_etal_2002_Resultstext.R` | reads the snapshot, writes CSV + public TSV |
| `Koay_etal_2002_Resultstext.csv` | tidy analysis rows |
| `reference_tables/Koay_etal_2002_Resultstext_definitions.csv` | data dictionary |

## Data role
All rows are this paper's own new measurements (n=2 bats), reported as the
species-level mean.

## Observation level
Species mean across the 2 tested bats (individual per-bat means, e.g. 83 dB
at 1 kHz rising to a mean 1 dB at 20 kHz, are given only in Fig. 2 and the
Discussion prose, not as a data table).

## Units
- `audible_freq_low/high_60dBSPL`: kHz, lowest/highest frequency audible at
  60 dB SPL re 20 uPa.
- `hearing_range`: octaves spanned at that 60-dB criterion.
- `best_sensitivity`: dB SPL, lowest threshold recorded (at 20 kHz).
- `best_frequency`: kHz, frequency of best sensitivity.

## Companion items in this registry
- `Koay_etal_2003_ResultsText` (same lab, *Carollia perspicillata*, second
  paper in the same American-leaf-nosed-bat series).
- `Heffner_etal_2003_Resultstext` (third paper in the series, *Artibeus
  jamaicensis*).
- `Heffner_etal_2013_Resultstext` (fourth paper, *Desmodus rotundus*).

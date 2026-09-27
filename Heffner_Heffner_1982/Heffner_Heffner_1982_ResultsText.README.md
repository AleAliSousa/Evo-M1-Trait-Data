# Heffner_Heffner_1982_ResultsText

## Source
Heffner, R. S., & Heffner, H. E. (1982). Hearing in the elephant (*Elephas
maximus*): Absolute sensitivity, frequency discrimination, and sound
localization. *Journal of Comparative and Physiological Psychology*, 96(6),
926-944. doi:10.1037/0735-7036.96.6.926

Registry Item **Results text**, printed pp. 929-931 (Experiment 1: Absolute
Sensitivity). Public copy:
`Heffner_Heffner_1982/Heffner-1982-Hearing in the elephant (Elephas.pdf`.

## Why this item exists
This is the first full behavioral audiogram of any elephant, obtained from
a young Asian (Indian) elephant tested with a two-alternative conditioned
procedure. The audiogram (Fig. 2) reveals three features the paper singles
out as unique for a mammal: (1) the lowest high-frequency hearing limit of
any mammal tested (10.5 kHz at 60 dB, vs. an average mammalian cutoff of
55 kHz), (2) low-frequency sensitivity superior to any other mammal
including humans, and (3) a best frequency of 1 kHz, far below the average
mammalian best frequency of 9.8 kHz. This item captures those core
audiogram summary numbers as stated in the Results text; the paper's
`Table 1` is a separate sound-field calibration table (not the audiogram)
and is not the subject of this item. The paper's other two experiments
(frequency discrimination, sound localization, with its own `Table 2`) are
out of scope for this item -- absolute sensitivity is the priority-1 result
for this hearing/audiogram-focused registry cluster.

## Pipeline
Results-text values -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_Heffner_1982_ResultsText_snapshot.csv` | frozen source, values as printed in Results text |
| `Heffner_Heffner_1982_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_Heffner_1982_ResultsText.csv` | one row (this species) |
| `reference_tables/Heffner_Heffner_1982_ResultsText_definitions.csv` | data dictionary |

## Data role
Primary -- this is the paper's own new measurement (this study), the only
row in this item.

## Observation level
Single animal (one young Indian elephant); no replicate individuals were
tested in this experiment. Thresholds were determined for two loudspeaker
positions (left/right of midline) and averaged (Fig. 2's solid line is
"the average of the two thresholds").

## Units
Frequency in kHz (Hz for the low-frequency limit, matching the paper's own
convention when quoting sub-100 Hz values); threshold/sensitivity in dB
SPL. The 60-dB-SPL hearing range and its low/high limits are the paper's
own operational definition, used throughout the Heffner lab's comparative
audiogram series (matching the convention used elsewhere in this registry
cluster, e.g. `Heffner_etal_2006_ResultsText`).

## Additional detail captured
The snapshot also preserves two supplementary threshold data points quoted
in the same paragraph as the core audiogram summary: the elephant could
hear 16 Hz at 65 dB (just below the 60-dB low-frequency limit of 17 Hz),
and could hear 12 kHz at 72 dB but not 14 kHz even at 90 dB (bracketing the
60-dB high-frequency limit of 10.5 kHz).

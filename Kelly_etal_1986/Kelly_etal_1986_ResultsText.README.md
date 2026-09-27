# Kelly_etal_1986_ResultsText

## Source
Kelly, J. B., Kavanagh, G. L., & Dalton, J. C. H. (1986). Hearing in the
ferret (*Mustela putorius*): Thresholds for pure tone detection. *Hearing
Research*, 24(3), 269-275. doi:10.1016/0378-5955(86)90025-0

Registry Item **Results text**, printed p. 271 (plus Fig. 2, p. 272). Public
copy: `Kelly_etal_1986/Kelly-1986-Hearing in the ferret (Mustela puto.pdf`.

## Why this item exists
This paper reports the first complete behavioral audiogram for the domestic
ferret (2 subjects: ferret 97 and ferret 98), using a conditioned avoidance
procedure. No data table is printed anywhere in the paper -- the audiogram
is shown only in Figs. 1-2 -- but the Results text and Abstract state the
60-dB SPL hearing range explicitly (mean lower limit 37 Hz, mean upper limit
44 kHz) and describe a shared, narrowly tuned best-sensitivity region
(8-12 kHz) for both animals. The paper does not give a single numeric
best-threshold value for either animal, so those two values were carefully
read off the printed Fig. 2 audiogram (200-dpi render) and are explicitly
flagged as approximate/digitized, consistent with the text's own statement
that the two ferrets' thresholds diverged by 27 dB at 8 kHz (captured here
as its own row).

## Pipeline
Printed Results-text sentences (+ digitized Fig. 2 minima) -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Kelly_etal_1986_ResultsText_snapshot.csv` | frozen source, one row per reported/digitized quantity, as printed/read |
| `Kelly_etal_1986_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Kelly_etal_1986_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Kelly_etal_1986_ResultsText_definitions.csv` | data dictionary |

## Data role
All rows are `primary` -- this paper's own new behavioral measurements.

## Observation level
Rows 1-4 are the mean-of-both-animals 60-dB range and best-sensitivity
region (population level); rows 5-6 are per-individual approximate best
threshold/frequency (digitized from Fig. 2, flagged `evidence_type =
"figure (digitized, Fig. 2)"`); row 7 is the paper's own reported
between-animal discrepancy at 8 kHz.

## Units
Frequencies in kHz (37 Hz stored as 0.037 kHz for consistency). Thresholds
in dB SPL. The two `hearing_range_60dB_*` rows record the 60-dB SPL
criterion (value = 60), not a separately measured threshold at that
frequency. The two `best_threshold_approx` rows (rows 5-6) are the only
values in this item not stated numerically in the text -- see N.B. in the
registry row for the precision caveat (~2 dB, ~1 kHz reading precision).

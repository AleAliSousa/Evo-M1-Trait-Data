# Jackson_etal_1997_ResultsText

## Source
Jackson, L. L., Heffner, H. E., & Heffner, R. S. (1997). Audiogram of the fox
squirrel (*Sciurus niger*). *Journal of Comparative Psychology*, 111(1),
100-104. doi:10.1037/0735-7036.111.1.100

Registry Item **Results text**, printed p. 102. Public copy:
`Jackson_etal_1997/Jackson-1997-Audiogram of the fox squirrel (Sc.pdf`.

## Why this item exists
This brief communication reports the first behavioral audiogram of an
arboreal rodent, the fox squirrel, obtained with a conditioned-avoidance
procedure in two wild-caught animals (Squirrel A, Squirrel B). The paper
prints no data table -- the audiogram is shown only as Fig. 2 -- but the
Results paragraph (p. 102) states the core quantitative findings verbatim:
the average low-frequency detection point, the population's best sensitivity
and frequency, each animal's individual high-frequency limit, and the
60-dB-SPL hearing range used throughout this project's comparative-audiogram
series. These text-stated values are captured here rather than digitizing
Fig. 2.

## Pipeline
Printed Results-text sentences -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Jackson_etal_1997_ResultsText_snapshot.csv` | frozen source, one row per reported quantitative statement, as printed |
| `Jackson_etal_1997_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Jackson_etal_1997_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Jackson_etal_1997_ResultsText_definitions.csv` | data dictionary |

## Data role
All six rows are `primary` -- they are this paper's own new behavioral
measurements (no rows are cited from other studies).

## Observation level
Population/individual mixed: the low-frequency point and the 60-dB range are
reported as the mean of the two squirrels (A and B); the two high-frequency
threshold rows are per-individual because the paper explicitly reports
Squirrel A and Squirrel B separately at the high-frequency end (69 dB at
50 kHz vs. 85 dB at 56 kHz).

## Units
Frequencies are converted to kHz for consistency (e.g., 63 Hz -> 0.063 kHz,
113 Hz -> 0.113 kHz); thresholds are dB SPL as printed. The two
`hearing_range_60dB_*` rows record the frequency at which the standard 60-dB
SPL criterion was crossed (threshold_db = 60 is the criterion, not a measured
value at that specific frequency).

# Awbrey_etal_1988_Table1

## Source
Awbrey, F. T., Thomas, J. A., & Kastelein, R. A. (1988). Low-frequency
underwater hearing sensitivity in belugas, *Delphinapterus leucas*. *Journal
of the Acoustical Society of America*, 84(6), 2273-2275.
https://doi.org/10.1121/1.397022

Registry Item **Table 1**, "Beluga hearing threshold data in decibels,"
printed p. 2274. Public copy:
`Awbrey_etal_1988/Awbrey-1988-Low-frequency underwater hearing s.pdf`.

## Why this item exists
This letter reports low-frequency (125 Hz-8 kHz) underwater hearing
thresholds for three captive belugas, measured with airborne loudspeakers to
avoid the standing-wave problems that make low-frequency underwater
audiometry difficult in small pools. It extends the only previously
published beluga audiogram (White et al. 1978, tested 1-120 kHz) down to
125 Hz. Table I is the paper's entire quantitative result: mean threshold,
range, and number of ascending series/catch trials for each of the three
whales individually and combined, at each of the seven tested frequencies.
This is the core reported audiogram data for the paper and is transcribed
in full.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Awbrey_etal_1988_Table1_snapshot.csv` | frozen source, printed layout |
| `Awbrey_etal_1988_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Awbrey_etal_1988_Table1.csv` | tidy analysis rows |
| `reference_tables/Awbrey_etal_1988_Table1_definitions.csv` | data dictionary |

## Data role
Primary for all rows -- all three whales (and their combined mean) are this
paper's own new low-frequency measurements. (The paper's Figure 1 also plots
a secondary comparison curve, from White et al. 1978, spanning 1-120 kHz for
two of the same whales tested 6 years earlier, but that comparison curve is
not printed as a table and is not transcribed here.)

## Observation level
Per-subject mean threshold per frequency (based on 2-20 ascending series
each), plus one across-subject combined-mean row per frequency. Subjects:
one adult male, one adult female, one juvenile male (3 individuals total).

## Verification
Table I was first read from the extracted PDF text layer, then the same
page was rendered at 150 dpi and checked value-by-value against the image.
The text-layer extraction misread the Combined row's 2-kHz mean ("101") as
"10!"; the rendered page image confirms the correct printed value is 101 dB
(matching the pattern that Combined values fall at or near the midpoint of
the three individual subjects' means at every frequency -- used only as a
plausibility check, not to alter any printed number).

## Units
Thresholds in dB re 1 uPa (root-mean-square sound pressure level, note this
is the modern SI reference used throughout the paper -- not the older dyne/cm2
convention seen in some other papers in this cluster, e.g. Dalland 1965 or
Gillette et al. 1973). Frequency in Hz (also given in kHz for convenience).
`n_ascending_series` = number of ascending method-of-limits series used to
estimate that frequency's threshold; `catch_series_n`/`catch_false_alarms`
are per-subject totals (constant across the 7 frequency rows for a given
subject), reproduced from the table's rightmost "Catch" column, and are
quality-control counts, not audiogram data points.

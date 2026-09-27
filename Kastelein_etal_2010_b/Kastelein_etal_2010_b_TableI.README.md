# Kastelein_etal_2010_b_TableI

## Source
Kastelein, R. A., Hoek, L., de Jong, C. A. F., & Wensveen, P. J. (2010). The
effect of signal duration on the underwater detection thresholds of a harbor
porpoise (*Phocoena phocoena*) for single frequency-modulated tonal signals
between 0.25 and 160 kHz. *Journal of the Acoustical Society of America*,
128(5), 3211-3222. doi:10.1121/1.3493435

Registry Item **Table I**, printed p. 3214. Public copy:
`Kastelein_etal_2010_b/Kastelein-2010-The effect of signal duration o.pdf`.

## Why this item exists
This paper's central result is exactly this table: the underwater 50%
detection threshold of a 3-4-year-old male harbor porpoise for 15 center
frequencies (0.25-160 kHz) at up to 16 signal durations (0.1-5000 ms) --
134 frequency-duration combinations in total, as stated in the Abstract --
plus a comparison column of another porpoise's thresholds from Kastelein et
al. (2002), corrected for signal bandwidth, at a fixed 1700-ms duration. The
paper's own audiogram summary (best sensitivity ~43 dB re 1 uPa at 125 kHz,
best-hearing range 8-150 kHz) is fully reproducible from this table (the
1500-ms row at 125 kHz reads exactly 43 dB, matching the Results text) so no
separate results-text item was needed.

## Pipeline
Printed Table I -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Kastelein_etal_2010_b_TableI_snapshot.csv` | frozen source, printed table layout (one row per frequency, one column per duration) |
| `Kastelein_etal_2010_b_TableI.R` | reshapes the snapshot to long format, writes CSV + public TSV |
| `Kastelein_etal_2010_b_TableI.csv` | tidy analysis rows (one row per tested frequency x duration combination) |
| `reference_tables/Kastelein_etal_2010_b_TableI_definitions.csv` | data dictionary |

## Data role
`primary` rows are this paper's own new thresholds ("present study" in the
table); `secondary` rows are the Kastelein et al. (2002) corrected
comparison column reprinted in the same table for reference.

## Observation level
Per-frequency, per-duration 50%-detection threshold for a single subject.
Not every frequency was tested at every duration (the printed table has many
blank cells, e.g., very short durations were only tested at the highest
frequencies where onset transients matter most) -- these combinations are
simply absent from the tidy CSV rather than filled with a placeholder.

## Units
Center frequency in kHz; signal duration in ms; threshold in dB re 1 uPa.

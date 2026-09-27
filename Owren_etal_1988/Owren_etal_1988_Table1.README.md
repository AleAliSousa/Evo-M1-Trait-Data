# Owren_etal_1988_Table1

## Source
Owren, M. J., Hopp, S. L., Sinnott, J. M., & Petersen, M. R. (1988).
Absolute auditory thresholds in three Old World monkey species
(*Cercopithecus aethiops*, *C. neglectus*, *Macaca fuscata*) and humans
(*Homo sapiens*). *Journal of Comparative Psychology*, 102(2), 99-107.
https://doi.org/10.1037/0735-7036.102.2.99

Registry Item **Table 1 + Table 3** (combined), printed pp. 102-103.
Public copy: `Owren_etal_1988/Owren-1988-Absolute auditory thresholds in thr.pdf`.

## Why this item exists
This paper reports earphone-measured absolute auditory thresholds (a full
audiogram) for three Old World monkey species -- vervet monkeys
(*Cercopithecus aethiops*, n=3), de Brazza's monkeys (*C. neglectus*, n=5),
Japanese macaques (*Macaca fuscata*, n=5) -- and 4 humans, tested with an
identical apparatus and procedure across 19 frequencies from 0.063 to 32.0
kHz (Table 1), with monkey-only testing continued up to 45.0 kHz (Table 3).
The headline comparative finding is that vervets (smallest interaural
distance of the species tested) show the greatest high-frequency
sensitivity, consistent with Masterton, Heffner, & Ravizza's (1969)
head-size/high-frequency-acuity relationship -- a foundational reference
for this entire trait-data cluster (see also the Ravizza et al. and
Ravizza & Masterton opossum papers built alongside this item).

## Pipeline
Printed tables -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Owren_etal_1988_Table1_snapshot.csv` | frozen source, printed layout (Table 1 rows + Table 3 rows, tagged by `Table` column) |
| `Owren_etal_1988_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Owren_etal_1988_Table1.csv` | tidy analysis rows |
| `reference_tables/Owren_etal_1988_Table1_definitions.csv` | data dictionary |

## Data role
All rows are this paper's own new psychophysical measurements (there is no
secondary/cited data reproduced in either table); `data_role` is therefore
implicitly "primary" for every row and is not a separate column here (see
`table_source` instead, which distinguishes the two printed tables that
were merged).

## Observation level
One row per species (or human group) per tested frequency, reporting the
across-subject mean threshold, SD, and range (min-max across subjects) at
that frequency; sample sizes (`n`) are given per group and occasionally
drop below the nominal group n (e.g., humans at 16.0/22.625 kHz, where only
the paper's "2 most sensitive" or "1" human subject(s) contributed --
explicitly footnoted in the original table and preserved in the `note`
column here). Table 3 rows above 42 kHz likewise show declining n as
individual monkeys stopped responding to the loudest producible signal
(~72 dB SPL); those cells are printed as `>72` with no SD/range and are
kept as the literal string `>72` in `mean_threshold_dB_SPL` (not coerced to
a number), flagged in `note`.

## Units
- `frequency_kHz`: test tone frequency in kilohertz.
- `mean_threshold_dB_SPL` / `sd_dB` / `range_low_dB` / `range_high_dB`: dB
  SPL (re 0.0002 dyne/cm^2), as printed; earphone-presented, binaural.
- Negative dB values are genuine (thresholds better than the 0 dB SPL
  reference at some mid frequencies) and are transcribed as printed,
  including tricky range strings like `-6--2` (i.e., -6 to -2 dB) and
  `-5-8` (i.e., -5 to 8 dB), which the R script parses explicitly rather
  than by a naive single-hyphen split.

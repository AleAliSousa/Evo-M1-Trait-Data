# Schusterman__1974_Table1

## Source
Schusterman, R. J. (1974). Auditory sensitivity of a California sea lion
to airborne sound. *Journal of the Acoustical Society of America*, 56(4),
1248-1251. https://doi.org/10.1121/1.1903415

Registry Item **Table I**, printed p. 1250. Public copy:
`Schusterman__1974/Schusterman-1974-Auditory sensitivity of a Cal.pdf`.

## Why this item exists
Using the conditioned-vocalization technique on a single trained male
California sea lion ("Sam"), this paper measured airborne auditory
thresholds from 4-32 kHz and compared them with Sam's own previously
published underwater audiogram (Schusterman, Balliet, & Nixon, 1972).
Table I presents the resulting **air-vs-water hearing-loss** (in dB) at
each tested frequency for Zalophus, alongside the equivalent published
values for two phocid seals -- the harp seal *Pagophilus groenlandicus*
(Terhune & Ronald, 1972) and the harbor seal *Phoca vitulina*
(Møhl, 1968, the companion audiogram paper also built in this project) --
supporting the paper's central conclusion that, like phocids, the otariid
Zalophus ear is "water-adapted" (poorer sensitivity in air than water by
~15-25 dB in the middle frequency range), while otariids and the harp seal
remain moderately sensitive to sound in the 20-30 kHz range where the
harbor seal does not.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Schusterman__1974_Table1_snapshot.csv` | frozen source, printed layout (wide, one column per species) |
| `Schusterman__1974_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Schusterman__1974_Table1.csv` | tidy (long) analysis rows |
| `reference_tables/Schusterman__1974_Table1_definitions.csv` | data dictionary |

## Data role
The Zalophus column is this paper's own new data (comparing its own new
airborne thresholds against its own previously published underwater
thresholds); the Pagophilus and Phoca v. columns are compiled by this
paper from external cited sources (Terhune & Ronald, 1972; Møhl, 1968)
rather than newly measured here. This distinction is not encoded as a
separate `data_role` column (all three species are printed together as
one table, with sourcing noted in the table caption itself) but is
described here in the README per house style for a compiled table.

## Observation level
One row per species per tested frequency; each cell is the point-estimate
difference between that species' aerial and underwater 50%-detection
thresholds at that frequency (i.e., not an SD/range summary of the kind
the primary audiogram tables report). Cells the source table prints as
"..." indicate the frequency was not tested (or not reported) for that
species and are kept as missing (`flag = not_tested_or_not_reported`), not
interpolated or guessed.

## Units
- `frequency_kHz`: test tone frequency in kHz.
- `hearing_loss_air_vs_water_dB`: airborne threshold minus underwater
  threshold at that frequency, in dB (a positive value means poorer
  sensitivity in air than in water); as printed in Table I, which itself
  notes this accounts for the different acoustic-impedance references of
  air vs. water (see Discussion in the source paper for the derivation).

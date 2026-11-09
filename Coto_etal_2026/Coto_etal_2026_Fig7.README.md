# Coto et al. 2026: Fig. 7 data (brain mass and brain O2 consumption, 7 mammals + 1 ant)

Source: Coto, Z. N., Ye, D., Arganda, S., Harrison, J. F., & Traniello, J. F. A. (2026). Energy prioritization and neurometabolic scaling in a social insect brain. Proceedings of the National Academy of Sciences of the United States of America, 123(32), e2605431123. https://doi.org/10.1073/pnas.2605431123

Item: Fig. 7 ("Brain metabolic scaling of T. immigrans and mammals for which data is available"); the plotted values
are in Dataset S1 (`pnas.2605431123.sd01.xlsx`), sheet `mammal_scaling_data_figure_7`. Registry: Item number `Fig 7`; Item name `Coto_etal_2026_Fig7`; Item encoded `10.1073%2Fpnas.2605431123_Fig7`.

## Frozen source (digital-native; no derived snapshot)

`pnas.2605431123.sd01.xlsx` is the untouched journal download (Dataset S1); the R script reads the sheet directly. The folder also holds
`Coto_etal_2026_fig7_snapshot.csv`, an earlier export of the same sheet: its 8 rows are identical to the sheet. The
build does not use it (house rule: no derived snapshot of a digital-native file), so it can be deleted.

## What the data are

`Coto_etal_2026_Fig7.csv`: 8 rows (7 mammals + 1 ant) x 11 columns: printed and accepted species, brain mass (g as printed; mg =
project unit), brain O2 consumption rate (mL/min as printed) and a derived mass-specific rate (mL O2/100 g/min).

- **Mammals (secondary).** The legend says the mammal values are averages of at least two studies (*Papio
  cynocephalus*: one study) taken from Karbowski (ref. 24) and Mink et al. (ref. 23) "and references therein". A
  trace of the values (8 Nov 2026, project notes) found: rat, cat and dog = mean of Mink's measured rate and
  Karbowski 2007 S1 x brain mass; sheep = Karbowski alone (so also one study); baboon = Sahlin 1987 corrected CMRO2
  x Mink's *P. papio* brain weight (147 g); human and macaque not reproduced from either source. The paper's ref. 24
  is Karbowski 2011, but the numbers match Karbowski 2007 S1.
- **Ant (primary).** *Tetramorium immigrans* queenright workers, measured at 31 C and corrected to 37 C assuming Q10 = 2
  (legend: 9.54e-6 to 1.53e-5 mL O2/min). The temperature correction is kept in `temperature_note`.
- Printed names are kept; accepted names come from `_keys/General/species_key.csv` (8 rows added 9 Nov 2026:
  *Felis domestica* -> *Felis catus*; *Canis familiaris* -> *Canis lupus familiaris*; the ant has no hub entry).

## Build

`Coto_etal_2026_Fig7.R` reads the sheet, checks the header and the 8 rows, resolves names through the species key, adds the unit
columns, and writes the CSV and the public TSV `10.1073%2Fpnas.2605431123_Fig7.tsv`. **R NOT RUN**: the CSV and TSV were written on 9 Nov 2026
by a Python mirror of this script; rerun the R to confirm.

## Use

Do not merge the mammal rows as new measurements: they repeat Mink 1981 / Karbowski 2007 / Sahlin 1987 values, which
the repo holds as their own items. The ant row is the paper's own value (an insect; outside the mammal merges).

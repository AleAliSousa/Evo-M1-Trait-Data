# Branstetter_etal_2017_TableI

## Source
Branstetter, B. K., St Leger, J., Acton, D., Stewart, J., Houser, D.,
Finneran, J. J., & Jenkins, K. (2017). Killer whale (*Orcinus orca*)
behavioral audiograms. *J Acoust Soc Am*, 141, 2387-2398.
doi:10.1121/1.4979116

Registry Item **Table I**, printed p. 2390. Public copy:
`Branstetter_etal_2017/Branstetter_etal_2017.pdf`.

## Why this item exists
Table IV (built separately in this folder) is the paper's own derived
summary and supplies the four *O. orca* metrics used by
SensoryData_compiled. Table I is the evidence underneath it: the raw
per-subject behavioral threshold matrix, 23 printed test frequencies
(0.1-160 kHz) x 10 killer whales. Eight of the whales (A-H) were measured
in this study; the other two (Vigga and Yakka) are reproduced from
Szymanski et al. (1999). Building it makes the composite audiogram
auditable and gives the project per-individual hearing thresholds rather
than only a species composite.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Branstetter_etal_2017_TableI_snapshot.csv` | frozen source, printed wide layout |
| `Branstetter_etal_2017_TableI.R` | reads the snapshot, melts it, writes CSV + public TSV |
| `Branstetter_etal_2017_TableI.csv` | tidy analysis rows (96) |
| `reference_tables/Branstetter_etal_2017_TableI_definitions.csv` | data dictionary |
| `reference_tables/Branstetter_etal_2017_TableI_references.csv` | the one secondary source the table cites |
| `__Public/comparative-data/10.1121%2F1.4979116_TableI.tsv` | public copy |

## Snapshot and reader provenance
The snapshot keeps the printed wide matrix exactly as published: the
`kHz A B C D E F G H Vigga Yakka Mean Median N SD` header in printed
column order, all 23 frequency rows in printed order, and every blank
cell left blank (a blank means the frequency was not tested for that
subject - it is not a zero and not a missing measurement).

The PDF has a text layer, but it is **not** usable for this table: the
sparse matrix collapses in the extracted text, so a printed value cannot
be attributed to its subject column. Every cell was therefore read by an
AI assistant (Claude, Anthropic), 2026-10-31, from a page image rendered
with `pdftools::pdf_convert` at 400 dpi and inspected zoomed in two
blocks. The column attribution was then independently confirmed
arithmetically: for all 23 rows the printed N equals the count of
printed thresholds in the eight summary columns, and the recomputed mean
and median reproduce the printed Mean and Median (see Table checks).
**Human visual curation is still pending.**

## Shape of the analysis data
The analysis CSV is long: one row per printed (frequency x subject)
threshold, 96 rows. The printed row statistics (Mean, Median, N, SD) are
carried as row-level metadata columns repeated on each subject row of
that frequency, defined in the definitions file - they are the published
statistics, never recomputed into the data.

## Data role
Per-subject rows carry their own `subject_data_role`. Killer whales A-H
are `primary` (measured in this paper); Vigga and Yakka are `secondary`
(reproduced from Szymanski et al., 1999, whose full citation is in the
references file). The registry `Data role` for the item is therefore
**both**, which is a proposed change from the registered `primary` -
see `Branstetter_etal_2017_TableI_registry_row.xlsx`.

Note also that the registry `Taxon` cell reads "Orcinus orca (8
individuals)". That is right for the whales this study tested, but the
printed table carries **ten** individuals; the two extra ones are the
Szymanski animals.

## Observation level
Per-individual thresholds. These are **not** species values: pool them,
or use the paper's own species composite in Table IV, before any
species-level use.

## Units
Frequency in kHz; thresholds, Mean, Median and SD in dB re 1 uPa, all
printed as integers.

## Table checks

The table checks itself: for each frequency the printed Mean, Median and
N should follow from the printed thresholds of the eight subjects that
enter the statistics (C-H, Vigga, Yakka - the caption excludes A and B
for hearing loss). The reader recomputes them into `table_checks`, in
whole printed units, allowing one unit for the mean (half a unit from
rounding the summed cells, half from rounding the printed mean) and one
unit for the median.

Result of the recorded run (`Rscript --vanilla`, 2026-10-31):
**69 pass, 0 mismatch, 23 not_evaluable**.

- N: 23/23 exact.
- Mean: 23/23 within tolerance; largest deviation 0.625 dB at 20 kHz
  (printed 46, recomputed 46.625 from the printed integers).
- Median: 23/23 within tolerance.
- SD: **not evaluable** for all 23 rows, and this is reported rather than
  forced. The printed statistics were computed on the unrounded
  thresholds, so SD cannot be reproduced from printed integers - at
  0.5 kHz the sample SD of the printed cells is 5.4 against a printed 6,
  while at 1 kHz it is 6.9 against a printed 7. Conflating "could not
  check" with "checked and fine" would hide that, so the status is
  `not_evaluable` with the reason recorded.

No printed value was altered and no erratum is raised.

## Pending
Human visual curation of all 96 cells against printed p. 2390; owner
paste of `Branstetter_etal_2017_TableI_registry_row.xlsx` (Progress stage
off `candidate`, Data role `both`, Taxon correction).

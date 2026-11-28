# Smaers et al. 2017 — Table S1 (frontal gray/white volumes, "Smaers data")

Smaers JB, Gomez-Robles A, Parks AN, Sherwood CC (2017). *Exceptional Evolutionary Expansion of
Prefrontal Cortex in Great Apes and Humans.* Current Biology 27(5):714-720.

Full title (for `__ReadMe.xlsx`): **"Table S1. Overview of data. Related to Figure 1. (Smaers data:
gray & white matter volumes)"**  (from supplement `mmc1`)

## Source -> Snapshot
From `Smaers_mmc1.xlsx` (supplemental). `Smaers_etal_2017_TableS1_snapshot.csv`
now keeps the complete Table S1 cell grid, with both the 19-species "Smaers
data" volume block and the 10-species Brodmann cortical surface-area block.
The archived R reader selects the volume block for its legacy output.

## Data readable
`Smaers_etal_2017_TableS1.R` -> `Smaers_etal_2017_TableS1.csv` (use this). This **supersedes the older
`Smaers.csv`** in this folder, which lacked the primary-visual gray column.

## IMPORTANT provenance + caveats
- **Not new data.** The supplement states the prefrontal/frontal-motor data were "taken from Smaers et
  al. [S1, S2] and Brodmann [S3]" -> the RAW source is **Smaers 2010 (PLoS One) [S1]** and
  **Smaers 2011 (BBE) [S2]** (see Smaers_etal_2011_a/). Treat 2017 as a derived compilation.
- **Units:** the supplement labels volumes mm3, but the values scale like cm3 (consistent with the
  2011 raw data). Verify units before merging.
- Smaers note that this proxy underestimates prefrontal and overestimates frontal-motor in great
  apes/humans (their Figure S2 legend).

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note (in progress) -> Online database

## Archived snapshot layout recheck (2026-11-27)

This archived snapshot now retains the full publisher Table S1 grid as a
34-row, 35-column CSV, source workbook `Smaers_mmc1.xlsx` rows 9–42,
columns A–AI. All 222 nonempty source cells match at the same relative
coordinates. The archived R reader selects the volume block; run
`Rscript Smaers_etal_2017/_superseded_single_table/Smaers_etal_2017_TableS1.R`
from the repository root. Its rebuilt 19-row CSV matches the prior version
cell for cell. This archived item is not the active public build. The layout
check is separate from independent human source signoff.

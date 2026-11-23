# Smaers et al. 2017 — Table S1 (frontal gray/white volumes, "Smaers data")

Smaers JB, Gomez-Robles A, Parks AN, Sherwood CC (2017). *Exceptional Evolutionary Expansion of
Prefrontal Cortex in Great Apes and Humans.* Current Biology 27(5):714-720.

Full title (for `__ReadMe.xlsx`): **"Table S1. Overview of data. Related to Figure 1. (Smaers data:
gray & white matter volumes)"**  (from supplement `mmc1`)

## Source -> Snapshot
From `Smaers_mmc1.xlsx` (supplemental). `Smaers_etal_2017_TableS1_snapshot.csv` = the "Smaers data"
block: 19 species x {gray, white} x {primary visual, prefrontal, other cortical association, frontal
motor}. (A second block, Brodmann 1909 cortical **surface area**, is a separate/secondary sub-table.)

## Data readable
`Smaers_etal_2017_TableS1.R` -> `Smaers_etal_2017_TableS1.csv` (use this). This **supersedes the older
`Smaers.csv`** in this folder, which lacked the primary-visual gray column.

## IMPORTANT provenance + caveats
- **Not new data.** The supplement states the prefrontal/frontal-motor data were "taken from Smaers et
  al. [S1, S2] and Brodmann [S3]" -> the RAW source is **Smaers 2010 (PLoS One) [S1]** and
  **Smaers 2011 (BBE) [S2]** (see Smaers_etal_2011/). Treat 2017 as a derived compilation.
- **Units:** the supplement labels volumes mm3, but the values scale like cm3 (consistent with the
  2011 raw data). Verify units before merging.
- Smaers note that this proxy underestimates prefrontal and overestimates frontal-motor in great
  apes/humans (their Figure S2 legend).

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note (in progress) -> Online database

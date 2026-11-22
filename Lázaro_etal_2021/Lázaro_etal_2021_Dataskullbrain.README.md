# Lázaro_etal_2021_Dataskullbrain

Source: `Data_skull_brain.csv`. born-digital Dryad CSV; byte-identical frozen copy. Registry item: `Lázaro_etal_2021_Dataskullbrain` in `__ReadMe.xlsx`.

## Build

Retains 516 individual records from four populations, including missing brain mass. The source brm is whole-brain mass in g, converted to WholeBrain_Mass.mg in a new column. Braincase height is a skull proxy and not a measured brain volume. The corrected brmst and other source fields remain verbatim. Stage s/w/a denotes summer juvenile, winter subadult, adult; location and age must be kept in comparisons.

All source columns retained; whole-brain mass converted g to mg in a new column. No imputation.

From this paper folder, run:

```sh
Rscript Lázaro_etal_2021_Dataskullbrain.R
```

The script reads only `Lázaro_etal_2021_Dataskullbrain_snapshot.csv` for measurements and writes `Lázaro_etal_2021_Dataskullbrain.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/Lázaro_etal_2021_Dataskullbrain_definitions.csv`.

## Source and verification

No replot: digital table, not a figure. Human visual transcription check is inapplicable; source copy was byte-compared.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.

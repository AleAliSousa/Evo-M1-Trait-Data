# Lázaro_etal_2021_Databrainregions

Source: `Data_brain_regions.csv`. born-digital Dryad CSV; byte-identical frozen copy. Registry item: `Lázaro_etal_2021_Databrainregions` in `__ReadMe.xlsx`.

## Build

Retains all 418 measured rows for 22 shrews and all 19 source region labels. The 672 wholly empty trailing rows in the source are excluded by the R reader. Source volume_abs is the corrected absolute volume of the traced hemisphere in mm3; the Brain row is a hemisphere, not whole-brain volume. Raw and tooth-corrected fields remain separately named as in the source. WholeBrain_Mass.mg is brain_mass (g) multiplied by 1000. The 19 regions overlap hierarchically and must not be summed. Stage s/w/a denotes summer juvenile, winter subadult, adult; these are age as well as season groups.

All source columns retained; one-hemisphere scope added explicitly; original brain mass converted to mg in a new column. No imputation.

From this paper folder, run:

```sh
Rscript Lázaro_etal_2021_Databrainregions.R
```

The script reads only `Lázaro_etal_2021_Databrainregions_snapshot.csv` for measurements and writes `Lázaro_etal_2021_Databrainregions.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/Lázaro_etal_2021_Databrainregions_definitions.csv`.

## Source and verification

No replot: digital table, not a figure. Human visual transcription check is inapplicable; source copy was byte-compared.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.

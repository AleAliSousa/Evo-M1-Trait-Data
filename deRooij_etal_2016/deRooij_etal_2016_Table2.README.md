# deRooij_etal_2016_Table2

Source: `de Rooij-2016-Prenatal famine exposure has sex.pdf`. printed PDF Table 2; extracted with pdftotext by snapshot R. Registry item: `deRooij_etal_2016_Table2` in `__ReadMe.xlsx`.

## Build

Male and female group means are kept separate for born-before, early-gestation exposed, and conceived-after groups. Sample sizes are 14/19/19 for males and 21/22/23 for females. Total (SD) is pooled across all three exposure groups, not a group SD; p compares exposed with the two unexposed groups combined. Regional VBM significance described in prose is not a regional volume measurement.

One row per sex, measure, and exposure group (54 rows). ml converted to mm3 by x1000; cm, mm, and TBV/ICV ratio stay in source units. Group SDs are not fabricated.

From this paper folder, run:

```sh
Rscript deRooij_etal_2016_Table2.R
```

The script reads only `deRooij_etal_2016_Table2_snapshot.csv` for measurements and writes `deRooij_etal_2016_Table2.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/deRooij_etal_2016_Table2_definitions.csv`.

## Source and verification

No replot: printed table, not a figure. AI checked PDF table text and layout; human visual signoff pending.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.
Initial frozen snapshot command (run once): `Rscript deRooij_etal_2016_Table2_snapshot.R`. The snapshot script refuses to overwrite an existing frozen CSV.

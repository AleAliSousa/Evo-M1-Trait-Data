# Baldoni_etal_2025_Table1

Source: `Baldoni-2025-Programmed-seasonal-brain-shrinka.pdf`. printed PDF Table 1; extracted with pdftotext by snapshot R. Registry item: `Baldoni_etal_2025_Table1` in `__ReadMe.xlsx`.

## Build

Thirteen Bayesian winter minus summer regional volume estimates in mm3, estimated errors, and 95% credible intervals. These are contrasts, not absolute group means. The source text separately reports total-brain winter minus summer -21.08 mm3; it is not a Table 1 row and is not inserted into this item.

Unicode minus and spacing parsed to numbers; 13 source rows preserved. No group means inferred.

From this paper folder, run:

```sh
Rscript Baldoni_etal_2025_Table1.R
```

The script reads only `Baldoni_etal_2025_Table1_snapshot.csv` for measurements and writes `Baldoni_etal_2025_Table1.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/Baldoni_etal_2025_Table1_definitions.csv`.

## Source and verification

No replot: printed table, not a figure. AI checked PDF table text and layout; human visual signoff pending.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.
Initial frozen snapshot command (run once): `Rscript Baldoni_etal_2025_Table1_snapshot.R`. The snapshot script refuses to overwrite an existing frozen CSV.

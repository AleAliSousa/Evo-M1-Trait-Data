# ClippertonAllen_etal_2019_TableS1

Source: `41398_2019_656_MOESM10_ESM.xlsx`. born-digital supplementary XLSX; byte-identical frozen copy. Registry item: `ClippertonAllen_etal_2019_TableS1` in `__ReadMe.xlsx`.

## Build

Regional MRI mean absolute volumes in mm3 for wild-type Pten+/+ and Pten+/- mice at P7 and P60. Relative volume columns are percentages of whole brain and must not replace absolute size. Source section, tissue category, figure cross-reference, p, FDR, and reported percent differences are retained. The table does not print a standalone total-brain row. Two P7 source rows print a positive percent difference despite smaller Pten+/- absolute means (paraventricular hypothalamic nucleus and medial preoptic area); values remain verbatim.

One row per region and available age (118 rows); all printed numeric source values retained; p/FDR strings such as <0.001 retained as strings. Missing P7 entries remain absent rather than inferred.

From this paper folder, run:

```sh
Rscript ClippertonAllen_etal_2019_TableS1.R
```

The script reads only `ClippertonAllen_etal_2019_TableS1_snapshot.xlsx` for measurements and writes `ClippertonAllen_etal_2019_TableS1.csv` plus the DOI-coded public TSV under `__Public/comparative-data/`. The snapshot is frozen; do not overwrite it when rebuilding. Definitions are in `reference_tables/ClippertonAllen_etal_2019_TableS1_definitions.csv`.

## Source and verification

No replot: digital table, not a figure. Human visual transcription check is inapplicable; source copy was byte-compared.

No cross-paper merge is performed by this item build. Condition labels and source measurement scopes must be respected before any merge.

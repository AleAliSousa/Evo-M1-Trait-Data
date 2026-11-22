# HerculanoHouzel_etal_2014_Table1

Table 1 | Cellular composition of the African elephant brain. Source: `Herculano-Houze-2014-The elephant brain in num.pdf`, PDF page 2, DOI in `__ReadMe.xlsx`.

## Build

Single African elephant. Fourteen printed structure rows; mass, neuronal and other-cell counts, densities, and ratios. The paper states that values are twice the measurements from one half-brain. The analysis CSV keeps the printed structure labels and parses B/M count suffixes into absolute counts. Nested rows (cortex and its parts; rest of brain and its parts) must not be added together.

From the paper folder, run:

```sh
Rscript HerculanoHouzel_etal_2014_Table1_snapshot.R
Rscript HerculanoHouzel_etal_2014_Table1.R
```

The snapshot script captures the table from the local PDF and refuses to overwrite an existing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript HerculanoHouzel_etal_2014_Table1.R`. The R script reads only its item snapshot for measurements and writes `HerculanoHouzel_etal_2014_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

The Rest of brain O/N cell prints `36,948`, while its counts imply roughly 37. It remains 36948 when parsed literally and is flagged in the analysis CSV. The cortical GM N/mg cell prints `3.661`; it too remains literal. No correction has been made. Overlap with later Herculano-Houzel compilations must be checked before merging.

The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.

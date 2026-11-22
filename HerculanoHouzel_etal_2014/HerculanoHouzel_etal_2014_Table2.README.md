# HerculanoHouzel_etal_2014_Table2

Table 2 | Cortical areas and volumes in the African elephant. Source: `Herculano-Houze-2014-The elephant brain in num.pdf`, PDF page 2, DOI in `__ReadMe.xlsx`.

## Build

Single African elephant. The seven printed cortical measurements are pivoted to one analysis row. Commas are removed and printed units are retained in column names. All values refer to one hemisphere; they are not doubled here.

From the paper folder, run:

```sh
Rscript HerculanoHouzel_etal_2014_Table2_snapshot.R
Rscript HerculanoHouzel_etal_2014_Table2.R
```

The snapshot script captures the table from the local PDF and refuses to overwrite an existing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript HerculanoHouzel_etal_2014_Table2.R`. The R script reads only its item snapshot for measurements and writes `HerculanoHouzel_etal_2014_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

Table 1 mass values are reported on a doubled half-brain basis, while these Table 2 area and volume values are one hemisphere. Do not join them as if the hemisphere bases match.

The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.

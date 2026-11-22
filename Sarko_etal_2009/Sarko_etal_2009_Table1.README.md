# Sarko_etal_2009_Table1

Table 1 | Comparative cellular composition of the brains of five insectivore species. Source: `Sarko-2009-Cellular scaling rul.pdf`, PDF page 4, DOI in `__ReadMe.xlsx`.

## Build

The five species rows provide body and whole-brain mass in g and total cells and neurons (printed ×10^6). The printed Variation summary row stays in the snapshot and is omitted from the analysis CSV. Values on each side of ± are separated, and counts are converted to absolute numbers. The paper Methods identify the binomials corresponding to its printed common names; the HerculanoHouzel species key supplies those mappings.

From the paper folder, run:

```sh
Rscript Sarko_etal_2009_Table1_snapshot.R
Rscript Sarko_etal_2009_Table1.R
```

The snapshot script captures the table from the local PDF and refuses to overwrite an existing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Sarko_etal_2009_Table1.R`. The R script reads only its item snapshot for measurements and writes `Sarko_etal_2009_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

The article does not label the ± quantity in the table or surrounding Methods, so the analysis columns say `plusminus_reported`, without assigning SD or SEM. The PDF is currently nested under the elephant paper folder; the script locates its own folder and uses the local PDF.

The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.

# Kazu_etal_2014_Table2

Table 2 | Cortical areas, volumes and folding index for artiodactyls. Source: `Kazu-2014-Cellular scaling rules for the brain.pdf`, PDF page 10, DOI in `__ReadMe.xlsx`.

## Build

Five species. The snapshot retains the printed species spellings and the four cortical measures. The analysis CSV parses area (mm2), gray- and white-matter volume (mm3), and folding index; each measurement is for one hemisphere only. The Stephan species key resolves the printed names while preserving them in `species_as_published`.

From the paper folder, run:

```sh
Rscript Kazu_etal_2014_Table2_snapshot.R
Rscript Kazu_etal_2014_Table2.R
```

The snapshot script captures the table from the local PDF and refuses to overwrite an existing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Kazu_etal_2014_Table2.R`. The R script reads only its item snapshot for measurements and writes `Kazu_etal_2014_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

The 2015 corrigendum replaces Kazu 2014 Table 1 (cellular/mass data), already built as Kazu_etal_2015_TABLE1. It does not reprint this Table 2; this item is kept separate from the superseded Table 1. Do not pool the same five animals twice.

The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.

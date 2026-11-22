# Sarko_etal_2009_Table2

Table 2 | Cellular composition of insectivore brains. Source: `Sarko-2009-Cellular scaling rul.pdf`, PDF page 6–7, DOI in `__ReadMe.xlsx`.

## Build

The two-page printed table has five structure sections and five species in each. The snapshot keeps those sections, source order, all twelve measure columns, and the printed ± pairs. The analysis CSV has 25 species-by-structure rows. Cell and neuron counts printed ×10^6 become absolute counts; density columns printed ×10^3 become cells/mg. Regional masses remain g. The paper Methods supply binomials through the collection species key.

From the paper folder, run:

```sh
Rscript Sarko_etal_2009_Table2_snapshot.R
Rscript Sarko_etal_2009_Table2.R
```

The snapshot script captures the table from the local PDF and refuses to overwrite an existing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Sarko_etal_2009_Table2.R`. The R script reads only its item snapshot for measurements and writes `Sarko_etal_2009_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

The article does not define the ± quantity, so uncertainty columns remain `plusminus_reported`. The cortex and hippocampus were dissected separately. Their printed percentages, with cerebellum, olfactory bulbs and remaining areas, sum to 94.2–100.8% across species; the eastern mole is 94.2%. These source values remain unchanged. Check overlap with later Herculano-Houzel compilations before merging.

The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.

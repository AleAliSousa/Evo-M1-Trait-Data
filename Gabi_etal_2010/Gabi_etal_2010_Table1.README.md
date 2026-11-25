# Gabi_etal_2010_Table1

Charvet et al. Figure 8 uses this table's five cerebral-cortex mass/neuron pairs. The table-based unilateral coordinates (published values ÷ 2, then mass ÷ 1.036 g/cm³) are assembled in `../Charvet_etal_2013/internal_checks/Charvet_etal_2013_Figure8_source_points.README.md`.

Table 1 | Cellular composition of the brain of a new set of primate species. Source: `Gabi-2010-Cellular scaling rul.pdf`, PDF page 4, DOI in `__ReadMe.xlsx`.

## Build

The printed table is transposed — species as columns, measures as rows, in four structure blocks (Whole brain, Cerebral cortex, Cerebellum, Remaining areas) — and the snapshot keeps that layout; the build transposes it into one row per species. For each species the table gives the number of individuals (n), body mass, and per structure: mass, total cells, neurons, non-neuronal cells, % neuronal cells and NN/N, plus neuronal and non-neuronal densities for the three dissected structures. Counts printed as ×10^6 or ×10^9 are converted to absolute numbers. "Remaining areas" is the paper's rest of brain (RoB): everything other than cerebral cortex and cerebellum, pooled; the olfactory bulb was not included in any brain. All values are whole-structure values: only one hemisphere was available per animal, so the printed counts are twice the single-hemisphere counts. Table 1 prints no SDs, so the analysis CSV has no SD columns. The printed fold-variation column (Δ) stays in the snapshot and is omitted from the analysis CSV. The table's footnotes read: "N = Number of neuronal cells; NN = number of non-neuronal cells. ¹ From Stephan et al., 1981. ² From Burish et al., 2010."

From the paper folder, run:

```sh
Rscript Gabi_etal_2010_Table1_snapshot.R
Rscript Gabi_etal_2010_Table1.R
```

The snapshot script captures the table from the frozen PMC full text (`fulltext.html`) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Gabi_etal_2010_Table1.R`. The R script reads only its item snapshot for measurements and writes `Gabi_etal_2010_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- The snapshot was cross-checked cell-for-cell against the publisher PDF (text layer and rendered page): all 216 value cells, 36 row labels and the species headings agree. The only rendering differences are the ones documented in the snapshot script: superscripts are rendered with a caret, and PMC's HTML renders the printed Δ column heading as the letter "A" (the snapshot restores Δ).
- **Erratum corrected in the build** (kept verbatim in the snapshot): the remaining-areas total number of cells for *Callimico goeldii* is printed as 248.44 × 10^9. The exponent is a misprint — the row's own components (53.91 × 10^6 neurons + 194.53 × 10^6 non-neuronal cells) and the printed densities ((25,844 + 93,254)/mg × 2,086 mg) both give 248.44 × 10^6, and Herculano-Houzel et al. (2015) re-report the components summing to 248,440,000. The build uses ×10^6, guarded on the exact printed string.
- Two further printed anomalies are kept as printed. The whole-brain total neurons of *Macaca radiata* (3.78 × 10^9) disagrees with the paper's own structure values, which sum to 3.76 × 10^9, and with its printed % neuronal cells (43.5) and NN/N (1.299), both of which fit the structure sum; Herculano-Houzel et al. (2015) print the structure sum (3,755,620,300). And the remaining-areas non-neuronal density of *Microcebus murinus* is printed as 93,254/mg — the same digits as the *Callimico* value beside it — where the printed count and mass give 101,731/mg, the value Herculano-Houzel et al. (2015) print. Both are flagged in the definitions file; which value the merge should carry is a wiring decision, not a build decision.
- *Callimico goeldii* has no cerebellum or whole-brain rows: its cerebellum was only partially included in the dissection and was eliminated from the analysis (Methods). Its cerebral cortex and remaining-areas rows are complete.
- Body mass was measured only for the mouse lemur and the baboons. The *Callimico* value (480 g, footnote 1) is from Stephan et al. (1981) and the two macaque values (footnote 2) are from Burish et al. (2010), as the Methods explain; all five values are built as printed, with the provenance recorded in the definitions file.
- Herculano-Houzel et al. (2015) list the baboon as *Papio anubis cynocephalus*; this build keeps the name as printed here, *Papio cynocephalus*.
- The snapshot was checked by the assistant against the PDF text and layout; human visual signoff remains pending in the registry. These are source measurements, not a normal-versus-condition contrast. No merge is performed by this build.

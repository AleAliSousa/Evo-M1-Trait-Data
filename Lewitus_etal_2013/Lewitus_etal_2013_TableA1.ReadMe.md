# Lewitus_etal_2013_TableA1

Lewitus E, Kelava I, Huttner WB (2013). *Conical expansion of the outer subventricular zone and the role of neocortical folding in evolution and development.* Frontiers in Human Neuroscience 7:424. DOI: 10.3389/fnhum.2013.00424.

## Source -> Snapshot

`Lewitus_etal_2013_TableA1_snapshot.csv` is a manual transcription of Appendix Table A1 from PDF pages 11-12. It contains 66 mammal species and preserves species names as printed, including abbreviated names (`Hydrochoerus h.` and `Daubentonia m.`). `NA` represents cells printed as NA.

The table title says "40 mammal species," but the printed table contains 66 species rows. The snapshot follows the rows actually printed rather than the title count.

## Columns and sources

Definitions are limited to information explicitly printed in Table A1 and its footnotes. In particular, `GI` is not expanded because Table A1 labels the field only as `GI`.

- Brain weight and ventricle volume: footnote a, Stephan et al. (1981)
- Neuron and astrocyte density: footnote b, Lewitus et al. (2012)
- Gray matter thickness: footnote c, Figure 5
- GI: footnote d, Lewitus et al. (2013)
- All data are for adults, per the table footnote

## Build

`Lewitus_etal_2013_TableA1.R` reads the frozen snapshot, checks for 66 unique species rows, converts measurement fields to numeric values, appends `source = Lewitus_etal_2013`, writes the local CSV, and writes the DOI-coded public TSV using `__ReadMe.xlsx`. Taxonomic harmonisation is intentionally left downstream.

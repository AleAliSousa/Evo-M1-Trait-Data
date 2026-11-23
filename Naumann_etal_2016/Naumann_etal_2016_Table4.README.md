# Naumann et al. 2016, Table 4

Naumann, R. K., Ray, S., Prokop, S., Las, L., Heppner, F. L., & Brecht, M. (2016). Conserved size and periodicity of pyramidal patches in layer 2 of medial/caudal entorhinal cortex. *The Journal of Comparative Neurology*, 524(4), 783–806. DOI: [10.1002/cne.23865](https://doi.org/10.1002/cne.23865).

## Source and scope

The frozen open-access source is `Naumann_etal_2016_fullText.xml`, obtained from the [Europe PMC full-text XML endpoint](https://www.ebi.ac.uk/europepmc/webservices/rest/PMC5014138/fullTextXML) on 2026-11-23. Its Table 4 is “Patch Number, Patch Size, and Spacing”. There are five species-level summaries for medial/caudal entorhinal cortex: shrew, mouse, rat, Egyptian fruit bat, and human. These are summaries of specimens, not five individual observations. The table footnote describes variable specimen/hemisphere counts and difficulty estimating total patch number from staining and areal boundaries.

`Naumann_etal_2016_Table4_snapshot.R` extracts only this table from the frozen XML, keeping printed column order, row order, caption, ± notation, units, and footnote. It writes `Naumann_etal_2016_Table4_snapshot.csv` and refuses to replace a different existing snapshot. The item reader reads that snapshot alone for scientific values. The paper's text provides the scientific names used in `_keys/General/species_key.csv` while the printed common names remain in the analysis file.

Table 4 does not state what its ± quantities represent, so the analysis file retains them as unsigned printed quantities and labels the statistic “not specified in Table 4”. The shrew patch diameter is 103 ± 23 µm in Table 4 but 104 ± 25 µm in the prose; the table value is retained. This discrepancy is not silently reconciled.

## Build

From the repository root:

```sh
Rscript --vanilla Naumann_etal_2016/Naumann_etal_2016_Table4_snapshot.R
Rscript --vanilla Naumann_etal_2016/Naumann_etal_2016_Table4.R
```

The first command reproduced the frozen snapshot identically on 2026-11-23. The second produced the five-row local CSV and the DOI-coded public TSV. `Item encoded` is looked up by `Item name`, preferring `__ReadMe.xlsx` and falling back to `__ReadMeAddON.xlsx` while the main workbook is occupied. Definitions describe every output column. Basic checks require the five printed rows, two parseable ± cells per row, numeric density values, and a unique species-key match. The table has no independent printed total to recompute.

Codex compared the snapshot against the frozen XML table on 2026-11-23. Human visual signoff remains pending; AI review is not a human signature. No figure-derived dataset is made here, so a figure replot is not applicable.

# Baron_etal_1987_Table1

## Source and snapshot

Source: `baron_etal_1987_VI_scan.pdf`, printed Table 1 on PDF p. 2 and Table 2 on PDF p. 3. Table 1 contains Macroscelidea, Insectivora and Scandentia; Table 2 contains prosimians and simians. Each printed table has one species column, seven volume columns (`BOL, RB, PRPI, TOL, TRL, COA, SIN`; mm³), and seven corresponding index columns.

`Baron_etal_1987_Table1_snapshot.xlsx` now has separate `Table1` and `Table2` sheets with those column positions, the printed group breaks, and the 89 source-order species rows. The seven volume fields were retained from the former snapshot, which was reconstructed from `old/baron_etal_1987.csv`; they were not retranscribed from the scan. The printed index values have **not** been transcribed: their columns are kept empty to preserve the table geometry and make the omission visible. The paper does not print an NTO column in either table.

`reference_tables/Baron_etal_1987_Table1_species_lookup.csv` records the relationship between each printed row and the existing analysis name/order. Name expansion and output ordering occur in `Baron_etal_1987_Table1.R`, not in the snapshot. The R reader takes the seven volume columns from both sheets and writes the 89-row `Baron_etal_1987_Table1.csv` and the DOI-named public TSV. The index columns do not enter those outputs.

Run from the repository root:

```sh
Rscript --vanilla Baron_etal_1987/Baron_etal_1987_Table1.R
```

The regenerated analysis CSV was compared cell for cell with the pre-change version: 89 species rows and no differences.

## Abbreviations

BOL bulbus olfactorius; RB retrobulbar cortex; PRPI prepiriform cortex; TOL tuberculum olfactorium; TRL tractus olfactorius lateralis; COA commissura anterior; SIN substantia innominata. `reference_tables/Baron_etal_1987_definitions.csv` is the item data dictionary.

This is an assistant source-layout check, not human visual signoff.

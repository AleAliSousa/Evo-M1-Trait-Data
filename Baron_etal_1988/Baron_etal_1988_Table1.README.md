# Baron_etal_1988_Table1

## Source and snapshot

Source: `baron_etal_1988_scan.pdf`, printed Table 1 on PDF p. 4 and Table 2 on PDF p. 5. Table 1 contains Insectivora and Scandentia; Table 2 contains prosimians and simians. Both tables place the five volume columns in `VC, VM, VI, VL, VS` order (mm³, both sides), followed by five corresponding index columns. Table 2 has a final locomotory-type column.

The former `Baron_etal_1988_Table1_snapshot.xlsx` reordered 76 species, merged the two printed tables, put `VI` before `VM`, and omitted the group breaks, index geometry, and locomotory column. The workbook now has separate `Table1` and `Table2` sheets in source order with the printed column positions and group breaks. The existing volume values were retained from the former snapshot, which was reconstructed from an earlier formatted table; they were not retranscribed from the scan. Locomotory codes were copied from printed Table 2. The printed **index values remain untranscribed**: their columns are empty so the omission is explicit while the spatial layout is preserved.

`reference_tables/Baron_etal_1988_Table1_species_lookup.csv` maps printed rows to existing analysis names and output order. `Baron_etal_1988_Table1.R` reads the two source-layout sheets, selects/reorders volume columns, and writes the 76-row `Baron_etal_1988_Table1.csv` and DOI-named public TSV. The index and locomotory columns do not enter those outputs.

Run from the repository root:

```sh
Rscript --vanilla Baron_etal_1988/Baron_etal_1988_Table1.R
```

The regenerated analysis CSV was compared cell for cell with the pre-change version: 76 species rows and no differences.

## Abbreviations

VC complexus vestibularis; VM nucleus vestibularis medialis; VI nucleus vestibularis descendens; VL nucleus vestibularis lateralis; VS nucleus vestibularis superior. `reference_tables/Baron_etal_1988_definitions.csv` is the item data dictionary.

This is an assistant source-layout check, not human visual signoff.

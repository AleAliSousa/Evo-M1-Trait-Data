# Barks et al. 2014, Table 2

Source: `Barks-2014-Brain organization o.pdf`, printed Table 2 on PDF p. 2 (right table). It has four columns: Region, Hemisphere, Average number of points counted, and CE. Paired left/right rows leave the region cell blank on the second line; the external capsule label wraps across two rows.

`Barks_etal_2014_TABLE2_snapshot.xlsx` retains the caption, headers, 26 source-order data rows, meaningful blanks, and wrapped label. This layout pass removed a wholly empty fifth workbook column. `Barks_etal_2014_TABLE2.R` fills the paired region labels for analysis and rebuilt the 26-row CSV and public TSV; the CSV matched the pre-change version cell for cell.

Run: `Rscript --vanilla Barks_etal_2014/Barks_etal_2014_TABLE2.R` from the repository root. The assistant checked layout against the rendered/source-text PDF; human visual signoff remains open.
